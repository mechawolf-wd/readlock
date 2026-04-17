// Reusable horizontal progress bar with a track + fill
// Used wherever a small reading/course progress indicator is needed

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const RLProgressBar({
    super.key,
    required this.progress,
    this.color = RLDS.success,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius barRadius = BorderRadius.circular(height);

    final BoxDecoration trackDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: barRadius,
    );

    final BoxDecoration fillDecoration = BoxDecoration(
      color: color,
      borderRadius: barRadius,
    );

    return Container(
      height: height,
      decoration: trackDecoration,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(decoration: fillDecoration),
      ),
    );
  }
}
