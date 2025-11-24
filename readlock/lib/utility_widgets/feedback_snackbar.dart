// Shared utility for showing consistent feedback snackbars across the app
// Provides educational guidance for wrong answers and celebration for correct ones

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/typography.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/app_theme.dart';

// Constants
const String CORRECT_ANSWER_MESSAGE = '+5 Aha';
const String WRONG_ANSWER_TITLE = 'Think again';
const String DEFAULT_WRONG_ANSWER_MESSAGE = 'Consider the key concepts from this section. The correct answer relates to the main principle discussed.';
const Duration CORRECT_ANSWER_DURATION = Duration(seconds: 2);
const Duration WRONG_ANSWER_DURATION = Duration(milliseconds: 3000);
const Duration CUSTOM_FEEDBACK_DURATION = Duration(seconds: 3);

class FeedbackSnackBar {
  static void showCorrectAnswer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Div.row([
          Style.StarIcon,
          const Spacing.width(8),
          Typography.bodyLarge(CORRECT_ANSWER_MESSAGE, color: Colors.white),
        ]),
        backgroundColor: AppTheme.primaryGreen,
        duration: CORRECT_ANSWER_DURATION,
        behavior: SnackBarBehavior.floating,
        shape: Style.snackbarShape,
        margin: Style.snackbarMargin,
      ),
    );
  }

  static void showWrongAnswer(
    BuildContext context, {
    String? explanation,
  }) {
    final String message = WrongAnswerMessage(explanation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Div.column([
          Div.row([
            Style.LightbulbIcon,
            const Spacing.width(8),
            Typography.bodyLarge(
              WRONG_ANSWER_TITLE,
              color: Colors.white,
            ),
          ]),
          const Spacing.height(4),
          Typography.bodyMedium(
            message,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
        backgroundColor: Colors.orange.shade600,
        duration: WRONG_ANSWER_DURATION,
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
        content: Typography.bodyMedium(message, color: Colors.white),
        backgroundColor: CustomFeedbackColor(isCorrect),
        duration: CUSTOM_FEEDBACK_DURATION,
        behavior: SnackBarBehavior.floating,
        shape: Style.snackbarShape,
        margin: Style.snackbarMargin,
      ),
    );
  }

  // Helper methods
  static String WrongAnswerMessage(String? explanation) {

    if (explanation != null) {
      return 'Common thought, though $explanation';
    }

    return DEFAULT_WRONG_ANSWER_MESSAGE;
  }

  static Color CustomFeedbackColor(bool isCorrect) {

    if (isCorrect) {
      return AppTheme.primaryGreen;
    }

    return Colors.orange.shade600;
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
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  static const EdgeInsets snackbarMargin = EdgeInsets.all(16);
}
