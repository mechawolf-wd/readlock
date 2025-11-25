import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

class CCTextContent extends StatelessWidget {
  final TextContent content;

  const CCTextContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: RLTheme.contentPaddingInsets,
      child: ProgressiveText(
        textSegments: content.textSegments,
        textStyle: RLTypography.bodyMediumStyle,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
