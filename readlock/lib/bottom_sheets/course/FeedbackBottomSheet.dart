// Centralized bottom sheet modals for course feedback
// Provides consistent UI for explanations and hints across the app

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
class FeedbackBottomSheets {
  // Show explanation bottom sheet for correct answers
  static void showExplanation({required BuildContext context, required String explanation}) {
    showFeedbackSheet(
      context: context,
      content: explanation,
      buttonColor: RLDS.success,
    );
  }

  // Show hint bottom sheet for wrong answers
  static void showHint({required BuildContext context, required String hint}) {
    showFeedbackSheet(
      context: context,
      content: hint,
      buttonColor: RLDS.info,
    );
  }

  // Generic bottom sheet implementation
  static void showFeedbackSheet({
    required BuildContext context,
    required String content,
    required Color buttonColor,
  }) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      showGrabber: false,
      applyBackdropBlur: true,
      child: FeedbackSheet(
        content: content,
        buttonColor: buttonColor,
      ),
    );
  }
}

class FeedbackSheet extends StatelessWidget {
  final String content;
  final Color buttonColor;

  const FeedbackSheet({
    super.key,
    required this.content,
    required this.buttonColor,
  });

  // Style definitions
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(
    RLDS.spacing24,
    RLDS.spacing24,
    RLDS.spacing24,
    0,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RLDS.spacing16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BodySection(),

          FooterButton(),
        ],
      ),
    );
  }

  Widget BodySection() {
    return Padding(
      padding: bodyPadding,
      child: RLTypography.readingLarge(content, textAlign: TextAlign.left),
    );
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
