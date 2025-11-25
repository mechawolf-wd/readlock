// Widget that displays introductory content for course lessons
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/constants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';

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
        padding: RLConstants.COURSE_SECTION_PADDING,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
