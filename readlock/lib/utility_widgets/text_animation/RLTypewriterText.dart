// One-shot character-by-character text reveal used by the tab headers
// (Home, Search, Bookshelf) so each screen wakes up with a small flourish
// instead of snapping the title in. Each character fades in from alpha 0
// to 1 over the same window ProgressiveText uses
// (progressiveTextLeadingCharacterFadeDuration), so the look matches the
// in-course typewriter without re-implementing the engine.
//
// Designed for short labels — does not support sentence segmentation,
// blur, tap-to-reveal, or sound. Reach for ProgressiveText when those
// features are needed.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLStaggerReveal.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class RLTypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration characterStep;

  const RLTypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.characterStep = STAGGER_STEP,
  });

  @override
  State<RLTypewriterText> createState() => RLTypewriterTextState();
}

class RLTypewriterTextState extends State<RLTypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    final int characterCount = widget.text.length;
    final Duration totalDuration =
        widget.characterStep * characterCount +
        progressiveTextLeadingCharacterFadeDuration;

    animationController = AnimationController(duration: totalDuration, vsync: this);
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: animationController, builder: TypewriterFrame);
  }

  Widget TypewriterFrame(BuildContext context, Widget? child) {
    final List<TextSpan> characterSpans = buildFadingCharacterSpans();

    return RichText(
      text: TextSpan(style: widget.style, children: characterSpans),
      textAlign: widget.textAlign,
    );
  }

  // Per-character alpha is elapsed-since-reveal / fade-window. Unrevealed
  // characters render at alpha 0 so the line's full baseline + width is
  // reserved from frame 1 and the layout never reflows mid-animation.
  List<TextSpan> buildFadingCharacterSpans() {
    final int textLength = widget.text.length;
    final double totalAnimationMs =
        animationController.duration!.inMilliseconds.toDouble();
    final double currentMs = animationController.value * totalAnimationMs;
    final double characterStepMs = widget.characterStep.inMilliseconds.toDouble();
    final double fadeWindowMs =
        progressiveTextLeadingCharacterFadeDuration.inMilliseconds.toDouble();
    final Color baseColor = widget.style.color ?? RLDS.textPrimary;

    TextSpan buildCharacterSpan(int characterIndex) {
      final double revealAtMs = characterIndex * characterStepMs;
      final double elapsedSinceReveal = currentMs - revealAtMs;
      final double characterAlpha = (elapsedSinceReveal / fadeWindowMs).clamp(0.0, 1.0);
      final TextStyle characterStyle = TextStyle(
        color: baseColor.withValues(alpha: characterAlpha),
      );

      return TextSpan(text: widget.text[characterIndex], style: characterStyle);
    }

    return List.generate(textLength, buildCharacterSpan);
  }
}
