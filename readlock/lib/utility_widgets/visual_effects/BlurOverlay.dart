// Animated blur overlay widget
// Always present in the tree to avoid layout shifts - animates blur and opacity

import 'dart:ui';
import 'package:flutter/material.dart';

class BlurOverlay extends StatefulWidget {
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
  State<BlurOverlay> createState() => BlurOverlayState();
}

class BlurOverlayState extends State<BlurOverlay> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: 0.0,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(BlurOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool enabledChanged = widget.enabled != oldWidget.enabled;

    if (enabledChanged) {
      if (widget.enabled) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double progress = animation.value;
        final double currentBlur = widget.blurSigma * progress;
        final double currentOpacity = 1.0 - ((1.0 - widget.opacity) * progress);

        final ImageFilter blurFilter = ImageFilter.blur(
          sigmaX: currentBlur,
          sigmaY: currentBlur,
        );

        return ImageFiltered(
          imageFilter: blurFilter,
          child: Opacity(opacity: currentOpacity, child: child),
        );
      },
      child: widget.child,
    );
  }
}
