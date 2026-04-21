// Settings demo widgets showing live previews of reading options
// Includes reveal, blur, colored text, and text speed demos

import 'dart:async';
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

// Demo widget for Text speed setting.
// Types out a sample sentence character-by-character at the pace that matches
// the selected speed — replaces the old numeric words/min card so users feel
// the rate instead of reading it.
class TextSpeedDemo extends StatefulWidget {
  final String selectedSpeed;

  const TextSpeedDemo({super.key, required this.selectedSpeed});

  @override
  State<TextSpeedDemo> createState() => TextSpeedDemoState();
}

class TextSpeedDemoState extends State<TextSpeedDemo> {
  Timer? revealTimer;
  int revealedCharacterCount = 0;

  static const String sampleText = 'This is how fast the text will appear.';
  static const Duration restartDelay = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    startReveal();
  }

  @override
  void didUpdateWidget(TextSpeedDemo oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool hasSpeedChanged = oldWidget.selectedSpeed != widget.selectedSpeed;

    if (hasSpeedChanged) {
      startReveal();
    }
  }

  @override
  void dispose() {
    revealTimer?.cancel();
    super.dispose();
  }

  void startReveal() {
    revealTimer?.cancel();
    revealedCharacterCount = 0;

    final Duration tickDuration = Duration(
      milliseconds: getMillisecondsPerCharacter(),
    );

    revealTimer = Timer.periodic(tickDuration, handleRevealTick);
  }

  void handleRevealTick(Timer timer) {
    final bool isRevealComplete = revealedCharacterCount >= sampleText.length;

    if (isRevealComplete) {
      timer.cancel();

      Future.delayed(restartDelay, restartIfMounted);
      return;
    }

    setState(() {
      revealedCharacterCount++;
    });
  }

  void restartIfMounted() {
    if (!mounted) {
      return;
    }

    startReveal();
  }

  // Matches the ProgressiveText swipe widget — classic ticks at the swipe's
  // own typewriterCharacterDelay (10ms). Careful slows it, speed doubles it.
  int getMillisecondsPerCharacter() {
    switch (widget.selectedSpeed) {
      case RLUIStrings.SPEED_CAREFUL:
        {
          return 20;
        }
      case RLUIStrings.SPEED_CLASSIC:
        {
          return 10;
        }
      case RLUIStrings.SPEED_SPEED:
        {
          return 5;
        }
      default:
        {
          return 10;
        }
    }
  }

  String getSpeedDescription() {
    switch (widget.selectedSpeed) {
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

  @override
  Widget build(BuildContext context) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(RLDS.spacing8),
    );

    final Widget sampleRow = SampleRow();
    final Widget descriptionText = DescriptionText(getSpeedDescription());

    return Container(
      width: double.infinity,
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing16),
      margin: const EdgeInsets.only(bottom: RLDS.spacing16),
      child: Div.column([
        sampleRow,

        const Spacing.height(RLDS.spacing12),

        descriptionText,
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  // Keeps the layout stable by rendering the full sample with the
  // not-yet-revealed tail in a transparent colour.
  Widget SampleRow() {
    final int totalCharacters = sampleText.length;
    final int revealedClamped = revealedCharacterCount.clamp(0, totalCharacters);

    final String revealedPortion = sampleText.substring(0, revealedClamped);
    final String hiddenPortion = sampleText.substring(revealedClamped);

    final TextStyle revealedStyle = RLTypography.readingMediumStyle.copyWith(
      color: RLDS.textPrimary,
    );
    final TextStyle hiddenStyle = RLTypography.readingMediumStyle.copyWith(
      color: RLDS.transparent,
    );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: revealedPortion, style: revealedStyle),

          TextSpan(text: hiddenPortion, style: hiddenStyle),
        ],
      ),
    );
  }

  Widget DescriptionText(String description) {
    return Text(
      description,
      style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
    );
  }
}
