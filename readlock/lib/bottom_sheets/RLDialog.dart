// Centralized dialog wrapper for the Readlock application
// Provides consistent styling and layout for all modal dialogs

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';

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

  // * Confirm dialog — title, message, primary + secondary action
  static void showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
    bool isDismissible = true,
  }) {
    final Color buttonColor = confirmColor ?? RLDS.primaryGreen;
    final Color secondaryColor = cancelColor ?? RLDS.textSecondary;

    show(
      context,
      isDismissible: isDismissible,
      child: ConfirmDialogContent(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: buttonColor,
        cancelColor: secondaryColor,
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm();
        },
        onCancel: () {
          Navigator.of(context).pop();

          if (onCancel != null) {
            onCancel();
          }
        },
      ),
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
    final Color actionColor = buttonColor ?? RLDS.primaryBlue;

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
      borderRadius: BorderRadius.circular(20),
    );

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: dialogDecoration,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

// * Confirm dialog content — two-action layout
class ConfirmDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final Color cancelColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialogContent({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
    required this.cancelColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          RLTypography.headingMedium(title),

          const Spacing.height(8),

          // Message
          RLTypography.bodyMedium(message, color: RLDS.textSecondary),

          const Spacing.height(24),

          // Confirm button
          ConfirmButton(),

          const Spacing.height(12),

          // Cancel button
          CancelButton(),
        ],
      ),
    );
  }

  Widget ConfirmButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: confirmColor,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: onConfirm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: buttonDecoration,
        child: Center(
          child: RLTypography.bodyLarge(confirmLabel, color: RLDS.white),
        ),
      ),
    );
  }

  Widget CancelButton() {
    return GestureDetector(
      onTap: onCancel,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: RLTypography.bodyMedium(cancelLabel, color: cancelColor),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          RLTypography.headingMedium(title),

          const Spacing.height(8),

          // Message
          RLTypography.bodyMedium(message, color: RLDS.textSecondary),

          const Spacing.height(24),

          // Action button
          ActionButton(),
        ],
      ),
    );
  }

  Widget ActionButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: buttonDecoration,
        child: Center(
          child: RLTypography.bodyLarge(buttonLabel, color: RLDS.white),
        ),
      ),
    );
  }
}
