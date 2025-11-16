// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/utility_widgets/visual_effects/blur_overlay.dart';

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

  @override
  void initState() {
    super.initState();

    textSentences = widget.textSegments;

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

  @override
  void dispose() {
    isRevealingCurrentSentence = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [RevealedTextDisplay()],
    );

    if (!widget.showClickableArea) {
      return content;
    }

    return Div.column([
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: handleTap,
          behavior: HitTestBehavior.translucent,
          child: content,
        ),
      ),
    ], crossAxisAlignment: 'start');
  }

  Widget RevealedTextDisplay() {
    final List<Widget> sentenceWidgets = List.generate(
      currentSentenceNumber,
      (sentenceItemIndex) {
        Widget sentenceWidget = Padding(
          padding: const EdgeInsets.only(
            bottom: ProgressiveText.DEFAULT_BOTTOM_SPACING,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textSentences[sentenceItemIndex],
                style: widget.textStyle ?? Typography.bodyMediumStyle,
              ),
            ],
          ),
        );

        if (widget.enableBlurOnCompleted) {
          sentenceWidget = BlurOverlay(
            blurSigma: widget.blurSigma,
            opacity: widget.completedOpacity,
            child: sentenceWidget,
          );
        }

        return sentenceWidget;
      },
    );

    final bool hasCurrentSentence =
        currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      sentenceWidgets.add(CurrentSentenceDisplay());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentenceWidgets,
    );
  }

  Widget CurrentSentenceDisplay() {
    final bool hasText = revealedText.isNotEmpty;

    if (!hasText) {
      return const SizedBox.shrink();
    }

    return Div.column([
      Text(
        revealedText,
        style:
            widget.textStyle ??
            const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.start,
      ),
    ]);
  }
}
