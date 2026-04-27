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
import 'package:flutter/services.dart';
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

// * Supported button arrangements.
//
//   vertical    — filled primary on top, tertiary text below.
//   horizontal  — cancel (if any) left, cta right. Both filled.
//   iconCancel  — cancel renders as a compact square icon-only button on
//                 the left (tinted with its variant colour), cta fills the
//                 rest of the row as the filled primary. Use when the
//                 escape action is better read as a glyph than a word
//                 (e.g. Pause ⏸ next to a big "Read" continue button).

enum RLConfirmationLayout {
  vertical,
  horizontal,
  iconCancel,
}

// * One action shown inside a confirmation dialog.

class RLConfirmationAction {
  final String label;
  final VoidCallback? onTap;
  final RLConfirmationVariant variant;

  // Optional glyph. Only consumed by the iconCancel layout today — the
  // icon-only cancel button renders this icon tinted with the action's
  // variant colour.
  final IconData? icon;

  const RLConfirmationAction({
    required this.label,
    this.onTap,
    this.variant = RLConfirmationVariant.primary,
    this.icon,
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
    // Dark scrim behind the dialog — RLDS.dialogBarrierColor is the single
    // source of truth shared with RLDialog, so every modal dims the page
    // by the same amount. The card itself is RLLunarBlur (same family as
    // RLToast / login sheet).
    showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: RLDS.dialogBarrierColor,
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

  static const EdgeInsets dialogButtonPadding = EdgeInsets.symmetric(vertical: RLDS.spacing16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RLDS.dialogContentInsets,
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
    switch (layout) {
      case RLConfirmationLayout.horizontal:
        {
          return HorizontalButtons();
        }
      case RLConfirmationLayout.iconCancel:
        {
          return IconCancelButtons();
        }
      case RLConfirmationLayout.vertical:
        {
          return VerticalButtons();
        }
    }
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

  // Vertical: cta renders as the filled primary on top, cancel as the
  // tertiary text button below. Each action's variant only controls its
  // colour — the call site decides which role carries the visual weight
  // by choosing what to put in `cta` vs `cancel`.
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

  // Compact icon-on-left + filled-cta-on-right row. Used when the escape
  // action carries a glyph (pause, close, etc.) that reads faster than a
  // word. Falls back to the plain HorizontalButtons layout when no cancel
  // is supplied, since there's nothing to render as an icon.
  Widget IconCancelButtons() {
    final RLConfirmationAction? cancelAction = cancel;
    final bool hasCancel = cancelAction != null;

    if (!hasCancel) {
      return HorizontalButtons();
    }

    return Row(
      children: [
        IconCancelButton(action: cancelAction),

        const Spacing.width(RLDS.spacing12),

        Expanded(child: PrimaryButton(action: cta)),
      ],
    );
  }

  // Square icon-only button matching the primary button's vertical footprint
  // so the row reads as one aligned block. Glyph paints in textPrimary
  // (white) with no background — the frosted dialog surface is the only
  // card behind it, keeping the row visually calm so the filled CTA on
  // the right carries all the visual weight.
  Widget IconCancelButton({required RLConfirmationAction action}) {
    final IconData? glyph = action.icon;
    final Widget iconWidget = glyph == null
        ? const SizedBox.shrink()
        : Icon(glyph, color: RLDS.textPrimary, size: RLDS.iconMedium);

    const EdgeInsets buttonPadding = EdgeInsets.all(RLDS.spacing16);

    void onIconCancelTap() {
      HapticFeedback.lightImpact();
      onDismiss();
      action.onTap?.call();
    }

    return GestureDetector(
      onTap: onIconCancelTap,
      child: Padding(padding: buttonPadding, child: iconWidget),
    );
  }

  Widget PrimaryButton({required RLConfirmationAction action}) {
    final Color buttonColor = RLConfirmationDialog.getVariantColor(action.variant);
    final IconData? leadingGlyph = action.icon;
    final bool hasLeadingGlyph = leadingGlyph != null;

    // RLButton fires its own haptic; the icon-label path uses a raw
    // GestureDetector, so it needs one explicit here to match.
    void onPrimaryTap() {
      if (hasLeadingGlyph) {
        HapticFeedback.lightImpact();
      }

      onDismiss();
      action.onTap?.call();
    }

    if (hasLeadingGlyph) {
      return IconLabelPrimaryButton(
        action: action,
        buttonColor: buttonColor,
        glyph: leadingGlyph,
        onTap: onPrimaryTap,
      );
    }

    return RLButton.primary(
      label: action.label,
      color: buttonColor,
      onTap: onPrimaryTap,
      padding: dialogButtonPadding,
    );
  }

  // Filled primary button with a leading glyph (e.g. play icon on the
  // quit dialog's CTA). Keeps the same vertical footprint as
  // RLButton.primary so icon-cancel + icon-label rows stay aligned. The
  // glyph renders in the button's text colour (white) so it reads as a
  // single unit with the label. When the action's label is empty the
  // button becomes icon-only — useful for a pure "▶" CTA.
  Widget IconLabelPrimaryButton({
    required RLConfirmationAction action,
    required Color buttonColor,
    required IconData glyph,
    required VoidCallback onTap,
  }) {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: buttonColor,
      borderRadius: RLDS.borderRadiusSmall,
    );

    final Widget GlyphIcon = Icon(glyph, color: RLDS.white, size: RLDS.iconMedium);
    final bool hasLabel = action.label.isNotEmpty;

    final List<Widget> rowChildren = [GlyphIcon];

    if (hasLabel) {
      rowChildren.add(const Spacing.width(RLDS.spacing8));
      rowChildren.add(RLTypography.bodyLarge(action.label, color: RLDS.white));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: dialogButtonPadding,
        decoration: buttonDecoration,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: rowChildren),
      ),
    );
  }

  Widget TertiaryButton({required RLConfirmationAction action}) {
    final Color buttonColor = RLConfirmationDialog.getVariantColor(action.variant);

    return RLButton.tertiary(
      label: action.label,
      color: buttonColor,
      onTap: () => handleTertiaryTap(action),
    );
  }

  void handleTertiaryTap(RLConfirmationAction action) {
    onDismiss();
    action.onTap?.call();
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
