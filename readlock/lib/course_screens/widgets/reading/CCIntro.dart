// Lesson intro slide that sets the stage for what the reader is about to learn
// Shows the lesson title and introductory text with progressive reveal animation
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class CCIntro extends StatelessWidget {
  final IntroContent content;

  const CCIntro({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLDS.backgroundDark,
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
