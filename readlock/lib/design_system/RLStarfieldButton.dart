// Tappable surface that paints the shared starfield behind a translucent
// tint of the button colour. Used by the Login / Create-my-nest auth CTAs
// and the Home tab's "Try out something new" row so the brand identity
// reads consistently across surfaces with this treatment. Other primary
// CTAs in the app keep RLButton's flat fill.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';

// Alpha tuned so the label and any leading/trailing icons stay legible
// against every brand colour the call sites pass in (red, green, blue).
const double RL_STARFIELD_BUTTON_TINT_ALPHA = 0.85;

class RLStarfieldButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const RLStarfieldButton({
    super.key,
    required this.child,
    required this.color,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(
      vertical: RLDS.spacing16,
      horizontal: RLDS.spacing24,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final Color tintColor = color.withValues(alpha: RL_STARFIELD_BUTTON_TINT_ALPHA);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: RLDS.borderRadiusSmall,
        child: Stack(
          children: [
            const Positioned.fill(child: RLStarfieldBackground()),

            Positioned.fill(child: ColoredBox(color: tintColor)),

            Container(
              width: double.infinity,
              padding: padding,
              alignment: Alignment.center,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
