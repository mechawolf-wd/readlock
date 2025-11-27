// Courses list screen showing available courses
// Clean card-based layout with course selection

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/courseData.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  List<Course> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with stats
            const Padding(
              padding: EdgeInsets.all(24),
              child: StatisticsTopBar(),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Div.row([
                RLTypography.headingLarge('Choose Your Course'),
              ], mainAxisAlignment: MainAxisAlignment.start),
            ),

            const Spacing.height(24),

            // Courses list
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: RLTheme.primaryBlue,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: courses.length,
                  itemBuilder: (context, index) =>
                      CourseCard(course: courses[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> loadCourses() async {
    try {
      final List<Map<String, dynamic>> courseData =
          await CourseDataService.availableCourses;
      final List<Course> loadedCourses = courseData
          .map(
            (data) => Course(
              id: data['id'] ?? '',
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              coverImagePath: data['cover-image-path'] ?? '',
              color: data['color'] ?? 'blue',
              lessons: [], // Lessons loaded separately when needed
            ),
          )
          .toList();

      setState(() {
        courses = loadedCourses;
        isLoading = false;
      });
    } on Exception {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final Color courseColor = getColorFromString(course.color);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        RLTheme.slideUpTransition(
          CourseRoadmapScreen(courseId: course.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: RLTheme.backgroundLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: courseColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Div.column([
          // Course header
          Div.row([
            // Course info
            Expanded(
              child: Div.column([
                RLTypography.headingMedium(course.title),

                const Spacing.height(8),

                RLTypography.text(course.description),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),

            const Spacing.width(16),

            // Course icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: courseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                course.id == 'design-everyday-things'
                    ? Icons.psychology_outlined
                    : Icons.trending_up_outlined,
                color: courseColor,
                size: 24,
              ),
            ),
          ], crossAxisAlignment: CrossAxisAlignment.start),

          const Spacing.height(20),

          // Footer with start button
          Div.row([
            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: courseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: courseColor.withValues(alpha: 0.3),
                ),
              ),
              child: Div.row([
                RLTypography.text('Start Course'),

                const Spacing.width(8),

                Icon(
                  Icons.arrow_forward_ios,
                  color: courseColor,
                  size: 12,
                ),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Color getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return RLTheme.primaryGreen;
      case 'purple':
        return Colors.purple;
      case 'blue':
        return RLTheme.primaryBlue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return RLTheme.primaryBlue;
    }
  }
}
