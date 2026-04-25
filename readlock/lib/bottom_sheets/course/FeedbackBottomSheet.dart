// Centralized bottom sheet modals for course feedback
// Provides consistent UI for explanations and hints across the app

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLUtility.dart';
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

  // Generic bottom sheet implementation — LunarBlur over `backgroundLight` to
  // match the LoginSupport / Account sheets, so the Why?/Hint/Consequence
  // sheets read as the same frosted pane family as the snackbar that opens
  // them.
  static void showFeedbackSheet({
    required BuildContext context,
    required String content,
    required Color buttonColor,
  }) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      showGrabber: false,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BodySection(),

        const Spacing.height(RLDS.spacing24),

        FooterButton(),
      ],
    );
  }

  Widget BodySection() {
    return Padding(
      padding: bodyPadding,
      child: RLTypography.readingLarge(content, textAlign: TextAlign.left),
    );
  }

  // Tertiary footer — transparent background, just the coloured label.
  // The reader doesn't need a filled CTA to know what to tap; the body
  // text is the focus, the dismiss action sits quietly underneath.
  Widget FooterButton() {
    return Builder(
      builder: (context) {
        return RLButton.tertiary(
          label: RLUIStrings.FEEDBACK_GOT_IT_LABEL,
          color: buttonColor,
          margin: RL_BOTTOM_SHEET_FOOTER_BUTTON_MARGIN,
          onTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}
