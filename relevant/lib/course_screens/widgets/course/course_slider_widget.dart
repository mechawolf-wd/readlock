// Enhanced Course Slider Widget
//
// This file contains an improved CourseSliderWidget with modern card design,
// smooth animations, and better visual hierarchy. Features include enhanced
// spacing, improved navigation, and a more engaging user experience.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/course/course_card_widget.dart';

class CourseSliderWidget extends StatefulWidget {
  final List<Course> courses;
  final Function(Course) onCourseSelected;

  const CourseSliderWidget({
    super.key,
    required this.courses,
    required this.onCourseSelected,
  });

  @override
  State<CourseSliderWidget> createState() => CourseSliderWidgetState();
}

class CourseSliderWidgetState extends State<CourseSliderWidget> {
  late PageController pageController;
  int currentIndex = 0;

  /// @Method: Initialize page controller with viewport fraction
  @override
  void initState() {
    super.initState();
    pageController = PageController(
      viewportFraction: AppConstants.COURSE_SLIDER_VIEWPORT_FRACTION,
      initialPage: currentIndex,
    );
  }

  /// @Method: Clean up page controller
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EnhancedCourseSlider(),

        const SizedBox(height: AppTheme.spacingXL),

        PageIndicators(),
      ],
    );
  }

  /// @Widget: Horizontal scrolling view of course cards with smooth animations
  Widget EnhancedCourseSlider() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: handlePageChanged,
        itemCount: widget.courses.length,
        itemBuilder: (context, courseIndex) {
          final Course course = widget.courses[courseIndex];
          final bool isActive = courseIndex == currentIndex;

          return EnhancedCourseSlideItem(course, isActive);
        },
      ),
    );
  }

  /// @Widget: Row of dots showing current course position in slider
  Widget PageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.courses.length; i++)
          PageIndicatorDot(isActive: i == currentIndex),
      ],
    );
  }

  /// @Widget: Animated dot that changes size and color based on active state
  Widget PageIndicatorDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryDeepPurple : AppTheme.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// @Method: Handle page changes with haptic feedback
  void handlePageChanged(int pageIndex) {
    final bool isNewPage = pageIndex != currentIndex;

    if (isNewPage) {
      triggerHapticFeedback();
      setState(() {
        currentIndex = pageIndex;
      });
    }
  }

  /// @Method: Trigger haptic feedback for iOS
  void triggerHapticFeedback() {
    HapticFeedback.selectionClick();
  }

  /// @Widget: Individual course card with scaling and opacity animations
  Widget EnhancedCourseSlideItem(Course course, bool isActive) {
    final double slideScale = isActive ? 1.0 : 0.9;
    final double slideOpacity = isActive ? 1.0 : 0.7;

    return AnimatedScale(
      scale: slideScale,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: slideOpacity,
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: isActive
                ? AppTheme.elevatedShadow
                : AppTheme.cardShadow,
          ),
          child: CourseCardWidget(
            course: course,
            onTap: () => widget.onCourseSelected(course),
          ),
        ),
      ),
    );
  }
}
