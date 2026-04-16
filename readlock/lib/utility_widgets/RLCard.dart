// Reusable card component with elevated and subtle variants
// Elevated: white background with dark border for hero/featured content
// Subtle: transparent background with light border for list items and content

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

enum RLCardVariant { elevated, subtle }

class RLCard extends StatelessWidget {
  final Widget child;
  final RLCardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final VoidCallback? onTap;

  const RLCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.onTap,
  }) : variant = RLCardVariant.elevated;

  const RLCard.subtle({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.onTap,
  }) : variant = RLCardVariant.subtle;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = getCardDecoration();

    final EdgeInsets resolvedPadding = padding ?? const EdgeInsets.all(12);

    final Widget cardContainer = Container(
      decoration: cardDecoration,
      padding: resolvedPadding,
      margin: margin,
      child: child,
    );

    final bool hasTapHandler = onTap != null;

    if (hasTapHandler) {
      return GestureDetector(onTap: onTap, child: cardContainer);
    }

    return cardContainer;
  }

  BoxDecoration getCardDecoration() {
    final bool isElevated = variant == RLCardVariant.elevated;

    if (isElevated) {
      return BoxDecoration(
        color: RLDS.surface,
        borderRadius: RLDS.borderRadiusSmall,
        border: Border.all(
          color: borderColor ?? RLDS.onSurface,
          width: 1.5,
        ),
      );
    }

    return BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.08),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(
        color: borderColor ?? RLDS.textMuted.withValues(alpha: 0.3),
      ),
    );
  }
}
