// Widget that displays introductory content for course sections
import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';

class IntroContentWidget extends StatelessWidget {
  final IntroContent content;

  const IntroContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Div.column(
        [
          Typography.headingMedium(content.title),

          const Spacing.height(16),

          ProgressiveText(
            textSegments: content.introTextSegments,
            textStyle: Typography.bodyMediumStyle,
            characterDelay: const Duration(milliseconds: 15),
          ),
        ],
        padding: Constants.COURSE_SECTION_PADDING,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
