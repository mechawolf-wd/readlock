// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter/scheduler.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/course_screens/CourseAccentScope.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/text_animation/HyphenatedText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';
import 'package:readlock/constants/RLReadingSettings.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

const double progressiveTextDefaultBottomSpacing = RLDS.spacing0;
const Duration progressiveTextAutoRevealDelay = Duration(milliseconds: 7);
const Duration progressiveTextDoubleTapTimeout = Duration(milliseconds: 500);

// Each character fades in from alpha 0 → 1 over this window from the moment
// it is revealed. Kept short so the effect reads as a soft settle, not a
// visible animation. Multiple characters can be in flight at once when the
// typewriter is faster than this window, each gets its own timeline, so
// adjacent characters crossfade smoothly without popping.
const Duration progressiveTextLeadingCharacterFadeDuration = Duration(milliseconds: 60);

// Inline markup styling for <c:g>…</c:g> and <c:r>…</c:r> spans. Both render
// paths (live typewriter + settled CompletedSentenceWidget) route through
// here so the rule lives in one place.
//
//   <c:g>, italic, painted in the active course's accent colour. Falls back
//           to the legacy markup palette when no CourseAccentScope is in
//           place (eg. settings preview).
//   <c:r>, italic + bold, no colour override (inherits from the surrounding
//           text style).
TextStyle resolveMarkupStyle(BuildContext context, String colorCode, TextStyle baseStyle) {
  // When the user disables Accent in Settings, all markup spans render as
  // plain body text (no colour, no italic/bold override).
  final bool isColoredTextDisabled = !coloredTextEnabledNotifier.value;

  if (isColoredTextDisabled) {
    return baseStyle;
  }

  final bool isAccentMarkup = colorCode == 'g';

  if (isAccentMarkup) {
    final Color accentColor = CourseAccentScope.of(context, fallback: RLDS.success);

    return baseStyle.copyWith(color: accentColor, fontStyle: FontStyle.italic);
  }

  return baseStyle.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold);
}

// Class to represent a segment of text with optional highlighting
class TextSegmentWithHighlighting {
  final String textContent;
  final bool shouldBeHighlighted;
  final Color? highlightColor;
  final int segmentStartPosition;
  final int segmentEndPosition;

  const TextSegmentWithHighlighting({
    required this.textContent,
    required this.shouldBeHighlighted,
    required this.highlightColor,
    required this.segmentStartPosition,
    required this.segmentEndPosition,
  });
}

class ProgressiveText extends StatefulWidget {
  // Required properties
  // List of text sentences to reveal progressively
  final List<String> textSegments;

  // Animation properties
  // Delay between each character reveal in milliseconds
  final Duration typewriterCharacterDelay;
  // Whether to automatically reveal next sentence after current one completes
  final bool automaticallyRevealNextSentence;

  // Visual styling properties
  // Text style to apply to all revealed text
  final TextStyle? textStyle;
  // Padding around the entire progressive text widget
  final EdgeInsets? contentPadding;
  // Cross axis alignment for text display
  final CrossAxisAlignment? textAlignment;
  // Horizontal alignment applied inside each rendered line (RichText / Text).
  final TextAlign textAlign;

  // Blur effect properties for completed sentences
  // Whether to apply blur effect to completed sentences
  final bool blurCompletedSentences;
  // Intensity of the blur effect (sigma value)
  final double completedSentenceBlurIntensity;
  // Opacity level for completed sentences with blur
  final double completedSentenceOpacity;

  // Interaction properties
  // Custom tap callback (overrides default reveal behavior)
  final VoidCallback? onTapCallback;
  // Whether to enable tap interaction for revealing next sentence
  final bool enableTapToReveal;
  // Callback triggered when all text segments have been fully revealed
  final VoidCallback? onAllSegmentsRevealed;
  // Tap on the bottom reveal-button area AFTER every segment has finished
  // revealing. Overrides the default blur-toggle behavior. Lets callers
  // (e.g. CCTextContent) repurpose the bottom tap zone as an advance-to-
  // next-slide affordance once the last segment has landed.
  final VoidCallback? onTapAfterAllRevealed;

  const ProgressiveText({
    super.key,
    required this.textSegments,
    this.typewriterCharacterDelay = const Duration(milliseconds: 10),
    this.automaticallyRevealNextSentence = false,
    this.textStyle,
    this.contentPadding,
    this.textAlignment,
    this.textAlign = TextAlign.left,
    this.blurCompletedSentences = true,
    // Completed-sentence blur defaults inherited from the centralised
    // Apple-Music-style lyrics blur token, keeps every reading surface
    // (text swipes, question answers, true/false buttons, Settings demo)
    // aligned by default.
    this.completedSentenceBlurIntensity = RLDS.lyricsBlurSigma,
    this.completedSentenceOpacity = RLDS.lyricsBlurOpacity,
    this.onTapCallback,
    this.enableTapToReveal = true,
    this.onAllSegmentsRevealed,
    this.onTapAfterAllRevealed,
  });

  @override
  State<ProgressiveText> createState() => ProgressiveTextState();
}

class ProgressiveTextState extends State<ProgressiveText> with TickerProviderStateMixin {
  // Text state management
  // All sentences to be displayed progressively
  late List<String> textSentences;
  // Blur on/off state for each completed sentence (true = blurred)
  late List<bool> sentenceBlurStates;
  // Track which sentences have no-blur modifier
  late List<bool> sentenceNoBlurFlags;

  // Animation state tracking
  // Index of the sentence currently being revealed (0-based)
  int currentSentenceNumber = 0;
  // Flag indicating if typewriter animation is actively running
  bool isRevealingCurrentSentence = false;

  // Current sentence reveal state
  // Full text of the sentence being animated
  String currentSentenceText = '';
  // Current character index in the typewriter animation (used for color transition)
  int currentCharacterPosition = 0;

  // Per-character fade-in timeline for the current sentence. Index i stores
  // the stopwatch elapsed at which character i was revealed; the span
  // builder turns that into an alpha based on elapsed-since-reveal / fade
  // duration. The ticker drives repaints while any character is still
  // mid-fade.
  final Stopwatch currentSentenceStopwatch = Stopwatch();
  List<Duration> currentSentenceCharRevealTimes = [];
  Ticker? leadingCharacterFadeTicker;

  // When the last character exits its fade window the ticker stops calling
  // setState, but the previous frame rendered at alpha < 1.0. This flag
  // ensures one final rebuild flushes every character to full opacity.
  bool needsFadeSettlingRebuild = false;

  // Per-character bionic-bold mask for the current sentence. Computed once
  // in initializeCurrentSentence and gated at render time by
  // bionicEnabledNotifier so the toggle flips live without touching this
  // cache.
  List<bool> currentSentenceBoldMask = const [];

  // * Hyphenation resolution state. When text is justified, soft hyphens
  // are inserted at syllable boundaries. On the first layout pass the
  // available width is captured and resolveVisibleHyphens converts the
  // relevant soft hyphens to real dashes. The typewriter starts only after
  // resolution so the dash glyphs are part of the pre-laid-out text.
  bool needsHyphenResolution = false;
  bool isResolutionScheduled = false;

  // Double tap tracking for unblur all functionality
  DateTime? lastTapTime;
  int tapCount = 0;

  // Drives auto-scroll in bounded layouts so newly revealed sentences
  // stay visible instead of overflowing below the fold.
  final ScrollController boundedScrollController = ScrollController();

  // Initializes the widget state when first created
  // Sets up text data and starts the typewriter animation for the first sentence
  @override
  void initState() {
    super.initState();

    // Set up the sentences array and blur states from widget properties
    initializeTextState();

    // Ticker drives vsync-paced repaints while any character is still fading
    // in. It's the cheapest way to animate wall-clock-based alphas without
    // also pulsing setState every frame when nothing is in flight.
    leadingCharacterFadeTicker = createTicker(onLeadingCharacterFadeTick);
    leadingCharacterFadeTicker!.start();

    // Live bionic-toggle listener, flipping the switch in Settings re-paints
    // every visible sentence without remounting.
    bionicEnabledNotifier.addListener(onBionicEnabledChanged);

    // Live reading-setting listeners, blur, accent colour, and reveal-all
    // repaint every visible sentence when the user flips a toggle in Settings.
    blurEnabledNotifier.addListener(onReadingSettingChanged);
    coloredTextEnabledNotifier.addListener(onReadingSettingChanged);

    // Check if there's any content to display
    final bool hasSentencesToReveal = textSentences.isNotEmpty;

    // When justified, the typewriter starts after the first layout pass
    // resolves soft hyphens into real dashes (see maybeResolveHyphens).
    final bool shouldDeferStart = needsHyphenResolution;

    if (hasSentencesToReveal && !shouldDeferStart) {
      // Prepare the first sentence for display
      initializeCurrentSentence();

      // Start the typewriter animation for the first sentence
      startCurrentSentenceReveal();
    }
  }

  @override
  void didUpdateWidget(covariant ProgressiveText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool textAlignChanged = widget.textAlign != oldWidget.textAlign;

    if (textAlignChanged) {
      rehydrateTextSentences();
    }
  }

  // Re-hyphenates (or un-hyphenates) all sentences when the textAlign
  // changes at runtime (e.g. user toggles justified in Settings). Justified
  // text gets soft hyphens inserted; non-justified text reverts to the raw
  // segments.
  void rehydrateTextSentences() {
    final bool isJustified = widget.textAlign == TextAlign.justify;

    textSentences = isJustified
        ? widget.textSegments.map(hyphenateSentence).toList()
        : widget.textSegments;

    needsHyphenResolution = isJustified;
  }

  // Resets the current sentence state to prepare for revealing a new sentence
  // Sets the text and resets character position for color transition animation
  void initializeCurrentSentence() {
    final bool hasCurrentSentence = currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      // Use clean text for animation (without highlight markers)
      currentSentenceText = removeHighlightMarkersFromText(
        textSentences[currentSentenceNumber],
      );
      currentCharacterPosition = -1; // Start with no characters revealed

      // Reset per-character fade timeline: the new sentence's chars will
      // each record their own reveal time as the typewriter loop advances.
      currentSentenceCharRevealTimes = [];
      currentSentenceStopwatch
        ..reset()
        ..start();

      // Pre-compute bionic fixation positions for this sentence. Cheap
      // single pass; saved so the render path stays a lookup.
      currentSentenceBoldMask = bionicBoldMask(currentSentenceText);
    }
  }

  // Begins the typewriter animation for the current sentence
  // Reveals one character at a time with stable layout using color transitions
  // Automatically triggers next sentence if automaticallyRevealNextSentence is true
  void startCurrentSentenceReveal() async {
    final bool isAlreadyRevealing = isRevealingCurrentSentence;
    final bool hasTextToReveal = currentSentenceText.isNotEmpty;
    final bool canStartRevealAnimation = !isAlreadyRevealing && hasTextToReveal;

    if (!canStartRevealAnimation) {
      return;
    }

    // When Progressive is OFF (reveal-all), skip the typewriter entirely
    // and land all characters at once. Fires the completion callback and
    // auto-advances through remaining sentences so every segment appears
    // instantly.
    final bool shouldRevealAllAtOnce = revealAllEnabledNotifier.value;

    if (shouldRevealAllAtOnce) {
      revealSentenceInstantly();
      return;
    }

    final bool isWidgetStillMounted = mounted;

    if (isWidgetStillMounted) {
      setState(() {
        isRevealingCurrentSentence = true;
        currentCharacterPosition = -1; // Start with no characters revealed
      });

      // One random click per new sentence reveal, replaces the looped
      // typewriter clip so the cadence is one tick per beat instead of a
      // continuous keyboard chatter. Routed through the typing-specific
      // method so the Typing Sound switch can mute it without silencing
      // the rest of the UI sounds.
      SoundService.playProgressiveTextTick();
    }

    // Simple character-by-character reveal with stable layout
    for (int charIndex = 0; charIndex < currentSentenceText.length; charIndex++) {
      final bool shouldAbortReveal = !mounted || !isRevealingCurrentSentence;

      if (shouldAbortReveal) {
        break;
      }

      if (mounted) {
        final Duration revealTime = currentSentenceStopwatch.elapsed;

        setState(() {
          currentCharacterPosition = charIndex;
          currentSentenceCharRevealTimes.add(revealTime);
        });
      }

      await Future.delayed(widget.typewriterCharacterDelay);
    }

    final bool canCompleteRevealAnimation = mounted;

    if (canCompleteRevealAnimation) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

      // Check if all sentences have been revealed
      final bool isLastSentence = currentSentenceNumber == textSentences.length - 1;

      final bool shouldTriggerCompletionCallback =
          isLastSentence && widget.onAllSegmentsRevealed != null;

      if (shouldTriggerCompletionCallback) {
        widget.onAllSegmentsRevealed!();
      }

      final bool shouldAutoAdvanceToNextSentence = widget.automaticallyRevealNextSentence;

      if (shouldAutoAdvanceToNextSentence) {
        final bool hasMoreSentencesToReveal = currentSentenceNumber < textSentences.length - 1;

        if (hasMoreSentencesToReveal) {
          await Future.delayed(progressiveTextAutoRevealDelay);

          revealNextSentence();
        }
      }
    }
  }

  // Instant reveal path for when Progressive is OFF. Lands all characters
  // of the current segment at full opacity in a single frame (no typewriter),
  // but does NOT auto-advance to the next segment. The reader still taps to
  // reveal each subsequent segment, preserving the pacing of the reading
  // experience. Only the character-by-character animation is skipped.
  //
  // The completion callback is deferred to a post-frame callback because
  // this method can run during initState (which is inside the build phase).
  // Calling onAllSegmentsRevealed synchronously would trigger setState on a
  // parent widget (e.g. CCTrueFalseQuestion) while Flutter is still laying
  // out the tree, which throws a "dirty descendant" assertion.
  void revealSentenceInstantly() {
    if (!mounted) {
      return;
    }

    // Fill reveal times so every character renders at full opacity.
    final Duration fullyFadedTime =
        currentSentenceStopwatch.elapsed - progressiveTextLeadingCharacterFadeDuration;

    final List<Duration> instantRevealTimes = List<Duration>.filled(
      currentSentenceText.length,
      fullyFadedTime,
    );

    setState(() {
      currentCharacterPosition = currentSentenceText.length - 1;
      currentSentenceCharRevealTimes = instantRevealTimes;
      isRevealingCurrentSentence = false;
    });

    // Defer callbacks to after the current build frame so parent setState
    // calls don't collide with the widget tree layout pass.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final bool isLastSentence = currentSentenceNumber == textSentences.length - 1;

      final bool shouldTriggerCompletionCallback =
          isLastSentence && widget.onAllSegmentsRevealed != null;

      if (shouldTriggerCompletionCallback) {
        widget.onAllSegmentsRevealed!();
      }

      // When auto-advance is explicitly requested by the caller, honour it
      // even in instant-reveal mode (e.g. question answer lists that must
      // show all options without taps).
      final bool shouldAutoAdvance = widget.automaticallyRevealNextSentence;
      final bool hasMoreSentences = currentSentenceNumber < textSentences.length - 1;

      if (shouldAutoAdvance && hasMoreSentences) {
        revealNextSentence();
      }
    });
  }

  // Advances to the next sentence in the sequence
  // Updates the sentence counter and starts revealing the new sentence
  void revealNextSentence() {
    final bool hasMoreSentencesToReveal = currentSentenceNumber < textSentences.length - 1;
    final bool canUpdateUI = mounted;
    final bool shouldAdvanceToNextSentence = hasMoreSentencesToReveal && canUpdateUI;

    if (shouldAdvanceToNextSentence) {
      setState(() {
        currentSentenceNumber++;
      });

      initializeCurrentSentence();
      startCurrentSentenceReveal();
      scrollToLatestContent();
    }
  }

  // Auto-scrolls the bounded scroll view so the newly revealed sentence
  // is visible. Deferred to a post-frame callback so the layout has
  // already incorporated the new sentence widget before we read
  // maxScrollExtent.
  void scrollToLatestContent() {
    final bool isAttached = boundedScrollController.hasClients;

    if (!isAttached) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isStillAttached = boundedScrollController.hasClients && mounted;

      if (!isStillAttached) {
        return;
      }

      boundedScrollController.animateTo(
        boundedScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Handles tap interactions on the widget
  // Either calls custom callback or reveals the next sentence
  void handleTap() {
    final bool hasCustomCallback = widget.onTapCallback != null;

    if (hasCustomCallback) {
      widget.onTapCallback!();

      return;
    }

    final bool isCurrentlyAnimating = isRevealingCurrentSentence;
    final bool hasUnrevealedSentences = currentSentenceNumber < textSentences.length - 1;
    final bool hasInteractiveContent = isCurrentlyAnimating || hasUnrevealedSentences;

    if (hasInteractiveContent) {
      // Provide haptic feedback only for interactive taps
      HapticsService.lightImpact();
    }

    if (isCurrentlyAnimating) {
      // Instantly complete current sentence reveal
      completeCurrentSentenceReveal();
      return;
    }

    if (hasUnrevealedSentences) {
      revealNextSentence();
    }
  }

  // Handles taps on the reveal/toggle button area
  void handleRevealOrToggleTap(bool hasRevealableContent, bool shouldToggleBlur) {
    final bool hasCustomCallback = widget.onTapCallback != null;

    if (hasCustomCallback) {
      widget.onTapCallback!();
      return;
    }

    if (hasRevealableContent) {
      // Standard reveal behavior
      handleTap();
      return;
    }

    // After every segment has landed, prefer the caller's "what happens
    // when the reader taps below the last line" callback over the default
    // blur-toggle, so a CCTextContent-style "advance to next slide" can
    // take priority without losing the toggle elsewhere.
    final bool hasAfterRevealCallback = widget.onTapAfterAllRevealed != null;

    if (hasAfterRevealCallback) {
      HapticsService.lightImpact();
      widget.onTapAfterAllRevealed!();
      return;
    }

    if (shouldToggleBlur) {
      // Handle double tap for blur toggle
      handleDoubleTapForBlurToggle();
    }
  }

  // Handles double tap detection for blur toggle functionality
  void handleDoubleTapForBlurToggle() {
    final DateTime currentTime = DateTime.now();
    final bool hasLastTapTime = lastTapTime != null;

    if (hasLastTapTime) {
      final Duration timeSinceLastTap = currentTime.difference(lastTapTime!);

      final bool isWithinDoubleTapWindow = timeSinceLastTap <= progressiveTextDoubleTapTimeout;

      if (isWithinDoubleTapWindow) {
        tapCount++;

        if (tapCount >= 2) {
          // Execute double tap action
          HapticsService.lightImpact();
          toggleBlurAllSegments();

          // Reset tap tracking
          resetTapTracking();
          return;
        }
      } else {
        // Reset if outside double tap window
        tapCount = 1;
      }
    } else {
      // First tap
      tapCount = 1;
    }

    lastTapTime = currentTime;
  }

  // Resets double tap tracking state
  void resetTapTracking() {
    lastTapTime = null;
    tapCount = 0;
  }

  // Instantly completes the current sentence reveal when tapped
  void completeCurrentSentenceReveal() {
    final bool canCompleteReveal = mounted && isRevealingCurrentSentence;

    if (!canCompleteReveal) {
      return;
    }

    setState(() {
      isRevealingCurrentSentence = false;
      currentCharacterPosition = currentSentenceText.length - 1;

      // Backdate every character's reveal time so all alphas resolve to 1.0
      // in this frame. The while-loop only covered unrevealed characters;
      // recently revealed ones (still mid-fade) kept their original
      // timestamps and froze at sub-1.0 opacity because the ticker saw
      // the backdated last entry and stopped immediately.
      final Duration fullyFadedTime =
          currentSentenceStopwatch.elapsed - progressiveTextLeadingCharacterFadeDuration;

      currentSentenceCharRevealTimes = List<Duration>.filled(
        currentSentenceText.length,
        fullyFadedTime,
      );
    });

    // Check if all sentences have been revealed
    final bool isLastSentence = currentSentenceNumber == textSentences.length - 1;

    final bool shouldTriggerCompletionCallback =
        isLastSentence && widget.onAllSegmentsRevealed != null;

    if (shouldTriggerCompletionCallback) {
      widget.onAllSegmentsRevealed!();
    }
  }

  // Toggles the blur effect on/off for a specific completed sentence
  // Allows users to tap completed sentences to make them readable again
  void toggleBlurForSentence(int sentenceIndex) {
    final bool isValidSentenceIndex = sentenceIndex < sentenceBlurStates.length;

    // Don't allow toggling if sentence has no-blur modifier
    final bool hasNoBlurFlag =
        sentenceIndex < sentenceNoBlurFlags.length && sentenceNoBlurFlags[sentenceIndex];

    if (hasNoBlurFlag) {
      return;
    }

    if (isValidSentenceIndex) {
      setState(() {
        sentenceBlurStates[sentenceIndex] = !sentenceBlurStates[sentenceIndex];
      });
    }
  }

  // Toggles blur state for all segments that can be toggled (excluding no-blur flagged ones)
  void toggleBlurAllSegments() {
    final bool canToggleSegments = mounted;

    if (!canToggleSegments) {
      return;
    }

    // Determine if we should blur or unblur based on current state
    // If any segments are unblurred, we blur all. If all are blurred, we unblur all.
    final bool hasAnyUnblurredSegments = sentenceBlurStates.any((isBlurred) => !isBlurred);
    final bool shouldBlurAll = hasAnyUnblurredSegments;

    setState(() {
      for (int sentenceIndex = 0; sentenceIndex < sentenceBlurStates.length; sentenceIndex++) {
        // Only toggle if the segment doesn't have no-blur flag
        final bool hasNoBlurFlag =
            sentenceIndex < sentenceNoBlurFlags.length && sentenceNoBlurFlags[sentenceIndex];

        if (!hasNoBlurFlag) {
          sentenceBlurStates[sentenceIndex] = shouldBlurAll;
        }
      }
    });
  }

  // Cleanup method called when widget is removed from the widget tree
  // Ensures animation state is properly reset
  @override
  void dispose() {
    isRevealingCurrentSentence = false;

    bionicEnabledNotifier.removeListener(onBionicEnabledChanged);
    blurEnabledNotifier.removeListener(onReadingSettingChanged);
    coloredTextEnabledNotifier.removeListener(onReadingSettingChanged);
    leadingCharacterFadeTicker?.dispose();
    currentSentenceStopwatch.stop();
    boundedScrollController.dispose();
    super.dispose();
  }

  // Live bionic toggle, repaint with the updated weight distribution.
  void onBionicEnabledChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // Live blur / accent toggle, repaint so completed sentences and markup
  // spans reflect the updated setting immediately.
  void onReadingSettingChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Extract condition for clarity (rule #27)
    final bool shouldDisableTapInteraction = !widget.enableTapToReveal;

    if (shouldDisableTapInteraction) {
      final Widget content = Div.column(
        [RevealedTextDisplay()],
        crossAxisAlignment: CrossAxisAlignment.start,
        width: double.infinity,
      );

      // Justified text needs a LayoutBuilder to capture the available
      // width for hyphen resolution, even when tap interaction is off.
      final bool isJustified = widget.textAlign == TextAlign.justify;

      if (isJustified) {
        return LayoutBuilder(
          builder: (context, constraints) {
            maybeResolveHyphens(constraints.maxWidth);
            return content;
          },
        );
      }

      return content;
    }

    // Main layout with text content and reveal button area
    return LayoutBuilder(
      builder: (context, constraints) {
        maybeResolveHyphens(constraints.maxWidth);

        final bool hasUnboundedHeight = constraints.maxHeight == double.infinity;

        if (hasUnboundedHeight) {
          // In scrollable context, use fixed layout
          return Div.column(
            [
              // Text content area
              RevealedTextDisplay(),

              // Reveal button with fixed height
              RevealButtonArea(constraints),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            width: double.infinity,
          );
        } else {
          // In bounded context, CustomScrollView lets the text scroll
          // when it exceeds the viewport. SliverFillRemaining expands
          // the tap area to fill remaining viewport below the text,
          // matching the original full-area "tap to reveal" target.
          return CustomScrollView(
            controller: boundedScrollController,
            slivers: [
              SliverToBoxAdapter(child: RevealedTextDisplay()),

              SliverFillRemaining(hasScrollBody: false, child: RevealTapArea()),
            ],
          );
        }
      },
    );
  }

  // * Tap area that advances the typewriter or toggles sentence blur.
  // Shared by both the unbounded fixed-height layout (RevealButtonArea)
  // and the bounded sliver layout (SliverFillRemaining). Returns
  // SizedBox.shrink when there is nothing left to reveal or toggle.
  Widget RevealTapArea() {
    final bool isCurrentlyAnimating = isRevealingCurrentSentence;
    final bool hasMoreSentences = currentSentenceNumber < textSentences.length - 1;
    final bool hasRevealableContent = isCurrentlyAnimating || hasMoreSentences;

    final bool allSegmentsRevealed =
        currentSentenceNumber >= textSentences.length - 1 && !isCurrentlyAnimating;
    final bool hasToggleableSegments = sentenceBlurStates.isNotEmpty;
    final bool shouldShowToggleButton = allSegmentsRevealed && hasToggleableSegments;
    // Caller-supplied "tap below last line to advance" affordance keeps the
    // bottom area live after every segment has landed, even when there are
    // no blur states left to toggle.
    final bool shouldShowAfterRevealTap =
        allSegmentsRevealed && widget.onTapAfterAllRevealed != null;

    final bool shouldShowButton =
        hasRevealableContent || shouldShowToggleButton || shouldShowAfterRevealTap;

    if (!shouldShowButton) {
      return const SizedBox.shrink();
    }

    // Reveal fires on the very first touch (onTapDown) so the next segment
    // lands the moment the reader's finger contacts the screen, instead of
    // waiting for finger-up. Reads as immediate, the way a hardware key
    // would feel.
    void onAreaTapDown(TapDownDetails _) {
      handleRevealOrToggleTap(hasRevealableContent, shouldShowToggleButton);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: onAreaTapDown,
        child: Container(width: double.infinity, color: RLDS.transparent),
      ),
    );
  }

  // Fixed-height wrapper around RevealTapArea for the unbounded layout
  // path, where there is no sliver to fill remaining viewport space.
  Widget RevealButtonArea(BoxConstraints constraints) {
    const double minButtonHeight = 120.0;

    return Container(
      margin: const EdgeInsets.only(top: RLDS.spacing16),
      height: minButtonHeight,
      child: RevealTapArea(),
    );
  }

  // Main display widget for revealed sentences
  Widget RevealedTextDisplay() {
    final List<Widget> sentenceWidgets = [];

    // Add completed sentence widgets
    for (int sentenceIndex = 0; sentenceIndex < currentSentenceNumber; sentenceIndex++) {
      sentenceWidgets.add(
        CompletedSentenceWidget(
          key: ValueKey('sentence_$sentenceIndex'),
          sentenceIndex: sentenceIndex,
          sentenceText: textSentences[sentenceIndex],
          shouldBlur: shouldBlurSentence(sentenceIndex),
          blurIntensity: widget.completedSentenceBlurIntensity,
          blurOpacity: widget.completedSentenceOpacity,
          textStyle: getConsistentTextStyle(),
          textAlign: widget.textAlign,
          onTap: () => toggleBlurForSentence(sentenceIndex),
        ),
      );
    }

    // Add current sentence if it exists
    final bool hasActiveSentenceToDisplay = currentSentenceNumber < textSentences.length;

    if (hasActiveSentenceToDisplay) {
      sentenceWidgets.add(CurrentSentenceDisplay());
    }

    return Div.column(sentenceWidgets, crossAxisAlignment: CrossAxisAlignment.start);
  }

  // Display widget for currently revealing sentence
  Widget CurrentSentenceDisplay() {
    final String originalText = textSentences[currentSentenceNumber];
    final bool containsHighlightingMarkup = originalText.contains('<c:');

    if (containsHighlightingMarkup) {
      return ProgressiveHighlightedTextWithColorTransition(
        originalText,
        currentCharacterPosition,
      );
    }

    return TextWithColorTransition(currentSentenceText, currentCharacterPosition);
  }

  // Build text with full layout, transitioning colors for revealed characters.
  // Each newly revealed character fades in from alpha 0 → 1 over
  // progressiveTextLeadingCharacterFadeDuration; settled characters render at
  // full opacity and unrevealed characters stay transparent so the layout
  // never reflows.
  Widget TextWithColorTransition(String fullText, int revealedPosition) {
    final TextStyle baseStyle = getConsistentTextStyle();
    final int actualRevealedLength = (revealedPosition + 1).clamp(0, fullText.length);

    final List<TextSpan> spans = createRevealSpans(
      fullText,
      0,
      baseStyle,
      actualRevealedLength,
    );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: widget.textAlign,
    );
  }

  // Build progressively revealed text with highlighting using color transition
  Widget ProgressiveHighlightedTextWithColorTransition(
    String originalText,
    int revealedPosition,
  ) {
    final List<TextSpan> spans = [];
    final RegExp highlightRegex = RegExp(r'<c:([gr])>([^<]*)</c:\1>');
    String remaining = originalText;
    int cleanTextPosition = 0;
    final TextStyle baseStyle = getConsistentTextStyle();
    final int actualRevealedLength = revealedPosition + 1;

    // Process the full text, making characters transparent/visible based on position
    while (remaining.isNotEmpty) {
      final RegExpMatch? match = highlightRegex.firstMatch(remaining);

      if (match == null) {
        // Handle remaining text without highlights
        spans.add(
          createSpanWithColorTransition(
            remaining,
            baseStyle,
            cleanTextPosition,
            actualRevealedLength,
          ),
        );
        break;
      }

      // Handle text before highlight
      if (match.start > 0) {
        final String beforeText = remaining.substring(0, match.start);

        spans.add(
          createSpanWithColorTransition(
            beforeText,
            baseStyle,
            cleanTextPosition,
            actualRevealedLength,
          ),
        );

        cleanTextPosition += beforeText.length;
      }

      // Handle highlighted text. Style branches on <c:g> vs <c:r> via
      // resolveMarkupStyle so the rule stays in one place across both
      // render paths.
      final String colorCode = match.group(1)!;
      final String highlightedText = match.group(2)!;
      final TextStyle highlightStyle = resolveMarkupStyle(context, colorCode, baseStyle);

      spans.add(
        createSpanWithColorTransition(
          highlightedText,
          highlightStyle,
          cleanTextPosition,
          actualRevealedLength,
        ),
      );

      cleanTextPosition += highlightedText.length;
      remaining = remaining.substring(match.end);
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: widget.textAlign,
    );
  }

  // Create text span with color transition based on reveal position. Thin
  // wrapper over createRevealSpans, highlighted text (bold + colour) routes
  // through the same per-character fade-in as plain text.
  TextSpan createSpanWithColorTransition(
    String text,
    TextStyle style,
    int startPosition,
    int revealedLength,
  ) {
    final List<TextSpan> spans = createRevealSpans(text, startPosition, style, revealedLength);

    return TextSpan(children: spans);
  }

  // Build the TextSpan slices for a substring of the current sentence.
  // `startPosition` is where this substring begins in the clean (markup-
  // stripped) sentence; `revealedLength` is how many characters of the full
  // sentence have been revealed so far. The result groups contiguous
  // fully-opaque runs into a single span and gives each still-fading
  // character its own span with computed alpha, so the number of spans per
  // render stays bounded by the fade window size, not the sentence length.
  List<TextSpan> createRevealSpans(
    String text,
    int startPosition,
    TextStyle style,
    int revealedLength,
  ) {
    if (text.isEmpty) {
      return const [];
    }

    final Color baseColor = style.color ?? RLDS.onSurface;
    final TextStyle transparentStyle = style.copyWith(color: RLDS.transparent);
    final bool shouldApplyBionic = bionicEnabledNotifier.value;
    final List<TextSpan> spans = [];
    int cursor = 0;

    while (cursor < text.length) {
      final int globalIndex = startPosition + cursor;
      final bool isRevealed = globalIndex < revealedLength;

      if (!isRevealed) {
        // Everything from here to the end of this chunk is unrevealed, one
        // transparent span covers it.
        spans.add(TextSpan(text: text.substring(cursor), style: transparentStyle));
        break;
      }

      final double alpha = getCharacterFadeAlpha(globalIndex);
      final bool shouldBoldChar = shouldApplyBionic && isBionicBoldAt(globalIndex);
      final TextStyle settledStyle = shouldBoldChar
          ? style.copyWith(fontWeight: FontWeight.w700)
          : style;

      if (alpha >= 1.0) {
        // Walk forward grouping consecutive settled characters with the
        // same bionic-bold state into one span.
        int runEnd = cursor + 1;

        while (runEnd < text.length) {
          final int runGlobalIndex = startPosition + runEnd;
          final bool runRevealed = runGlobalIndex < revealedLength;
          final bool runSettled = runRevealed && getCharacterFadeAlpha(runGlobalIndex) >= 1.0;
          final bool runMatchesBold =
              (shouldApplyBionic && isBionicBoldAt(runGlobalIndex)) == shouldBoldChar;

          final bool shouldEndRun = !runSettled || !runMatchesBold;

          if (shouldEndRun) {
            break;
          }

          runEnd++;
        }

        spans.add(TextSpan(text: text.substring(cursor, runEnd), style: settledStyle));
        cursor = runEnd;
        continue;
      }

      // Character still fading in, its own span with reduced alpha, bold
      // weight applied if the fixation mask says so.
      final TextStyle fadingStyle = settledStyle.copyWith(
        color: baseColor.withValues(alpha: alpha),
      );

      spans.add(TextSpan(text: text[cursor], style: fadingStyle));
      cursor++;
    }

    return spans;
  }

  // Per-character bionic-bold lookup guarded against out-of-range indices
  // (the mask only covers the current sentence's clean text).
  bool isBionicBoldAt(int globalCharIndex) {
    final bool isOutOfRange =
        globalCharIndex < 0 || globalCharIndex >= currentSentenceBoldMask.length;

    if (isOutOfRange) {
      return false;
    }

    return currentSentenceBoldMask[globalCharIndex];
  }

  // Current fade alpha (0..1) for the character at `globalCharIndex` in the
  // clean sentence. Returns 0 if the character hasn't been revealed yet,
  // 1 once elapsed-since-reveal passes the fade window.
  double getCharacterFadeAlpha(int globalCharIndex) {
    final bool hasRevealTime = globalCharIndex < currentSentenceCharRevealTimes.length;

    if (!hasRevealTime) {
      return 0.0;
    }

    final Duration elapsedSinceReveal =
        currentSentenceStopwatch.elapsed - currentSentenceCharRevealTimes[globalCharIndex];
    final double progress =
        elapsedSinceReveal.inMicroseconds /
        progressiveTextLeadingCharacterFadeDuration.inMicroseconds;

    return progress.clamp(0.0, 1.0);
  }

  // Ticker callback, triggers rebuilds while any character is mid-fade,
  // plus one final settling rebuild to flush all alphas to 1.0.
  void onLeadingCharacterFadeTick(Duration _) {
    if (!mounted) {
      return;
    }

    final bool isAnimating = hasAnyAnimatingCharacter();

    if (isAnimating) {
      needsFadeSettlingRebuild = true;
      setState(() {});
      return;
    }

    if (needsFadeSettlingRebuild) {
      needsFadeSettlingRebuild = false;
      setState(() {});
    }
  }

  // True if the most recently revealed character is still inside its fade
  // window. Equivalent to "any character currently has alpha < 1" because
  // reveal times are monotonically non-decreasing.
  bool hasAnyAnimatingCharacter() {
    final bool hasNoRevealedCharacters = currentSentenceCharRevealTimes.isEmpty;

    if (hasNoRevealedCharacters) {
      return false;
    }

    final Duration lastRevealTime = currentSentenceCharRevealTimes.last;
    final Duration elapsedSinceLastReveal = currentSentenceStopwatch.elapsed - lastRevealTime;

    return elapsedSinceLastReveal < progressiveTextLeadingCharacterFadeDuration;
  }

  // Helper methods

  // Initializes the text sentences and blur states from widget properties
  // Called once during initState to set up the initial data
  void initializeTextState() {
    final bool isJustified = widget.textAlign == TextAlign.justify;

    textSentences = isJustified
        ? widget.textSegments.map(hyphenateSentence).toList()
        : widget.textSegments;

    needsHyphenResolution = isJustified;

    sentenceBlurStates = List.filled(textSentences.length, true);

    // Initialize no-blur flags based on modifiers in text
    sentenceNoBlurFlags = textSentences.map((sentence) {
      return sentence.contains('[no-blur]');
    }).toList();
  }

  // * Hyphen resolution pipeline. Called from the LayoutBuilder on the
  // first frame. Resolves soft hyphens into real dashes once, then never
  // runs again (device width is constant).
  void maybeResolveHyphens(double width) {
    final bool isJustified = widget.textAlign == TextAlign.justify;
    final bool shouldSkip = !isJustified || isResolutionScheduled || !needsHyphenResolution;

    if (shouldSkip) {
      return;
    }

    isResolutionScheduled = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      isResolutionScheduled = false;
      needsHyphenResolution = false;
      resolveAllSentences(width);
      initializeCurrentSentence();
      startCurrentSentenceReveal();

      setState(() {});
    });
  }

  // Walks every sentence and replaces soft hyphens that caused a line break
  // with a real dash. Non-break soft hyphens are stripped so the resolved
  // text is ready to render as-is.
  void resolveAllSentences(double maxWidth) {
    final TextStyle style = getConsistentTextStyle();

    for (int i = 0; i < textSentences.length; i++) {
      final String sentence = textSentences[i];
      final bool hasSoftHyphen = sentence.contains(softHyphen);

      if (!hasSoftHyphen) {
        continue;
      }

      final bool hasMarkup = sentence.contains('<c:');

      if (hasMarkup) {
        textSentences[i] = resolveVisibleHyphensForMarkup(sentence, style, maxWidth, widget.textAlign);
      } else {
        textSentences[i] = resolveVisibleHyphens(sentence, style, maxWidth, widget.textAlign);
      }
    }
  }

  // Remove highlight markers and return clean text for animation
  String removeHighlightMarkersFromText(String originalText) {
    return originalText.replaceAll(RegExp(r'<c:[gr]>|</c:[gr]>'), '');
  }

  // Determines whether a specific sentence should have blur effect applied
  // Returns true if blur is enabled and the sentence's blur state is active
  bool shouldBlurSentence(int sentenceIndex) {
    final bool isBlurFeatureDisabled = !widget.blurCompletedSentences;

    if (isBlurFeatureDisabled) {
      return false;
    }

    // Global user preference, when the user turns Focus off in Settings,
    // no sentence blurs regardless of the per-widget flag.
    final bool isBlurGloballyDisabled = !blurEnabledNotifier.value;

    if (isBlurGloballyDisabled) {
      return false;
    }

    final bool isIndexOutOfBounds = sentenceIndex >= sentenceBlurStates.length;

    if (isIndexOutOfBounds) {
      return false;
    }

    // Check if sentence has no-blur modifier
    final bool hasNoBlurFlag =
        sentenceIndex < sentenceNoBlurFlags.length && sentenceNoBlurFlags[sentenceIndex];

    if (hasNoBlurFlag) {
      return false;
    }

    return sentenceBlurStates[sentenceIndex];
  }

  // Get consistent text style for all text (both revealed and completed).
  // Height matches RLTypography's readingLarge/Medium (1.6) so swapping
  // between ProgressiveText and a static RLTypography label in the same
  // slot (CCQuestion OptionText's three-state render) doesn't shift the
  // card height. fontSize is promoted to 18 regardless of caller so every
  // reading surface types in at the same size.
  TextStyle getConsistentTextStyle() {
    final bool hasCustomTextStyle = widget.textStyle != null;

    TextStyle baseStyle = RLTypography.readingMediumStyle;

    if (hasCustomTextStyle) {
      baseStyle = widget.textStyle!;
    }

    // Slightly negative word spacing tightens the inter-word gaps that
    // TextAlign.justify creates on short lines. The value is subtle enough
    // that non-justified last lines still read naturally.
    final bool isJustified = widget.textAlign == TextAlign.justify;
    final double? justifiedWordSpacing = isJustified ? -1 : null;

    return baseStyle.copyWith(fontSize: 18, height: 1.6, wordSpacing: justifiedWordSpacing);
  }
}

// Separate widget for completed sentences to prevent unnecessary rebuilds
class CompletedSentenceWidget extends StatelessWidget {
  final int sentenceIndex;
  final String sentenceText;
  final bool shouldBlur;
  final double blurIntensity;
  final double blurOpacity;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final VoidCallback onTap;

  const CompletedSentenceWidget({
    super.key,
    required this.sentenceIndex,
    required this.sentenceText,
    required this.shouldBlur,
    required this.blurIntensity,
    required this.blurOpacity,
    required this.textStyle,
    required this.textAlign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget sentenceContent = Div.column(
      [SentenceText(context)],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: const [0, 0, progressiveTextDefaultBottomSpacing, 0],
    );

    return Div.column(
      [
        BlurOverlay(
          blurSigma: blurIntensity,
          opacity: blurOpacity,
          enabled: shouldBlur,
          child: sentenceContent,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      onTap: onTap,
    );
  }

  Widget SentenceText(BuildContext context) {
    final bool containsHighlighting = sentenceText.contains('<c:');

    if (containsHighlighting) {
      return HighlightedTextDisplay(context);
    }

    return PlainOrBionicText(sentenceText);
  }

  Widget PlainOrBionicText(String text) {
    final bool isBionicEnabled = bionicEnabledNotifier.value;

    if (isBionicEnabled) {
      final List<InlineSpan> spans = bionicSpans(text, textStyle);

      return RichText(
        text: TextSpan(children: spans),
        textAlign: textAlign,
      );
    }

    return RichText(
      text: TextSpan(text: text, style: textStyle),
      textAlign: textAlign,
    );
  }

  Widget HighlightedTextDisplay(BuildContext context) {
    final List<TextSpan> spans = [];
    final RegExp highlightRegex = RegExp(r'<c:([gr])>([^<]*)</c:\1>');
    String remaining = sentenceText;

    while (remaining.isNotEmpty) {
      final RegExpMatch? match = highlightRegex.firstMatch(remaining);

      // Extract conditions above conditional logic
      final bool hasNoHighlightMatch = match == null;

      if (hasNoHighlightMatch) {
        addRemainingTextSpan(spans, remaining);
        break;
      }

      addTextBeforeHighlight(spans, remaining, match);
      addHighlightedTextSpan(context, spans, match);

      remaining = remaining.substring(match.end);
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
    );
  }

  void addRemainingTextSpan(List<TextSpan> spans, String remainingText) {
    final bool hasRemainingText = remainingText.isNotEmpty;

    if (hasRemainingText) {
      addPlainOrBionicSpans(spans, remainingText);
    }
  }

  void addTextBeforeHighlight(List<TextSpan> spans, String text, RegExpMatch match) {
    final bool hasTextBeforeMatch = match.start > 0;

    if (hasTextBeforeMatch) {
      final String beforeText = text.substring(0, match.start);
      addPlainOrBionicSpans(spans, beforeText);
    }
  }

  void addPlainOrBionicSpans(List<TextSpan> spans, String text) {
    final bool isBionicEnabled = bionicEnabledNotifier.value;

    if (isBionicEnabled) {
      final List<InlineSpan> bionicInlineSpans = bionicSpans(text, textStyle);

      for (final InlineSpan span in bionicInlineSpans) {
        spans.add(span as TextSpan);
      }

      return;
    }

    spans.add(TextSpan(text: text, style: textStyle));
  }

  void addHighlightedTextSpan(BuildContext context, List<TextSpan> spans, RegExpMatch match) {
    final String colorCode = match.group(1)!;
    final String highlightedText = match.group(2)!;
    final TextStyle highlightedTextStyle = resolveMarkupStyle(context, colorCode, textStyle);

    final bool isBionicEnabled = bionicEnabledNotifier.value;

    if (isBionicEnabled) {
      final List<InlineSpan> bionicInlineSpans = bionicSpans(
        highlightedText,
        highlightedTextStyle,
      );

      for (final InlineSpan span in bionicInlineSpans) {
        spans.add(span as TextSpan);
      }

      return;
    }

    spans.add(TextSpan(text: highlightedText, style: highlightedTextStyle));
  }
}
