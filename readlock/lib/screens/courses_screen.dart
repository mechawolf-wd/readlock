// Courses list screen showing available courses
// Clean card-based layout with course selection

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/course_screens/course_roadmap_screen.dart';
import 'package:relevant/course_screens/data/course_data.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> allCourses = [];
  Map<String, List<Map<String, dynamic>>> coursesByGenre = {};
  bool isLoading = true;
  String selectedGenre = 'design';
  Map<String, Color> genreColorMap = {};
  ScrollController scrollController = ScrollController();
  Map<String, GlobalKey> genreSectionKeys = {};

  // Constants
  static const String COURSE_COLOR_KEY = 'color';
  static const String COURSE_GENRES_KEY = 'genres';
  static const String DEFAULT_COLOR_NAME = 'blue';
  static const String COURSE_SELECTION_TITLE = 'Choose Your Course';
  static const String GENRE_ID_KEY = 'id';
  static const String GENRE_NAME_KEY = 'name';
  static const double GENRE_CHIP_HEIGHT = 40.0;
  
  // Define available genres
  final List<Map<String, String>> genres = [
    {'id': 'design', 'name': 'Design'},
    {'id': 'marketing', 'name': 'Marketing'},
    {'id': 'strategy', 'name': 'Strategy'},
    {'id': 'leadership', 'name': 'Leadership'},
    {'id': 'business', 'name': 'Business'},
    {'id': 'user-experience', 'name': 'UX'},
    {'id': 'social-media', 'name': 'Social Media'},
  ];

  @override
  void initState() {
    super.initState();
    initializeGenreKeys();
    loadCourses();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void initializeGenreKeys() {
    for (final genre in genres) {
      genreSectionKeys[genre[GENRE_ID_KEY]!] = GlobalKey();
    }
  }

  Future<void> loadCourses() async {
    try {
      final courses = await CourseData.availableCourses;
      buildGenreColorMap(courses);
      organizeCoursesByGenre(courses);
      setState(() {
        allCourses = courses;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void organizeCoursesByGenre(List<Map<String, dynamic>> courses) {
    coursesByGenre.clear();
    
    // Initialize all genre lists
    for (final genre in genres) {
      final genreId = genre[GENRE_ID_KEY]!;
      coursesByGenre[genreId] = [];
    }
    
    // Add courses to appropriate genre sections (one category per course)
    for (final course in courses) {
      final List<dynamic> courseGenres = course[COURSE_GENRES_KEY] ?? [];
      if (courseGenres.isNotEmpty) {
        // Use only the first category for each course
        final String primaryCategory = courseGenres.first.toString();
        if (coursesByGenre.containsKey(primaryCategory)) {
          coursesByGenre[primaryCategory]!.add(course);
        }
      }
    }
  }

  void buildGenreColorMap(List<Map<String, dynamic>> courses) {
    final Map<String, Color> colorMap = {};

    for (final course in courses) {
      final String colorName = course[COURSE_COLOR_KEY] ?? DEFAULT_COLOR_NAME;
      final Color courseColor = getColorFromString(colorName);
      final List<dynamic> courseGenres = course[COURSE_GENRES_KEY] ?? [];

      if (courseGenres.isNotEmpty) {
        // Use only the first (primary) category for color mapping
        final String primaryCategory = courseGenres.first.toString();
        if (!colorMap.containsKey(primaryCategory)) {
          colorMap[primaryCategory] = courseColor;
        }
      }
    }

    genreColorMap = colorMap;
  }
  
  Color getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return AppTheme.primaryGreen;
      case 'purple':
        return Colors.purple;
      case 'blue':
        return AppTheme.primaryBlue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return AppTheme.primaryBlue;
    }
  }
  
  void scrollToGenreSection(String genreId) {
    setState(() {
      selectedGenre = genreId;
    });

    final targetKey = genreSectionKeys[genreId];
    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: AppTheme.backgroundDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    return Container(
      color: AppTheme.backgroundDark,
      child: SafeArea(
        child: Div.column(
          [
            Container(
              padding: const EdgeInsets.all(24),
              child: Div.column(
                [
                  TopStatsBar(),

                  const Spacing.height(24),

                  GenreSelector(),
                ],
                crossAxisAlignment: CrossAxisAlignment.stretch,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CoursesSectionedList(),
              ),
            ),
          ],
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

  Widget GenreSelector() {
    return Div.column(
      [
        Typography.headingLarge(COURSE_SELECTION_TITLE),

        const Spacing.height(16),

        GenreChipsScrollView(),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget GenreChipsScrollView() {
    return SizedBox(
      height: GENRE_CHIP_HEIGHT,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: genres.length,
        separatorBuilder: (context, index) => const Spacing.width(12),
        itemBuilder: buildGenreChipItem,
      ),
    );
  }

  Widget buildGenreChipItem(BuildContext context, int index) {
    final genre = genres[index];
    final genreId = genre[GENRE_ID_KEY]!;
    final genreLabel = genre[GENRE_NAME_KEY]!;
    final isSelected = selectedGenre == genreId;
    final chipColor = genreColorMap[genreId] ?? AppTheme.primaryBlue;

    return GenreChip(
      label: genreLabel,
      isSelected: isSelected,
      color: chipColor,
      onTap: () => scrollToGenreSection(genreId),
    );
  }

  Widget CoursesSectionedList() {
    final List<Widget> sectionWidgets = [];
    
    for (final genre in genres) {
      final genreId = genre[GENRE_ID_KEY]!;
      final genreName = genre[GENRE_NAME_KEY]!;
      final genreCourses = coursesByGenre[genreId] ?? [];
      
      if (genreCourses.isNotEmpty) {
        sectionWidgets.addAll([
          Container(
            key: genreSectionKeys[genreId],
            child: Div.column(
              [
                const Spacing.height(16),
                
                Typography.headingMedium(genreName),
                
                const Spacing.height(16),
                
                ...genreCourses.map((course) => CourseCard(
                  course: course, 
                  getColorFromString: getColorFromString,
                )),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ]);
      }
    }
    
    return Div.column(
      sectionWidgets,
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Color Function(String) getColorFromString;

  const CourseCard({super.key, required this.course, required this.getColorFromString});

  @override
  Widget build(BuildContext context) {
    final String title = course['title'] ?? 'Untitled Course';
    final String description = course['description'] ?? '';
    final String color = course['color'] ?? 'blue';
    final String courseId = course['id'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              AppTheme.fadeTransition(CourseRoadmapScreen(courseId: courseId)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: getColorFromString(color).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: getColorFromString(color).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Div.column(
              [
                Div.row(
                  [
                    Expanded(
                      child: Div.column(
                        [
                          Typography.headingMedium(title),

                          const Spacing.height(8),

                          Typography.text(description),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),

                    const Spacing.width(16),

                    CourseIcon(color: getColorFromString(color)),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),

                const Spacing.height(20),

                Div.row(
                  [
                    CourseStats(),

                    const Spacer(),

                    StartButton(color: getColorFromString(color)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget CourseIcon({required Color color}) {
    final IconData icon = course['id'] == 'design-everyday-things' 
      ? Icons.psychology_outlined 
      : Icons.trending_up_outlined;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget CourseStats() {
    final int sections = (course['sections'] as List?)?.length ?? 0;
    
    return Div.row(
      [
        Icon(
          Icons.book_outlined,
          color: AppTheme.textPrimary.withValues(alpha: 0.6),
          size: 16,
        ),

        const Spacing.width(6),

        Typography.text(
          '$sections sections',
        ),
      ],
    );
  }

  Widget StartButton({required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Div.row(
        [
          Typography.text('Start Course'),

          const Spacing.width(8),

          Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 12,
          ),
        ],
      ),
    );
  }

}

class GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  // Constants
  static const double CHIP_BORDER_RADIUS = 20.0;
  static const double CHIP_HORIZONTAL_PADDING = 16.0;
  static const double CHIP_VERTICAL_PADDING = 8.0;
  static const double CHIP_FONT_SIZE = 14.0;
  static const double SELECTED_ALPHA_BACKGROUND = 0.15;
  static const double UNSELECTED_ALPHA_BACKGROUND = 0.04;
  static const double SELECTED_ALPHA_BORDER = 0.4;
  static const double UNSELECTED_ALPHA_BORDER = 0.12;
  static const double SELECTED_ALPHA_TEXT = 1.0;
  static const double UNSELECTED_ALPHA_TEXT = 0.6;

  const GenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CHIP_BORDER_RADIUS),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CHIP_HORIZONTAL_PADDING,
            vertical: CHIP_VERTICAL_PADDING,
          ),
          decoration: buildChipDecoration(),
          child: buildChipLabel(),
        ),
      ),
    );
  }

  BoxDecoration buildChipDecoration() {
    final double backgroundAlpha = isSelected
        ? SELECTED_ALPHA_BACKGROUND
        : UNSELECTED_ALPHA_BACKGROUND;
    final double borderAlpha = isSelected
        ? SELECTED_ALPHA_BORDER
        : UNSELECTED_ALPHA_BORDER;

    return BoxDecoration(
      color: color.withValues(alpha: backgroundAlpha),
      borderRadius: BorderRadius.circular(CHIP_BORDER_RADIUS),
      border: Border.all(
        color: color.withValues(alpha: borderAlpha),
      ),
    );
  }

  Widget buildChipLabel() {
    final double textAlpha = isSelected
        ? SELECTED_ALPHA_TEXT
        : UNSELECTED_ALPHA_TEXT;
    final FontWeight fontWeight = isSelected
        ? FontWeight.w600
        : FontWeight.w500;

    return Text(
      label,
      style: TextStyle(
        color: color.withValues(alpha: textAlpha),
        fontWeight: fontWeight,
        fontSize: CHIP_FONT_SIZE,
      ),
    );
  }
}