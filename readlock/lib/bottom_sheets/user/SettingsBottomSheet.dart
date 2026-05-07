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
import 'package:readlock/services/feedback/HapticsService.dart';

class SettingsBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.showFullHeight(context, child: const SettingsContent());
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  // * Heading icon — matches the Account sheet's icon-beside-title pattern.
  static final Widget SettingsIcon = const Icon(
    Pixel.menu,
    color: RLDS.info,
    size: RLDS.iconXLarge,
  );

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // Tapping the same icon that opened this sheet pops it back closed —
    // the menu glyph reads as a toggle, mirroring how the bookshelf
    // settings entry treats it.
    void onSettingsIconTap() {
      HapticsService.lightImpact();
      Navigator.of(context).pop();
    }

    final Widget SettingsCloseTap = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSettingsIconTap,
      child: SettingsIcon,
    );

    return Div.column([
      // Heading — icon + title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
        child: Div.row([
          SettingsCloseTap,

          const Spacing.width(RLDS.spacing12),

          RLTypography.headingLarge(RLUIStrings.SETTINGS_TITLE),
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
