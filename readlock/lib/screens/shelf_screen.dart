// Home screen with latest courses and user stats
// Features top bar with streak and aha counters

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/course_screens/course_roadmap_screen.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';

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
          child: Div.column(
            [
              TopStatsBar(),

              const Spacing.height(32),

              HomeWelcomeHeader(),

              const Spacing.height(24),

              LatestCoursesSection(),

              const Spacing.height(24),
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
        ),
      ),
    );
  }

  Widget TopStatsBar() {
    return Div.row(
      [
        StreakCounter(),

        const Spacer(),

        AhaCounter(),
      ],
    );
  }

  Widget StreakCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Div.row(
        [
          const Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: 20,
          ),

          const Spacing.width(8),

          Typography.text('7'),
        ],
      ),
    );
  }

  Widget AhaCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Div.row(
        [
          const Icon(
            Icons.lightbulb,
            color: AppTheme.primaryGreen,
            size: 20,
          ),

          const Spacing.width(8),

          Typography.text('23'),
        ],
      ),
    );
  }

  Widget HomeWelcomeHeader() {
    return Div.column(
      [
        Typography.headingLarge(HOME_TITLE),

        const Spacing.height(8),

        Typography.text('Continue your learning journey'),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget LatestCoursesSection() {
    return LatestCourseCard();
  }

  Widget LatestCourseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.2),
            AppTheme.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              AppTheme.fadeTransition(const CourseRoadmapScreen(courseId: 'design-everyday-things')),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Div.column(
            [
              Div.row(
                [
                  Expanded(
                    child: Div.column(
                      [
                        Typography.headingMedium('The Design of Everyday Things'),

                        const Spacing.height(8),

                        Typography.text('Based on Don Norman\'s classic book'),

                        const Spacing.height(12),

                        Div.row(
                          [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),

                            const Spacing.width(8),

                            Text(
                              '6 sections',
                              style: TextStyle(
                                color: AppTheme.textPrimary.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),

                  const Spacing.width(16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: AppTheme.primaryGreen,
                      size: 32,
                    ),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              const Spacing.height(20),

              Div.row(
                [
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Div.row(
                      [
                        Text(
                          'Continue Learning',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacing.width(8),

                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.primaryGreen,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
