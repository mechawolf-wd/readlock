import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
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
        title: Text(widget.course.title),
        actions: [
          TextButton(
            onPressed: startCourse,
            child: const Text('Start'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.description,
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Sections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: widget.course.sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = widget.course.sections[sectionIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(section.title),
                      subtitle: Text('${section.content.length} lessons'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => handleNodeTap(sectionIndex, 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
