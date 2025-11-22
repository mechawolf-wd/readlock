// Courses list screen showing available courses
// Clean card-based layout with course selection

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/course_roadmap_screen.dart';
import 'package:readlock/course_screens/data/course_data.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> allCourses = [];
  bool isLoading = true;
  String selectedGenre = 'design';
  ScrollController scrollController = ScrollController();
  Map<String, GlobalKey> genreSectionKeys = {};

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
      genreSectionKeys[genre['id']!] = GlobalKey();
    }
  }

  Future<void> loadCourses() async {
    try {
      final courses = await CourseData.availableCourses;
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

  List<Map<String, dynamic>> getCoursesForGenre(String genreId) {
    return allCourses.where((course) {
      final List<dynamic> courseGenres = course['genres'] ?? [];
      return courseGenres.contains(genreId);
    }).toList();
  }

  Color getGenreColor(String genreId) {
    final coursesInGenre = getCoursesForGenre(genreId);
    if (coursesInGenre.isNotEmpty) {
      final colorName = coursesInGenre.first['color'] ?? 'blue';
      return getColorFromString(colorName);
    }
    return getColorFromString('blue');
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
        child: Div.column([
          Container(
            padding: const EdgeInsets.all(24),
            child: Div.column([
              const StatsBar(),

              const Spacing.height(24),

              Div.column([
                Typography.headingLarge('Choose Your Course'),

                const Spacing.height(16),

                GenreChipsList(),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ], crossAxisAlignment: CrossAxisAlignment.stretch),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CoursesListByGenre(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget GenreChipsList() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: genres.length,
        separatorBuilder: (context, index) => const Spacing.width(12),
        itemBuilder: GenreChipItem,
      ),
    );
  }

  Widget GenreChipItem(BuildContext context, int index) {
    final genre = genres[index];
    final genreId = genre['id']!;
    final genreLabel = genre['name']!;
    final isSelected = selectedGenre == genreId;
    final chipColor = getGenreColor(genreId);

    return GenreChip(
      label: genreLabel,
      isSelected: isSelected,
      color: chipColor,
      onTap: () => scrollToGenreSection(genreId),
    );
  }

  Widget CoursesListByGenre() {
    return Div.column(GenreSections());
  }

  List<Widget> GenreSections() {
    return genres
        .map(GenreSection)
        .where((section) => section != null)
        .cast<Widget>()
        .toList();
  }

  Widget? GenreSection(Map<String, String> genre) {
    final genreId = genre['id']!;
    final genreName = genre['name']!;
    final coursesInGenre = getCoursesForGenre(genreId);

    if (coursesInGenre.isEmpty) {
      return null;
    }

    final List<Widget> sectionWidgets = [
      const Spacing.height(16),
      Typography.headingMedium(genreName),
      const Spacing.height(16),
    ];
    sectionWidgets.addAll(CourseCards(coursesInGenre));

    return Container(
      key: genreSectionKeys[genreId],
      child: Div.column(
        sectionWidgets,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  List<Widget> CourseCards(List<Map<String, dynamic>> courses) {
    return courses
        .map(
          (courseData) => CourseCard(
            course: courseData,
            getColorFromString: getColorFromString,
          ),
        )
        .toList();
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Color Function(String) getColorFromString;

  const CourseCard({
    super.key,
    required this.course,
    required this.getColorFromString,
  });

  @override
  Widget build(BuildContext context) {
    final String title = course['title'] ?? 'Untitled Course';
    final String description = course['description'] ?? '';
    final String color = course['color'] ?? 'blue';
    final String courseId = course['id'] ?? '';

    final BoxDecoration cardDecoration = BoxDecoration(
      color: getColorFromString(color).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: getColorFromString(color).withValues(alpha: 0.2),
        width: 1.5,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              AppTheme.fadeTransition(
                CourseRoadmapScreen(courseId: courseId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: cardDecoration,
            child: Div.column([
              Div.row([
                Expanded(
                  child: Div.column([
                    Typography.headingMedium(title),

                    const Spacing.height(8),

                    Typography.text(description),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                ),

                const Spacing.width(16),

                CourseIcon(color: getColorFromString(color)),
              ], crossAxisAlignment: CrossAxisAlignment.start),

              const Spacing.height(20),

              Div.row([
                CourseStats(),

                const Spacer(),

                StartButton(color: getColorFromString(color)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget CourseIcon({required Color color}) {
    final IconData icon = course['id'] == 'design-everyday-things'
        ? Icons.psychology_outlined
        : Icons.trending_up_outlined;

    final BoxDecoration iconDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: iconDecoration,
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget CourseStats() {
    final int sections = (course['sections'] as List?)?.length ?? 0;

    return Div.row([
      Icon(
        Icons.book_outlined,
        color: AppTheme.textPrimary.withValues(alpha: 0.6),
        size: 16,
      ),

      const Spacing.width(6),

      Typography.text('$sections sections'),
    ]);
  }

  Widget StartButton({required Color color}) {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: buttonDecoration,
      child: Div.row([
        Typography.text('Start Course'),

        const Spacing.width(8),

        Icon(Icons.arrow_forward_ios, color: color, size: 12),
      ]),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BoxDecoration chipDecoration = BoxDecoration(
      color: color.withValues(alpha: isSelected ? 0.15 : 0.04),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withValues(alpha: isSelected ? 0.4 : 0.12),
      ),
    );

    final TextStyle chipTextStyle = TextStyle(
      color: color.withValues(alpha: isSelected ? 1.0 : 0.6),
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      fontSize: 14,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: chipDecoration,
          child: Text(label, style: chipTextStyle),
        ),
      ),
    );
  }
}
