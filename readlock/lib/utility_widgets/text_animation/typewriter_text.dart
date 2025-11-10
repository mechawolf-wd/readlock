// Typewriter text widget for character-by-character text animation
// Provides TypewriterText widget for simple text revealing effect

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration characterDelay;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;
  final bool autoStart;

  const TypewriterText({
    super.key,
    required this.text,
    this.characterDelay = const Duration(milliseconds: 50),
    this.textStyle,
    this.onComplete,
    this.autoStart = true,
  });

  @override
  State<TypewriterText> createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText> {
  String displayedText = '';
  int currentIndex = 0;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();

    if (widget.autoStart) {
      startAnimation();
    }
  }

  void startAnimation() async {
    if (isAnimating || widget.text.isEmpty) {
      return;
    }

    setState(() {
      isAnimating = true;
      currentIndex = 0;
      displayedText = '';
    });

    for (
      int characterIndex = 0;
      characterIndex < widget.text.length && mounted;
      characterIndex++
    ) {
      if (!mounted || !isAnimating) {
        break;
      }

      setState(() {
        currentIndex = characterIndex;
        displayedText = widget.text.substring(0, characterIndex + 1);
      });

      await Future.delayed(widget.characterDelay);
    }

    if (mounted) {
      setState(() {
        isAnimating = false;
      });

      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  void completeAnimation() {
    if (mounted) {
      setState(() {
        isAnimating = false;
        currentIndex = widget.text.length - 1;
        displayedText = widget.text;
      });

      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  void resetAnimation() {
    if (mounted) {
      setState(() {
        isAnimating = false;
        currentIndex = 0;
        displayedText = '';
      });
    }
  }

  @override
  void dispose() {
    isAnimating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(displayedText, style: widget.textStyle);
  }
}
