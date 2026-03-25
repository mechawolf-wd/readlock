// Settings bottom sheet wrapping profile settings content
// Displayed from the bookshelf screen's settings button

import 'package:flutter/material.dart';
import 'package:readlock/screens/profile/ProfileScreen.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius sheetBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    const BoxDecoration sheetDecoration = BoxDecoration(
      color: RLTheme.backgroundDark,
      borderRadius: sheetBorderRadius,
    );

    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final double sheetHeight = MediaQuery.of(context).size.height * 0.9;

    return ClipRRect(
      borderRadius: sheetBorderRadius,
      child: Container(
        height: sheetHeight,
        decoration: sheetDecoration,
        child: Div.column([
          // Drag handle
          const Spacing.height(12),

          const BottomSheetGrabber(),

          const Spacing.height(16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Div.row([
              RLTypography.headingMedium('Settings'),
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
        ], crossAxisAlignment: CrossAxisAlignment.stretch),
      ),
    );
  }
}
