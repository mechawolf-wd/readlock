import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/layout/course_roadmap_widget.dart';
import 'package:relevant/course_screens/course_detail_screen.dart';

class CourseRoadmapScreen extends StatefulWidget {
  final Course course;

  const CourseRoadmapScreen({super.key, required this.course});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  int currentSectionIndex = 0;
  int currentContentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.COURSE_OVERVIEW),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.primaryDeepPurple,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: startCourse,
            child: const Text(AppConstants.START_BUTTON_TEXT),
          ),
        ],
      ),
      body: CourseRoadmapWidget(
        course: widget.course,
        currentSectionIndex: currentSectionIndex,
        currentContentIndex: currentContentIndex,
        onNodeTap: handleNodeTap,
      ),
    );
  }

  /// @Method: Handle tapping on a roadmap node
  void handleNodeTap(int sectionIndex, int contentIndex) {
    navigateToCourseContent(sectionIndex, contentIndex);
  }

  /// @Method: Start the course from the beginning
  void startCourse() {
    navigateToCourseContent(0, 0);
  }

  /// @Method: Navigate to specific course content
  void navigateToCourseContent(int sectionIndex, int contentIndex) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          course: widget.course,
          initialSectionIndex: sectionIndex,
          initialContentIndex: contentIndex,
        ),
      ),
    );
  }
}
