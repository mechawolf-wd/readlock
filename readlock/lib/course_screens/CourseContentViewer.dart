// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples

import 'package:flutter/material.dart';
import 'package:readlock/course_screens/widgets/CCJSONContentFactory.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/screens/StreakplierRewardScreen.dart';
import 'package:readlock/bottom_sheets/course/QuitConfirmationSheet.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/services/SoundService.dart';

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
  JSONList allContent = [];
  JSONMap? courseData;

  // Loading state
  bool isLoading = true;

  // Icon definitions
  static const Icon BackNavigationIcon = Icon(
    Icons.close_rounded,
    color: Color.fromARGB(255, 157, 157, 157),
    size: RLDS.iconMedium,
  );

  static const Icon BookmarkIcon = Icon(Icons.bookmark_rounded, color: Colors.amber, size: 24);

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
    fetchCourseData();

    // Start atmosphere audio loop
    SoundService.playAtmosphere();
  }

  // Cleanup page controller and stop atmosphere when widget is disposed
  @override
  void dispose() {
    SoundService.stopAtmosphere();
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
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  // Main course content screen
  Widget MainCourseScreen() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: RLDS.backgroundDark,
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
    return Center(child: RLTypography.bodyMedium(RLUIStrings.NO_CONTENT_AVAILABLE_MESSAGE));
  }

  // Top navigation bar with progress indicator
  Widget TopProgressBar() {
    return Div.row([
      // Back navigation button
      BackNavigationButton(),

      const Spacing.width(RLDS.spacing12),

      // Course progress indicator
      Expanded(child: ProgressIndicator()),

      const Spacing.width(RLDS.spacing12),

      // Bookmark slide icon
      BookmarkButton(),
    ], padding: RLDS.spacing16);
  }

  // Back button for navigation
  Widget BackNavigationButton() {
    return GestureDetector(onTap: showQuitConfirmationSheet, child: BackNavigationIcon);
  }

  // Bookmark button for slide favoriting
  Widget BookmarkButton() {
    return GestureDetector(onTap: handleBookmarkTap, child: BookmarkIcon);
  }

  // Progress indicator for course content
  Widget ProgressIndicator() {
    final double progressValue = calculateProgress();

    return SizedBox(
      height: 12.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: LinearProgressIndicator(
          value: progressValue,
          backgroundColor: RLDS.backgroundLight,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }

  // Build content item widget for specific index
  Widget getContentItem(BuildContext context, int contentItemIndex) {
    final JSONMap content = allContent[contentItemIndex];

    return CCJSONContentFactory.createContentWidget(
      content,
      onLessonComplete: showStreakplierRewardScreen,
    );
  }

  // Load course data from service
  Future<void> fetchCourseData() async {
    try {
      // Fetch course data by ID
      courseData = await CourseDataService.fetchCourseById(widget.courseId);

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        allContent = await getAllContent();
      }
    } on Exception catch (error) {
      debugPrint('$RLUIStrings.ERROR_LOADING_COURSE_DATA: $error');
    } finally {
      // Update loading state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Extract content items from current lesson only
  Future<JSONList> getAllContent() async {
    final bool hasNoCourseData = courseData == null;

    if (hasNoCourseData) {
      return [];
    }

    // Navigate through segments to find lessons
    final JSONList segments = JSONList.from(courseData!['segments'] ?? []);

    return getContentFromCurrentLessonInSegments(segments);
  }

  // Get content from current lesson by navigating through segments
  JSONList getContentFromCurrentLessonInSegments(JSONList segments) {
    // Flatten all lessons from all segments
    final JSONList allLessons = [];

    for (final segment in segments) {
      final JSONList segmentLessons = JSONList.from(segment['lessons'] ?? []);
      allLessons.addAll(segmentLessons);
    }

    return getContentFromCurrentLesson(allLessons);
  }

  // Get content from the current lesson only
  JSONList getContentFromCurrentLesson(JSONList lessons) {
    final bool hasValidLessonIndex =
        currentLessonIndex >= 0 && currentLessonIndex < lessons.length;

    if (!hasValidLessonIndex) {
      return [];
    }

    final JSONMap currentLesson = lessons[currentLessonIndex];
    final JSONList lessonContent = JSONList.from(currentLesson['content'] ?? []);

    return lessonContent;
  }

  // Handle page change events
  void handlePageChanged(int contentItemIndex) {
    // Clear any feedback snackbar when user scrolls to next content
    FeedbackSnackBar.clearSnackbars();

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

  // Navigate back to course roadmap
  void navigateBackToRoadmap() {
    // Clear any lingering snackbars before leaving
    FeedbackSnackBar.clearSnackbars();

    Navigator.of(context).pop();
  }

  // Show quit confirmation dialog
  void showQuitConfirmationSheet() {
    QuitConfirmationSheet.show(
      context: context,
      onQuitTap: navigateBackToRoadmap,
    );
  }

  // Show Streakplier reward screen after lesson completion
  void showStreakplierRewardScreen() {
    // Clear any lingering snackbars before showing rewards
    FeedbackSnackBar.clearSnackbars();

    final LessonReward reward = createLessonReward();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            StreakplierRewardScreen(reward: reward, onContinue: handleRewardScreenContinue),
      ),
    );
  }

  // Create lesson reward data based on current lesson performance
  LessonReward createLessonReward() {
    // Calculate lesson duration (example: 5 minutes 30 seconds)
    final Duration lessonDuration = const Duration(minutes: 5, seconds: 30);

    return LessonReward(
      experiencePointsGained: 190,
      streakplierMultiplier: 1.35,
      lessonDuration: lessonDuration,
    );
  }

  // Handle continue from reward screen
  void handleRewardScreenContinue() {
    // Pop reward screen and course content viewer to return to roadmap
    Navigator.of(context).pop(); // Close reward screen
    Navigator.of(context).pop(); // Close course content viewer
  }

  // Handle bookmark tap to favorite current slide
  void handleBookmarkTap() {
    // Check if PageController is attached to a PageView
    if (!pageController.hasClients) {
      return; // PageController not attached yet
    }

    // Get current page index
    final double? currentPageDouble = pageController.page;
    final bool hasCurrentPage = currentPageDouble != null;

    if (!hasCurrentPage) {
      return;
    }

    // Show bookmark feedback using custom snackbar
    FeedbackSnackBar.showCustomFeedback(
      context,
      RLUIStrings.BOOKMARK_FEEDBACK_MESSAGE,
      true,
    );
  }

}

// Bottom sheet for quit confirmation
