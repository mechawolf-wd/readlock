// LunarBlur — the app's shared frosted-glass treatment. Clips its area to a
// rounded rect, blurs whatever is painted behind it, and lays a semi-
// transparent dark tint on top so content inside stays readable. One widget
// = one source of truth for every "floaty pane over the starfield" surface
// (cards, nav bar, sheets, floating buttons, …).

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

// Default tuning — gentler than the modal backdrop blur so surfaces don't
// completely hide the stars behind them.
const double RL_LUNAR_BLUR_DEFAULT_SIGMA = 4.0;
const double RL_LUNAR_BLUR_DEFAULT_SURFACE_ALPHA = 0.35;
// Matches RLToast's border so cards and toast notifications share the same
// visual weight on the edge.
const double RL_LUNAR_BLUR_BORDER_WIDTH = 2.0;

class RLLunarBlur extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final double surfaceAlpha;
  final Color? surfaceColor;
  final Color? borderColor;
  final EdgeInsets? padding;

  const RLLunarBlur({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma = RL_LUNAR_BLUR_DEFAULT_SIGMA,
    this.surfaceAlpha = RL_LUNAR_BLUR_DEFAULT_SURFACE_ALPHA,
    this.surfaceColor,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius resolvedRadius = borderRadius ?? RLDS.borderRadiusSmall;
    final Color baseSurface = surfaceColor ?? RLDS.surface;
    final Color resolvedBorder = borderColor ?? RLDS.transparent;

    final BoxDecoration tintDecoration = BoxDecoration(
      color: baseSurface.withValues(alpha: surfaceAlpha),
      border: Border.all(color: resolvedBorder, width: 0),
    );

    return ClipRRect(
      borderRadius: resolvedRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(decoration: tintDecoration, padding: padding, child: child),
      ),
    );
  }
}
