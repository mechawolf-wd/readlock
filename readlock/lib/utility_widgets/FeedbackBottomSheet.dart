// Centralized bottom sheet modals for course feedback
// Provides consistent UI for explanations and hints across the app

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLConstants.dart';

class FeedbackBottomSheets {
  // Icon definitions
  static const Widget ExperienceIcon = Icon(
    Icons.lightbulb,
    color: RLTheme.primaryGreen,
    size: 20,
  );

  static const Widget HintIcon = Icon(
    Icons.tips_and_updates_outlined,
    color: RLTheme.primaryBlue,
    size: 20,
  );

  // Show explanation bottom sheet for correct answers
  static void showExplanation({
    required BuildContext context,
    required String explanation,
  }) {
    showFeedbackSheet(
      context: context,
      title: FEEDBACK_DIALOG_TITLE,
      content: explanation,
      buttonColor: RLTheme.primaryGreen,
      icon: ExperienceIcon,
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
      backgroundColor: RLTheme.backgroundDark.withValues(alpha: 0),
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
  static const BoxDecoration modalDecoration = BoxDecoration(
    color: RLTheme.backgroundLight,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  );

  static const EdgeInsets bodyPadding = EdgeInsets.symmetric(
    horizontal: MODAL_PADDING,
  );

  static const EdgeInsets buttonMargin = EdgeInsets.all(MODAL_PADDING);

  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(
    MODAL_PADDING,
    16,
    MODAL_PADDING,
    MODAL_PADDING,
  );

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
              Div.column([
                const BottomSheetGrabber(),
              ], padding: const EdgeInsets.only(top: 12)),

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

  Widget BodySection() {
    return Padding(
      padding: bodyPadding,
      child: RLTypography.bodyMedium(
        content,
        textAlign: TextAlign.left,
      ),
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
        return RLDesignSystem.BlockButton(
          children: [
            RLTypography.bodyMedium(
              FEEDBACK_GOT_IT_LABEL,
              color: RLTheme.white,
            ),
          ],
          backgroundColor: buttonColor,
          onTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}
