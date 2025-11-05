/// Screen that displays the main world view with course discovery and exploration features
library;

import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/course_screens/data/course_data.dart';
import 'package:relevant/course_screens/widgets/course/course_slider_widget.dart';
import 'package:relevant/course_screens/course_roadmap_screen.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

/// @Class: Main world screen for course discovery and exploration
class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => WorldScreenState();
}

class WorldScreenState extends State<WorldScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Body());
  }

  /// @Widget: Main content layout with welcome section and course listings
  Widget Body() {
    return Div([
      WelcomeSection(),

      const SizedBox(height: AppConstants.WELCOME_COURSES_SPACING),

      Expanded(child: coursesSection()),
    ]);
  }

  /// @Widget: Hero section with app introduction and title text
  Widget WelcomeSection() {
    return Div(
      margin: AppTheme.spacingL,
      padding: AppTheme.spacingXXL,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primaryDeepPurpleLight),
      ),
      [
        Div([
          titleText(),

          const SizedBox(height: AppTheme.spacingL),

          subtitleText(),
        ]),
      ],
    );
  }

  /// @Widget: Interactive course slider for browsing available courses
  Widget coursesSection() {
    return CourseSliderWidget(
      courses: CourseData.availableCourses,
      onCourseSelected: handleCourseSelection,
    );
  }

  /// @Method: Handles course selection and navigates to course roadmap
  void handleCourseSelection(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseRoadmapScreen(course: course),
      ),
    );
  }

  /// @Widget: Large heading text displaying the main app title
  Widget titleText() {
    return const Div(
      [
        Icon(
          Icons.explore,
          color: AppTheme.primaryDeepPurple,
          size: 32,
        ),

        SizedBox(width: AppTheme.spacingM),

        Text(
          AppConstants.DISCOVER_KNOWLEDGE_TITLE,
          style: TextStyle(
            fontSize: AppConstants.TITLE_FONT_SIZE,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDeepPurple,
            letterSpacing: 0.5,
          ),
        ),
      ],
      direction: 'horizontal',
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  /// @Widget: Descriptive text explaining the app's purpose and value
  Widget subtitleText() {
    return Text(
      AppConstants.COURSES_SUBTITLE,
      style: TextStyle(
        fontSize: AppConstants.SUBTITLE_FONT_SIZE,
        color: AppTheme.grey600,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}
