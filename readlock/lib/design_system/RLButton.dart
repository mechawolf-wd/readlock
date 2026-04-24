// Reusable button component with primary, secondary, and tertiary variants
// Full-width by default, uses design system colors and border radius

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

enum RLButtonVariant { primary, secondary, tertiary }

class RLButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final RLButtonVariant variant;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const RLButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = RLButtonVariant.primary,
    this.color,
    this.margin,
    this.padding,
  });

  const RLButton.primary({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.margin,
    this.padding,
  }) : variant = RLButtonVariant.primary;

  const RLButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.margin,
    this.padding,
  }) : variant = RLButtonVariant.secondary;

  const RLButton.tertiary({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.margin,
    this.padding,
  }) : variant = RLButtonVariant.tertiary;

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor = color ?? RLDS.green;
    final RLButtonColors style = getStyleForVariant(resolvedColor);

    final EdgeInsets resolvedPadding =
        padding ?? const EdgeInsets.symmetric(vertical: RLDS.spacing16, horizontal: RLDS.spacing24);

    final bool isTertiary = variant == RLButtonVariant.tertiary;

    if (isTertiary) {
      return TertiaryButton(
        label: label,
        textColor: style.textColor,
        resolvedPadding: resolvedPadding,
        margin: margin,
        onTap: onTap,
      );
    }

    return FilledButton(
      label: label,
      style: style,
      resolvedPadding: resolvedPadding,
      margin: margin,
      onTap: onTap,
    );
  }

  Widget FilledButton({
    required String label,
    required RLButtonColors style,
    required EdgeInsets resolvedPadding,
    required EdgeInsets? margin,
    required VoidCallback? onTap,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      color: style.backgroundColor,
      borderRadius: RLDS.borderRadiusSmall,
      border: style.borderColor != null
          ? Border.all(color: style.borderColor!, width: RLDS.borderWidth)
          : null,
    );

    return GestureDetector(
      onTap: wrapWithHaptic(onTap),
      child: Container(
        width: double.infinity,
        margin: margin,
        padding: resolvedPadding,
        decoration: decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [RLTypography.bodyLarge(label, color: style.textColor)],
        ),
      ),
    );
  }

  Widget TertiaryButton({
    required String label,
    required Color textColor,
    required EdgeInsets resolvedPadding,
    required EdgeInsets? margin,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: wrapWithHaptic(onTap),
      child: Container(
        width: double.infinity,
        margin: margin,
        padding: resolvedPadding,
        child: Center(child: RLTypography.bodyMedium(label, color: textColor)),
      ),
    );
  }

  // Wraps an optional tap handler so every button press fires a single
  // light haptic before the underlying action runs. Returns null when
  // no handler is supplied so the GestureDetector stays inert.
  VoidCallback? wrapWithHaptic(VoidCallback? rawHandler) {
    if (rawHandler == null) {
      return null;
    }

    return () {
      HapticFeedback.lightImpact();
      rawHandler();
    };
  }

  RLButtonColors getStyleForVariant(Color resolvedColor) {
    switch (variant) {
      case RLButtonVariant.primary:
        {
          return RLButtonColors(backgroundColor: resolvedColor, textColor: RLDS.white);
        }
      case RLButtonVariant.secondary:
        {
          return RLButtonColors(backgroundColor: RLDS.transparent, textColor: resolvedColor);
        }
      case RLButtonVariant.tertiary:
        {
          return RLButtonColors(backgroundColor: RLDS.transparent, textColor: resolvedColor);
        }
    }
  }
}

class RLButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const RLButtonColors({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
}
