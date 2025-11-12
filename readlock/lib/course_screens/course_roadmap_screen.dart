// Course roadmap screen displaying a list of course sections
// Allows navigation to course content and starting the course from the beginning
import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/course_detail_screen.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/app_theme.dart';

const String START_BUTTON_TEXT = 'Start';
const String LESSONS_SUFFIX_TEXT = ' lessons';

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
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        actions: [
          TextButton(
            onPressed: startCourse,
            child: const Text(START_BUTTON_TEXT),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Div.column([
          Expanded(
            child: ListView.builder(
              itemCount: widget.course.sections.length,
              itemBuilder: (context, sectionItemIndex) {
                final section =
                    widget.course.sections[sectionItemIndex];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(section.title),
                    subtitle: Text(
                      '${section.content.length}$LESSONS_SUFFIX_TEXT',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => handleNodeTap(sectionItemIndex, 0),
                  ),
                );
              },
            ),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    );
  }

  void handleNodeTap(int sectionIndex, int contentIndex) {
    navigateToCourseContent(sectionIndex, contentIndex);
  }

  void startCourse() {
    navigateToCourseContent(0, 0);
  }

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
