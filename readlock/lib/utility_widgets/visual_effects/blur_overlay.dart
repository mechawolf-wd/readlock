// Blur overlay widget for applying blur effects to child widgets
// Provides BlurOverlay widget for visual filtering effects

import 'dart:ui';
import 'package:flutter/material.dart';

class BlurOverlay extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;
  final bool enabled;

  const BlurOverlay({
    super.key,
    required this.child,
    this.blurSigma = 1.5,
    this.opacity = 0.3,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
      ),
      child: Opacity(opacity: opacity, child: child),
    );
  }
}
