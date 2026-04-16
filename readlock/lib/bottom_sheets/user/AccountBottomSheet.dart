// Bottom sheet for account settings and management
// Displays user profile information and account actions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/bottom_sheets/RLDialog.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

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
  static final Widget PersonIcon = const Icon(Icons.person, color: RLDS.info, size: 20);

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
        // Account info rows
        const InfoRow(label: 'Name', value: 'Alex Johnson'),

        const Spacing.height(16),

        const InfoRow(label: 'Age', value: '28'),

        const Spacing.height(16),

        const InfoRow(label: 'Email', value: 'alex.johnson@email.com'),

        const Spacing.height(24),

        // Divider
        Container(height: 1, color: RLDS.textPrimary.withValues(alpha: 0.1)),

        const Spacing.height(24),

        // Account actions
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
    RLDialog.showConfirm(
      context,
      title: RLUIStrings.ACCOUNT_DEACTIVATE_LABEL,
      message: RLUIStrings.ACCOUNT_DEACTIVATE_MESSAGE,
      confirmLabel: RLUIStrings.ACCOUNT_DEACTIVATE_CONFIRM,
      confirmColor: RLDS.warning,
      onConfirm: () {},
    );
  }

  void handleDeleteAccountTap(BuildContext context) {
    RLDialog.showConfirm(
      context,
      title: RLUIStrings.ACCOUNT_DELETE_LABEL,
      message: RLUIStrings.ACCOUNT_DELETE_MESSAGE,
      confirmLabel: RLUIStrings.ACCOUNT_DELETE_CONFIRM,
      confirmColor: RLDS.error,
      onConfirm: () {},
    );
  }

  void handleDismissTap(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget FooterButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.info,
      borderRadius: BorderRadius.circular(12),
    );

    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () => handleDismissTap(context),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: buttonDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [RLTypography.bodyMedium(RLUIStrings.ACCOUNT_DONE_LABEL)],
            ),
          ),
        );
      },
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Div.row([
      Expanded(
        child: RLTypography.bodyMedium(label, color: RLDS.textPrimary.withValues(alpha: 0.6)),
      ),

      RLTypography.bodyMedium(value),
    ]);
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
      Icons.chevron_right,
      color: textColor.withValues(alpha: 0.5),
      size: 20,
    );

    return Div.row([
      Expanded(child: RLTypography.bodyMedium(label, color: textColor)),

      ChevronIcon,
    ], onTap: onTap);
  }
}
