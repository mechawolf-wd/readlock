// Centralized bottom sheet modals for course feedback
// Provides consistent UI for explanations and hints across the app

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

const String AHA_DIALOG_TITLE = 'Explanation';
const String HINT_DIALOG_TITLE = 'Hint';
const String CLOSE_BUTTON_LABEL = 'Got it';
const double MODAL_PADDING = 24.0;
const double BORDER_RADIUS = 12.0;

class FeedbackBottomSheets {
  // Icon definitions
  static const Widget AhaIcon = Icon(
    Icons.lightbulb,
    color: RLTheme.primaryGreen,
    size: 20,
  );

  static const Widget HintIcon = Icon(
    Icons.tips_and_updates_outlined,
    color: RLTheme.primaryBlue,
    size: 20,
  );

  // Show Aha explanation bottom sheet for correct answers
  static void showAhaExplanation({
    required BuildContext context,
    required String explanation,
  }) {
    showFeedbackSheet(
      context: context,
      title: AHA_DIALOG_TITLE,
      content: explanation,
      buttonColor: RLTheme.primaryGreen,
      icon: AhaIcon,
    );
  }

  // Show hint bottom sheet for wrong answers
  static void showHint({
    required BuildContext context,
    required String hint,
  }) {
    showFeedbackSheet(
      context: context,
      title: HINT_DIALOG_TITLE,
      content: hint,
      buttonColor: RLTheme.primaryBlue,
      icon: HintIcon,
    );
  }

  // Generic bottom sheet implementation
  static void showFeedbackSheet({
    required BuildContext context,
    required String title,
    required String content,
    required Color buttonColor,
    required Widget icon,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FeedbackSheet(
          title: title,
          content: content,
          buttonColor: buttonColor,
          icon: icon,
        );
      },
    );
  }
}

class FeedbackSheet extends StatelessWidget {
  final String title;
  final String content;
  final Color buttonColor;
  final Widget icon;

  const FeedbackSheet({
    super.key,
    required this.title,
    required this.content,
    required this.buttonColor,
    required this.icon,
  });

  // Style definitions
  BoxDecoration get modalDecoration => const BoxDecoration(
    color: RLTheme.backgroundLight,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  );

  EdgeInsets get bodyPadding =>
      const EdgeInsets.symmetric(horizontal: MODAL_PADDING);

  BoxDecoration get buttonDecoration => BoxDecoration(
    color: buttonColor,
    borderRadius: BorderRadius.circular(BORDER_RADIUS),
  );

  EdgeInsets get buttonMargin => const EdgeInsets.all(MODAL_PADDING);

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

  Widget BodySection() {
    return Padding(
      padding: bodyPadding,
      child: RLTypography.bodyMedium(content, textAlign: TextAlign.left),
    );
  }

  Widget HeaderSection() {
    return Div.column([
      // Title row with icon
      TitleRow(),
    ], padding: headerPadding);
  }

  Widget TitleRow() {
    return Div.row([
      icon,

      const Spacing.width(12),

      RLTypography.headingMedium(title),
    ]);
  }

  Widget FooterButton() {
    return Builder(
      builder: (context) {
        // Extract navigation handler
        void handleCloseButtonTap() {
          Navigator.of(context).pop();
        }

        return RLDesignSystem.BlockButton(
          children: [
            RLTypography.bodyMedium(
              CLOSE_BUTTON_LABEL,
              color: Colors.white,
            ),
          ],
          backgroundColor: buttonColor,
          onTap: handleCloseButtonTap,
        );
      },
    );
  }
}
