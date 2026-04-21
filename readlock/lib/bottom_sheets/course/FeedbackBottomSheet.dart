// Centralized bottom sheet modals for course feedback
// Provides consistent UI for explanations and hints across the app

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';
class FeedbackBottomSheets {
  // Icon definitions
  static final Widget ExperienceIcon = const Icon(
    Pixel.infobox,
    color: RLDS.success,
    size: 20,
  );

  static final Widget HintIcon = const Icon(
    Pixel.infobox,
    color: RLDS.info,
    size: 20,
  );

  // Show explanation bottom sheet for correct answers
  static void showExplanation({required BuildContext context, required String explanation}) {
    showFeedbackSheet(
      context: context,
      title: RLUIStrings.FEEDBACK_DIALOG_TITLE,
      content: explanation,
      buttonColor: RLDS.success,
      icon: ExperienceIcon,
    );
  }

  // Show hint bottom sheet for wrong answers
  static void showHint({required BuildContext context, required String hint}) {
    showFeedbackSheet(
      context: context,
      title: RLUIStrings.HINT_DIALOG_TITLE,
      content: hint,
      buttonColor: RLDS.info,
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
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      child: FeedbackSheet(
        title: title,
        content: content,
        buttonColor: buttonColor,
        icon: icon,
      ),
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
  static const EdgeInsets bodyPadding = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets buttonMargin = EdgeInsets.all(24);

  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 16, 24, 24);

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
          BodySection(),

          // Footer button
          FooterButton(),
        ],
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
    return Div.row([icon, const Spacing.width(12), RLTypography.headingMedium(title)]);
  }

  Widget FooterButton() {
    return Builder(
      builder: (context) {
        return RLButton.primary(
          label: RLUIStrings.FEEDBACK_GOT_IT_LABEL,
          color: buttonColor,
          margin: const EdgeInsets.all(RLDS.spacing24),
          onTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}
