// Shared utility for showing consistent feedback snackbars across the app
// Provides educational guidance for wrong answers and celebration for correct ones

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';
import 'package:readlock/utility_widgets/FeedbackBottomSheet.dart';
import 'package:readlock/utility_widgets/Utility.dart';

// Constants
const String CORRECT_ANSWER_MESSAGE = '+5 Aha';
const String WRONG_ANSWER_TITLE = 'Think again';
const Duration CORRECT_ANSWER_DURATION = Duration(
  days: 365,
); // Effectively indefinite
const Duration WRONG_ANSWER_DURATION = Duration(milliseconds: 3000);
const Duration CUSTOM_FEEDBACK_DURATION = Duration(seconds: 3);

class FeedbackSnackBar {
  static void showCorrectAnswer(
    BuildContext context, {
    String? explanation,
  }) {
    final bool hasExplanation =
        explanation != null && explanation.isNotEmpty;
    // Keep snackbar visible indefinitely for correct answers
    final Duration snackbarDuration = CORRECT_ANSWER_DURATION;

    // Extract button press handler
    void handleExplanationButtonPress() {
      // Dismiss snackbar first
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show explanation bottom sheet
      if (explanation != null) {
        FeedbackBottomSheets.showAhaExplanation(
          context: context,
          explanation: explanation,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Style.StarIcon,

            const Spacing.width(8),

            RLTypography.bodyLarge(
              CORRECT_ANSWER_MESSAGE,
              color: Colors.white,
            ),

            // Show "Why?" button if explanation is available
            RenderIf.condition(
              hasExplanation,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: handleExplanationButtonPress,
                      child: Text(
                        'Why?',
                        style: RLTypography.bodyMediumStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: RLTheme.primaryGreen.withValues(alpha: 0.85),
        duration: snackbarDuration,
        behavior: SnackBarBehavior.floating,
        shape: Style.snackbarShape,
        margin: Style.snackbarMargin,
      ),
    );
  }

  static void showWrongAnswer(BuildContext context, {String? hint}) {
    final bool hasHint = hint != null && hint.isNotEmpty;
    final Duration snackbarDuration = hasHint
        ? const Duration(seconds: 5)
        : WRONG_ANSWER_DURATION;

    // Extract button press handler
    void handleHintButtonPress() {
      // Dismiss snackbar first
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show hint bottom sheet
      if (hint != null) {
        FeedbackBottomSheets.showHint(context: context, hint: hint);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Style.LightbulbIcon,

            const Spacing.width(8),

            RLTypography.bodyLarge(
              WRONG_ANSWER_TITLE,
              color: Colors.white,
            ),

            // Show "Hint" button if hint is available
            RenderIf.condition(
              hasHint,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: handleHintButtonPress,
                      child: Text(
                        'Hint',
                        style: RLTypography.bodyMediumStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: snackbarDuration,
        behavior: SnackBarBehavior.floating,
        shape: Style.snackbarShape,
        margin: Style.snackbarMargin,
      ),
    );
  }

  static void showCustomFeedback(
    BuildContext context,
    String message,
    bool isCorrect,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: RLTypography.bodyMedium(message, color: Colors.white),
        backgroundColor: CustomFeedbackColor(isCorrect),
        duration: CUSTOM_FEEDBACK_DURATION,
        behavior: SnackBarBehavior.floating,
        shape: Style.snackbarShape,
        margin: Style.snackbarMargin,
      ),
    );
  }

  // Helper methods
  static Color CustomFeedbackColor(bool isCorrect) {
    final Color feedbackColor = isCorrect
        ? RLTheme.primaryGreen
        : Colors.orange.shade600;

    return feedbackColor;
  }
}

class Style {
  static const Icon StarIcon = Icon(
    Icons.star,
    color: Colors.white,
    size: 16,
  );

  static const Icon LightbulbIcon = Icon(
    Icons.lightbulb_outline,
    color: Colors.white,
    size: 16,
  );

  static final RoundedRectangleBorder snackbarShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

  static const EdgeInsets snackbarMargin = EdgeInsets.all(16);
}
