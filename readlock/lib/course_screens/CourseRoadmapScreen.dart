// Course roadmap screen with Duolingo-style winding path
// Circular nodes connected by a zigzag path

import 'package:flutter/material.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/CourseLoadingScreen.dart';

// Layout constants
const double NODE_SIZE = 72.0;
const double PATH_HORIZONTAL_OFFSET = 60.0;
const double NODE_VERTICAL_SPACING = 64.0;

// Mastery dots constants
const double MASTERY_DOT_SIZE = 8.0;
const double MASTERY_DOT_SPACING = 4.0;
const int MASTERY_DOTS_PER_LESSON = 3;

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? courseData;
  List<Map<String, dynamic>> courseSegments = [];
  bool isLoading = true;

  TabController? tabController;
  late PageController pageController;
  int currentSegmentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    loadCourseData();
  }

  @override
  void dispose() {
    tabController?.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadCourseData() async {
    try {
      courseData = await CourseDataService.getCourseById(
        widget.courseId,
      );

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        courseSegments = List<Map<String, dynamic>>.from(
          courseData!['segments'] ?? [],
        );

        final bool canInitializeTabController =
            mounted && courseSegments.isNotEmpty;

        if (canInitializeTabController) {
          tabController = TabController(
            length: courseSegments.length,
            vsync: this,
            initialIndex: currentSegmentIndex,
          );
        }
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowLoadingIndicator = isLoading;

    if (shouldShowLoadingIndicator) {
      return const Center(child: CircularProgressIndicator());
    }

    return Material(
      color: RLTheme.backgroundDark,
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Div.column([
              // Header section
              RoadmapHeader(),

              const Spacing.height(16),

              // Segment indicators
              SegmentPageIndicators(),

              const Spacing.height(8),

              // Path view
              Expanded(child: SegmentPageView()),

              // Bottom spacing
              const Spacing.height(80),
            ]),

            // Continue button
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: ContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget RoadmapHeader() {
    final String courseTitle = courseData?['title'] ?? 'Course Roadmap';

    final Widget BackArrowIcon = const Icon(
      Icons.arrow_back,
      color: RLTheme.textPrimary,
      size: 24,
    );

    final Widget BookCover = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/covers/doet-cover.png',
        width: 120,
        height: 168,
        fit: BoxFit.cover,
      ),
    );

    return Div.column(
      [
        // Header navigation
        Div.row([
          Div.row(
            [BackArrowIcon],
            padding: 8,
            radius: BorderRadius.circular(36),
            onTap: handleBackTap,
          ),

          const Spacer(),
        ]),

        const Spacing.height(20),

        // Centered book cover
        BookCover,

        const Spacing.height(16),

        // Course title
        RLTypography.headingLarge(
          courseTitle,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(8),

        // Course subtitle
        RLTypography.bodyMedium(
          'Master design psychology fundamentals',
          color: RLTheme.textSecondary,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(16),

        // Course stats
        CourseStatsRow(),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const [20, 16],
    );
  }

  Widget ContinueButton() {
    return RLDesignSystem.BlockButton(
      children: [
        RLTypography.bodyLarge('Continue', color: RLTheme.white),
      ],
      backgroundColor: RLTheme.primaryGreen,
      margin: EdgeInsets.zero,
      onTap: handleContinueTap,
    );
  }

  Widget CourseStatsRow() {
    const Icon LessonsIcon = Icon(
      Icons.lightbulb,
      color: RLTheme.primaryGreen,
      size: 16,
    );

    const Icon MemorizersIcon = Icon(
      Icons.quiz,
      color: RLTheme.primaryBlue,
      size: 16,
    );

    return Div.row([
      LessonsIcon,

      const Spacing.width(4),

      RLTypography.bodyMedium('37 masterclasses'),

      const Spacing.width(16),

      MemorizersIcon,

      const Spacing.width(4),

      RLTypography.bodyMedium('32 memorizers'),
    ], mainAxisAlignment: MainAxisAlignment.center);
  }

  void handleContinueTap() {
    const int currentLessonIndex = 3;
    const int currentContentIndex = 0;
    showLoadingScreenThenNavigate(
      currentLessonIndex,
      currentContentIndex,
    );
  }

  void handleBackTap() {
    Navigator.of(context).pop();
  }

  Widget SegmentPageIndicators() {
    final bool hasMultipleSegments = courseSegments.length > 1;
    final bool hasTabController = tabController != null;
    final bool shouldShow = hasMultipleSegments && hasTabController;

    return RenderIf.condition(
      shouldShow,
      Div.row(
        SegmentIndicators(),
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  List<Widget> SegmentIndicators() {
    final List<Widget> indicators = [];

    for (int segmentIndex = 0; segmentIndex < courseSegments.length; segmentIndex++) {
      final bool isActive = segmentIndex == currentSegmentIndex;
      final bool isNotFirstIndicator = segmentIndex > 0;

      if (isNotFirstIndicator) {
        indicators.add(const Spacing.width(6));
      }

      final Color color = isActive
          ? RLTheme.primaryGreen
          : Colors.grey.withValues(alpha: 0.3);
      final double width = isActive ? 24.0 : 16.0;

      indicators.add(
        Container(
          width: width,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return indicators;
  }

  Widget SegmentPageView() {
    return PageView.builder(
      controller: pageController,
      itemCount: courseSegments.length,
      onPageChanged: handleSegmentPageChanged,
      itemBuilder: SegmentPage,
    );
  }

  void handleSegmentPageChanged(int index) {
    final bool isWidgetMounted = mounted;

    if (isWidgetMounted) {
      setState(() {
        currentSegmentIndex = index;

        final bool hasTabController = tabController != null;

        if (hasTabController) {
          tabController!.index = index;
        }
      });
    }
  }

  Widget SegmentPage(BuildContext context, int segmentIndex) {
    final Map<String, dynamic> segment = courseSegments[segmentIndex];

    return DuolingoPathView(
      segment: segment,
      segmentIndex: segmentIndex,
      onLessonTap: showLoadingScreenThenNavigate,
    );
  }

  void showLoadingScreenThenNavigate(
    int lessonIndex,
    int contentIndex,
  ) {
    navigateToCourseWithLoading(lessonIndex, contentIndex);
  }

  void navigateToCourseWithLoading(int lessonIndex, int contentIndex) {
    Navigator.push(
      context,
      RLTheme.slowFadeTransition(const CourseLoadingScreen()),
    );

    Future.delayed(
      const Duration(milliseconds: 500),
      () => performCourseNavigation(lessonIndex, contentIndex),
    );
  }

  void performCourseNavigation(int lessonIndex, int contentIndex) {
    final bool isWidgetMounted = mounted;

    if (isWidgetMounted) {
      Navigator.pushReplacement(
        context,
        RLTheme.slowFadeTransition(
          CourseDetailScreen(
            courseId: widget.courseId,
            initialLessonIndex: lessonIndex,
            initialContentIndex: contentIndex,
          ),
        ),
      );
    }
  }
}

// Duolingo-style winding path view
class DuolingoPathView extends StatelessWidget {
  final Map<String, dynamic> segment;
  final int segmentIndex;
  final Function(int, int) onLessonTap;

  const DuolingoPathView({
    super.key,
    required this.segment,
    required this.segmentIndex,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final String segmentTitle =
        segment['segment-title'] ?? 'Unnamed Segment';
    final List<dynamic> lessons = segment['lessons'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Segment header
          PathSegmentHeader(title: segmentTitle),

          const Spacing.height(24),

          // Winding path with nodes
          PathWithNodes(
            lessons: lessons,
            segmentIndex: segmentIndex,
            onLessonTap: onLessonTap,
          ),

          const Spacing.height(40),
        ],
      ),
    );
  }
}

// Segment header for the path
class PathSegmentHeader extends StatelessWidget {
  final String title;

  const PathSegmentHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final String letter = title.split(' ').first;
    final String name = title.split(' ').skip(1).join(' ');
    final Color color = getColorForLetter(letter);

    final BoxDecoration letterDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    );

    return Div.row([
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: letterDecoration,
        child: RLTypography.headingMedium(letter, color: color),
      ),

      const Spacing.width(10),

      RLTypography.headingMedium(name),
    ], mainAxisAlignment: MainAxisAlignment.center);
  }

  Color getColorForLetter(String letter) {
    switch (letter) {
      case 'A':
        return RLTheme.primaryGreen;
      case 'B':
        return RLTheme.primaryBlue;
      case 'C':
        return RLTheme.accentPurple;
      default:
        return RLTheme.primaryGreen;
    }
  }
}

// Path with connected lesson nodes
class PathWithNodes extends StatelessWidget {
  final List<dynamic> lessons;
  final int segmentIndex;
  final Function(int, int) onLessonTap;

  const PathWithNodes({
    super.key,
    required this.lessons,
    required this.segmentIndex,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: PathNodes());
  }

  List<Widget> PathNodes() {
    final List<Widget> nodes = [];

    for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
      final Map<String, dynamic> lesson =
          lessons[lessonIndex] as Map<String, dynamic>;
      final bool isCompleted = segmentIndex == 0 && lessonIndex < 3;
      final bool isCurrent = segmentIndex == 0 && lessonIndex == 3;
      final bool isLocked = segmentIndex > 0;

      // Determine horizontal alignment (zigzag pattern)
      final PathNodeAlignment alignment = getAlignmentForIndex(lessonIndex);

      // Get mastery count based on lesson state
      final int masteryCount = getMasteryCount(
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        isLocked: isLocked,
      );

      // Add spacing before node (except first)
      final bool isNotFirstNode = lessonIndex > 0;

      if (isNotFirstNode) {
        nodes.add(const Spacing.height(NODE_VERTICAL_SPACING));
      }

      // Add the lesson node
      nodes.add(
        PathLessonNode(
          lesson: lesson,
          lessonIndex: lessonIndex,
          alignment: alignment,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLocked: isLocked,
          masteryCount: masteryCount,
          onTap: () => onLessonTap(lessonIndex, 0),
        ),
      );
    }

    return nodes;
  }

  PathNodeAlignment getAlignmentForIndex(int index) {
    // Create zigzag: center, right, center, left, center, right...
    final int pattern = index % 4;

    switch (pattern) {
      case 0:
        return PathNodeAlignment.center;
      case 1:
        return PathNodeAlignment.right;
      case 2:
        return PathNodeAlignment.center;
      case 3:
        return PathNodeAlignment.left;
      default:
        return PathNodeAlignment.center;
    }
  }

  int getMasteryCount({
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    if (isCompleted) {
      return MASTERY_DOTS_PER_LESSON;
    }

    if (isCurrent) {
      return 2;
    }

    return 0;
  }
}

enum PathNodeAlignment { left, center, right }

// Individual lesson node on the path
class PathLessonNode extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final int lessonIndex;
  final PathNodeAlignment alignment;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final int masteryCount;
  final VoidCallback onTap;

  const PathLessonNode({
    super.key,
    required this.lesson,
    required this.lessonIndex,
    required this.alignment,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    required this.masteryCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = lesson['title'] ?? 'Lesson';
    final double offsetX = getOffsetForAlignment();
    final Color titleColor = getTitleColor();
    final VoidCallback? tapHandler = isLocked ? null : onTap;

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Column(
        children: [
          // Node circle
          GestureDetector(onTap: tapHandler, child: NodeCircle()),

          const Spacing.height(8),

          // Mastery dots
          MasteryDots(),

          const Spacing.height(8),

          // Lesson title
          SizedBox(
            width: 120,
            child: RLTypography.text(
              title,
              color: titleColor,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  double getOffsetForAlignment() {
    switch (alignment) {
      case PathNodeAlignment.left:
        return -PATH_HORIZONTAL_OFFSET;
      case PathNodeAlignment.right:
        return PATH_HORIZONTAL_OFFSET;
      case PathNodeAlignment.center:
        return 0;
    }
  }

  Color getTitleColor() {
    if (isLocked) {
      return RLTheme.textSecondary.withValues(alpha: 0.5);
    }

    return RLTheme.textPrimary;
  }

  Widget NodeCircle() {
    final Color bgColor = getBackgroundColor();
    final Color borderColor = getBorderColor();
    final Widget icon = NodeIcon();
    final List<BoxShadow>? nodeShadow = getNodeShadow();

    final BoxDecoration nodeDecoration = BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 3),
      boxShadow: nodeShadow,
    );

    return Container(
      width: NODE_SIZE,
      height: NODE_SIZE,
      decoration: nodeDecoration,
      child: Center(child: icon),
    );
  }

  List<BoxShadow>? getNodeShadow() {
    if (isCurrent) {
      return [
        BoxShadow(
          color: RLTheme.primaryGreen.withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    }

    return null;
  }

  Color getBackgroundColor() {
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }

    if (isCurrent) {
      return RLTheme.primaryGreen.withValues(alpha: 0.15);
    }

    if (isLocked) {
      return RLTheme.backgroundLight;
    }

    return RLTheme.backgroundLight;
  }

  Color getBorderColor() {
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }

    if (isCurrent) {
      return RLTheme.primaryGreen;
    }

    if (isLocked) {
      return RLTheme.textSecondary.withValues(alpha: 0.2);
    }

    return RLTheme.textSecondary.withValues(alpha: 0.3);
  }

  Widget MasteryDots() {
    final List<Widget> dots = [];

    for (int dotIndex = 0; dotIndex < MASTERY_DOTS_PER_LESSON; dotIndex++) {
      final bool isFilled = dotIndex < masteryCount;
      final bool isNotFirstDot = dotIndex > 0;

      if (isNotFirstDot) {
        dots.add(const Spacing.width(MASTERY_DOT_SPACING));
      }

      dots.add(MasteryDot(isFilled: isFilled));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: dots);
  }

  Widget MasteryDot({required bool isFilled}) {
    final Color dotColor = getDotColor(isFilled);
    final Color fillColor = isFilled ? dotColor : Colors.transparent;

    final BoxDecoration dotDecoration = BoxDecoration(
      color: fillColor,
      shape: BoxShape.circle,
      border: Border.all(color: dotColor, width: 1.5),
    );

    return Container(
      width: MASTERY_DOT_SIZE,
      height: MASTERY_DOT_SIZE,
      decoration: dotDecoration,
    );
  }

  Color getDotColor(bool isFilled) {
    if (isLocked) {
      return RLTheme.textSecondary.withValues(alpha: 0.3);
    }

    if (isCompleted || isCurrent) {
      return RLTheme.primaryGreen;
    }

    return RLTheme.textSecondary.withValues(alpha: 0.5);
  }

  Widget NodeIcon() {
    if (isCompleted) {
      return const Icon(
        Icons.check,
        color: RLTheme.white,
        size: 32,
      );
    }

    if (isCurrent) {
      return const Icon(
        Icons.play_arrow,
        color: RLTheme.primaryGreen,
        size: 32,
      );
    }

    if (isLocked) {
      return Icon(
        Icons.lock,
        color: RLTheme.textSecondary.withValues(alpha: 0.4),
        size: 28,
      );
    }

    return const Icon(
      Icons.auto_stories,
      color: RLTheme.textSecondary,
      size: 28,
    );
  }
}
