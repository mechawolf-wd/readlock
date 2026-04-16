// Settings demo widgets showing live previews of reading options
// Includes reveal, blur, colored text, and text speed demos

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

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
  static const String demoText = RLUIStrings.DEMO_REVEAL_TEXT;
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
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(8.0),
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedTextDisplay(),
    );
  }

  Widget AnimatedTextDisplay() {
    if (widget.isEnabled) {
      return Text(demoText, style: RLTypography.bodyMediumStyle);
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final int charCount = (animationController.value * demoText.length).toInt();
        final String visibleText = demoText.substring(0, charCount);
        final String hiddenText = demoText.substring(charCount);

        return RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: RLDS.textPrimary),
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
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(8.0),
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: Div.column([
        BlurredSentence(),

        const Spacing.height(8),

        Text(RLUIStrings.DEMO_BLUR_CURRENT, style: RLTypography.bodyMediumStyle),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  Widget BlurredSentence() {
    final Widget sentenceText = Text(
      RLUIStrings.DEMO_BLUR_PREVIOUS,
      style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
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
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(8.0),
    );

    Color highlightColor = RLDS.textPrimary;

    if (isEnabled) {
      highlightColor = RLDS.info;
    }

    FontWeight keyTermsFontWeight = FontWeight.normal;

    if (isEnabled) {
      keyTermsFontWeight = FontWeight.w600;
    }

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: RLDS.textPrimary, height: 1.5),
          children: [
            TextSpan(
              text: RLUIStrings.DEMO_COLORED_HIGHLIGHT,
              style: TextStyle(color: highlightColor, fontWeight: keyTermsFontWeight),
            ),
            const TextSpan(text: RLUIStrings.DEMO_COLORED_SUFFIX),
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
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(8.0),
    );

    final int wordsPerMinute = getWordsPerMinute();
    final String description = getSpeedDescription();

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: Div.row([
        Div.column([
          RLTypography.headingMedium('$wordsPerMinute', color: RLDS.info),

          Text(RLUIStrings.DEMO_SPEED_UNIT, style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary)),
        ], crossAxisAlignment: CrossAxisAlignment.start),

        const Spacing.width(16),

        Expanded(child: Text(description, style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary))),
      ]),
    );
  }

  int getWordsPerMinute() {
    switch (selectedSpeed) {
      case RLUIStrings.SPEED_CAREFUL:
        {
          return 120;
        }
      case RLUIStrings.SPEED_CLASSIC:
        {
          return 180;
        }
      case RLUIStrings.SPEED_SPEED:
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
      case RLUIStrings.SPEED_CAREFUL:
        {
          return RLUIStrings.DEMO_SPEED_CAREFUL;
        }
      case RLUIStrings.SPEED_CLASSIC:
        {
          return RLUIStrings.DEMO_SPEED_CLASSIC;
        }
      case RLUIStrings.SPEED_SPEED:
        {
          return RLUIStrings.DEMO_SPEED_FAST;
        }
      default:
        {
          return RLUIStrings.DEMO_SPEED_CLASSIC;
        }
    }
  }
}
