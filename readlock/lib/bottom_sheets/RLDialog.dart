// Generic dialog primitives for the Readlock application.
// For two-action confirmations, use RLConfirmationDialog in design_system/.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';

class RLDialog {
  // * Standard dialog, centered card with title, content, and action buttons
  static void show(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    // Matches the Support bottom sheet's surface, RLDS.backgroundLight
    // tinted by RLLunarBlur, so every modal in the app sits on the same
    // frosted pane instead of a flat dark card.
    final Color dialogColor = backgroundColor ?? RLDS.surface;

    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: RLDS.dialogBarrierColor,
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: RLDS.backdropBlurSigma,
            sigmaY: RLDS.backdropBlurSigma,
          ),
          child: DialogContainer(backgroundColor: dialogColor, child: child),
        );
      },
    );
  }

  // * Alert dialog — title, message, single dismiss button
  static void showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = RLUIStrings.DIALOG_DEFAULT_ACTION_LABEL,
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

// * Dialog container with consistent styling. The card is the exact same
// surface as RLToast, RLLunarBlur over `backgroundLight` with a
// transparent border, so dialogs read as the same frosted floating pane
// as every other top-level surface (toast, login bottom sheet). The
// page behind the dialog gets its own backdrop blur via the BackdropFilter
// wrapper in `RLDialog.show`, so the dialog card sits on a softly
// blurred-and-dimmed page rather than the page's raw pixels.
class DialogContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const DialogContainer({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final Color dialogColor = backgroundColor ?? RLDS.backgroundLight;

    const EdgeInsets outerPadding = EdgeInsets.symmetric(
      horizontal: RLDS.dialogOuterHorizontalInset,
    );

    return Center(
      child: Padding(
        padding: outerPadding,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          surfaceColor: dialogColor,
          borderColor: RLDS.transparent,
          child: Material(color: RLDS.transparent, child: child),
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
      padding: RLDS.dialogContentInsets,
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
          RLButton.secondary(
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
