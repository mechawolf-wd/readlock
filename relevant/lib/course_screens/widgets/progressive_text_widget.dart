import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

class ProgressiveTextWidget extends StatefulWidget {
  final String text;
  final Duration revealDuration;
  final bool autoReveal;

  const ProgressiveTextWidget({
    super.key,
    required this.text,
    this.revealDuration = const Duration(milliseconds: 10),
    this.autoReveal = false,
  });

  @override
  State<ProgressiveTextWidget> createState() =>
      ProgressiveTextWidgetState();
}

class ProgressiveTextWidgetState extends State<ProgressiveTextWidget> {
  late List<String> sentences;
  int currentSentenceIndex = 0;
  bool isRevealingCurrentSentence = false;

  // Character-by-character reveal within current sentence
  String currentSentenceText = '';
  int currentCharacterIndex = 0;
  String revealedText = '';

  @override
  void initState() {
    super.initState();

    sentences = splitIntoSentences(widget.text);

    final bool hasSentences = sentences.isNotEmpty;

    if (hasSentences) {
      initializeCurrentSentence();
    }

    // Always start revealing the first sentence immediately
    if (hasSentences) {
      startCurrentSentenceReveal();
    }
  }

  List<String> splitIntoSentences(String text) {
    final List<String> rawSentences = text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .map((sentence) => sentence.trim())
        .toList();

    return rawSentences;
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

    setState(() {
      isRevealingCurrentSentence = true;
      currentCharacterIndex = 0;
      revealedText = '';
    });

    for (
      int characterIndex = 0;
      characterIndex < currentSentenceText.length && mounted;
      characterIndex++
    ) {
      final bool shouldContinue = mounted && isRevealingCurrentSentence;

      if (!shouldContinue) {
        break;
      }

      setState(() {
        currentCharacterIndex = characterIndex;
        revealedText = currentSentenceText.substring(
          0,
          characterIndex + 1,
        );
      });

      // Delay between characters (10ms)
      await Future.delayed(const Duration(milliseconds: 10));
    }

    setState(() {
      isRevealingCurrentSentence = false;
    });
  }

  void revealNextSentence() {
    final bool hasNextSentence =
        currentSentenceIndex < sentences.length - 1;

    if (hasNextSentence) {
      setState(() {
        currentSentenceIndex++;
      });

      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
  }

  void revealAll() {
    setState(() {
      isRevealingCurrentSentence = false;
      currentSentenceIndex = sentences.length - 1;
      initializeCurrentSentence();
      currentCharacterIndex = currentSentenceText.length - 1;
      revealedText = currentSentenceText;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: handleTap,
        behavior: HitTestBehavior.translucent,
        child: Div.column(
          [RevealedText()],
          width: 'full',
          padding: 20,
          crossAxisAlignment: 'start',
        ),
      ),
    );
  }

  void handleTap() {
    final bool canRevealNext =
        !isRevealingCurrentSentence &&
        currentSentenceIndex < sentences.length - 1;

    if (canRevealNext) {
      revealNextSentence();
    }
  }

  Widget RevealedText() {
    final List<Widget> sentenceWidgets = [];

    // Show all completed sentences (blurred)

    for (
      int sentenceIndex = 0;
      sentenceIndex < currentSentenceIndex;
      sentenceIndex++
    ) {
      Widget sentenceWidget = Div.column(
        [
          Text(
            '${sentences[sentenceIndex]}.',
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
        padding: const EdgeInsets.only(bottom: 8),
        crossAxisAlignment: CrossAxisAlignment.start,
      );

      // Apply blur to completed sentences
      sentenceWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: Opacity(opacity: 0.3, child: sentenceWidget),
      );

      sentenceWidgets.add(sentenceWidget);
    }

    // Show current sentence being revealed word by word
    final bool hasCurrentSentence =
        currentSentenceIndex < sentences.length;

    if (hasCurrentSentence) {
      sentenceWidgets.add(CurrentSentence());
    }

    return Div.column(
      sentenceWidgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget CurrentSentence() {
    final bool hasText = revealedText.isNotEmpty;

    if (!hasText) {
      return Spacing.height(0);
    }

    return Div.column(
      [
        Text(
          '$revealedText.',
          style: const TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.start,
        ),
      ],
      padding: const EdgeInsets.only(bottom: 8),
      crossAxisAlignment: 'start',
    );
  }
}
