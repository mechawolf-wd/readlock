// Course roadmap screen with Duolingo-style winding path
// One long scrollable list with sticky segment tiles

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';
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
const double NODE_VERTICAL_SPACING = 96.0;

// Mastery dots constants
const double MASTERY_DOT_SIZE = 8.0;
const double MASTERY_DOT_SPACING = 4.0;
const int MASTERY_DOTS_PER_LESSON = 3;

// Sticky header constants
const double STICKY_HEADER_PADDING = 8.0;
const double STICKY_HEADER_CONTENT_PADDING = 12.0;
const double STICKY_HEADER_LETTER_SIZE = 40.0;
const double STICKY_HEADER_HEIGHT =
    (STICKY_HEADER_PADDING * 2) +
    (STICKY_HEADER_CONTENT_PADDING * 2) +
    STICKY_HEADER_LETTER_SIZE;

// Segment content constants
const double SEGMENT_CONTENT_TOP_SPACING = 16.0;

// Shared shadow constant
const double SOLID_SHADOW_OFFSET = 4.0;
const Color SOLID_SHADOW_COLOR = Color(0xFFD0D0D0);
const BoxShadow SOLID_SHADOW = BoxShadow(
  color: SOLID_SHADOW_COLOR,
  offset: Offset(0, SOLID_SHADOW_OFFSET),
);

// Segment color mapping
Color getColorForLetter(String letter) {
  switch (letter) {
    case 'A':
      {
        return RLTheme.primaryGreen;
      }
    case 'B':
      {
        return RLTheme.primaryBlue;
      }
    case 'C':
      {
        return RLTheme.accentPurple;
      }
    default:
      {
        return RLTheme.primaryGreen;
      }
  }
}

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  Map<String, dynamic>? courseData;
  List<Map<String, dynamic>> courseSegments = [];
  bool isLoading = true;
  int activeSegmentIndex = 0;
  int lastLessonAtThreshold = -1;
  bool isProgrammaticScroll = false;
  bool showBackToTop = false;

  List<GlobalKey> segmentKeys = [];
  List<GlobalKey> lessonKeys = [];
  late ScrollController scrollController;

  double? screenHeight;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(handleScrollUpdate);
    loadCourseData();
  }

  void handleScrollUpdate() {
    updateActiveSegment();
    checkLessonHaptic();
    updateBackToTopVisibility();
  }

  void updateBackToTopVisibility() {
    const double scrollThreshold = 100.0;
    final bool shouldShow = scrollController.offset > scrollThreshold;

    if (shouldShow != showBackToTop) {
      setState(() {
        showBackToTop = shouldShow;
      });
    }
  }

  void checkLessonHaptic() {
    if (isProgrammaticScroll) {
      return;
    }

    final int currentLesson = findLessonAtThreshold();
    final bool hasLessonChanged =
        currentLesson != lastLessonAtThreshold;
    final bool isValidLesson = currentLesson >= 0;

    if (hasLessonChanged && isValidLesson) {
      lastLessonAtThreshold = currentLesson;
      HapticFeedback.lightImpact();
    }
  }

  int findLessonAtThreshold() {
    final double threshold = (screenHeight ?? 800) / 2;

    for (
      int lessonIndex = lessonKeys.length - 1;
      lessonIndex >= 0;
      lessonIndex--
    ) {
      final RenderBox? box =
          lessonKeys[lessonIndex].currentContext?.findRenderObject()
              as RenderBox?;

      if (box != null) {
        final double y = box.localToGlobal(Offset.zero).dy;
        final bool hasPassedThreshold = y < threshold;

        if (hasPassedThreshold) {
          return lessonIndex;
        }
      }
    }

    return -1;
  }

  @override
  void dispose() {
    scrollController.removeListener(handleScrollUpdate);
    scrollController.dispose();
    super.dispose();
  }

  void updateActiveSegment() {
    if (isProgrammaticScroll) {
      return;
    }

    final int visible = findVisibleSegment();

    if (visible != activeSegmentIndex) {
      setState(() {
        activeSegmentIndex = visible;
      });
    }
  }

  int findVisibleSegment() {
    const double visibilityThreshold = 300;

    for (
      int segmentIndex = segmentKeys.length - 1;
      segmentIndex >= 0;
      segmentIndex--
    ) {
      final RenderBox? box =
          segmentKeys[segmentIndex].currentContext?.findRenderObject()
              as RenderBox?;

      if (box != null) {
        final double y = box.localToGlobal(Offset.zero).dy;
        final bool isSegmentVisible = y < visibilityThreshold;

        if (isSegmentVisible) {
          return segmentIndex;
        }
      }
    }

    return 0;
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

        segmentKeys = List.generate(
          courseSegments.length,
          (index) => GlobalKey(),
        );

        // Count total lessons across all segments
        int totalLessons = 0;

        for (final segment in courseSegments) {
          final List<dynamic> lessons = segment['lessons'] ?? [];
          totalLessons += lessons.length;
        }

        lessonKeys = List.generate(
          totalLessons,
          (index) => GlobalKey(),
        );
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int scrollGeneration = 0;

  void handleSegmentTap(int segmentIndex) {
    final bool isAlreadyActive = segmentIndex == activeSegmentIndex;

    if (isAlreadyActive) {
      return;
    }

    HapticFeedback.lightImpact();
    isProgrammaticScroll = true;
    scrollGeneration++;
    final int currentGeneration = scrollGeneration;

    // Instantly highlight the tapped segment
    setState(() {
      activeSegmentIndex = segmentIndex;
    });

    // First segment scrolls to top
    final bool isFirstSegment = segmentIndex == 0;

    if (isFirstSegment) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Calculate scroll position manually to account for sticky header
      final RenderBox? targetBox =
          segmentKeys[segmentIndex].currentContext?.findRenderObject()
              as RenderBox?;

      if (targetBox != null) {
        final double currentScroll = scrollController.offset;
        final double targetY = targetBox.localToGlobal(Offset.zero).dy;

        // Calculate offset to position content just below pinned header
        // targetY = current position of content (Padding widget)
        // We want content to end up at: safeAreaTop + STICKY_HEADER_HEIGHT
        final double safeAreaTop = MediaQuery.of(context).padding.top;
        final double headerOffset = safeAreaTop + STICKY_HEADER_HEIGHT;
        final double newScrollPosition =
            currentScroll + targetY - headerOffset;

        scrollController.animateTo(
          newScrollPosition.clamp(
            0,
            scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    }

    // Only clear flag if no new scroll was started
    Future.delayed(const Duration(milliseconds: 450), () {
      final bool isLatestScroll = currentGeneration == scrollGeneration;

      if (isLatestScroll) {
        isProgrammaticScroll = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    final bool shouldShowLoadingIndicator = isLoading;

    if (shouldShowLoadingIndicator) {
      return const Center(child: CircularProgressIndicator());
    }

    return Material(
      color: RLTheme.backgroundDark,
      child: SafeArea(
        child: Stack(
          children: [
            // Scrollable content with sticky headers
            CustomScrollView(
              controller: scrollController,
              slivers: [
                // Header
                SliverToBoxAdapter(child: RoadmapHeader()),

                const SliverToBoxAdapter(child: Spacing.height(24)),

                // All segments with sticky headers
                ...AllSegmentSlivers(),

                // Bottom padding for floating buttons
                const SliverToBoxAdapter(child: Spacing.height(180)),
              ],
            ),

            // Bottom floating section
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back to top button (above the bar, only when scrolled)
                  if (showBackToTop) ...[
                    BackToTopButton(),

                    const Spacing.height(12),
                  ],

                  // Navigation bar
                  BottomFloatingBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget BackToTopButton() {
    const BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      shape: BoxShape.circle,
      boxShadow: [SOLID_SHADOW],
    );

    final Widget ChevronUpIcon = const Icon(
      Icons.keyboard_arrow_up,
      color: RLTheme.textPrimary,
      size: 28,
    );

    return GestureDetector(
      onTap: handleBackToTop,
      child: Container(
        width: 48,
        height: 48,
        decoration: buttonDecoration,
        child: Center(child: ChevronUpIcon),
      ),
    );
  }

  void handleBackToTop() {
    HapticFeedback.lightImpact();
    isProgrammaticScroll = true;

    setState(() {
      activeSegmentIndex = 0;
    });

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 450), () {
      isProgrammaticScroll = false;
    });
  }

  Widget BottomFloatingBar() {
    final BoxDecoration barDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [SOLID_SHADOW],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: barDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segment tiles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: SegmentTiles(),
          ),

          const Spacing.height(12),

          // Continue button
          ContinueButton(),
        ],
      ),
    );
  }

  Widget RoadmapHeader() {
    final String courseTitle = courseData?['title'] ?? 'Course Roadmap';
    final String courseAuthor =
        courseData?['author'] ?? 'Unknown Author';

    final Widget BackArrowIcon = const Icon(
      Icons.arrow_back,
      color: RLTheme.textPrimary,
      size: 24,
    );

    final Widget BookCover = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/covers/doet-cover.png',
        width: 80,
        height: 112,
        fit: BoxFit.cover,
      ),
    );

    return Div.column(
      [
        // Back button
        Div.row(
          [BackArrowIcon],
          padding: 8,
          radius: BorderRadius.circular(36),
          onTap: handleBackTap,
        ),

        const Spacing.height(12),

        // Book + info row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            BookCover,

            const Spacing.width(16),

            // Title, description, author
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RLTypography.headingLarge(courseTitle),

                  const Spacing.height(4),

                  RLTypography.bodyMedium(
                    'Master design psychology fundamentals',
                    color: RLTheme.textSecondary,
                  ),

                  const Spacing.height(4),

                  RLTypography.bodyMedium(
                    'by $courseAuthor',
                    color: RLTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),

        const Spacing.height(16),

        // Course stats
        CourseStatsRow(),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: const [20, 16],
    );
  }

  List<Widget> SegmentTiles() {
    final List<Widget> tiles = [];

    for (
      int segmentIndex = 0;
      segmentIndex < courseSegments.length;
      segmentIndex++
    ) {
      final Map<String, dynamic> segment = courseSegments[segmentIndex];
      final String title = segment['segment-title'] ?? 'Segment';
      final String letter = title.split(' ').first;
      final bool isActive = segmentIndex == activeSegmentIndex;
      final bool isNotFirst = segmentIndex > 0;

      if (isNotFirst) {
        tiles.add(const Spacing.width(12));
      }

      final Color segmentColor = getColorForLetter(letter);

      Color backgroundColor = RLTheme.textSecondary.withValues(
        alpha: 0.08,
      );
      Color borderColor = RLTheme.textSecondary.withValues(alpha: 0.15);
      Color textColor = RLTheme.textSecondary;

      if (isActive) {
        backgroundColor = segmentColor.withValues(alpha: 0.15);
        borderColor = segmentColor.withValues(alpha: 0.3);
        textColor = segmentColor;
      }

      final BoxDecoration tileDecoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      );

      tiles.add(
        GestureDetector(
          onTap: () => handleSegmentTap(segmentIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: tileDecoration,
            child: RLTypography.headingMedium(letter, color: textColor),
          ),
        ),
      );
    }

    return tiles;
  }

  List<Widget> AllSegmentSlivers() {
    final List<Widget> slivers = [];
    int lessonOffset = 0;

    for (
      int segmentIndex = 0;
      segmentIndex < courseSegments.length;
      segmentIndex++
    ) {
      final Map<String, dynamic> segment = courseSegments[segmentIndex];
      final List<dynamic> lessons = segment['lessons'] ?? [];
      final String segmentTitle = segment['segment-title'] ?? 'Segment';
      final bool isNotFirst = segmentIndex > 0;

      // Spacing between segments
      if (isNotFirst) {
        slivers.add(
          const SliverToBoxAdapter(child: Spacing.height(48)),
        );
      }

      // Segment with sticky header that pushes out previous headers
      slivers.add(
        MultiSliver(
          pushPinnedChildren: true,
          children: [
            // Sticky segment header
            SliverPersistentHeader(
              pinned: true,
              delegate: StickySegmentHeaderDelegate(
                title: segmentTitle,
              ),
            ),

            // Segment lessons
            SliverToBoxAdapter(
              child: Padding(
                key: segmentKeys[segmentIndex],
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Spacing.height(SEGMENT_CONTENT_TOP_SPACING),

                    PathWithNodes(
                      lessons: lessons,
                      segmentIndex: segmentIndex,
                      lessonKeys: lessonKeys.sublist(
                        lessonOffset,
                        lessonOffset + lessons.length,
                      ),
                      onLessonTap: showLoadingScreenThenNavigate,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      lessonOffset += lessons.length;
    }

    return slivers;
  }

  Widget ContinueButton() {
    return RLDesignSystem.BlockButton(
      children: [
        RLTypography.bodyLarge('Continue latest', color: RLTheme.white),
      ],
      backgroundColor: RLTheme.primaryGreen,
      margin: EdgeInsets.zero,
      onTap: handleContinueTap,
    );
  }

  Widget CourseStatsRow() {
    final BoxDecoration chipDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: RLTheme.textSecondary.withValues(alpha: 0.2),
      ),
    );

    final Widget MasterclassIcon = const Icon(
      Icons.lightbulb_outline,
      color: RLTheme.primaryGreen,
      size: 16,
    );

    final Widget MemorizersIcon = const Icon(
      Icons.psychology_outlined,
      color: RLTheme.primaryBlue,
      size: 16,
    );

    return Row(
      children: [
        // Masterclasses chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: chipDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MasterclassIcon,

              const Spacing.width(6),

              RLTypography.bodyMedium('37 masterclasses'),
            ],
          ),
        ),

        const Spacing.width(8),

        // Memorizers chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: chipDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MemorizersIcon,

              const Spacing.width(6),

              RLTypography.bodyMedium('32 memorizers'),
            ],
          ),
        ),
      ],
    );
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

  void showLoadingScreenThenNavigate(
    int lessonIndex,
    int contentIndex,
  ) {
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

// Sticky header delegate for segment titles
class StickySegmentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final String title;

  const StickySegmentHeaderDelegate({required this.title});

  @override
  double get minExtent => STICKY_HEADER_HEIGHT;

  @override
  double get maxExtent => STICKY_HEADER_HEIGHT;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final String letter = title.split(' ').first;
    final String name = title.split(' ').skip(1).join(' ');
    final Color color = getColorForLetter(letter);

    final BoxDecoration letterDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    );

    final BoxDecoration headerDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [SOLID_SHADOW],
    );

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: STICKY_HEADER_PADDING,
      ),
      child: Container(
        decoration: headerDecoration,
        padding: const EdgeInsets.all(STICKY_HEADER_CONTENT_PADDING),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: STICKY_HEADER_LETTER_SIZE,
              height: STICKY_HEADER_LETTER_SIZE,
              decoration: letterDecoration,
              child: Center(
                child: RLTypography.headingMedium(letter, color: color),
              ),
            ),

            const Spacing.width(12),

            RLTypography.headingMedium(name),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(StickySegmentHeaderDelegate oldDelegate) {
    return title != oldDelegate.title;
  }
}

// Path with connected lesson nodes
class PathWithNodes extends StatelessWidget {
  final List<dynamic> lessons;
  final int segmentIndex;
  final List<GlobalKey> lessonKeys;
  final Function(int, int) onLessonTap;

  const PathWithNodes({
    super.key,
    required this.lessons,
    required this.segmentIndex,
    required this.lessonKeys,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: PathNodes());
  }

  List<Widget> PathNodes() {
    final List<Widget> nodes = [];

    for (
      int lessonIndex = 0;
      lessonIndex < lessons.length;
      lessonIndex++
    ) {
      final Map<String, dynamic> lesson =
          lessons[lessonIndex] as Map<String, dynamic>;
      final bool isCompleted = segmentIndex == 0 && lessonIndex < 3;
      final bool isCurrent = segmentIndex == 0 && lessonIndex == 3;
      final bool isLocked = segmentIndex > 0;

      // Determine horizontal alignment (zigzag pattern)
      final PathNodeAlignment alignment = getAlignmentForIndex(
        lessonIndex,
      );

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
          key: lessonKeys[lessonIndex],
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
    final int pattern = index % 4;

    switch (pattern) {
      case 0:
        {
          return PathNodeAlignment.center;
        }
      case 1:
        {
          return PathNodeAlignment.right;
        }
      case 2:
        {
          return PathNodeAlignment.center;
        }
      case 3:
        {
          return PathNodeAlignment.left;
        }
      default:
        {
          return PathNodeAlignment.center;
        }
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
    final bool canTap = !isLocked;
    final VoidCallback? tapHandler = canTap ? onTap : null;

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
        {
          return -PATH_HORIZONTAL_OFFSET;
        }
      case PathNodeAlignment.right:
        {
          return PATH_HORIZONTAL_OFFSET;
        }
      case PathNodeAlignment.center:
        {
          return 0;
        }
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

    final BoxDecoration nodeDecoration = BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 3),
    );

    return Container(
      width: NODE_SIZE,
      height: NODE_SIZE,
      decoration: nodeDecoration,
      child: Center(child: icon),
    );
  }

  Color getBackgroundColor() {
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }

    if (isCurrent) {
      return RLTheme.primaryGreen.withValues(alpha: 0.15);
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

    for (
      int dotIndex = 0;
      dotIndex < MASTERY_DOTS_PER_LESSON;
      dotIndex++
    ) {
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

    Color fillColor = Colors.transparent;

    if (isFilled) {
      fillColor = dotColor;
    }

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
      return const Icon(Icons.check, color: RLTheme.white, size: 32);
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
