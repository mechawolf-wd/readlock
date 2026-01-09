// Simple retention motivation bottom sheet
// Designed to improve lesson completion rates through motivational messaging

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/Utility.dart';

// String constants for retention messaging
const String RETENTION_MODAL_TITLE = 'Quick Completion';
const String RETENTION_MODAL_SUBTITLE = 'You\'re almost there!';
const String RETENTION_MODAL_MESSAGE =
    'You will be able to finish this lesson in 1 day. Completing lessons consistently helps build strong learning habits and improves knowledge retention.';
const String RETENTION_MODAL_BUTTON = 'Start Assessment';

// Layout constants
const double MODAL_PADDING = 24.0;
const double CONTENT_SPACING = 20.0;
const double BORDER_RADIUS = 20.0;

class CCRetentionBottomSheet extends StatelessWidget {
  final VoidCallback onStartAssessment;

  const CCRetentionBottomSheet({
    super.key,
    required this.onStartAssessment,
  });

  // Style definitions
  BoxDecoration get modalDecoration => const BoxDecoration(
    color: RLTheme.backgroundLight,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(BORDER_RADIUS),
      topRight: Radius.circular(BORDER_RADIUS),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  );

  EdgeInsets get bodyPadding =>
      const EdgeInsets.symmetric(horizontal: MODAL_PADDING);
  EdgeInsets get headerPadding => const EdgeInsets.all(MODAL_PADDING);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: modalDecoration,
        padding: const EdgeInsets.only(bottom: 16),
        child: Wrap(
          children: [
            Div.column([
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
    );
  }

  // Header section with simple icon
  Widget HeaderSection() {
    return Div.column([
      // Simple timer icon
      SimpleIcon(),

      const Spacing.height(CONTENT_SPACING),

      // Title and subtitle
      TitleSection(),
    ], padding: headerPadding);
  }

  // Simple timer icon
  Widget SimpleIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: RLTheme.primaryGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.timer_outlined,
        size: 40,
        color: RLTheme.primaryGreen,
      ),
    );
  }

  // Title and subtitle section
  Widget TitleSection() {
    return Div.column([
      RLTypography.headingLarge(
        RETENTION_MODAL_TITLE,
        textAlign: TextAlign.center,
        color: RLTheme.primaryGreen,
      ),

      const Spacing.height(8),

      RLTypography.bodyMedium(
        RETENTION_MODAL_SUBTITLE,
        textAlign: TextAlign.center,
        color: RLTheme.textSecondary,
      ),
    ]);
  }

  // Body content with motivational message
  Widget BodySection() {
    return Padding(
      padding: bodyPadding,
      child: RLTypography.bodyMedium(
        RETENTION_MODAL_MESSAGE,
        textAlign: TextAlign.center,
        color: RLTheme.textPrimary,
      ),
    );
  }

  // Simple footer button
  Widget FooterButton() {
    return Container(
      margin: const EdgeInsets.all(MODAL_PADDING),
      child: RLDesignSystem.BlockButton(
        children: [
          RLTypography.bodyMedium(
            RETENTION_MODAL_BUTTON,
            color: Colors.white,
          ),
        ],
        backgroundColor: RLTheme.primaryGreen,
        onTap: onStartAssessment,
      ),
    );
  }
}
