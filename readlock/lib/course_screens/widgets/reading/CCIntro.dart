// Widget that displays introductory content for course lessons
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

class CCIntro extends StatelessWidget {
  final IntroContent content;

  const CCIntro({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      child: Div.column(
        [
          ProgressiveText(
            textSegments: content.introTextSegments,
            textStyle: RLTypography.bodyMediumStyle,
          ),
        ],
        padding: 24,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
