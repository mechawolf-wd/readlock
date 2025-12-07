// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';
import 'package:readlock/services/SoundService.dart';
import 'package:readlock/services/HapticsService.dart';

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
  static const double DEFAULT_BOTTOM_SPACING = 8.0;
  static const Duration AUTO_REVEAL_DELAY = Duration(milliseconds: 7);

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

  const ProgressiveText({
    super.key,
    required this.textSegments,
    this.typewriterCharacterDelay = const Duration(milliseconds: 10),
    this.automaticallyRevealNextSentence = false,
    this.textStyle,
    this.contentPadding,
    this.textAlignment,
    this.blurCompletedSentences = true,
    this.completedSentenceBlurIntensity = 4,
    this.completedSentenceOpacity = 0.2,
    this.onTapCallback,
    this.enableTapToReveal = true,
    this.onAllSegmentsRevealed,
  });

  @override
  State<ProgressiveText> createState() => ProgressiveTextState();
}

class ProgressiveTextState extends State<ProgressiveText>
    with TickerProviderStateMixin {
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

  // Image reveal animation controller
  AnimationController? imageRevealController;
  Animation<double>? imageRevealAnimation;

  // Double tap tracking for unblur all functionality
  DateTime? lastTapTime;
  int tapCount = 0;
  static const Duration doubleTapTimeout = Duration(milliseconds: 500);

  // Initializes the widget state when first created
  // Sets up text data and starts the typewriter animation for the first sentence
  @override
  void initState() {
    super.initState();

    // Set up the sentences array and blur states from widget properties
    initializeTextState();

    // Check if there's any content to display
    final bool hasSentencesToReveal = textSentences.isNotEmpty;

    if (hasSentencesToReveal) {
      // Prepare the first sentence for display
      initializeCurrentSentence();

      // Start the typewriter animation for the first sentence
      startCurrentSentenceReveal();
    }
  }

  // Resets the current sentence state to prepare for revealing a new sentence
  // Sets the text and resets character position for color transition animation
  void initializeCurrentSentence() {
    final bool hasCurrentSentence =
        currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      // Use clean text for animation (without highlight markers)
      currentSentenceText = removeHighlightMarkersFromText(
        textSentences[currentSentenceNumber],
      );
      currentCharacterPosition =
          -1; // Start with no characters revealed
    }
  }

  // Begins the typewriter animation for the current sentence
  // Reveals one character at a time with stable layout using color transitions
  // Automatically triggers next sentence if automaticallyRevealNextSentence is true
  void startCurrentSentenceReveal() async {
    final bool isAlreadyRevealing = isRevealingCurrentSentence;
    final bool hasTextToReveal = currentSentenceText.isNotEmpty;
    final bool canStartRevealAnimation =
        !isAlreadyRevealing && hasTextToReveal;

    if (!canStartRevealAnimation) {
      return;
    }

    // Check if current sentence is an image
    final String originalSentence =
        textSentences[currentSentenceNumber];
    final bool isImageSentence = originalSentence.startsWith(
      'image-link',
    );

    if (isImageSentence) {
      // Start image reveal animation
      startImageRevealAnimation();
      return;
    }

    final bool isWidgetStillMounted = mounted;

    if (isWidgetStillMounted) {
      setState(() {
        isRevealingCurrentSentence = true;
        currentCharacterPosition =
            -1; // Start with no characters revealed
      });

      // Start typewriter sound
      SoundService.playTypewriter();
    }

    // Simple character-by-character reveal with stable layout
    for (
      int charIndex = 0;
      charIndex < currentSentenceText.length;
      charIndex++
    ) {
      if (!mounted || !isRevealingCurrentSentence) {
        break;
      }

      if (mounted) {
        setState(() {
          currentCharacterPosition = charIndex;
        });
      }

      await Future.delayed(widget.typewriterCharacterDelay);
    }

    final bool canCompleteRevealAnimation = mounted;

    if (canCompleteRevealAnimation) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

      // Stop typewriter sound
      SoundService.stopTypewriter();

      // Check if all sentences have been revealed
      final bool isLastSentence =
          currentSentenceNumber == textSentences.length - 1;

      final bool shouldTriggerCompletionCallback =
          isLastSentence && widget.onAllSegmentsRevealed != null;

      if (shouldTriggerCompletionCallback) {
        widget.onAllSegmentsRevealed!();
      }

      final bool shouldAutoAdvanceToNextSentence =
          widget.automaticallyRevealNextSentence;

      if (shouldAutoAdvanceToNextSentence) {
        final bool hasMoreSentencesToReveal =
            currentSentenceNumber < textSentences.length - 1;

        if (hasMoreSentencesToReveal) {
          await Future.delayed(ProgressiveText.AUTO_REVEAL_DELAY);

          revealNextSentence();
        }
      }
    }
  }

  // Starts the image reveal animation
  void startImageRevealAnimation() async {
    if (!mounted) {
      return;
    }

    setState(() {
      isRevealingCurrentSentence = true;
    });

    // Create animation controller for image reveal
    imageRevealController?.dispose();
    imageRevealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    imageRevealAnimation = CurvedAnimation(
      parent: imageRevealController!,
      curve: Curves.linear,
    );

    await imageRevealController!.forward();

    if (mounted) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

      // Stop typewriter sound (in case it was playing)
      SoundService.stopTypewriter();

      // Check if all sentences have been revealed
      final bool isLastSentence =
          currentSentenceNumber == textSentences.length - 1;

      final bool shouldTriggerCompletionCallback =
          isLastSentence && widget.onAllSegmentsRevealed != null;

      if (shouldTriggerCompletionCallback) {
        widget.onAllSegmentsRevealed!();
      }

      final bool shouldAutoAdvanceToNextSentence =
          widget.automaticallyRevealNextSentence;

      if (shouldAutoAdvanceToNextSentence) {
        final bool hasMoreSentencesToReveal =
            currentSentenceNumber < textSentences.length - 1;

        if (hasMoreSentencesToReveal) {
          await Future.delayed(ProgressiveText.AUTO_REVEAL_DELAY);
          revealNextSentence();
        }
      }
    }
  }

  // Advances to the next sentence in the sequence
  // Updates the sentence counter and starts revealing the new sentence
  void revealNextSentence() {
    final bool hasMoreSentencesToReveal =
        currentSentenceNumber < textSentences.length - 1;
    final bool canUpdateUI = mounted;
    final bool shouldAdvanceToNextSentence =
        hasMoreSentencesToReveal && canUpdateUI;

    if (shouldAdvanceToNextSentence) {
      setState(() {
        currentSentenceNumber++;
      });

      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
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
    final bool hasUnrevealedSentences =
        currentSentenceNumber < textSentences.length - 1;
    final bool hasInteractiveContent =
        isCurrentlyAnimating || hasUnrevealedSentences;

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
  void handleRevealOrToggleTap(
    bool hasRevealableContent,
    bool shouldToggleBlur,
  ) {
    final bool hasCustomCallback = widget.onTapCallback != null;

    if (hasCustomCallback) {
      widget.onTapCallback!();
      return;
    }

    if (hasRevealableContent) {
      // Standard reveal behavior
      handleTap();
    } else if (shouldToggleBlur) {
      // Handle double tap for blur toggle
      handleDoubleTapForBlurToggle();
    }
  }

  // Handles double tap detection for blur toggle functionality
  void handleDoubleTapForBlurToggle() {
    final DateTime currentTime = DateTime.now();
    final bool hasLastTapTime = lastTapTime != null;

    if (hasLastTapTime) {
      final Duration timeSinceLastTap = currentTime.difference(
        lastTapTime!,
      );

      final bool isWithinDoubleTapWindow =
          timeSinceLastTap <= doubleTapTimeout;

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
    final bool canCompleteReveal =
        mounted && isRevealingCurrentSentence;

    if (!canCompleteReveal) {
      return;
    }

    setState(() {
      isRevealingCurrentSentence = false;
      currentCharacterPosition = currentSentenceText.length - 1;
    });

    // Stop typewriter sound immediately
    SoundService.stopTypewriter();

    // Check if all sentences have been revealed
    final bool isLastSentence =
        currentSentenceNumber == textSentences.length - 1;

    final bool shouldTriggerCompletionCallback =
        isLastSentence && widget.onAllSegmentsRevealed != null;

    if (shouldTriggerCompletionCallback) {
      widget.onAllSegmentsRevealed!();
    }
  }

  // Toggles the blur effect on/off for a specific completed sentence
  // Allows users to tap completed sentences to make them readable again
  void toggleBlurForSentence(int sentenceIndex) {
    final bool isValidSentenceIndex =
        sentenceIndex < sentenceBlurStates.length;

    // Don't allow toggling if sentence has no-blur modifier
    final bool hasNoBlurFlag =
        sentenceIndex < sentenceNoBlurFlags.length &&
        sentenceNoBlurFlags[sentenceIndex];

    if (hasNoBlurFlag) {
      return;
    }

    if (isValidSentenceIndex) {
      setState(() {
        sentenceBlurStates[sentenceIndex] =
            !sentenceBlurStates[sentenceIndex];
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
    final bool hasAnyUnblurredSegments = sentenceBlurStates.any(
      (isBlurred) => !isBlurred,
    );
    final bool shouldBlurAll = hasAnyUnblurredSegments;

    setState(() {
      for (int i = 0; i < sentenceBlurStates.length; i++) {
        // Only toggle if the segment doesn't have no-blur flag
        final bool hasNoBlurFlag =
            i < sentenceNoBlurFlags.length && sentenceNoBlurFlags[i];

        if (!hasNoBlurFlag) {
          sentenceBlurStates[i] = shouldBlurAll;
        }
      }
    });
  }

  // Cleanup method called when widget is removed from the widget tree
  // Ensures animation state is properly reset
  @override
  void dispose() {
    isRevealingCurrentSentence = false;

    // Stop typewriter sound on disposal
    SoundService.stopTypewriter();

    imageRevealController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract condition for clarity (rule #27)
    final bool shouldDisableTapInteraction = !widget.enableTapToReveal;

    if (shouldDisableTapInteraction) {
      return Div.column(
        [RevealedTextDisplay()],
        crossAxisAlignment: CrossAxisAlignment.start,
        width: double.infinity,
      );
    }

    // Main layout with text content and reveal button area
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasUnboundedHeight =
            constraints.maxHeight == double.infinity;

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
          // In bounded context, use flexible layout to fill remaining space
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text content area
              RevealedTextDisplay(),

              // Reveal button fills remaining space
              Flexible(child: RevealButtonArea(constraints)),
            ],
          );
        }
      },
    );
  }

  // Reveal button area widget (rule #10, #12)
  Widget RevealButtonArea(BoxConstraints constraints) {
    // Check if there's more content to reveal or if we should show unblur button
    final bool isCurrentlyAnimating = isRevealingCurrentSentence;
    final bool hasMoreSentences =
        currentSentenceNumber < textSentences.length - 1;
    final bool hasRevealableContent =
        isCurrentlyAnimating || hasMoreSentences;

    // Check if all segments are revealed and we can toggle blur states
    final bool allSegmentsRevealed =
        currentSentenceNumber >= textSentences.length - 1 &&
        !isCurrentlyAnimating;
    final bool hasToggleableSegments = sentenceBlurStates.isNotEmpty;
    final bool shouldShowToggleButton =
        allSegmentsRevealed && hasToggleableSegments;

    final bool shouldShowButton =
        hasRevealableContent || shouldShowToggleButton;

    if (!shouldShowButton) {
      return const SizedBox.shrink();
    }

    // Extract style constants above widget (rule #16)
    const double buttonMarginTop = 16.0;
    const double minButtonHeight = 120.0;

    // Extract margin for clarity
    final EdgeInsets buttonMargin = const EdgeInsets.only(
      top: buttonMarginTop,
    );

    // Calculate button height based on constraints
    final bool hasUnboundedHeight =
        constraints.maxHeight == double.infinity;

    return Container(
      margin: buttonMargin,
      height: hasUnboundedHeight ? minButtonHeight : double.infinity,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => handleRevealOrToggleTap(
            hasRevealableContent,
            shouldShowToggleButton,
          ),
          child: Container(
            width: double.infinity,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  // Main display widget for revealed sentences
  Widget RevealedTextDisplay() {
    final List<Widget> sentenceWidgets = [];

    // Add completed sentence widgets
    for (int i = 0; i < currentSentenceNumber; i++) {
      sentenceWidgets.add(
        CompletedSentenceWidget(
          key: ValueKey('sentence_$i'),
          sentenceIndex: i,
          sentenceText: textSentences[i],
          shouldBlur: shouldBlurSentence(i),
          blurIntensity: widget.completedSentenceBlurIntensity,
          blurOpacity: widget.completedSentenceOpacity,
          textStyle: getConsistentTextStyle(),
          onTap: () => toggleBlurForSentence(i),
        ),
      );
    }

    // Add current sentence if it exists
    final bool hasActiveSentenceToDisplay =
        currentSentenceNumber < textSentences.length;

    if (hasActiveSentenceToDisplay) {
      sentenceWidgets.add(CurrentSentenceDisplay());
    }

    return Div.column(
      sentenceWidgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // Display widget for currently revealing sentence
  Widget CurrentSentenceDisplay() {
    // Check if we should display anything
    final String originalText = textSentences[currentSentenceNumber];
    final bool isImageLinkSegment = originalText.startsWith(
      'image-link',
    );

    if (isImageLinkSegment) {
      return CurrentImageDisplay(originalText);
    }

    final bool containsHighlightingMarkup = originalText.contains(
      '<c:',
    );

    if (containsHighlightingMarkup) {
      return ProgressiveHighlightedTextWithColorTransition(
        originalText,
        currentCharacterPosition,
      );
    }

    // Render full text with color transition for revealed characters
    return BuildTextWithColorTransition(
      currentSentenceText,
      currentCharacterPosition,
    );
  }

  // Build text with full layout, transitioning colors for revealed characters
  Widget BuildTextWithColorTransition(
    String fullText,
    int revealedPosition,
  ) {
    final TextStyle baseStyle = getConsistentTextStyle();
    final Color textColor = baseStyle.color ?? Colors.black;
    final List<TextSpan> spans = [];

    // Add revealed characters in black
    if (revealedPosition >= 0 && fullText.isNotEmpty) {
      final int actualRevealedLength = (revealedPosition + 1).clamp(
        0,
        fullText.length,
      );

      if (actualRevealedLength > 0) {
        spans.add(
          TextSpan(
            text: fullText.substring(0, actualRevealedLength),
            style: baseStyle.copyWith(color: textColor),
          ),
        );
      }

      // Add remaining characters as transparent
      if (actualRevealedLength < fullText.length) {
        spans.add(
          TextSpan(
            text: fullText.substring(actualRevealedLength),
            style: baseStyle.copyWith(color: Colors.transparent),
          ),
        );
      }
    } else {
      // All transparent if nothing revealed yet
      spans.add(
        TextSpan(
          text: fullText,
          style: baseStyle.copyWith(color: Colors.transparent),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  // Display widget for current image segment
  Widget CurrentImageDisplay(String imageSegmentText) {
    final bool hasNoBlurModifier = imageSegmentText.contains(
      '[no-blur]',
    );

    // Extract the path after removing modifiers
    String cleanImageText = imageSegmentText;
    if (hasNoBlurModifier) {
      cleanImageText = cleanImageText.replaceAll('[no-blur]', '');
    }

    final String imageAssetPath = cleanImageText.substring(
      'image-link:'.length,
    );

    // Extract styling above method
    const double maxImageHeight = 200.0;
    const double errorImageHeight = 100.0;
    const double imageSpacing = 16.0;
    const double cornerRadius = 8.0;

    final BorderRadius imageBorderRadius = BorderRadius.circular(
      cornerRadius,
    );

    final BoxDecoration errorContainerDecoration = BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: imageBorderRadius,
    );

    final TextStyle errorTextStyle = getConsistentTextStyle().copyWith(
      color: Colors.grey.shade600,
      fontSize: 12,
    );

    // Create animated builder for reveal effect
    final bool hasAnimation = imageRevealAnimation != null;

    if (!hasAnimation) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: imageRevealAnimation!,
      builder: (context, child) {
        final double revealProgress = imageRevealAnimation!.value;

        return Center(
          child: Div.column([
            // Image with curtain reveal effect
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: revealProgress,
                child: ClipRRect(
                  borderRadius: imageBorderRadius,
                  child: Image.asset(
                    imageAssetPath,
                    fit: BoxFit.contain,
                    height: maxImageHeight,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: errorImageHeight,
                          decoration: errorContainerDecoration,
                          child: Center(
                            child: Text(
                              'Image not found: $imageAssetPath',
                              style: errorTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ),

            const Spacing.height(imageSpacing),
          ]),
        );
      },
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

      // Handle highlighted text
      final String colorCode = match.group(1)!;
      final String highlightedText = match.group(2)!;
      final Color highlightColor = getHighlightColor(colorCode);
      final TextStyle highlightStyle = baseStyle.copyWith(
        color: highlightColor,
        fontWeight: FontWeight.bold,
      );

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
      textAlign: TextAlign.left,
    );
  }

  // Create text span with color transition based on reveal position
  TextSpan createSpanWithColorTransition(
    String text,
    TextStyle style,
    int startPosition,
    int revealedLength,
  ) {
    final int endPosition = startPosition + text.length;

    // Fully revealed - use original color
    if (endPosition <= revealedLength) {
      return TextSpan(text: text, style: style);
    }

    // Fully hidden - make transparent
    if (startPosition >= revealedLength) {
      return TextSpan(
        text: text,
        style: style.copyWith(color: Colors.transparent),
      );
    }

    // Partially revealed - split into visible and transparent parts
    final int splitIndex = revealedLength - startPosition;
    final String visiblePart = text.substring(0, splitIndex);
    final String transparentPart = text.substring(splitIndex);

    return TextSpan(
      children: [
        TextSpan(text: visiblePart, style: style),
        TextSpan(
          text: transparentPart,
          style: style.copyWith(color: Colors.transparent),
        ),
      ],
    );
  }

  // Helper methods

  // Initializes the text sentences and blur states from widget properties
  // Called once during initState to set up the initial data
  void initializeTextState() {
    textSentences = widget.textSegments;
    sentenceBlurStates = List.filled(textSentences.length, true);

    // Initialize no-blur flags based on modifiers in text
    sentenceNoBlurFlags = textSentences.map((sentence) {
      return sentence.contains('[no-blur]');
    }).toList();
  }

  // Remove highlight markers and return clean text for animation
  String removeHighlightMarkersFromText(String originalText) {
    return originalText.replaceAll(RegExp(r'<c:[gr]>|</c:[gr]>'), '');
  }

  // Get color based on marker code
  Color getHighlightColor(String code) {
    switch (code) {
      case 'g':
        return Colors.green.shade600;
      case 'r':
        return Colors.red.shade600;
      default:
        return Colors
            .green
            .shade600; // Fallback to green for any unknown codes
    }
  }

  // Determines whether a specific sentence should have blur effect applied
  // Returns true if blur is enabled and the sentence's blur state is active
  bool shouldBlurSentence(int sentenceIndex) {
    final bool isBlurFeatureDisabled = !widget.blurCompletedSentences;

    if (isBlurFeatureDisabled) {
      return false;
    }

    final bool isIndexOutOfBounds =
        sentenceIndex >= sentenceBlurStates.length;

    if (isIndexOutOfBounds) {
      return false;
    }

    // Check if sentence has no-blur modifier
    final bool hasNoBlurFlag =
        sentenceIndex < sentenceNoBlurFlags.length &&
        sentenceNoBlurFlags[sentenceIndex];

    if (hasNoBlurFlag) {
      return false;
    }

    return sentenceBlurStates[sentenceIndex];
  }

  // Get consistent text style for all text (both revealed and completed)
  // Ensures no visual jump when toggling blur state
  TextStyle getConsistentTextStyle() {
    final bool hasCustomTextStyle = widget.textStyle != null;
    final TextStyle baseStyle = hasCustomTextStyle
        ? widget.textStyle!
        : RLTypography.bodyMediumStyle;

    return baseStyle.copyWith(fontSize: 16, height: 1.5);
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
  final VoidCallback onTap;

  const CompletedSentenceWidget({
    super.key,
    required this.sentenceIndex,
    required this.sentenceText,
    required this.shouldBlur,
    required this.blurIntensity,
    required this.blurOpacity,
    required this.textStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget sentenceWidget = Div.column(
      [SentenceText()],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: const [0, 0, ProgressiveText.DEFAULT_BOTTOM_SPACING, 0],
    );

    if (shouldBlur) {
      sentenceWidget = BlurOverlay(
        blurSigma: blurIntensity,
        opacity: blurOpacity,
        child: sentenceWidget,
      );
    }

    return Div.column(
      [sentenceWidget],
      crossAxisAlignment: CrossAxisAlignment.start,
      onTap: onTap,
    );
  }

  Widget SentenceText() {
    // Extract conditions above widget logic
    final bool isImageLinkSegment = sentenceText.startsWith(
      'image-link',
    );
    final bool containsHighlighting = sentenceText.contains('<c:');

    if (isImageLinkSegment) {
      return ImageDisplay();
    }

    if (containsHighlighting) {
      return HighlightedTextDisplay();
    }

    return Text(
      sentenceText,
      style: textStyle,
      textAlign: TextAlign.left,
    );
  }

  Widget ImageDisplay() {
    final String imageAssetPath = extractImagePath();

    // Extract styling above method
    const double maxImageHeight = 200.0;
    const double errorImageHeight = 100.0;
    const double imageSpacing = 16.0;
    const double cornerRadius = 8.0;

    final BorderRadius imageBorderRadius = BorderRadius.circular(
      cornerRadius,
    );

    final BoxDecoration errorContainerDecoration = BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: imageBorderRadius,
    );

    final TextStyle errorTextStyle = textStyle.copyWith(
      color: Colors.grey.shade600,
      fontSize: 12,
    );

    return Center(
      child: Div.column([
        // Course image display
        CourseImageDisplay(
          imageBorderRadius: imageBorderRadius,
          imageAssetPath: imageAssetPath,
          maxImageHeight: maxImageHeight,
          errorContainerDecoration: errorContainerDecoration,
          errorTextStyle: errorTextStyle,
          errorImageHeight: errorImageHeight,
        ),

        const Spacing.height(imageSpacing),
      ]),
    );
  }

  String extractImagePath() {
    // Remove modifiers if present
    String cleanText = sentenceText;
    if (cleanText.contains('[no-blur]')) {
      cleanText = cleanText.replaceAll('[no-blur]', '');
    }

    const String imageLinkPrefix = 'image-link:';
    return cleanText.substring(imageLinkPrefix.length);
  }

  Widget CourseImageDisplay({
    required BorderRadius imageBorderRadius,
    required String imageAssetPath,
    required double maxImageHeight,
    required BoxDecoration errorContainerDecoration,
    required TextStyle errorTextStyle,
    required double errorImageHeight,
  }) {
    return ClipRRect(
      borderRadius: imageBorderRadius,
      child: Image.asset(
        imageAssetPath,
        fit: BoxFit.contain,
        height: maxImageHeight,
        errorBuilder: (context, error, stackTrace) =>
            ImageErrorFallback(
              errorContainerDecoration: errorContainerDecoration,
              errorTextStyle: errorTextStyle,
              errorImageHeight: errorImageHeight,
              imageAssetPath: imageAssetPath,
            ),
      ),
    );
  }

  Widget ImageErrorFallback({
    required BoxDecoration errorContainerDecoration,
    required TextStyle errorTextStyle,
    required double errorImageHeight,
    required String imageAssetPath,
  }) {
    return Container(
      height: errorImageHeight,
      decoration: errorContainerDecoration,
      child: Center(
        child: Text(
          'Image not found: $imageAssetPath',
          style: errorTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget HighlightedTextDisplay() {
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
      addHighlightedTextSpan(spans, match);

      remaining = remaining.substring(match.end);
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  void addRemainingTextSpan(
    List<TextSpan> spans,
    String remainingText,
  ) {
    final bool hasRemainingText = remainingText.isNotEmpty;

    if (hasRemainingText) {
      spans.add(TextSpan(text: remainingText, style: textStyle));
    }
  }

  void addTextBeforeHighlight(
    List<TextSpan> spans,
    String text,
    RegExpMatch match,
  ) {
    final bool hasTextBeforeMatch = match.start > 0;

    if (hasTextBeforeMatch) {
      final String beforeText = text.substring(0, match.start);
      spans.add(TextSpan(text: beforeText, style: textStyle));
    }
  }

  void addHighlightedTextSpan(List<TextSpan> spans, RegExpMatch match) {
    final String colorCode = match.group(1)!;
    final String highlightedText = match.group(2)!;
    final Color highlightColor = getHighlightColor(colorCode);

    final TextStyle highlightedTextStyle = textStyle.copyWith(
      color: highlightColor,
      fontWeight: FontWeight.bold,
    );

    spans.add(
      TextSpan(text: highlightedText, style: highlightedTextStyle),
    );
  }

  Color getHighlightColor(String code) {
    switch (code) {
      case 'g':
        return Colors.green.shade600;
      case 'r':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }
}
