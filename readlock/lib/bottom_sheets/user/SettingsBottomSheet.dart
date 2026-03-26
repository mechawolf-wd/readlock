// Settings bottom sheet wrapping profile settings content
// Displayed from the bookshelf screen's settings button

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/screens/profile/ProfileScreen.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';

class SettingsBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.showFullHeight(context, child: const SettingsContent());
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Div.column([
      const Spacing.height(16),

      // Title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Div.row([
          RLTypography.headingMedium(RLUIStrings.SETTINGS_TITLE),
        ], mainAxisAlignment: MainAxisAlignment.start),
      ),

      const Spacing.height(20),

      // Settings content
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomSafeArea),
          child: const ProfileContent(),
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}
