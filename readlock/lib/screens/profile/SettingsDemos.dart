// Settings demo widgets showing live previews of reading options
// Includes reveal, blur, colored text, and text speed demos

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

// Demo widget for Reveal setting
// Shows text appearing all at once vs character by character
class RevealDemo extends StatefulWidget {
  final bool isEnabled;

  const RevealDemo({super.key, required this.isEnabled});

  @override
  State<RevealDemo> createState() => RevealDemoState();
}

class RevealDemoState extends State<RevealDemo> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  static const String demoText = 'Design is not just what it looks like.';
  bool isPaused = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    animationController.addStatusListener(handleAnimationStatus);
    animationController.forward();
  }

  void handleAnimationStatus(AnimationStatus status) {
    final bool isAnimationComplete = status == AnimationStatus.completed;

    if (isAnimationComplete && !isPaused) {
      isPaused = true;

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          isPaused = false;
          animationController.reset();
          animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    animationController.removeStatusListener(handleAnimationStatus);
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: RLDimensions.borderRadiusM,
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: RLDimensions.paddingAllM,
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedTextDisplay(),
    );
  }

  Widget AnimatedTextDisplay() {
    if (widget.isEnabled) {
      return RLTypography.text(demoText);
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final int charCount = (animationController.value * demoText.length).toInt();
        final String visibleText = demoText.substring(0, charCount);
        final String hiddenText = demoText.substring(charCount);

        return RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: RLTheme.textPrimary),
            children: [
              TextSpan(text: visibleText),

              TextSpan(
                text: hiddenText,
                style: const TextStyle(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Demo widget for Blur setting
// Shows how completed sentences get blurred to focus on current content
class BlurDemo extends StatelessWidget {
  final bool isEnabled;

  const BlurDemo({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: RLDimensions.borderRadiusM,
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: RLDimensions.paddingAllM,
      margin: const EdgeInsets.only(bottom: 16),
      child: Div.column([
        BlurredSentence(),

        const Spacing.height(8),

        RLTypography.text('Current sentence stays clear.'),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  Widget BlurredSentence() {
    final Widget sentenceText = RLTypography.text(
      'Previous sentence fades away.',
      color: RLTheme.textSecondary,
    );

    if (isEnabled) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Opacity(opacity: 0.4, child: sentenceText),
      );
    }

    return sentenceText;
  }
}

// Demo widget for Colored text setting
// Shows how highlighted terms appear in the content
class ColoredTextDemo extends StatelessWidget {
  final bool isEnabled;

  const ColoredTextDemo({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: RLDimensions.borderRadiusM,
    );

    Color highlightColor = RLTheme.textPrimary;

    if (isEnabled) {
      highlightColor = RLTheme.primaryBlue;
    }

    FontWeight keyTermsFontWeight = FontWeight.normal;

    if (isEnabled) {
      keyTermsFontWeight = FontWeight.w600;
    }

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: RLDimensions.paddingAllM,
      margin: const EdgeInsets.only(bottom: 16),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: RLTheme.textPrimary, height: 1.5),
          children: [
            TextSpan(
              text: 'Key terms',
              style: TextStyle(color: highlightColor, fontWeight: keyTermsFontWeight),
            ),
            const TextSpan(text: ' are highlighted in text.'),
          ],
        ),
      ),
    );
  }
}

// Demo widget for Text speed setting
// Shows visual representation of different reading speeds
class TextSpeedDemo extends StatelessWidget {
  final String selectedSpeed;

  const TextSpeedDemo({super.key, required this.selectedSpeed});

  @override
  Widget build(BuildContext context) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: RLDimensions.borderRadiusM,
    );

    final int wordsPerMinute = getWordsPerMinute();
    final String description = getSpeedDescription();

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: RLDimensions.paddingAllM,
      margin: const EdgeInsets.only(bottom: 16),
      child: Div.row([
        Div.column([
          RLTypography.headingMedium('$wordsPerMinute', color: RLTheme.primaryBlue),

          RLTypography.text('words/min', color: RLTheme.textSecondary),
        ], crossAxisAlignment: CrossAxisAlignment.start),

        const Spacing.width(16),

        Expanded(child: RLTypography.text(description, color: RLTheme.textSecondary)),
      ]),
    );
  }

  int getWordsPerMinute() {
    switch (selectedSpeed) {
      case 'Careful':
        {
          return 120;
        }
      case 'Classic':
        {
          return 180;
        }
      case 'Speed':
        {
          return 250;
        }
      default:
        {
          return 180;
        }
    }
  }

  String getSpeedDescription() {
    switch (selectedSpeed) {
      case 'Careful':
        {
          return 'Slower pace for deep comprehension.';
        }
      case 'Classic':
        {
          return 'Balanced speed for comfortable learning.';
        }
      case 'Speed':
        {
          return 'Faster pace for quick review.';
        }
      default:
        {
          return 'Balanced speed for comfortable learning.';
        }
    }
  }
}
