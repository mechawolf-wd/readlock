// Shared utility for showing consistent feedback snackbars across the app
// Provides educational guidance for wrong answers and celebration for correct ones

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/typography.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';

class FeedbackSnackBar {
  static void showCorrectAnswer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 16),
            const Spacing.width(8),
            Typography.bodyLarge('+5 Aha', color: Colors.white),
          ],
        ),``
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showWrongAnswer(
    BuildContext context, {
    String? explanation,
  }) {
    final String message = explanation != null
        ? 'Common thought, though $explanation'
        : 'Consider the key concepts from this section. The correct answer relates to the main principle discussed.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const Spacing.width(8),
                Typography.bodyLarge(
                  'Think again',
                  color: Colors.white,
                ),
              ],
            ),
            const Spacing.height(4),
            Typography.bodyMedium(
              message,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
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
        backgroundColor: isCorrect
            ? Colors.green.shade600
            : Colors.orange.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
