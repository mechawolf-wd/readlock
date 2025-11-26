// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/widgets/CCJSONContentFactory.dart';
import 'package:readlock/course_screens/data/courseData.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/constants/RLTypography.dart';

// String constants
const String NO_CONTENT_AVAILABLE_MESSAGE =
    'No content available for this course';
const String ERROR_LOADING_COURSE_DATA = 'Error loading course data';

// Styling constants
const double TOP_BAR_PADDING = 16.0;
const double BACK_ICON_SIZE = 20.0;
const double PROGRESS_BAR_RADIUS = 8.0;
const double PROGRESS_BAR_HEIGHT = 12.0;
const double NAVIGATION_SPACING = 12.0;
const int PAGE_ANIMATION_DURATION_MS = 300;

class CourseDetailScreen extends StatefulWidget {
  // Course identifier to load
  final String courseId;

  // Initial lesson to display (0-based index)
  final int initialLessonIndex;

  // Initial content item within the lesson (0-based index)
  final int initialContentIndex;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.initialLessonIndex = 0,
    this.initialContentIndex = 0,
  });

  @override
  State<CourseDetailScreen> createState() => CourseDetailScreenState();
}

class CourseDetailScreenState extends State<CourseDetailScreen> {
  // Page navigation controller
  late PageController pageController;

  // Current position tracking
  late int currentContentIndex;
  late int currentLessonIndex;

  // Content data management
  List<Map<String, dynamic>> allContent = [];
  Map<String, dynamic>? courseData;

  // Loading state
  bool isLoading = true;

  // Icon definitions
  static const Icon backNavigationIcon = Icon(
    Icons.arrow_back,
    color: Color.fromARGB(255, 157, 157, 157),
    size: BACK_ICON_SIZE,
  );

  // Initializes widget state and loads course data
  @override
  void initState() {
    super.initState();

    // Set initial indices from widget properties
    currentLessonIndex = widget.initialLessonIndex;
    currentContentIndex = widget.initialContentIndex;

    // Initialize page controller with initial page
    pageController = PageController(initialPage: currentContentIndex);

    // Load course data asynchronously
    loadCourseData();
  }

  // Cleanup page controller when widget is disposed
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowLoadingScreen = isLoading;

    if (shouldShowLoadingScreen) {
      return LoadingScreen();
    }

    return MainCourseScreen();
  }

  // Loading screen widget
  Widget LoadingScreen() {
    return const Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  // Main course content screen
  Widget MainCourseScreen() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: RLTheme.backgroundDark,
        body: Div.column([
          // Progress bar and navigation header
          TopProgressBar(),

          // Main course content area
          Expanded(child: CourseBody()),
        ]),
      ),
    );
  }

  // Course body containing page view or empty state
  Widget CourseBody() {
    final bool hasNoContent = allContent.isEmpty;

    if (hasNoContent) {
      return EmptyContentMessage();
    }

    return CourseContentPageView();
  }

  // Vertical page view for course content
  Widget CourseContentPageView() {
    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: allContent.length,
      onPageChanged: handlePageChanged,
      itemBuilder: getContentItem,
    );
  }

  // Empty state message when no content available
  Widget EmptyContentMessage() {
    return Center(
      child: RLTypography.bodyMedium(NO_CONTENT_AVAILABLE_MESSAGE),
    );
  }

  // Top navigation bar with progress indicator
  Widget TopProgressBar() {
    return Div.row([
      // Back navigation button
      BackNavigationButton(),

      const Spacing.width(NAVIGATION_SPACING),

      // Course progress indicator
      Expanded(child: ProgressIndicator()),
    ], padding: TOP_BAR_PADDING);
  }

  // Back button for navigation
  Widget BackNavigationButton() {
    return Div.row(const [
      backNavigationIcon,
    ], onTap: navigateToMainScreen);
  }

  // Linear progress indicator showing course completion
  Widget ProgressIndicator() {
    final double progressValue = calculateProgress();

    return ClipRRect(
      borderRadius: BorderRadius.circular(PROGRESS_BAR_RADIUS),
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: RLTheme.backgroundLight,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        minHeight: PROGRESS_BAR_HEIGHT,
      ),
    );
  }

  // Build content item widget for specific index
  Widget getContentItem(BuildContext context, int contentItemIndex) {
    final Map<String, dynamic> content = allContent[contentItemIndex];

    return JsonContentWidgetFactory.createContentWidget(content);
  }

  // Load course data from service
  Future<void> loadCourseData() async {
    try {
      // Fetch course data by ID
      courseData = await CourseDataService.getCourseById(
        widget.courseId,
      );

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        allContent = await getAllContent();
      }
    } on Exception catch (error) {
      debugPrint('$ERROR_LOADING_COURSE_DATA: $error');
    } finally {
      // Update loading state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Extract all content items from lessons
  Future<List<Map<String, dynamic>>> getAllContent() async {
    final bool hasNoCourseData = courseData == null;

    if (hasNoCourseData) {
      return [];
    }

    final List<Map<String, dynamic>> lessons =
        List<Map<String, dynamic>>.from(courseData!['lessons'] ?? []);

    return expandLessonsToContent(lessons);
  }

  // Expand lessons array to flat content list
  List<Map<String, dynamic>> expandLessonsToContent(
    List<Map<String, dynamic>> lessons,
  ) {
    // Extract content from each lesson
    final expandedContent = lessons.expand(
      (lesson) =>
          List<Map<String, dynamic>>.from(lesson['content'] ?? []),
    );

    return expandedContent.toList();
  }

  // Handle page change events
  void handlePageChanged(int contentItemIndex) {
    // Dismiss any active snackbar when user scrolls to next content
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (mounted) {
      setState(() {
        currentContentIndex = contentItemIndex;
      });
    }
  }

  // Calculate current progress percentage
  double calculateProgress() {
    final bool hasNoContent = allContent.isEmpty;

    if (hasNoContent) {
      return 0.0;
    }

    final int completedItems = currentContentIndex + 1;
    final int totalItems = allContent.length;

    return completedItems / totalItems;
  }

  // Navigate back to main navigation screen
  void navigateToMainScreen() {
    Navigator.of(
      context,
    ).push(RLTheme.fadeTransition(const MainNavigation()));
  }
}
