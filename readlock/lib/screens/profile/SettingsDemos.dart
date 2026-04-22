// Settings demo widgets showing live previews of reading options.
// Each demo mirrors exactly what CCTextContent / ProgressiveText does in a
// real swipe:
//   - Font: readingMedium promoted to fontSize 18 / height 1.5 (the style
//     ProgressiveText.getConsistentTextStyle applies to every line)
//   - Reveal animation: character-by-character typewriter via a transparent
//     tail (no layout shift as chars fill in)
//   - Blur: sigma 4 / opacity 0.2 on completed sentences (the ProgressiveText
//     / BlurOverlay defaults)
//   - Colored text: RLDS.markupGreen + FontWeight.bold (the exact style
//     ProgressiveText applies to <c:g>…</c:g> markup)

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

// Mirrors ProgressiveText.getConsistentTextStyle — every swipe renders at
// fontSize 18 / height 1.5 regardless of the caller's passed style. The
// demos must use the same style or the preview won't match the swipe.
final TextStyle demoReadingStyle = RLTypography.readingMediumStyle.copyWith(
  fontSize: 18,
  height: 1.5,
);

// Matches ProgressiveText's inline-highlight render for <c:g>…</c:g> markup.
// Both colour and weight need to match or the demo understates the visual
// weight of a highlighted key term in the real swipe.
final Color demoHighlightColor = RLDS.markupGreen;
const FontWeight demoHighlightWeight = FontWeight.bold;

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
      child: Align(alignment: Alignment.centerLeft, child: AnimatedTextDisplay()),
    );
  }

  Widget AnimatedTextDisplay() {
    if (widget.isEnabled) {
      return Text(demoText, style: demoReadingStyle);
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: buildTypewriterFrame,
    );
  }

  // Renders the current typewriter frame — visible prefix painted in the
  // swipe's text colour, hidden tail painted transparent so the layout stays
  // reserved from the first frame (same technique ProgressiveText uses).
  Widget buildTypewriterFrame(BuildContext context, Widget? child) {
    final int charCount = (animationController.value * demoText.length).toInt();
    final String visibleText = demoText.substring(0, charCount);
    final String hiddenText = demoText.substring(charCount);

    return RichText(
      text: TextSpan(
        style: demoReadingStyle,
        children: [
          TextSpan(text: visibleText),

          TextSpan(
            text: hiddenText,
            style: const TextStyle(color: RLDS.transparent),
          ),
        ],
      ),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlurredSentence(),

          const Spacing.height(RLDS.spacing8),

          Text(RLUIStrings.DEMO_BLUR_CURRENT, style: demoReadingStyle),
        ],
      ),
    );
  }

  Widget BlurredSentence() {
    final Widget sentenceText = Text(
      RLUIStrings.DEMO_BLUR_PREVIOUS,
      style: demoReadingStyle,
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

    // When disabled, the highlight matches the surrounding text (no colour,
    // normal weight) — same as ProgressiveText would render raw text without
    // <c:g> markup. When enabled, matches the markupGreen + bold style
    // ProgressiveText applies via RLDS.getMarkupColor('g').
    Color highlightColor = RLDS.textPrimary;
    FontWeight keyTermsFontWeight = FontWeight.normal;

    if (isEnabled) {
      highlightColor = demoHighlightColor;
      keyTermsFontWeight = demoHighlightWeight;
    }

    final TextStyle highlightStyle = TextStyle(
      color: highlightColor,
      fontWeight: keyTermsFontWeight,
    );

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: const EdgeInsets.only(bottom: RLDS.spacing16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: demoReadingStyle,
            children: [
              TextSpan(
                text: RLUIStrings.DEMO_COLORED_HIGHLIGHT,
                style: highlightStyle,
              ),

              const TextSpan(text: RLUIStrings.DEMO_COLORED_SUFFIX),
            ],
          ),
        ),
      ),
    );
  }
}
