// Quit confirmation dialog for course content viewer
// Asks user to confirm leaving a lesson in progress

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLDialog.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

class QuitConfirmationSheet {
  static void show({
    required BuildContext context,
    required VoidCallback onQuitTap,
  }) {
    RLDialog.showConfirm(
      context,
      title: RLUIStrings.QUIT_CONFIRMATION_TITLE,
      message: RLUIStrings.QUIT_CONFIRMATION_MESSAGE,
      confirmLabel: RLUIStrings.QUIT_CONFIRMATION_LEARN_BUTTON,
      cancelLabel: RLUIStrings.QUIT_CONFIRMATION_QUIT_BUTTON,
      cancelColor: RLDS.error,
      horizontalButtons: true,
      onConfirm: () {},
      onCancel: onQuitTap,
    );
  }
}
