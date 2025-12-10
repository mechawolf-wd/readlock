// Home screen with latest courses and user stats
// Features top bar with streak and experience counters

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
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
    final List<Course> courses = getFeaturedCourses();

    return Div.column([
      // The Design of Everyday Things card
      CustomCourseCard(course: courses[0]),
    ]);
  }

  List<Course> getFeaturedCourses() {
    return [
      const Course(
        id: 'design-everyday-things-comprehensive',
        title: 'The Design of Everyday Things',
        description:
            'Extraordinary design is not done by geniuses.',
        coverImagePath: '',
        color: 'green',
        lessons: [],
      ),
    ];
  }
}

class CustomCourseCard extends StatelessWidget {
  final Course course;

  const CustomCourseCard({super.key, required this.course});

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RLTheme.grey300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Div.column([
          // Book header section
          Container(
            padding: const EdgeInsets.all(24),
            child: Div.row([
              // Book cover mockup
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      courseColor,
                      courseColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: courseColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(3, 6),
                    ),
                  ],
                ),
                child: Div.column([
                  const Spacing.height(12),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 2,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),

                  const Spacing.height(6),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),

                  const Spacing.height(6),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.menu_book,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),

                  const Spacing.height(8),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),

              const Spacing.width(20),

              // Book title and author info
              Expanded(
                child: Div.column([
                  // Book title
                  RLTypography.headingMedium(course.title),

                  const Spacing.height(4),

                  // Author
                  RLTypography.text(
                    getAuthorName(course.id),
                    color: courseColor,
                  ),

                  const Spacing.height(8),

                  // Book description
                  RLTypography.text(
                    course.description,
                    color: RLTheme.textSecondary,
                  ),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          // Inspired by section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: courseColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: courseColor.withValues(alpha: 0.15),
                ),
              ),
              child: Div.column([
                RLTypography.text('Inspired by', color: courseColor),

                const Spacing.height(12),

                BookInspirationsList(course.id),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
          ),

          const Spacing.height(20),

          // Start reading button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: courseColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: courseColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Div.row([
                const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),

                const Spacing.width(8),

                RLTypography.text('Start Reading', color: Colors.white),
              ], mainAxisAlignment: MainAxisAlignment.center),
            ),
          ),
        ]),
      ),
    );
  }

  String getAuthorName(String courseId) {
    return courseId == 'ux-design-magic-1'
        ? 'Don Norman'
        : 'Donald A. Norman';
  }

  String getChapterCount(String courseId) {
    return courseId == 'ux-design-magic-1' ? '7 lessons' : '6 lessons';
  }

  Widget BookChaptersList(String courseId) {
    final List<String> chapters = courseId == 'ux-design-magic-1'
        ? [
            'The Psychology of Everyday Things',
            'The Psychology of Everyday Actions',
            'Knowledge in the Head and in the World',
            'Knowing What to Do',
            'To Err is Human',
            'The Design Challenge',
            'User-Centered Design',
          ]
        : [
            'Attractive Things Work Better',
            'The Multiple Faces of Emotion',
            'Three Levels of Processing',
            'Fun and Games',
            'People, Places, and Things',
            'The Future of Everyday Things',
          ];

    return Div.column(
      chapters
          .take(3)
          .map(
            (chapter) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Div.row([
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: getColorFromString(
                      course.color,
                    ).withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),

                const Spacing.width(12),

                Expanded(
                  child: RLTypography.text(
                    chapter,
                    color: RLTheme.textSecondary,
                  ),
                ),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
          )
          .toList(),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget BookInspirationsList(String courseId) {
    final List<String> books = courseId == 'ux-design-magic-1'
        ? [
            'Emotional Design',
            'Design of Everyday Things',
            'User Friendly by Fabricant',
          ]
        : [
            'The Visual Display of Quantitative Information',
            'About Face: Interface Design',
            'Atomic Design by Brad Frost',
          ];

    return Div.column(
      books
          .map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Div.row([
                Icon(
                  Icons.menu_book,
                  color: RLTheme.primaryBlue.withValues(alpha: 0.7),
                  size: 16,
                ),

                const Spacing.width(8),

                Expanded(
                  child: RLTypography.text(
                    book,
                    color: RLTheme.textSecondary,
                  ),
                ),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
          )
          .toList(),
      crossAxisAlignment: CrossAxisAlignment.start,
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
