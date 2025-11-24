// Courses list screen showing available courses
// Clean card-based layout with course selection and genre filtering

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
  bool isCourseDataLoading = true;
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
        isCourseDataLoading = false;
      });
    } on Exception {
      setState(() {
        isCourseDataLoading = false;
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
      case 'green': {
        return AppTheme.primaryGreen;
      }
      case 'purple': {
        return Colors.purple;
      }
      case 'blue': {
        return AppTheme.primaryBlue;
      }
      case 'red': {
        return Colors.red;
      }
      case 'orange': {
        return Colors.orange;
      }
      default: {
        return AppTheme.primaryBlue;
      }
    }
  }

  void scrollToGenreSection(String genreId) {
    setState(() {
      selectedGenre = genreId;
    });

    final targetKey = genreSectionKeys[genreId];
    final bool hasValidContext = targetKey?.currentContext != null;

    if (hasValidContext) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = isCourseDataLoading;

    if (isLoading) {
      return LoadingState();
    }

    return MainContent();
  }

  Widget LoadingState() {
    return Div.column(const [
      Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      ),
    ],
      color: AppTheme.backgroundDark,
      height: 'full',
      mainAxisAlignment: 'center',
    );
  }

  Widget MainContent() {
    return Div.column([
      SafeArea(
        child: Div.column([
          // Header section with stats and course selection
          HeaderSection(),

          // Scrollable courses list organized by genre
          CoursesSection(),
        ]),
      ),
    ],
      color: AppTheme.backgroundDark,
      height: 'full',
    );
  }

  Widget HeaderSection() {
    return Div.column([
      // User stats bar
      const StatsBar(),

      const Spacing.height(24),

      // Course selection header and genre filters
      CourseSelectionHeader(),
    ],
      padding: const EdgeInsets.all(24),
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }

  Widget CourseSelectionHeader() {
    return Div.column([
      // Main heading
      Typography.headingLarge('Choose Your Course'),

      const Spacing.height(16),

      // Genre filter chips
      GenreChipsList(),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget CoursesSection() {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: CoursesListByGenre(),
      ),
    );
  }

  Widget GenreChipsList() {
    return Div.column([
      ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: genres.length,
        separatorBuilder: (context, itemIndex) => const Spacing.width(12),
        itemBuilder: GenreChipItem,
      ),
    ],
      height: 40,
    );
  }

  Widget GenreChipItem(BuildContext context, int itemIndex) {
    final genre = genres[itemIndex];
    final genreId = genre['id']!;
    final genreLabel = genre['name']!;
    final bool isSelected = selectedGenre == genreId;
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
    final List<Widget> sections = [];
    
    for (final genre in genres) {
      final section = GenreSection(genre);
      
      if (section != null) {
        sections.add(section);
      }
    }
    
    return sections;
  }

  Widget? GenreSection(Map<String, String> genre) {
    final genreId = genre['id']!;
    final genreName = genre['name']!;
    final coursesInGenre = getCoursesForGenre(genreId);
    final bool hasCoursesInGenre = coursesInGenre.isNotEmpty;

    if (!hasCoursesInGenre) {
      return null;
    }

    return Div.column(
      GenreSectionContent(genreName, coursesInGenre),
      key: genreSectionKeys[genreId],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  List<Widget> GenreSectionContent(String genreName, List<Map<String, dynamic>> coursesInGenre) {
    final List<Widget> sectionWidgets = [
      // Section spacing
      const Spacing.height(16),
      
      // Genre heading
      Typography.headingMedium(genreName),
      
      const Spacing.height(16),
    ];

    // Course cards for this genre
    sectionWidgets.addAll(CourseCards(coursesInGenre));

    return sectionWidgets;
  }

  List<Widget> CourseCards(List<Map<String, dynamic>> courses) {
    final List<Widget> courseCardWidgets = [];
    
    for (final courseData in courses) {
      courseCardWidgets.add(
        CourseCard(
          course: courseData,
          getColorFromString: getColorFromString,
        ),
      );
    }
    
    return courseCardWidgets;
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
    final Color courseColor = getColorFromString(color);

    return Div.column(
      [
        // Course header with title and icon
        CourseHeader(title, description, courseColor),

        const Spacing.height(20),

        // Course footer with stats and start button
        CourseFooter(courseColor),
      ],
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: Style.cardDecoration,
      radius: BorderRadius.circular(16),
      onTap: () => navigateToCourseRoadmap(context, courseId),
    );
  }

  Widget CourseHeader(String title, String description, Color courseColor) {
    return Div.row([
      // Course content section
      Expanded(
        child: CourseContent(title, description),
      ),

      const Spacing.width(16),

      // Course icon
      CourseIcon(color: courseColor),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget CourseContent(String title, String description) {
    return Div.column([
      // Course title
      Typography.headingMedium(title),

      const Spacing.height(8),

      // Course description
      Typography.text(description),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget CourseFooter(Color courseColor) {
    return Div.row([
      // Course statistics
      CourseStats(),

      const Spacer(),

      // Start course button
      StartButton(color: courseColor),
    ]);
  }

  void navigateToCourseRoadmap(BuildContext context, String courseId) {
    Navigator.push(
      context,
      AppTheme.fadeTransition(
        CourseRoadmapScreen(courseId: courseId),
      ),
    );
  }

  Widget CourseIcon({required Color color}) {
    final bool isDesignCourse = course['id'] == 'design-everyday-things';
    final IconData icon = isDesignCourse
        ? Icons.psychology_outlined
        : Icons.trending_up_outlined;

    return Div.column([
      Icon(icon, color: color, size: 24),
    ],
      padding: const EdgeInsets.all(12),
      decoration: Style.iconDecoration,
    );
  }

  Widget CourseStats() {
    final int sectionsCount = (course['sections'] as List?)?.length ?? 0;
    final Color iconColor = AppTheme.textPrimary.withValues(alpha: 0.6);

    return Div.row([
      // Book icon
      Icon(
        Icons.book_outlined,
        color: iconColor,
        size: 16,
      ),

      const Spacing.width(6),

      // Sections count text
      Typography.text('$sectionsCount sections'),
    ]);
  }

  Widget StartButton({required Color color}) {
    return Div.row([
      // Button text
      Typography.text('Start Course'),

      const Spacing.width(8),

      // Forward arrow icon
      Icon(Icons.arrow_forward_ios, color: color, size: 12),
    ],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: Style.startButtonDecoration,
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
    return Div.row(
      [
        // Genre chip label
        Text(label, style: Style.chipTextStyle),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: Style.chipDecoration,
      radius: BorderRadius.circular(20),
      onTap: onTap,
    );
  }
}

class Style {
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppTheme.backgroundLight.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
      width: 1.5,
    ),
  );

  static final BoxDecoration iconDecoration = BoxDecoration(
    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
  );

  static final BoxDecoration startButtonDecoration = BoxDecoration(
    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
    ),
  );

  static final BoxDecoration chipDecoration = BoxDecoration(
    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppTheme.primaryBlue.withValues(alpha: 0.4),
    ),
  );

  static final TextStyle chipTextStyle = const TextStyle(
    color: AppTheme.primaryBlue,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
}
