// Bottom sheet that lets the user pick their profile bird.
// Hosts the shared BirdCarousel, same widget the onboarding flow uses, so
// the picker behaves identically in both surfaces. Sheet chrome (heading
// row + bottom inset) is the only thing that lives here.

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

import 'package:pixelarticons/pixel.dart';

class BirdPickerBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(context, child: const BirdPickerSheet());
  }
}

class BirdPickerSheet extends StatelessWidget {
  const BirdPickerSheet({super.key});

  // No top inset, RLBottomSheet's grabber block already reserves
  // RLDS.spacing16 below the grabber. Duplicating it here was the anti-
  // pattern the sheet wrapper is meant to kill.
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(
    RLDS.spacing24,
    RLDS.spacing0,
    RLDS.spacing24,
    RLDS.spacing0,
  );

  static final Widget HeaderIcon = const Icon(
    Pixel.shuffle,
    color: RLDS.primary,
    size: RLDS.iconLarge,
  );

  @override
  Widget build(BuildContext context) {
    return Div.column([
      // Heading
      Div.row(
        [
          HeaderIcon,

          const Spacing.width(RLDS.spacing12),

          RLTypography.headingMedium(RLUIStrings.BIRD_PICKER_TITLE),
        ],
        padding: headerPadding,
        mainAxisAlignment: MainAxisAlignment.start,
      ),

      // Carousel + selected name, sits flush below the header so the
      // bird sprite reads as the immediate subject. Carousel owns its own
      // top padding via its 200pt height; no extra Spacing here. Runs in
      // browse-only mode: the reader can swipe across every bird
      // (locked included) without committing one as their profile bird.
      BirdCarousel(),
    ], padding: const EdgeInsets.only(bottom: RLDS.spacing24));
  }
}
