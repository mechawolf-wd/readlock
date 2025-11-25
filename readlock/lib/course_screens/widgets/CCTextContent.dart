import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';

class TextContentWidget extends StatelessWidget {
  final TextContent content;

  const TextContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: AppTheme.contentPaddingInsets,
      child: ProgressiveText(
        textSegments: content.textSegments,
        textStyle: Typography.bodyMediumStyle,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
