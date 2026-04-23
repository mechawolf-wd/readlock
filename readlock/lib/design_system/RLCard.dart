// Reusable card component with elevated and subtle variants.
// Both variants use RLLunarBlur (blurs the starfield / whatever is
// behind) — elevated is a touch more opaque so hero cards feel more solid,
// subtle uses a lighter tint for list items that should stay recessive.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';

// Tint opacities for the two variants — both share the same blur sigma.
const double RL_CARD_ELEVATED_ALPHA = 0.35;
const double RL_CARD_SUBTLE_ALPHA = 0.35;

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
    final EdgeInsets resolvedPadding = padding ?? const EdgeInsets.all(RLDS.spacing12);
    final bool isElevated = variant == RLCardVariant.elevated;

    final double resolvedAlpha = isElevated ? RL_CARD_ELEVATED_ALPHA : RL_CARD_SUBTLE_ALPHA;

    final Widget cardBody = FrostedCardBody(
      padding: resolvedPadding,
      borderColor: borderColor,
      surfaceAlpha: resolvedAlpha,
      child: child,
    );

    final Widget cardWithMargin = Container(margin: margin, child: cardBody);

    final bool hasTapHandler = onTap != null;

    if (hasTapHandler) {
      return GestureDetector(onTap: onTap, child: cardWithMargin);
    }

    return cardWithMargin;
  }
}

// * Frosted card body — delegates the blur + tint + rounded clip to the
// shared RLLunarBlur. The variant's alpha controls how opaque the dark
// tint is, so elevated hero cards feel solid and subtle list rows recede.
class FrostedCardBody extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final double surfaceAlpha;

  const FrostedCardBody({
    super.key,
    required this.child,
    required this.padding,
    required this.surfaceAlpha,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return RLLunarBlur(
      borderColor: borderColor,
      surfaceAlpha: surfaceAlpha,
      padding: padding,
      child: child,
    );
  }
}
