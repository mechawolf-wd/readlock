// Bottom sheet for account settings and management
// Displays user profile information and account actions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLButton.dart';
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
      backgroundColor: RLDS.backgroundLight,
      child: const AccountSheet(),
    );
  }
}

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key});

  // Icon definitions
  static final Widget PersonIcon = const Icon(Pixel.user, color: RLDS.info, size: 20);

  // Style definitions
  static const EdgeInsets headerPadding = EdgeInsets.all(24);

  static const EdgeInsets bodyPadding = EdgeInsets.symmetric(horizontal: 24);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          HeaderSection(),

          // Body content
          BodySection(context),

          // Footer button
          FooterButton(),
        ],
      ),
    );
  }

  Widget HeaderSection() {
    return Div.row([
      PersonIcon,

      const Spacing.width(12),

      RLTypography.headingMedium(RLUIStrings.ACCOUNT_TITLE),
    ], padding: const EdgeInsets.fromLTRB(24, 16, 24, 24));
  }

  Widget BodySection(BuildContext context) {
    return Padding(
      padding: bodyPadding,
      child: Div.column([
        // Account actions — destructive only. Personal data (name / age / email)
        // isn't shown here; account identity lives elsewhere.
        DangerRow(
          label: RLUIStrings.ACCOUNT_DEACTIVATE_LABEL,
          color: RLDS.textSecondary,
          onTap: () => handleDeactivateAccountTap(context),
        ),

        const Spacing.height(12),

        DangerRow(
          label: RLUIStrings.ACCOUNT_DELETE_LABEL,
          color: RLDS.textSecondary,
          onTap: () => handleDeleteAccountTap(context),
        ),
      ]),
    );
  }

  void handleDeactivateAccountTap(BuildContext context) {
    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.ACCOUNT_DEACTIVATE_LABEL,
      message: RLUIStrings.ACCOUNT_DEACTIVATE_MESSAGE,
      cta: RLConfirmationAction(
        label: RLUIStrings.ACCOUNT_DEACTIVATE_CONFIRM,
        variant: RLConfirmationVariant.warning,
        onTap: () {},
      ),
      cancel: rlDismissCancelAction(),
    );
  }

  void handleDeleteAccountTap(BuildContext context) {
    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.ACCOUNT_DELETE_LABEL,
      message: RLUIStrings.ACCOUNT_DELETE_MESSAGE,
      cta: RLConfirmationAction(
        label: RLUIStrings.ACCOUNT_DELETE_CONFIRM,
        variant: RLConfirmationVariant.destructive,
        onTap: () {},
      ),
      cancel: rlDismissCancelAction(),
    );
  }

  void handleDismissTap(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget FooterButton() {
    return Builder(
      builder: (context) {
        return RLButton.primary(
          label: RLUIStrings.ACCOUNT_DONE_LABEL,
          color: RLDS.info,
          margin: const EdgeInsets.all(RLDS.spacing24),
          onTap: () => handleDismissTap(context),
        );
      },
    );
  }
}

class DangerRow extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const DangerRow({super.key, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color textColor = RLDS.warning;

    final bool hasCustomColor = color != null;

    if (hasCustomColor) {
      textColor = color!;
    }

    final Widget ChevronIcon = Icon(
      Pixel.chevronright,
      color: textColor.withValues(alpha: 0.5),
      size: 20,
    );

    return Div.row([
      Expanded(child: RLTypography.bodyMedium(label, color: textColor)),

      ChevronIcon,
    ], onTap: onTap);
  }
}
