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
    return Container(
      color: AppTheme.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Div.column([
            const StatsBar(),

            const Spacing.height(32),

            HomeWelcomeHeader(),

            const Spacing.height(24),

            LatestCoursesSection(),

            const Spacing.height(24),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget HomeWelcomeHeader() {
    return Div.column([
      Typography.headingLarge(HOME_TITLE),

      const Spacing.height(8),

      Typography.text('Continue your learning journey'),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget LatestCoursesSection() {
    return LatestCourseCard();
  }

  Widget LatestCourseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: navigateToDesignCourse,
          borderRadius: BorderRadius.circular(18),
          child: Div.column([
            Div.row([
              Expanded(
                child: Div.column([
                  Typography.headingMedium(
                    'The Design of Everyday Things',
                  ),

                  const Spacing.height(8),

                  Typography.text(
                    'Based on Don Norman\'s classic book',
                  ),

                  const Spacing.height(12),

                  Div.row([
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: Style.newBadgeDecoration,
                      child: Text(
                        'NEW',
                        style: Style.newBadgeTextStyle,
                      ),
                    ),

                    const Spacing.width(8),

                    Text('6 sections', style: Style.sectionsTextStyle),
                  ]),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),

              const Spacing.width(16),

              Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),

            const Spacing.height(20),

            Div.row([
              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: Style.continueButtonDecoration,
                child: Div.row([
                  Text(
                    'Continue Learning',
                    style: Style.continueButtonTextStyle,
                  ),

                  const Spacing.width(8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.primaryGreen,
                    size: 14,
                  ),
                ]),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // Navigation methods

  void navigateToDesignCourse() {
    showLoadingScreenThenNavigate();
  }

  void showLoadingScreenThenNavigate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CourseRoadmapScreen(courseId: 'design-everyday-things'),
      ),
    );
  }
}


class Style {
  static final TextStyle sectionsTextStyle = Typography.bodyLargeStyle
      .copyWith(color: AppTheme.textSecondary, fontSize: 12);

  static final TextStyle newBadgeTextStyle = Typography.bodyLargeStyle
      .copyWith(
        color: AppTheme.primaryGreen,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      );

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

  static final TextStyle continueButtonTextStyle = Typography
      .bodyLargeStyle
      .copyWith(
        color: AppTheme.primaryGreen,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
}
