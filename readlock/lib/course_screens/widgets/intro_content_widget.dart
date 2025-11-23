// Widget that displays introductory content for course sections
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';

class IntroContentWidget extends StatelessWidget {
  final IntroContent content;

  const IntroContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Div.column(
        [
          ProgressiveText(
            textSegments: content.introTextSegments,
            textStyle: Typography.bodyMediumStyle,
          ),
        ],
        padding: Constants.COURSE_SECTION_PADDING,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
