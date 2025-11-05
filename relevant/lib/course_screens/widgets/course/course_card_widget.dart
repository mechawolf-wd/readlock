import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';

/// @Class: Course card widget for displaying course information and progress
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Stack(
            children: [
              backgroundGradient(),

              courseContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// @Widget: Decorative gradient background matching course theme colors
  Widget backgroundGradient() {
    final ColorScheme colors = getColorScheme();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: AppTheme.alphaDark),
            colors.secondary.withValues(alpha: AppTheme.alphaOpaque),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// @Widget: Main content area containing title, description and progress
  Widget courseContent() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          courseTitle(),

          const SizedBox(height: AppTheme.spacingS),

          courseDescription(),

          const Spacer(),

          progressIndicator(),
        ],
      ),
    );
  }

  /// @Widget: Large, bold text displaying the course name
  Widget courseTitle() {
    return Text(
      course.title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// @Widget: Brief descriptive text explaining the course content
  Widget courseDescription() {
    return Text(
      course.description,
      style: TextStyle(
        color: AppTheme.whiteOpaque,
        fontSize: 15,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// @Widget: Linear progress bar showing course completion percentage
  Widget progressIndicator() {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: 0.0,
            backgroundColor: AppTheme.whiteHeavy,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.textPrimary,
            ),
          ),
        ),

        const SizedBox(width: AppTheme.spacingS),

        const Text(
          AppConstants.PROGRESS_PERCENTAGE,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// @Method: Gets color scheme based on course color
  ColorScheme getColorScheme() {
    return AppTheme.getCourseColorScheme(course.color);
  }
}
