// Widget that displays reflective prompts for deeper thinking
import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';

class ReflectionContentWidget extends StatelessWidget {
  final ReflectionContent content;

  const ReflectionContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with emoji and title
          Row(
            children: [
              Text(
                content.emoji ?? '💭',
                style: const TextStyle(fontSize: 24),
              ),

              const Spacing.width(12),

              Expanded(
                child: Text(
                  content.title,
                  style: Typography.bodyLargeStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),

          const Spacing.height(20),

          // Main prompt
          ProgressiveText(
            textSegments: [content.prompt],
            textStyle: Typography.bodyLargeStyle,
            characterDelay: const Duration(milliseconds: 15),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),

          const Spacing.height(24),

          // Thinking points
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Think about:',
                  style: Typography.bodyLargeStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryBlue,
                  ),
                ),

                const Spacing.height(12),

                ...content.thinkingPoints.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: Typography.bodyMediumStyle.copyWith(
                            color: AppTheme.primaryBlue,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: Typography.bodyMediumStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacing.height(20),

          // Encouragement text
          Center(
            child: Text(
              'Take a moment to reflect...',
              style: Typography.bodyMediumStyle.copyWith(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}