// Course roadmap screen displaying a list of course sections
// Allows navigation to course content and starting the course from the beginning
import 'package:flutter/material.dart';
import 'package:relevant/course_screens/course_detail_screen.dart';
import 'package:relevant/course_screens/data/course_data.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/app_theme.dart';

const String START_BUTTON_TEXT = 'Start';
const String LESSONS_SUFFIX_TEXT = ' lessons';
const String ERROR_LOADING_COURSE_DATA = 'Error loading course data';

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  int currentSectionIndex = 0;
  int currentContentIndex = 0;
  
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
        courseSections = List<Map<String, dynamic>>.from(courseData!['sections'] ?? []);
      }
    } catch (e) {
      print('$ERROR_LOADING_COURSE_DATA: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
      ),
      body: Padding(
        padding: AppTheme.screenPaddingInsets,
        child: Div.column([
          Expanded(
            child: ListView.builder(
              itemCount: courseSections.length,
              itemBuilder: (context, sectionItemIndex) {
                final section = courseSections[sectionItemIndex];
                final content = List<Map<String, dynamic>>.from(section['content'] ?? []);

                return Card(
                  margin: AppTheme.cardMarginInsets,
                  child: ListTile(
                    title: Text(section['title'] ?? ''),
                    subtitle: Text(
                      '${content.length}$LESSONS_SUFFIX_TEXT',
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
          courseId: widget.courseId,
          initialSectionIndex: sectionIndex,
          initialContentIndex: contentIndex,
        ),
      ),
    );
  }
}
