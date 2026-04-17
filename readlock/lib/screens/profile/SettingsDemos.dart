// Settings demo widgets showing live previews of reading options
// Includes reveal, blur, colored text, and text speed demos

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
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
      borderRadius: BorderRadius.circular(RLDS.spacing8),
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: const EdgeInsets.only(bottom: RLDS.spacing16),
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
            style: RLTypography.bodyMediumStyle,
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
      borderRadius: BorderRadius.circular(RLDS.spacing8),
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: const EdgeInsets.only(bottom: RLDS.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlurredSentence(),

          const Spacing.height(RLDS.spacing8),

          Text(RLUIStrings.DEMO_BLUR_CURRENT, style: RLTypography.bodyMediumStyle),
        ],
      ),
    );
  }

  Widget BlurredSentence() {
    final TextStyle blurredStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLDS.textSecondary,
    );

    final Widget sentenceText = Text(RLUIStrings.DEMO_BLUR_PREVIOUS, style: blurredStyle);

    if (isEnabled) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Opacity(opacity: 0.5, child: sentenceText),
      );
    }

    return Opacity(opacity: 0.5, child: sentenceText);
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
      borderRadius: BorderRadius.circular(RLDS.spacing8),
    );

    Color highlightColor = RLDS.textPrimary;
    FontWeight keyTermsFontWeight = FontWeight.normal;

    if (isEnabled) {
      highlightColor = RLDS.primary;
      keyTermsFontWeight = FontWeight.w600;
    }

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: const EdgeInsets.only(bottom: RLDS.spacing16),
      child: RichText(
        text: TextSpan(
          style: RLTypography.bodyMediumStyle,
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
      borderRadius: BorderRadius.circular(RLDS.spacing8),
    );

    final int wordsPerMinute = getWordsPerMinute();
    final String description = getSpeedDescription();

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: const EdgeInsets.only(bottom: RLDS.spacing16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RLTypography.headingMedium('$wordsPerMinute', color: RLDS.primary),

              Text(
                RLUIStrings.DEMO_SPEED_UNIT,
                style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
              ),
            ],
          ),

          const Spacing.width(RLDS.spacing16),

          Expanded(
            child: Text(
              description,
              style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
            ),
          ),
        ],
      ),
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
