// Bottom sheet for account settings and management
// Displays user profile information and account actions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLConstants.dart';

class AccountBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RLTheme.backgroundDark.withValues(alpha: 0),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const AccountSheet();
      },
    );
  }
}

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key});

  // Icon definitions
  static const Widget PersonIcon = Icon(Icons.person, color: RLTheme.primaryBlue, size: 20);

  // Style definitions
  static const BoxDecoration modalDecoration = BoxDecoration(
    color: RLTheme.backgroundLight,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  );

  static const EdgeInsets headerPadding = EdgeInsets.all(MODAL_PADDING);

  static const EdgeInsets bodyPadding = EdgeInsets.symmetric(horizontal: MODAL_PADDING);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: modalDecoration,
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            children: [
              Div.column([
                // Drag handle
                const Div.column([BottomSheetGrabber()], padding: EdgeInsets.only(top: 12)),

                // Header section
                HeaderSection(),

                // Body content
                BodySection(),

                // Footer button
                FooterButton(),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget HeaderSection() {
    return Div.row([
      PersonIcon,

      const Spacing.width(12),

      RLTypography.headingMedium(ACCOUNT_TITLE),
    ], padding: const EdgeInsets.fromLTRB(MODAL_PADDING, 16, MODAL_PADDING, MODAL_PADDING));
  }

  Widget BodySection() {
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
        Container(height: 1, color: RLTheme.textPrimary.withValues(alpha: 0.1)),

        const Spacing.height(24),

        // Account actions
        DangerRow(label: 'Deactivate Account', color: RLTheme.textSecondary, onTap: () {}),

        const Spacing.height(12),

        DangerRow(label: 'Delete Account', color: RLTheme.textSecondary, onTap: () {}),
      ]),
    );
  }

  Widget FooterButton() {
    return Builder(
      builder: (context) {
        return RLDS.BlockButton(
          children: [RLTypography.bodyMedium(ACCOUNT_DONE_LABEL, color: RLTheme.white)],
          backgroundColor: RLTheme.primaryBlue,
          onTap: () => Navigator.of(context).pop(),
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
        child: RLTypography.bodyMedium(
          label,
          color: RLTheme.textPrimary.withValues(alpha: 0.6),
        ),
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
    final Color textColor = color ?? RLTheme.warningColor;

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
