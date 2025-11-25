// Home screen with latest courses and user stats
// Features top bar with streak and aha counters

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const String HOME_TITLE = 'Welcome Back';
const String LATEST_COURSES_SECTION_TITLE = 'Latest Courses';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // * -----------------
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
  // * -----------------

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
    // Card decoration
    final cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: RLTheme.primaryGreen.withValues(alpha: 0.2),
        width: 1.5,
      ),
    );

    return Div.column(
      [
        // Course header row
        Div.row([
          // Course info section
          Div.column([
            // Course title
            RLTypography.headingMedium('The Design of Everyday Things'),

            const Spacing.height(8),

            // Course description
            RLTypography.text('Based on Don Norman\'s classic book'),

            const Spacing.height(12),

            // Badge and lessons row
            Div.row([
              // Lessons count
              RLTypography.bodyMedium(
                '6 lessons',
                color: RLTheme.textSecondary,
              ),
            ]),
          ], crossAxisAlignment: CrossAxisAlignment.start),

          const Spacing.width(16),

          // Course icon
          Style.courseIcon,
        ], crossAxisAlignment: CrossAxisAlignment.start),

        const Spacing.height(20),

        // Continue button row
        Div.row([
          const Spacer(),

          // Continue learning button
          Div.row(
            [
              RLTypography.bodyMedium(
                'Continue Learning',
                color: RLTheme.primaryGreen,
              ),

              const Spacing.width(8),

              // Forward arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: RLTheme.primaryGreen,
                size: 14,
              ),
            ],
            padding: const [20, 10],
            decoration: Style.continueButtonDecoration,
          ),
        ]),
      ],
      padding: 24,
      decoration: cardDecoration,
      onTap: navigateToDesignCourse,
    );
  }

  // Navigation methods

  void navigateToDesignCourse() {
    final MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (context) =>
          const CourseRoadmapScreen(courseId: 'design-everyday-things'),
    );

    Navigator.push(context, pageRoute);
  }
}

class Style {
  static final BoxDecoration continueButtonDecoration = BoxDecoration(
    color: RLTheme.primaryGreen.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
  );

  static final Icon courseIcon = const Icon(
    Icons.psychology_outlined,
    color: RLTheme.primaryGreen,
    size: 32,
  );
}
