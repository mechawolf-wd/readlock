// Bottom sheet for account settings and management. Rendered as a LunarBlur
// surface without a grabber — content padding is the shared
// RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING from RLBottomSheet, so the
// layout rhythm matches Support / Font picker / any other no-grabber sheet.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLConfirmationDialog.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';

class AccountBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundDark,
      showGrabber: false,
      child: const AccountSheet(),
    );
  }
}

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key});

  static final Widget HeaderIcon = const Icon(
    Pixel.user,
    color: RLDS.info,
    size: RLDS.iconMedium,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderRow(),

          const Spacing.height(RLDS.spacing16),

          AccountActionRow(
            label: RLUIStrings.ACCOUNT_DELETE_LABEL,
            onTap: () => handleDeleteAccountTap(context),
          ),
        ],
      ),
    );
  }

  Widget HeaderRow() {
    return Div.row(
      [
        HeaderIcon,

        const Spacing.width(RLDS.spacing12),

        RLTypography.headingMedium(RLUIStrings.ACCOUNT_TITLE),
      ],
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }

  void handleDeleteAccountTap(BuildContext context) {
    // Mirrors the Sign out dialog — Cancel renders as the filled red CTA on
    // top so the safer default carries the visual weight, and Delete drops
    // to a regular muted tertiary text button below so committing requires
    // a deliberate tap.
    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.ACCOUNT_DELETE_LABEL,
      message: RLUIStrings.ACCOUNT_DELETE_MESSAGE,
      cta: const RLConfirmationAction(
        label: RLUIStrings.CANCEL_LABEL,
        variant: RLConfirmationVariant.destructive,
      ),
      cancel: const RLConfirmationAction(
        label: RLUIStrings.ACCOUNT_DELETE_CONFIRM,
        variant: RLConfirmationVariant.neutral,
      ),
    );
  }
}

// Same row shape as LoginSupportPicker's PickerRow — bodyLarge label +
// chevron, vertical spacing12 padding.
class AccountActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AccountActionRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget ChevronIcon = Icon(
      Pixel.chevronright,
      color: RLDS.textSecondary.withValues(alpha: 0.5),
      size: RLDS.iconMedium,
    );

    return Div.row(
      [
        Expanded(child: RLTypography.bodyLarge(label)),

        ChevronIcon,
      ],
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      onTap: onTap,
    );
  }
}
