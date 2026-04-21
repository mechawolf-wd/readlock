// Single source of truth for confirmation dialogs.
//
// Use RLConfirmationDialog.show(...) anywhere the app needs a titled, two-action
// modal (destructive confirmations, account actions, quit prompts, etc.).
//
// API shape:
//   - title + message define the content.
//   - cta (required) is the primary action the dialog is asking the user to take.
//   - cancel (optional) is the secondary escape action.
//   - Each action carries its own RLConfirmationVariant for button colour.
//   - layout controls whether the two buttons stack vertically or sit side-by-side.

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLDialog.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLUtility.dart';

// * Button colour roles.

enum RLConfirmationVariant {
  primary,
  success,
  destructive,
  warning,
  neutral,
}

// * Two supported button arrangements.

enum RLConfirmationLayout {
  vertical,
  horizontal,
}

// * One action shown inside a confirmation dialog.

class RLConfirmationAction {
  final String label;
  final VoidCallback? onTap;
  final RLConfirmationVariant variant;

  const RLConfirmationAction({
    required this.label,
    this.onTap,
    this.variant = RLConfirmationVariant.primary,
  });
}

// * Entry point.

class RLConfirmationDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required RLConfirmationAction cta,
    RLConfirmationAction? cancel,
    RLConfirmationLayout layout = RLConfirmationLayout.vertical,
    bool isDismissible = true,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: RLDS.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return DialogContainer(
          child: ConfirmationDialogContent(
            title: title,
            message: message,
            cta: cta,
            cancel: cancel,
            layout: layout,
            onDismiss: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  static Color getVariantColor(RLConfirmationVariant variant) {
    switch (variant) {
      case RLConfirmationVariant.primary:
        {
          return RLDS.info;
        }
      case RLConfirmationVariant.success:
        {
          return RLDS.success;
        }
      case RLConfirmationVariant.destructive:
        {
          return RLDS.error;
        }
      case RLConfirmationVariant.warning:
        {
          return RLDS.warning;
        }
      case RLConfirmationVariant.neutral:
        {
          return RLDS.textSecondary;
        }
    }
  }
}

// * Dialog shell — card container + title + message + action row/stack.

class ConfirmationDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final RLConfirmationAction cta;
  final RLConfirmationAction? cancel;
  final RLConfirmationLayout layout;
  final VoidCallback onDismiss;

  const ConfirmationDialogContent({
    super.key,
    required this.title,
    required this.message,
    required this.cta,
    required this.layout,
    required this.onDismiss,
    this.cancel,
  });

  static const EdgeInsets dialogPadding = EdgeInsets.all(RLDS.spacing24);
  static const EdgeInsets dialogButtonPadding = EdgeInsets.symmetric(vertical: RLDS.spacing16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: dialogPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RLTypography.headingMedium(title),

          const Spacing.height(RLDS.spacing8),

          RLTypography.bodyMedium(message, color: RLDS.textSecondary),

          const Spacing.height(RLDS.spacing24),

          ActionButtons(),
        ],
      ),
    );
  }

  Widget ActionButtons() {
    final bool isHorizontal = layout == RLConfirmationLayout.horizontal;

    if (isHorizontal) {
      return HorizontalButtons();
    }

    return VerticalButtons();
  }

  // Horizontal: cancel (if any) on the left, cta on the right. Both filled.
  Widget HorizontalButtons() {
    final RLConfirmationAction? cancelAction = cancel;
    final bool hasCancel = cancelAction != null;

    final Widget ctaButton = Expanded(child: PrimaryButton(action: cta));

    if (!hasCancel) {
      return Row(children: [ctaButton]);
    }

    return Row(
      children: [
        Expanded(child: PrimaryButton(action: cancelAction)),

        const Spacing.width(RLDS.spacing12),

        ctaButton,
      ],
    );
  }

  // Vertical: cta on top (filled), cancel below as a tertiary text button.
  Widget VerticalButtons() {
    final RLConfirmationAction? cancelAction = cancel;
    final bool hasCancel = cancelAction != null;

    if (!hasCancel) {
      return PrimaryButton(action: cta);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(action: cta),

        const Spacing.height(RLDS.spacing12),

        TertiaryButton(action: cancelAction),
      ],
    );
  }

  Widget PrimaryButton({required RLConfirmationAction action}) {
    final Color buttonColor = RLConfirmationDialog.getVariantColor(action.variant);

    return RLButton.primary(
      label: action.label,
      color: buttonColor,
      onTap: () {
        onDismiss();
        action.onTap?.call();
      },
      padding: dialogButtonPadding,
    );
  }

  Widget TertiaryButton({required RLConfirmationAction action}) {
    final Color buttonColor = RLConfirmationDialog.getVariantColor(action.variant);

    return RLButton.tertiary(
      label: action.label,
      color: buttonColor,
      onTap: () {
        onDismiss();
        action.onTap?.call();
      },
    );
  }
}

// * Convenience helper: a neutral 'Cancel' action wired to just dismiss.
// Keeps the common case short at the call site.

RLConfirmationAction rlDismissCancelAction() {
  return const RLConfirmationAction(
    label: RLUIStrings.CANCEL_LABEL,
    variant: RLConfirmationVariant.neutral,
  );
}
