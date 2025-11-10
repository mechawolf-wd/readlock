import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
