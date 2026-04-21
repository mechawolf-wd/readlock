// Settings demo widgets showing live previews of reading options
// Includes reveal, blur, and colored text demos

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
      return Text(demoText, style: RLTypography.readingMediumStyle);
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final int charCount = (animationController.value * demoText.length).toInt();
        final String visibleText = demoText.substring(0, charCount);
        final String hiddenText = demoText.substring(charCount);

        return RichText(
          text: TextSpan(
            style: RLTypography.readingMediumStyle,
            children: [
              TextSpan(text: visibleText),

              TextSpan(
                text: hiddenText,
                style: const TextStyle(color: RLDS.transparent),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Demo widget for Blur setting.
// Mirrors the swipe behavior — completed sentences use the same blur/opacity
// values as ProgressiveText (sigma 4, opacity 0.2). When blur is off, the
// previous sentence renders at full opacity with no blur, matching the swipe.
const double BLUR_DEMO_BLUR_SIGMA = 4.0;
const double BLUR_DEMO_BLUR_OPACITY = 0.2;

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

          Text(RLUIStrings.DEMO_BLUR_CURRENT, style: RLTypography.readingMediumStyle),
        ],
      ),
    );
  }

  Widget BlurredSentence() {
    final Widget sentenceText = Text(
      RLUIStrings.DEMO_BLUR_PREVIOUS,
      style: RLTypography.readingMediumStyle,
    );

    if (isEnabled) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: BLUR_DEMO_BLUR_SIGMA,
          sigmaY: BLUR_DEMO_BLUR_SIGMA,
        ),
        child: Opacity(opacity: BLUR_DEMO_BLUR_OPACITY, child: sentenceText),
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
          style: RLTypography.readingMediumStyle,
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

