// Animated blur overlay widget
// Always present in the tree to avoid layout shifts - animates blur and opacity
//
// Timing/curve are shared with RLReveal so every "thing becoming visible"
// surface in the app (continue button, password field, true/false buttons,
// question answers) fades at the same rate.
//
// Default blur strength is the centralised Apple-Music-style lyrics-blur
// token (RLDS.lyricsBlurSigma / lyricsBlurOpacity). Every covered-text
// surface that used to define its own sigma/opacity constants now just does
// `BlurOverlay(enabled: bool, child: …)` and inherits the token. One edit
// in RLDesignSystem flows to every call site.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLReveal.dart';

class BlurOverlay extends StatefulWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;
  final bool enabled;

  const BlurOverlay({
    super.key,
    required this.child,
    this.blurSigma = RLDS.lyricsBlurSigma,
    this.opacity = RLDS.lyricsBlurOpacity,
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
      duration: RLDS.opacityFadeDurationFast,
      vsync: this,
      value: 0.0,
    );

    animation = CurvedAnimation(parent: controller, curve: RL_REVEAL_CURVE);

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
