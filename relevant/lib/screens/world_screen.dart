import 'package:flutter/material.dart';
import 'package:relevant/course_screens/data/course_data.dart';
import 'package:relevant/course_screens/widgets/course/course_card_widget.dart';
import 'package:relevant/course_screens/course_roadmap_screen.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => WorldScreenState();
}

class WorldScreenState extends State<WorldScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Div.column([Expanded(child: CoursesSection())]),
    );
  }

  Widget CoursesSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: CourseData.availableCourses.length,
      itemBuilder: (context, index) {
        final course = CourseData.availableCourses[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CourseCardWidget(
            course: course,
            onTap: () => handleCourseSelection(course),
          ),
        );
      },
    );
  }

  void handleCourseSelection(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseRoadmapScreen(course: course),
      ),
    );
  }

  Widget TextSubtitle() {
    return const Text(
      'Explore interactive courses',
      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.0),
      textAlign: TextAlign.center,
    );
  }
}
