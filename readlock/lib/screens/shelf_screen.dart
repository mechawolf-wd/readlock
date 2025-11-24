// Home screen with latest courses and user stats
// Features top bar with streak and aha counters

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/course_roadmap_screen.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';

const String HOME_TITLE = 'Welcome Back';
const String LATEST_COURSES_SECTION_TITLE = 'Latest Courses';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => ShelfScreenState();
}

class ShelfScreenState extends State<ShelfScreen> {
  @override
  Widget build(BuildContext context) {
    return Div.column([
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Div.column([
            // Top stats bar
            const StatsBar(),

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
    ], 
    color: AppTheme.backgroundDark);
  }

  Widget HomeWelcomeHeader() {
    return Div.column([
      // Main welcome title
      Typography.headingLarge(HOME_TITLE),

      const Spacing.height(8),

      // Subtitle text
      Typography.text('Continue your learning journey'),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget LatestCoursesSection() {
    return LatestCourseCard();
  }

  Widget LatestCourseCard() {
    return Div.column([
      // Course header row
      Div.row([
        // Course info section
        Expanded(
          child: Div.column([
            // Course title
            Typography.headingMedium(
              'The Design of Everyday Things',
            ),

            const Spacing.height(8),

            // Course description
            Typography.text('Based on Don Norman\'s classic book'),

            const Spacing.height(12),

            // Badge and sections row
            Div.row([
              // NEW badge
              Div.column([
                Typography.bodyMedium(
                  'NEW', 
                  color: AppTheme.primaryGreen,
                ),
              ],
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: Style.newBadgeDecoration),

              const Spacing.width(8),

              // Sections count
              Typography.bodyMedium(
                '6 sections',
                color: AppTheme.textSecondary,
              ),
            ]),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ),

        const Spacing.width(16),

        // Course icon
        const Div.column([
          CourseIcon(),
        ],
        padding: EdgeInsets.all(16)),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(20),

      // Continue button row
      Div.row([
        const Spacer(),

        // Continue learning button
        Div.row([
          Typography.bodyMedium(
            'Continue Learning',
            color: AppTheme.primaryGreen,
          ),

          const Spacing.width(8),

          // Forward arrow icon
          const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.primaryGreen,
            size: 14,
          ),
        ],
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: Style.continueButtonDecoration),
      ]),
    ],
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    radius: BorderRadius.circular(18),
    onTap: navigateToDesignCourse);
  }

  // Navigation methods

  void navigateToDesignCourse() {
    showLoadingScreenThenNavigate();
  }

  void showLoadingScreenThenNavigate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseRoadmapScreen(
          courseId: 'design-everyday-things',
        ),
      ),
    );
  }
}

class CourseIcon extends StatelessWidget {
  const CourseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.psychology_outlined,
      color: AppTheme.primaryGreen,
      size: 32,
    );
  }
}

class Style {
  static final BoxDecoration newBadgeDecoration = BoxDecoration(
    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(
      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
    ),
  );

  static final BoxDecoration continueButtonDecoration = BoxDecoration(
    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
      width: 1.5,
    ),
  );
}
