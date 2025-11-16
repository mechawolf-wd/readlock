// Widget that displays reflective prompts for deeper thinking
// Encourages users to pause and think about design concepts

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
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
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
      child: Center(
        child: Div.column(
          [
            ReflectionPrompt(),

            const Spacing.height(24),

            ThinkingPointsSection(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget ReflectionPrompt() {
    return ProgressiveText(
      textSegments: [content.prompt],
      textStyle: Typography.bodyLargeStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }

  Widget ThinkingPointsSection() {
    return Div.column([
      Text(
        'Think about:',
        style: Typography.bodyLargeStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: AppTheme.textPrimary.withValues(alpha: 0.7),
        ),
      ),

      const Spacing.height(12),

      ...content.thinkingPoints.map(
        (point) => ThinkingPointItem(point: point),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ThinkingPointItem({required String point}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Div.row([
        Text(
          '•',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 14,
            color: AppTheme.textPrimary.withValues(alpha: 0.5),
          ),
        ),

        const Spacing.width(8),

        Expanded(
          child: Text(
            point,
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }
}
