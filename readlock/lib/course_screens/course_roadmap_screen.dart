// Course roadmap screen displaying a simple list of course sections
// Clean card-based layout showing course information
import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/course_screens/course_detail_screen.dart';
import 'package:relevant/course_screens/data/course_data.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  Map<String, dynamic>? courseData;
  List<Map<String, dynamic>> courseSections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourseData();
  }

  Future<void> loadCourseData() async {
    try {
      courseData = await CourseData.getCourseById(widget.courseId);

      if (courseData != null) {
        courseSections = List<Map<String, dynamic>>.from(
          courseData!['sections'] ?? [],
        );
      }
    } catch (error) {
      // Handle error silently
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.grey[900],
      child: SafeArea(
        child: Div.column([
          const Spacing.height(32),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: courseSections.length,
              itemBuilder: (context, sectionIndex) {
                final section = courseSections[sectionIndex];
                final contentList = List<Map<String, dynamic>>.from(
                  section['content'] ?? [],
                );

                return SectionCard(
                  section: section,
                  contentCount: contentList.length,
                  onTap: () => navigateToCourseContent(sectionIndex, 0),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  void navigateToCourseContent(int sectionIndex, int contentIndex) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          courseId: widget.courseId,
          initialSectionIndex: sectionIndex,
          initialContentIndex: contentIndex,
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Map<String, dynamic> section;
  final int contentCount;
  final VoidCallback onTap;

  const SectionCard({
    super.key,
    required this.section,
    required this.contentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Div.row([
          Expanded(
            child: Div.column([
              Typography.headingMedium(section['title'] ?? ''),

              const Spacing.height(8),

              Typography.bodyMedium('$contentCount lessons'),
            ], crossAxisAlignment: 'start'),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 20,
          ),
        ]),
      ),
    );
  }
}
