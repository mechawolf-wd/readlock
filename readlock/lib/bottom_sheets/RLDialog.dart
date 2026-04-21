// Generic dialog primitives for the Readlock application.
// For two-action confirmations, use RLConfirmationDialog in design_system/.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLUtility.dart';

class RLDialog {
  // * Standard dialog — centered card with title, content, and action buttons
  static void show(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    final Color dialogColor = backgroundColor ?? RLDS.backgroundDark;

    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: RLDS.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return DialogContainer(
          backgroundColor: dialogColor,
          child: child,
        );
      },
    );
  }

  // * Alert dialog — title, message, single dismiss button
  static void showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
    Color? buttonColor,
  }) {
    final Color actionColor = buttonColor ?? RLDS.info;

    show(
      context,
      child: AlertDialogContent(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        buttonColor: actionColor,
        onTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}

// * Dialog container with consistent styling
class DialogContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const DialogContainer({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color dialogColor = backgroundColor ?? RLDS.backgroundDark;

    final BoxDecoration dialogDecoration = BoxDecoration(
      color: dialogColor,
      borderRadius: RLDS.borderRadiusLarge,
    );

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
        decoration: dialogDecoration,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: RLDS.transparent,
          child: child,
        ),
      ),
    );
  }
}

// * Alert dialog content — single-action layout
class AlertDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const AlertDialogContent({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          RLTypography.headingMedium(title),

          const Spacing.height(RLDS.spacing8),

          // Message
          RLTypography.bodyMedium(message, color: RLDS.textSecondary),

          const Spacing.height(RLDS.spacing24),

          // Action button
          RLButton.primary(
            label: buttonLabel,
            color: buttonColor,
            onTap: onTap,
            padding: const EdgeInsets.symmetric(vertical: RLDS.spacing16),
          ),
        ],
      ),
    );
  }
}
