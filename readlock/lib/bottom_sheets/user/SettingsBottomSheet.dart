// Settings bottom sheet wrapping profile settings content
// Displayed from the bookshelf screen's settings button

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/ProfileScreen.dart';

class SettingsBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.showFullHeight(context, child: const SettingsContent());
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  // * Heading icon — matches the Account sheet's icon-beside-title pattern.
  static final Widget SettingsIcon = const Icon(
    Pixel.sliders,
    color: RLDS.info,
    size: 20,
  );

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Div.column([
      const Spacing.height(RLDS.spacing16),

      // Heading — icon + title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
        child: Div.row([
          SettingsIcon,

          const Spacing.width(RLDS.spacing12),

          RLTypography.headingMedium(RLUIStrings.SETTINGS_TITLE),
        ], mainAxisAlignment: MainAxisAlignment.start),
      ),

      const Spacing.height(RLDS.spacing20),

      // Settings content
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(RLDS.spacing24, 0, RLDS.spacing24, bottomSafeArea),
          child: const ProfileContent(),
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}
