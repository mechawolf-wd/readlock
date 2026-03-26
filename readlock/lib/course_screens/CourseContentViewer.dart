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

  static final Icon BlazeIcon = Icon(
    Icons.local_fire_department_rounded,
    color: RLDS.warningColor,
    size: 24,
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

      const Spacing.width(8),

      // Streak blaze icon
      BlazeIcon,
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

  // Progress indicator with individual segments for skill check questions
  Widget ProgressIndicator() {
    final bool hasSkillCheckQuestions = containsSkillCheckQuestions();

    if (hasSkillCheckQuestions) {
      return SegmentedProgressIndicator();
    }

    return StandardProgressIndicator();
  }

  // Standard linear progress indicator for regular content
  Widget StandardProgressIndicator() {
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

  // Segmented progress indicator for skill check sections
  Widget SegmentedProgressIndicator() {
    final List<ProgressSegment> progressSegments = createProgressSegments();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        height: 12.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;

            return Row(children: segmentList(progressSegments, availableWidth));
          },
        ),
      ),
    );
  }

  // Generate list of segment widgets without spacing issues
  List<Widget> segmentList(List<ProgressSegment> progressSegments, double availableWidth) {
    final List<Widget> segmentWidgets = [];

    for (int segmentIndex = 0; segmentIndex < progressSegments.length; segmentIndex++) {
      final ProgressSegment segment = progressSegments[segmentIndex];
      final double segmentWidth = calculateSegmentWidth(
        segment,
        progressSegments.length,
        availableWidth,
      );

      // Add spacing between segments
      if (segmentIndex > 0) {
        segmentWidgets.add(const SizedBox(width: 2.0));
      }

      // For regular segments, show partial progress
      final bool isRegularSegment = segment.type == ProgressSegmentType.regular;

      if (isRegularSegment) {
        segmentWidgets.add(
          RegularProgressSegment(
            segment: segment,
            currentIndex: currentContentIndex,
            width: segmentWidth,
          ),
        );
      } else {
        // For skill check segments, show completed or not
        final bool isCompleted = currentContentIndex > segment.startIndex;

        Color segmentColor = RLDS.backgroundLight;

        if (isCompleted) {
          segmentColor = RLDS.primaryGreen;
        }

        segmentWidgets.add(
          Container(
            width: segmentWidth,
            height: 12.0,
            decoration: BoxDecoration(
              color: segmentColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    }

    return segmentWidgets;
  }

  // Calculate width for individual segment
  double calculateSegmentWidth(
    ProgressSegment segment,
    int totalSegments,
    double availableWidth,
  ) {
    const double skillCheckWidth = 16.0;
    const double segmentSpacing = 2.0;

    final bool isSkillCheckSegment = segment.type == ProgressSegmentType.skillCheck;

    if (isSkillCheckSegment) {
      return skillCheckWidth;
    }

    final int skillCheckCount = 3;
    final int totalSpaces = totalSegments - 1; // Spaces between segments
    final double totalSpacingWidth = totalSpaces * segmentSpacing;
    final double totalSkillCheckWidth = skillCheckCount * skillCheckWidth;
    final double remainingWidth = availableWidth - totalSkillCheckWidth - totalSpacingWidth;
    final int regularSegmentCount = totalSegments - skillCheckCount;

    // Ensure we don't return negative width
    double calculatedWidth = skillCheckWidth;

    final bool hasRegularSegments = regularSegmentCount > 0;

    if (hasRegularSegments) {
      calculatedWidth = remainingWidth / regularSegmentCount;
    }

    final bool hasPositiveWidth = calculatedWidth > 0;

    if (!hasPositiveWidth) {
      return 20.0;
    }

    return calculatedWidth;
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

  // Check if course content contains skill check questions
  bool containsSkillCheckQuestions() {
    return allContent.any(isSkillCheckContent);
  }

  // Helper method to identify skill check content
  bool isSkillCheckContent(JSONMap content) {
    final String? entityType = content['entity-type'] as String?;
    final String? contentTitle = content['title']?.toString();

    final bool isSkillCheckEntity = entityType == 'skill-check';
    final bool isSingleChoiceWithSkillCheckTitle =
        entityType == 'single-choice-question' &&
        contentTitle != null &&
        contentTitle.contains('Skill Check');

    return isSkillCheckEntity || isSingleChoiceWithSkillCheckTitle;
  }

  // Create progress segments for different content sections
  List<ProgressSegment> createProgressSegments() {
    final List<ProgressSegment> segments = [];
    final int skillCheckStartIndex = findSkillCheckStartIndex();
    final bool hasSkillCheckSection = skillCheckStartIndex != -1;

    if (!hasSkillCheckSection) {
      // Single segment for all content if no skill check
      segments.add(
        ProgressSegment(
          startIndex: 0,
          endIndex: allContent.length - 1,
          type: ProgressSegmentType.regular,
        ),
      );
      return segments;
    }

    // Regular content segment (before skill check)
    if (skillCheckStartIndex > 0) {
      segments.add(
        ProgressSegment(
          startIndex: 0,
          endIndex: skillCheckStartIndex - 1,
          type: ProgressSegmentType.regular,
        ),
      );
    }

    // Individual segments for skill check questions
    final List<int> skillCheckQuestionIndices = findSkillCheckQuestionIndices();

    for (int questionIndex in skillCheckQuestionIndices) {
      segments.add(
        ProgressSegment(
          startIndex: questionIndex,
          endIndex: questionIndex,
          type: ProgressSegmentType.skillCheck,
        ),
      );
    }

    // Skip outro segment - we don't want it in the progress bar

    return segments;
  }

  // Find the starting index of skill check section
  int findSkillCheckStartIndex() {
    for (int itemIndex = 0; itemIndex < allContent.length; itemIndex++) {
      final JSONMap content = allContent[itemIndex];
      final bool isSkillCheckStart = content['entity-type'] == 'skill-check';

      if (isSkillCheckStart) {
        return itemIndex;
      }
    }
    return -1;
  }

  // Find indices of all skill check questions
  List<int> findSkillCheckQuestionIndices() {
    final List<int> questionIndices = [];

    for (int itemIndex = 0; itemIndex < allContent.length; itemIndex++) {
      final JSONMap content = allContent[itemIndex];
      final bool isSkillCheckQuestion =
          content['entity-type'] == 'single-choice-question' &&
          content['title']?.toString().contains('Skill Check') == true;

      if (isSkillCheckQuestion) {
        questionIndices.add(itemIndex);
      }
    }

    return questionIndices;
  }
}

// Progress segment data model
class ProgressSegment {
  final int startIndex;
  final int endIndex;
  final ProgressSegmentType type;

  ProgressSegment({required this.startIndex, required this.endIndex, required this.type});

  int get itemCount => endIndex - startIndex + 1;
}

// Types of progress segments
enum ProgressSegmentType { regular, skillCheck }

// Widget for regular progress segment with partial completion
class RegularProgressSegment extends StatelessWidget {
  final ProgressSegment segment;
  final int currentIndex;
  final double width;

  const RegularProgressSegment({
    super.key,
    required this.segment,
    required this.currentIndex,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress within this segment
    final double segmentProgress = calculateSegmentProgress();

    // Extract styling above build method
    final BoxDecoration progressBackgroundDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(8.0),
    );

    final BoxDecoration progressFillDecoration = BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(8.0),
    );

    return SizedBox(
      width: width,
      height: 12.0,
      child: Stack(
        children: [
          // Background
          Container(decoration: progressBackgroundDecoration),

          // Progress fill
          FractionallySizedBox(
            widthFactor: segmentProgress,
            child: Container(decoration: progressFillDecoration),
          ),
        ],
      ),
    );
  }

  // Calculate progress percentage within this segment
  double calculateSegmentProgress() {
    final bool hasNotReachedSegment = currentIndex < segment.startIndex;
    if (hasNotReachedSegment) {
      return 0.0;
    }

    final bool hasPassedSegment = currentIndex > segment.endIndex;
    if (hasPassedSegment) {
      return 1.0;
    }

    // Currently within this segment
    final int segmentSize = segment.endIndex - segment.startIndex + 1;
    final int progressInSegment = currentIndex - segment.startIndex + 1;

    return progressInSegment / segmentSize;
  }
}

// Widget for individual progress segment
class ProgressSegmentWidget extends StatelessWidget {
  final ProgressSegment segment;
  final double availableWidth;
  final int totalSegments;
  final bool isCompleted;

  const ProgressSegmentWidget({
    super.key,
    required this.segment,
    required this.availableWidth,
    required this.totalSegments,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color segmentColor = getSegmentColor();
    final double segmentWidth = calculateSegmentWidth();

    // Extract styling above build method
    final BoxDecoration segmentDecoration = BoxDecoration(
      color: segmentColor,
      borderRadius: BorderRadius.circular(8.0),
    );

    return Container(width: segmentWidth, height: 12.0, decoration: segmentDecoration);
  }

  // Get color based on segment type and completion status
  Color getSegmentColor() {
    if (isCompleted) {
      return segment.type == ProgressSegmentType.skillCheck ? RLDS.primaryGreen : Colors.green;
    }

    return RLDS.backgroundLight;
  }

  // Calculate proportional width for segment
  double calculateSegmentWidth() {
    const double skillCheckRectangleWidth = 16.0;
    const double segmentSpacing = 2.0;

    final bool isSkillCheckSegment = segment.type == ProgressSegmentType.skillCheck;

    if (isSkillCheckSegment) {
      // Fixed small width for individual skill check question rectangles
      return skillCheckRectangleWidth;
    }

    // Calculate remaining width for regular segments
    final int skillCheckCount = countSkillCheckSegments();
    final double totalSkillCheckWidth = skillCheckCount * skillCheckRectangleWidth;
    final double totalSpacing = (totalSegments - 1) * segmentSpacing;
    final double remainingWidth = availableWidth - totalSkillCheckWidth - totalSpacing;
    final int regularSegmentCount = totalSegments - skillCheckCount;

    final bool hasRegularSegments = regularSegmentCount > 0;

    if (hasRegularSegments) {
      return remainingWidth / regularSegmentCount;
    }

    return skillCheckRectangleWidth;
  }

  // Count skill check segments for width calculation
  int countSkillCheckSegments() {
    // Simplified approach, could be passed as a parameter
    return 3;
  }
}

// Bottom sheet for quit confirmation
