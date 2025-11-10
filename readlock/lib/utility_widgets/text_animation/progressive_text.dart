// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/utility_widgets/visual_effects/blur_overlay.dart';

class ProgressiveText extends StatefulWidget {
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
  late List<String> sentences;
  int currentSentenceIndex = 0;
  bool isRevealingCurrentSentence = false;

  String currentSentenceText = '';
  int currentCharacterIndex = 0;
  String revealedText = '';

  @override
  void initState() {
    super.initState();

    sentences = widget.textSegments;

    final bool hasSentences = sentences.isNotEmpty;

    if (hasSentences) {
      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
  }

  void initializeCurrentSentence() {
    final bool hasCurrentSentence =
        currentSentenceIndex < sentences.length;

    if (hasCurrentSentence) {
      currentSentenceText = sentences[currentSentenceIndex];
      currentCharacterIndex = 0;
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
        currentCharacterIndex = 0;
        revealedText = '';
      });
    }

    for (
      int characterIndex = 0;
      characterIndex < currentSentenceText.length && mounted;
      characterIndex++
    ) {
      final bool shouldContinue = mounted && isRevealingCurrentSentence;

      if (!shouldContinue) {
        break;
      }

      if (mounted) {
        setState(() {
          currentCharacterIndex = characterIndex;
          revealedText = currentSentenceText.substring(
            0,
            characterIndex + 1,
          );
        });
      }

      await Future.delayed(widget.characterDelay);
    }

    if (mounted) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

      if (widget.autoReveal) {
        final bool hasNextSentence =
            currentSentenceIndex < sentences.length - 1;

        if (hasNextSentence) {
          await Future.delayed(const Duration(milliseconds: 300));
          revealNextSentence();
        }
      }
    }
  }

  void revealNextSentence() {
    final bool hasNextSentence =
        currentSentenceIndex < sentences.length - 1;

    if (hasNextSentence && mounted) {
      setState(() {
        currentSentenceIndex++;
      });

      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
  }

  void revealAll() {
    if (mounted) {
      setState(() {
        isRevealingCurrentSentence = false;
        currentSentenceIndex = sentences.length - 1;

        initializeCurrentSentence();

        currentCharacterIndex = currentSentenceText.length - 1;
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
        currentSentenceIndex < sentences.length - 1;

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
      children: [revealedTextDisplay()],
    );

    if (!widget.showClickableArea) {
      return content;
    }

    // Here the column must take availabel height in order to full screen having the handleTap function attached to it
    return Div.column(
      [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: handleTap,
            behavior: HitTestBehavior.translucent,
            child: content,
          ),
        ),
      ],
      crossAxisAlignment: 'start',
      debugBorder: true,
    );
  }

  Widget revealedTextDisplay() {
    final List<Widget> sentenceWidgets = [];

    for (
      int sentenceIndex = 0;
      sentenceIndex < currentSentenceIndex;
      sentenceIndex++
    ) {
      Widget sentenceWidget = Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sentences[sentenceIndex],
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

      sentenceWidgets.add(sentenceWidget);
    }

    final bool hasCurrentSentence =
        currentSentenceIndex < sentences.length;

    if (hasCurrentSentence) {
      sentenceWidgets.add(currentSentenceDisplay());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentenceWidgets,
    );
  }

  Widget currentSentenceDisplay() {
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
