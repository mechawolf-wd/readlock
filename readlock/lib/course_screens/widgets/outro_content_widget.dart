// Widget that displays concluding content for course sections
import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/text_animation/text_animation.dart';
import 'package:relevant/constants/app_theme.dart';

class OutroContentWidget extends StatelessWidget {
  final OutroContent content;

  const OutroContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Typography.headingMedium(content.title),

              const Spacing.height(16),

              ProgressiveText(
                textSegments: content.outroTextSegments,
                textStyle: Typography.bodyMediumStyle,
                characterDelay: const Duration(milliseconds: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}