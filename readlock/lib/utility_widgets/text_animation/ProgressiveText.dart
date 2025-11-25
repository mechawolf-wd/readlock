// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

class ProgressiveText extends StatefulWidget {
  static const double DEFAULT_BOTTOM_SPACING = 8.0;
  static const Duration AUTO_REVEAL_DELAY = Duration(milliseconds: 300);

  final List<String> textSegments;
  final Duration characterDelay;
  final bool autoReveal;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool enableBlurOnCompleted;
  final double blurSigma;
  final double completedOpacity;
  final VoidCallback? onTap;
  final bool showClickableArea;

  const ProgressiveText({
    super.key,
    required this.textSegments,
    this.characterDelay = const Duration(milliseconds: 10),
    this.autoReveal = false,
    this.textStyle,
    this.padding,
    this.crossAxisAlignment,
    this.enableBlurOnCompleted = true,
    this.blurSigma = 1.5,
    this.completedOpacity = 0.2,
    this.onTap,
    this.showClickableArea = true,
  });

  @override
  State<ProgressiveText> createState() => ProgressiveTextState();
}

class ProgressiveTextState extends State<ProgressiveText> {
  late List<String> textSentences;
  int currentSentenceNumber = 0;
  bool isRevealingCurrentSentence = false;

  String currentSentenceText = '';
  int currentCharacterPosition = 0;
  String revealedText = '';

  late List<bool> sentenceBlurStates;

  @override
  void initState() {
    super.initState();

    initializeTextState();

    final bool hasSentences = textSentences.isNotEmpty;

    if (hasSentences) {
      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
  }

  void initializeCurrentSentence() {
    final bool hasCurrentSentence =
        currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      currentSentenceText = textSentences[currentSentenceNumber];
      currentCharacterPosition = 0;
      revealedText = '';
    }
  }

  void startCurrentSentenceReveal() async {
    final bool canReveal =
        !isRevealingCurrentSentence && currentSentenceText.isNotEmpty;

    if (!canReveal) {
      return;
    }

    if (mounted) {
      setState(() {
        isRevealingCurrentSentence = true;
        currentCharacterPosition = 0;
        revealedText = '';
      });
    }

    int characterIndex = 0;
    while (characterIndex < currentSentenceText.length && mounted) {
      final bool shouldContinue = mounted && isRevealingCurrentSentence;

      if (!shouldContinue) {
        break;
      }

      if (mounted) {
        setState(() {
          currentCharacterPosition = characterIndex;
          revealedText = currentSentenceText.substring(
            0,
            characterIndex + 1,
          );
        });
      }

      await Future.delayed(widget.characterDelay);
      characterIndex++;
    }

    if (mounted) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

      if (widget.autoReveal) {
        final bool hasNextSentence =
            currentSentenceNumber < textSentences.length - 1;

        if (hasNextSentence) {
          await Future.delayed(ProgressiveText.AUTO_REVEAL_DELAY);
          revealNextSentence();
        }
      }
    }
  }

  void revealNextSentence() {
    final bool hasNextSentence =
        currentSentenceNumber < textSentences.length - 1;

    if (hasNextSentence && mounted) {
      setState(() {
        currentSentenceNumber++;
      });

      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
  }

  void revealAll() {
    if (mounted) {
      setState(() {
        isRevealingCurrentSentence = false;
        currentSentenceNumber = textSentences.length - 1;

        initializeCurrentSentence();

        currentCharacterPosition = currentSentenceText.length - 1;
        revealedText = currentSentenceText;
      });
    }
  }

  void handleTap() {
    print('should work');

    if (widget.onTap != null) {
      widget.onTap!();

      return;
    }

    final bool canRevealNext =
        !isRevealingCurrentSentence &&
        currentSentenceNumber < textSentences.length - 1;

    if (canRevealNext) {
      revealNextSentence();
    }
  }

  void toggleBlurForSentence(int sentenceIndex) {
    if (sentenceIndex < sentenceBlurStates.length) {
      setState(() {
        sentenceBlurStates[sentenceIndex] =
            !sentenceBlurStates[sentenceIndex];
      });
    }
  }

  @override
  void dispose() {
    isRevealingCurrentSentence = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Div.column([
      RevealedTextDisplay(),
    ], crossAxisAlignment: CrossAxisAlignment.start);

    if (!widget.showClickableArea) {
      return content;
    }

    `return Div.column([
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: handleTap, child: content),
      ),
    ], onTap: handleTap);`
  }

  Widget RevealedTextDisplay() {
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

        if (shouldBlurSentence(sentenceItemIndex)) {
          sentenceWidget = BlurOverlay(
            blurSigma: widget.blurSigma,
            opacity: widget.completedOpacity,
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

    final bool hasCurrentSentence =
        currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      sentenceWidgets.add(CurrentSentenceDisplay());
    }

    return Div.column(
      sentenceWidgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget CurrentSentenceDisplay() {
    final bool hasText = revealedText.isNotEmpty;

    if (!hasText) {
      return const SizedBox.shrink();
    }

    return Div.column([
      RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(text: revealedText, style: revealedTextStyle()),
            if (isRevealingCurrentSentence)
              TextSpan(text: '|', style: cursorTextStyle()),
          ],
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  // Helper methods
  void initializeTextState() {
    textSentences = widget.textSegments;
    sentenceBlurStates = List.filled(textSentences.length, true);
  }

  bool shouldBlurSentence(int sentenceIndex) {
    if (!widget.enableBlurOnCompleted) {
      return false;
    }

    if (sentenceIndex >= sentenceBlurStates.length) {
      return false;
    }

    return sentenceBlurStates[sentenceIndex];
  }

  Widget SentenceText(int sentenceIndex) {
    return Text(
      textSentences[sentenceIndex],
      style: widget.textStyle ?? RLTypography.bodyMediumStyle,
      textAlign: TextAlign.left,
    );
  }

  TextStyle revealedTextStyle() {
    final TextStyle baseStyle =
        widget.textStyle ?? RLTypography.bodyMediumStyle;

    return baseStyle.copyWith(fontSize: 16, height: 1.5);
  }

  TextStyle cursorTextStyle() {
    final TextStyle baseStyle =
        widget.textStyle ?? RLTypography.bodyMediumStyle;

    return baseStyle.copyWith(
      fontSize: 16,
      height: 1.5,
      color: RLTheme.primaryBlue,
    );
  }
}
