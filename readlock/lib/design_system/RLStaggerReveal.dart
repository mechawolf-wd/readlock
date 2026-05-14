// Centralised stagger-reveal animation used by RLChargeBar tiles and
// RLTypewriterText characters. Each item fades in sequentially: item N
// starts revealing after N * STAGGER_STEP, and reaches full opacity after
// one STAGGER_FADE_WINDOW. Both constants mirror ProgressiveText's
// per-character fade so every stagger in the app shares one timing token.
//
// Usage:
//   RLStaggerReveal(
//     itemCount: myItems.length,
//     builder: StaggerBuilder,
//   )
//   Widget StaggerBuilder(BuildContext context, List<double> opacities) { ... }

import 'package:flutter/material.dart';

// 60ms per item, adjacent items crossfade cleanly without popping.
// Matches RL_TYPEWRITER_CHARACTER_STEP from RLTypewriterText.
const Duration STAGGER_STEP = Duration(milliseconds: 50);

// Fade window for each individual item. Matches
// progressiveTextLeadingCharacterFadeDuration from ProgressiveText.
const Duration STAGGER_FADE_WINDOW = Duration(milliseconds: 50);

class RLStaggerReveal extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, List<double> opacities) builder;
  final Duration step;
  final Duration fadeWindow;

  const RLStaggerReveal({
    super.key,
    required this.itemCount,
    required this.builder,
    this.step = STAGGER_STEP,
    this.fadeWindow = STAGGER_FADE_WINDOW,
  });

  @override
  State<RLStaggerReveal> createState() => RLStaggerRevealState();
}

class RLStaggerRevealState extends State<RLStaggerReveal> with SingleTickerProviderStateMixin {
  late AnimationController revealController;

  @override
  void initState() {
    super.initState();

    final Duration totalDuration = widget.step * widget.itemCount + widget.fadeWindow;

    revealController = AnimationController(vsync: this, duration: totalDuration)..forward();
  }

  @override
  void dispose() {
    revealController.dispose();
    super.dispose();
  }

  // Computes the 0..1 opacity for item at [index] given the current
  // animation progress. Mirrors the formula in RLTypewriterText so
  // the two stagger surfaces are pixel-identical.
  List<double> computeOpacities() {
    final double totalMs = revealController.duration!.inMilliseconds.toDouble();
    final double currentMs = revealController.value * totalMs;
    final double stepMs = widget.step.inMilliseconds.toDouble();
    final double fadeWindowMs = widget.fadeWindow.inMilliseconds.toDouble();

    return List<double>.generate(widget.itemCount, (int itemIndex) {
      final double revealAtMs = itemIndex * stepMs;
      final double elapsedSinceReveal = currentMs - revealAtMs;

      return (elapsedSinceReveal / fadeWindowMs).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: revealController,
      builder: (BuildContext context, Widget? child) {
        return widget.builder(context, computeOpacities());
      },
    );
  }
}
