// Widget that displays concluding content for course lessons
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/text_animation/TextAnimation.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';

class OutroContentWidget extends StatelessWidget {
  final OutroContent content;

  const OutroContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: AppTheme.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 24,
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

          ProgressiveText(
            textSegments: content.outroTextSegments,
            textStyle: Typography.bodyLargeStyle,
            characterDelay: const Duration(milliseconds: 15),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ],
      ),
    );
  }
}
