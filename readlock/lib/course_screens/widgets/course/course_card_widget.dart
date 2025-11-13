import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/app_theme.dart';

class CourseCardWidget extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCardWidget({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Div.column(
        [
          Text(
            course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacing.height(12),

          const LinearProgressIndicator(value: 0.0),
        ],
        padding: AppTheme.cardPaddingInsets,
        decoration: AppTheme.getCardDecoration(),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
