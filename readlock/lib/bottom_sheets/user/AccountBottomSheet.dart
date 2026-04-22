// Bottom sheet for account settings and management.
// Uses the same layout rhythm as the Support picker: fromLTRB(24,16,24,24)
// outer padding, icon + 12px gap + headingMedium title, spacing16 to the
// list of rows. Rendered as a LunarBlur surface.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLConfirmationDialog.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';

// Matches LoginSupportLayout.SUPPORT_SHEET_PADDING so the Account sheet
// reads as the same family as the Support sheets.
const EdgeInsets ACCOUNT_SHEET_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing16,
  RLDS.spacing24,
  RLDS.spacing24,
);

class AccountBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundDark,
      showGrabber: false,
      useLunarBlurSurface: true,
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
      padding: ACCOUNT_SHEET_PADDING,
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
    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.ACCOUNT_DELETE_LABEL,
      message: RLUIStrings.ACCOUNT_DELETE_MESSAGE,
      // CTA = Delete in neutral colour (filled primary on top).
      // Cancel = red, rendered as the tertiary text button below.
      cta: const RLConfirmationAction(
        label: RLUIStrings.ACCOUNT_DELETE_CONFIRM,
        variant: RLConfirmationVariant.neutral,
      ),
      cancel: const RLConfirmationAction(
        label: RLUIStrings.CANCEL_LABEL,
        variant: RLConfirmationVariant.destructive,
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
