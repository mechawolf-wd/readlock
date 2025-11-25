// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

class ProgressiveText extends StatefulWidget {
  static const double DEFAULT_BOTTOM_SPACING = 8.0;
  static const Duration AUTO_REVEAL_DELAY = Duration(milliseconds: 300);

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
  });

  @override
  State<ProgressiveText> createState() => ProgressiveTextState();
}

class ProgressiveTextState extends State<ProgressiveText> {
  // Text state management
  // All sentences to be displayed progressively
  late List<String> textSentences;
  // Blur on/off state for each completed sentence (true = blurred)
  late List<bool> sentenceBlurStates;

  // Animation state tracking
  // Index of the sentence currently being revealed (0-based)
  int currentSentenceNumber = 0;
  // Flag indicating if typewriter animation is actively running
  bool isRevealingCurrentSentence = false;

  // Current sentence reveal state
  // Full text of the sentence being animated
  String currentSentenceText = '';
  // Current character index in the typewriter animation
  int currentCharacterPosition = 0;
  // Portion of current sentence that has been revealed so far
  String revealedText = '';

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
  // Sets the text, resets character position, and clears revealed text
  void initializeCurrentSentence() {
    final bool hasCurrentSentence =
        currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      currentSentenceText = textSentences[currentSentenceNumber];
      currentCharacterPosition = 0;
      revealedText = '';
    }
  }

  // Begins the typewriter animation for the current sentence
  // Reveals one character at a time with the specified delay
  // Automatically triggers next sentence if automaticallyRevealNextSentence is true
  void startCurrentSentenceReveal() async {
    final bool isAlreadyRevealing = isRevealingCurrentSentence;
    final bool hasTextToReveal = currentSentenceText.isNotEmpty;
    final bool canStartRevealAnimation =
        !isAlreadyRevealing && hasTextToReveal;

    if (!canStartRevealAnimation) {
      return;
    }

    final bool isWidgetStillMounted = mounted;

    if (isWidgetStillMounted) {
      setState(() {
        isRevealingCurrentSentence = true;
        currentCharacterPosition = 0;
        revealedText = '';
      });
    }

    int characterIndex = 0;

    while (characterIndex < currentSentenceText.length && mounted) {
      final bool isStillMounted = mounted;
      final bool isStillRevealing = isRevealingCurrentSentence;
      final bool shouldContinueAnimation =
          isStillMounted && isStillRevealing;

      if (!shouldContinueAnimation) {
        break;
      }

      final bool canUpdateState = mounted;

      if (canUpdateState) {
        setState(() {
          currentCharacterPosition = characterIndex;
          revealedText = currentSentenceText.substring(
            0,
            characterIndex + 1,
          );
        });
      }

      await Future.delayed(widget.typewriterCharacterDelay);
      characterIndex++;
    }

    final bool canCompleteRevealAnimation = mounted;

    if (canCompleteRevealAnimation) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

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

  // Immediately reveals all remaining text without animation
  // Jumps to the last sentence and displays it fully
  void revealAll() {
    final bool canRevealAllText = mounted;

    if (canRevealAllText) {
      setState(() {
        isRevealingCurrentSentence = false;
        currentSentenceNumber = textSentences.length - 1;

        initializeCurrentSentence();

        currentCharacterPosition = currentSentenceText.length - 1;
        revealedText = currentSentenceText;
      });
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

    final bool isNotCurrentlyAnimating = !isRevealingCurrentSentence;
    final bool hasUnrevealedSentences =
        currentSentenceNumber < textSentences.length - 1;
    final bool canAdvanceToNextSentenceOnTap =
        isNotCurrentlyAnimating && hasUnrevealedSentences;

    if (canAdvanceToNextSentenceOnTap) {
      revealNextSentence();
    }
  }

  // Toggles the blur effect on/off for a specific completed sentence
  // Allows users to tap completed sentences to make them readable again
  void toggleBlurForSentence(int sentenceIndex) {
    final bool isValidSentenceIndex =
        sentenceIndex < sentenceBlurStates.length;

    if (isValidSentenceIndex) {
      setState(() {
        sentenceBlurStates[sentenceIndex] =
            !sentenceBlurStates[sentenceIndex];
      });
    }
  }

  // Cleanup method called when widget is removed from the widget tree
  // Ensures animation state is properly reset
  @override
  void dispose() {
    isRevealingCurrentSentence = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Main content container
    final Widget content = Div.column([
      RevealedTextDisplay(),
    ], crossAxisAlignment: CrossAxisAlignment.start);

    final bool shouldDisableTapInteraction = !widget.enableTapToReveal;

    if (shouldDisableTapInteraction) {
      return content;
    }

    // Clickable wrapper with mouse cursor hint
    final Widget clickableContent = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: content,
    );

    return Div.column(
      [clickableContent],
      onTap: handleTap,
      crossAxisAlignment: 'start',
    );
  }

  // Main display widget for revealed sentences
  Widget RevealedTextDisplay() {
    // Generate widgets for completed sentences
    final List<Widget> sentenceWidgets = List.generate(
      currentSentenceNumber,
      (sentenceItemIndex) {
        Widget sentenceWidget = Div.column(
          [SentenceText(sentenceItemIndex)],
          crossAxisAlignment: CrossAxisAlignment.start,
          padding: const [
            0,
            0,
            ProgressiveText.DEFAULT_BOTTOM_SPACING,
            0,
          ],
        );

        final bool shouldApplyBlurEffect = shouldBlurSentence(
          sentenceItemIndex,
        );

        if (shouldApplyBlurEffect) {
          sentenceWidget = BlurOverlay(
            blurSigma: widget.completedSentenceBlurIntensity,
            opacity: widget.completedSentenceOpacity,
            child: sentenceWidget,
          );
        }

        return Div.column(
          [sentenceWidget],
          crossAxisAlignment: CrossAxisAlignment.start,
          onTap: () => toggleBlurForSentence(sentenceItemIndex),
        );
      },
    );

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
    final bool hasRevealedTextToShow = revealedText.isNotEmpty;
    final bool shouldHideEmptyContent = !hasRevealedTextToShow;

    if (shouldHideEmptyContent) {
      return const SizedBox.shrink();
    }

    return Div.column([
      RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: revealedText,
              style: getConsistentTextStyle(),
            ),
          ],
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  // Helper methods

  // Initializes the text sentences and blur states from widget properties
  // Called once during initState to set up the initial data
  void initializeTextState() {
    textSentences = widget.textSegments;
    sentenceBlurStates = List.filled(textSentences.length, true);
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

    return sentenceBlurStates[sentenceIndex];
  }

  // Create text widget for a specific sentence
  Widget SentenceText(int sentenceIndex) {
    return Text(
      textSentences[sentenceIndex],
      style: getConsistentTextStyle(),
      textAlign: TextAlign.left,
    );
  }

  // Get consistent text style for all text (both revealed and completed)
  // Ensures no visual jump when toggling blur state
  TextStyle getConsistentTextStyle() {
    final TextStyle baseStyle =
        widget.textStyle ?? RLTypography.bodyMediumStyle;

    return baseStyle.copyWith(fontSize: 16, height: 1.5);
  }
}
