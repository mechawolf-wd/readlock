// Reusable card component, a frosted LunarBlur pane. The elevated/subtle
// factories are kept as call-site affordances but share a single tint
// opacity so the app's cards all read as the same surface.

import 'package:flutter/material.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';

// Single source of truth for the frosted card tint.
const double RL_CARD_ALPHA = 0.35;

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

    final Widget cardBody = FrostedCardBody(
      padding: resolvedPadding,
      borderColor: borderColor,
      surfaceAlpha: RL_CARD_ALPHA,
      child: child,
    );

    final Widget cardWithMargin = Container(margin: margin, child: cardBody);

    final VoidCallback? rawTapHandler = onTap;
    final bool hasTapHandler = rawTapHandler != null;

    if (hasTapHandler) {
      void handleTapWithHaptic() {
        HapticsService.lightImpact();
        rawTapHandler();
      }

      return GestureDetector(onTap: handleTapWithHaptic, child: cardWithMargin);
    }

    return cardWithMargin;
  }
}

// * Frosted card body, delegates the blur + tint + rounded clip to the
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
