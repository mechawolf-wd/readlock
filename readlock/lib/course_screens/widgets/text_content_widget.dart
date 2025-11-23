import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';

class TextContentWidget extends StatelessWidget {
  final TextContent content;

  const TextContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
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
