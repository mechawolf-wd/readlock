// Home screen with latest courses and user stats
// Features top bar with streak and experience counters

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const String HOME_TITLE = 'Welcome Back';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Div.column([
            // Top stats bar
            const StatisticsTopBar(),

            const Spacing.height(32),

            // Welcome header
            HomeWelcomeHeader(),

            const Spacing.height(24),

            // Latest courses section
            LatestCoursesSection(),

            const Spacing.height(24),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget HomeWelcomeHeader() {
    return Div.column([
      // Main welcome title
      RLTypography.headingLarge(HOME_TITLE),

      const Spacing.height(8),

      // Subtitle text
      RLTypography.text('Continue your learning journey'),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  Widget LatestCoursesSection() {
    final Course featuredCourse = getFeaturedCourse();

    return CourseCard(course: featuredCourse);
  }

  Course getFeaturedCourse() {
    return const Course(
      id: 'design-everyday-things',
      title: 'The Design of Everyday Things',
      description: 'Based on Don Norman\'s classic book',
      coverImagePath: '',
      color: 'green',
      lessons: [],
    );
  }

}
