// Courses screen — fetches /courses from Firestore and lists every course.

import 'package:flutter/material.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  JSONList availableCourses = [];
  bool isCoursesLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableCourses();
  }

  Future<void> fetchAvailableCourses() async {
    try {
      final JSONList courses = await CourseDataService.fetchAvailableCourses();

      if (!mounted) {
        return;
      }

      setState(() {
        availableCourses = courses;
        isCoursesLoading = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        isCoursesLoading = false;
      });
    }
  }

  void navigateToCourse(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseRoadmapScreen(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CoursesBody(),
      ),
    );
  }

  Widget CoursesBody() {
    if (isCoursesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool hasNoCourses = availableCourses.isEmpty;

    if (hasNoCourses) {
      return Center(
        child: Text(
          RLUIStrings.NO_COURSES_MESSAGE,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Div.column(
        CourseCards(),
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  List<Widget> CourseCards() {
    return availableCourses.map((course) {
      final String courseTitle = course['title'] as String? ?? '';
      final String courseAuthor = course['author'] as String? ?? '';
      final String? coverImagePath = course['cover-image-path'] as String?;
      final String courseId = course['course-id'] as String? ?? '';

      return BookListCard(
        title: courseTitle,
        author: courseAuthor,
        coverImagePath: coverImagePath,
        onTap: () => navigateToCourse(courseId),
      );
    }).toList();
  }
}
