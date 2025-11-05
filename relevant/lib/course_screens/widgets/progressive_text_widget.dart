// Progressive Text Widget
//
// This file contains the ProgressiveTextWidget that animates text reveal
// character by character with typewriter effect. Used for creating engaging
// text animations in story content and other narrative elements.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:relevant/constants/app_theme.dart';

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

  /// @Method: Initialize widget state and prepare sentences for reveal
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

  /// @Method: Split text into sentences while preserving structure
  List<String> splitIntoSentences(String text) {
    final List<String> rawSentences = text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .map((sentence) => sentence.trim())
        .toList();

    return rawSentences;
  }

  /// @Method: Initialize the current sentence for character-by-character reveal
  void initializeCurrentSentence() {
    final bool hasCurrentSentence =
        currentSentenceIndex < sentences.length;
        
    if (hasCurrentSentence) {
      currentSentenceText = sentences[currentSentenceIndex];
      currentCharacterIndex = 0;
      revealedText = '';
    }
  }

  /// @Method: Start revealing the current sentence character by character
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
        revealedText = currentSentenceText.substring(0, characterIndex + 1);
      });

      // Delay between characters (10ms)
      await Future.delayed(const Duration(milliseconds: 10));
    }

    setState(() {
      isRevealingCurrentSentence = false;
    });
  }

  /// @Method: Move to next sentence and start revealing it
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

  /// @Method: Reveal all remaining text instantly
  void revealAll() {
    setState(() {
      isRevealingCurrentSentence = false;
      currentSentenceIndex = sentences.length - 1;
      initializeCurrentSentence();
      currentCharacterIndex = currentSentenceText.length - 1;
      revealedText = currentSentenceText;
    });
  }

  /// @Method: Clean up resources
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
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200.0),
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: RevealedText(),
        ),
      ),
    );
  }

  /// @Method: Handle tap/click to reveal next sentence
  void handleTap() {
    final bool canRevealNext =
        !isRevealingCurrentSentence &&
        currentSentenceIndex < sentences.length - 1;

    if (canRevealNext) {
      revealNextSentence();
    }
  }

  /// @Widget: Text content showing completed sentences and current revealing sentence
  Widget RevealedText() {
    final List<Widget> sentenceWidgets = [];

    // Show all completed sentences (blurred)
    
    for (
      int sentenceIndex = 0;
      sentenceIndex < currentSentenceIndex;
      sentenceIndex++
    ) {
      Widget sentenceWidget = Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
        child: Text(
          '${sentences[sentenceIndex]}.',
          style: AppTheme.bodyMedium.copyWith(height: 1.6),
        ),
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
      sentenceWidgets.add(buildCurrentSentence());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentenceWidgets,
    );
  }

  /// @Widget: Build the current sentence with character-by-character reveal
  Widget buildCurrentSentence() {
    final bool hasText = revealedText.isNotEmpty;
    
    if (!hasText) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Text(
        '$revealedText.',
        style: AppTheme.bodyMedium.copyWith(height: 1.6),
      ),
    );
  }
}
