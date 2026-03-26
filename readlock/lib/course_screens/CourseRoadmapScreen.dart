// Course roadmap screen with winding path
// One long scrollable list with sticky segment tiles

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/course_screens/CourseLoadingScreen.dart';
import 'package:readlock/constants/DartAliases.dart';

// * Roadmap layout constants
const double roadmapNodeSize = 72.0;
const double roadmapPathHorizontalOffset = 60.0;
const double roadmapNodeVerticalSpacing = 96.0;
const double roadmapMasteryDotSize = 8.0;
const double roadmapMasteryDotSpacing = 4.0;
const int roadmapMasteryDotsPerLesson = 3;
const double roadmapStickyHeaderPadding = 8.0;
const double roadmapStickyHeaderContentPadding = 12.0;
const double roadmapStickyHeaderLetterSize = 40.0;
const double roadmapStickyHeaderHeight =
    (roadmapStickyHeaderPadding * 2) +
    (roadmapStickyHeaderContentPadding * 2) +
    roadmapStickyHeaderLetterSize;
const double roadmapSegmentContentTopSpacing = 16.0;

// Segment color mapping (Temporary) - each course will have its own color
Color getColorForLetter(String letter) {
  switch (letter) {
    case 'A':
      {
        return RLDS.primaryGreen;
      }
    case 'B':
      {
        return RLDS.primaryBlue;
      }
    case 'C':
      {
        return RLDS.accentPurple;
      }
    default:
      {
        return RLDS.primaryGreen;
      }
  }
}

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() => CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  JSONMap? courseData;
  JSONList courseSegments = [];
  bool isCourseDataLoading = true;
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
    fetchCourseData();
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
    final bool hasLessonChanged = currentLesson != lastLessonAtThreshold;
    final bool isValidLesson = currentLesson >= 0;

    if (hasLessonChanged && isValidLesson) {
      lastLessonAtThreshold = currentLesson;
      HapticFeedback.lightImpact();
    }
  }

  int findLessonAtThreshold() {
    final double threshold = (screenHeight ?? 800) / 2;

    for (int lessonIndex = lessonKeys.length - 1; lessonIndex >= 0; lessonIndex--) {
      final RenderBox? box =
          lessonKeys[lessonIndex].currentContext?.findRenderObject() as RenderBox?;

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

    for (int segmentIndex = segmentKeys.length - 1; segmentIndex >= 0; segmentIndex--) {
      final RenderBox? box =
          segmentKeys[segmentIndex].currentContext?.findRenderObject() as RenderBox?;

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

  Future<void> fetchCourseData() async {
    try {
      courseData = await CourseDataService.fetchCourseById(widget.courseId);

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        courseSegments = JSONList.from(courseData!['segments'] ?? []);

        segmentKeys = List.generate(courseSegments.length, (segmentIndex) => GlobalKey());

        // Count total lessons across all segments
        int totalLessons = 0;

        for (final segment in courseSegments) {
          final List<dynamic> lessons = segment['lessons'] ?? [];
          totalLessons += lessons.length;
        }

        lessonKeys = List.generate(totalLessons, (lessonIndex) => GlobalKey());
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isCourseDataLoading = false;
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
          segmentKeys[segmentIndex].currentContext?.findRenderObject() as RenderBox?;

      if (targetBox != null) {
        final double currentScroll = scrollController.offset;
        final double targetY = targetBox.localToGlobal(Offset.zero).dy;

        // Calculate offset to position content just below pinned header
        final double safeAreaTop = MediaQuery.of(context).padding.top;
        final double headerOffset = safeAreaTop + roadmapStickyHeaderHeight;
        final double newScrollPosition = currentScroll + targetY - headerOffset;

        scrollController.animateTo(
          newScrollPosition.clamp(0, scrollController.position.maxScrollExtent),
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

    final bool shouldShowLoadingIndicator = isCourseDataLoading;

    if (shouldShowLoadingIndicator) {
      return const Center(child: CircularProgressIndicator());
    }

    // Build slivers list explicitly (avoiding spread operator per rule @4.31)
    final List<Widget> slivers = [
      // Header
      SliverToBoxAdapter(child: RoadmapHeader()),
    ];

    // Add all segment slivers
    slivers.addAll(AllSegmentSlivers());

    // Bottom padding for floating buttons
    slivers.add(const SliverToBoxAdapter(child: Spacing.height(180)));

    return Material(
      color: RLDS.backgroundDark,
      child: SafeArea(
        child: Stack(
          children: [
            // Scrollable content with sticky headers
            CustomScrollView(controller: scrollController, slivers: slivers),

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
                  RenderIf.condition(
                    showBackToTop,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [BackToTopButton(), const Spacing.height(12)],
                    ),
                  ),

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
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.white,
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
    );

    final Widget ChevronUpIcon = Icon(
      Icons.keyboard_arrow_up,
      color: RLDS.textPrimary,
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
      color: RLDS.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: barDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segment tiles
          Row(mainAxisAlignment: MainAxisAlignment.center, children: SegmentTiles()),

          const Spacing.height(12),

          // Continue button
          ContinueButton(),
        ],
      ),
    );
  }

  Widget RoadmapHeader() {
    final String courseTitle = courseData?['title'] ?? 'Course Roadmap';
    final String courseAuthor = courseData?['author'] ?? 'Unknown Author';

    final Widget BackChevronIcon = Icon(
      Icons.keyboard_arrow_down,
      color: RLDS.textPrimary,
      size: 28,
    );

    return Div.column(
      [
        // Back button
        Div.row(
          [BackChevronIcon],
          padding: 8,
          radius: BorderRadius.circular(36),
          onTap: handleBackTap,
        ),

        const Spacing.height(16),

        // Hero card with book and info
        HeroCard(courseTitle: courseTitle, courseAuthor: courseAuthor),

        const Spacing.height(24),

        // Subtitle below card
        Center(
          child: RLTypography.bodyMedium(
            RLUIStrings.ROADMAP_SUBTITLE,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),
        ),

        const Spacing.height(16),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: const [20, 12],
    );
  }

  Widget HeroCard({required String courseTitle, required String courseAuthor}) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLDS.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
    );

    final BoxDecoration progressRingDecoration = BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: RLDS.primaryGreen.withValues(alpha: 0.2), width: 3),
    );

    final Widget BookCover = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        'assets/covers/doet-cover.png',
        width: 52,
        height: 72,
        fit: BoxFit.cover,
      ),
    );

    final Widget ProgressRing = SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          Container(width: 128, height: 128, decoration: progressRingDecoration),

          // Progress arc (using CustomPaint for partial circle)
          SizedBox(
            width: 128,
            height: 128,
            child: CustomPaint(
              painter: ProgressArcPainter(
                progress: 0.35,
                color: RLDS.primaryGreen,
                strokeWidth: 3,
              ),
            ),
          ),

          // Book cover in center
          BookCover,
        ],
      ),
    );

    final Widget PercentageChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: RLDS.primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RLTypography.bodyMedium('35%', color: RLDS.white),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration,
      child: Row(
        children: [
          // Progress ring with book
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProgressRing,

              // Percentage badge
              Positioned(bottom: -8, left: 0, right: 0, child: Center(child: PercentageChip)),
            ],
          ),

          const Spacing.width(16),

          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RLTypography.headingMedium(courseTitle),

                const Spacing.height(4),

                RLTypography.bodyMedium(courseAuthor, color: RLDS.textSecondary),

                const Spacing.height(12),

                // Mini stats row
                MiniStatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget MiniStatsRow() {
    final Widget LessonIcon = Icon(Icons.auto_stories, color: RLDS.primaryGreen, size: 14);

    final Widget QuizIcon = Icon(Icons.psychology_outlined, color: RLDS.primaryBlue, size: 14);

    final int totalLessons = countTotalLessons();
    final String lessonsLabel = '$totalLessons masterclasses';
    final String quizzesLabel = '$totalLessons memorizers';

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LessonIcon,

            const Spacing.width(4),

            RLTypography.bodyMedium(lessonsLabel, color: RLDS.textSecondary),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuizIcon,

            const Spacing.width(4),

            RLTypography.bodyMedium(quizzesLabel, color: RLDS.textSecondary),
          ],
        ),
      ],
    );
  }

  List<Widget> SegmentTiles() {
    final List<Widget> tiles = [];

    for (int segmentIndex = 0; segmentIndex < courseSegments.length; segmentIndex++) {
      final JSONMap segment = courseSegments[segmentIndex];
      final String letter = segment['segment-symbol'] ?? '';
      final bool isActive = segmentIndex == activeSegmentIndex;
      final bool isNotFirst = segmentIndex > 0;

      if (isNotFirst) {
        tiles.add(const Spacing.width(12));
      }

      final Color segmentColor = getColorForLetter(letter);

      Color backgroundColor = RLDS.textSecondary.withValues(alpha: 0.08);
      Color textColor = RLDS.textSecondary;

      if (isActive) {
        backgroundColor = segmentColor.withValues(alpha: 0.15);
        textColor = segmentColor;
      }

      final BoxDecoration tileDecoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      );

      tiles.add(
        Div.row(
          [RLTypography.headingMedium(letter, color: textColor)],
          padding: const [8, 16],
          decoration: tileDecoration,
          onTap: () => handleSegmentTap(segmentIndex),
        ),
      );
    }

    return tiles;
  }

  List<Widget> AllSegmentSlivers() {
    final List<Widget> slivers = [];
    int lessonOffset = 0;

    for (int segmentIndex = 0; segmentIndex < courseSegments.length; segmentIndex++) {
      final JSONMap segment = courseSegments[segmentIndex];
      final List<dynamic> lessons = segment['lessons'] ?? [];
      final String segmentSymbol = segment['segment-symbol'] ?? '';
      final String segmentTitle = segment['segment-title'] ?? 'Segment';
      final bool isNotFirst = segmentIndex > 0;

      // Spacing between segments
      if (isNotFirst) {
        slivers.add(const SliverToBoxAdapter(child: Spacing.height(48)));
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
                symbol: segmentSymbol,
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
                    const Spacing.height(roadmapSegmentContentTopSpacing),

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
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.primaryGreen,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: handleContinueTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: buttonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [RLTypography.bodyLarge(RLUIStrings.ROADMAP_CONTINUE_LABEL)],
        ),
      ),
    );
  }

  // Count total lessons across all segments from JSON data
  int countTotalLessons() {
    int total = 0;

    for (final segment in courseSegments) {
      final List<dynamic> lessons = segment['lessons'] ?? [];
      total += lessons.length;
    }

    return total;
  }

  void handleContinueTap() {
    const int currentLessonIndex = 0;
    const int currentContentIndex = 0;
    showLoadingScreenThenNavigate(currentLessonIndex, currentContentIndex);
  }

  void handleBackTap() {
    Navigator.of(context).pop();
  }

  void showLoadingScreenThenNavigate(int lessonIndex, int contentIndex) {
    Navigator.push(context, RLDS.slowFadeTransition(const CourseLoadingScreen()));

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
        RLDS.slowFadeTransition(
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
class StickySegmentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String symbol;
  final String title;

  const StickySegmentHeaderDelegate({required this.symbol, required this.title});

  @override
  double get minExtent => roadmapStickyHeaderHeight;

  @override
  double get maxExtent => roadmapStickyHeaderHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Color color = getColorForLetter(symbol);

    final BoxDecoration letterDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
    );

    final BoxDecoration headerDecoration = BoxDecoration(
      color: RLDS.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
    );

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: roadmapStickyHeaderPadding),
      child: Center(
        child: Container(
          decoration: headerDecoration,
          padding: const EdgeInsets.all(roadmapStickyHeaderContentPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: roadmapStickyHeaderLetterSize,
                height: roadmapStickyHeaderLetterSize,
                decoration: letterDecoration,
                child: Center(child: RLTypography.headingMedium(symbol, color: color)),
              ),

              const Spacing.width(12),

              RLTypography.headingMedium(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(StickySegmentHeaderDelegate oldDelegate) {
    final bool hasTitleChanged = title != oldDelegate.title;
    final bool hasSymbolChanged = symbol != oldDelegate.symbol;

    return hasTitleChanged || hasSymbolChanged;
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

    for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
      final JSONMap lesson = lessons[lessonIndex] as JSONMap;
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
        nodes.add(const Spacing.height(roadmapNodeVerticalSpacing));
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

  PathNodeAlignment getAlignmentForIndex(int lessonIndex) {
    final int pattern = lessonIndex % 4;

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
      return roadmapMasteryDotsPerLesson;
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
  final JSONMap lesson;
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

    VoidCallback? tapHandler;

    if (canTap) {
      tapHandler = onTap;
    }

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
            child: Text(
              title,
              style: RLTypography.bodyMediumStyle.copyWith(color: titleColor),
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
          return -roadmapPathHorizontalOffset;
        }
      case PathNodeAlignment.right:
        {
          return roadmapPathHorizontalOffset;
        }
      case PathNodeAlignment.center:
        {
          return 0;
        }
    }
  }

  Color getTitleColor() {
    if (isLocked) {
      return RLDS.textSecondary.withValues(alpha: 0.5);
    }

    return RLDS.textPrimary;
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
      width: roadmapNodeSize,
      height: roadmapNodeSize,
      decoration: nodeDecoration,
      child: Center(child: icon),
    );
  }

  Color getBackgroundColor() {
    if (isCompleted) {
      return RLDS.primaryGreen;
    }

    if (isCurrent) {
      return RLDS.primaryGreen.withValues(alpha: 0.15);
    }

    return RLDS.backgroundLight;
  }

  Color getBorderColor() {
    if (isCompleted) {
      return RLDS.primaryGreen;
    }

    if (isCurrent) {
      return RLDS.primaryGreen;
    }

    if (isLocked) {
      return RLDS.textSecondary.withValues(alpha: 0.2);
    }

    return RLDS.textSecondary.withValues(alpha: 0.3);
  }

  Widget MasteryDots() {
    final List<Widget> dots = [];

    for (int dotIndex = 0; dotIndex < roadmapMasteryDotsPerLesson; dotIndex++) {
      final bool isFilled = dotIndex < masteryCount;
      final bool isNotFirstDot = dotIndex > 0;

      if (isNotFirstDot) {
        dots.add(const Spacing.width(roadmapMasteryDotSpacing));
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
      width: roadmapMasteryDotSize,
      height: roadmapMasteryDotSize,
      decoration: dotDecoration,
    );
  }

  Color getDotColor(bool isFilled) {
    if (isLocked) {
      return RLDS.textSecondary.withValues(alpha: 0.3);
    }

    if (isCompleted || isCurrent) {
      return RLDS.primaryGreen;
    }

    return RLDS.textSecondary.withValues(alpha: 0.5);
  }

  Widget NodeIcon() {
    final Widget CompletedCheckIcon = Icon(Icons.check, color: RLDS.white, size: 32);

    final Widget CurrentPlayIcon = Icon(Icons.play_arrow, color: RLDS.primaryGreen, size: 32);

    final Widget LockedIcon = Icon(
      Icons.lock,
      color: RLDS.textSecondary.withValues(alpha: 0.4),
      size: 28,
    );

    final Widget DefaultIcon = Icon(Icons.auto_stories, color: RLDS.textSecondary, size: 28);

    if (isCompleted) {
      return CompletedCheckIcon;
    }

    if (isCurrent) {
      return CurrentPlayIcon;
    }

    if (isLocked) {
      return LockedIcon;
    }

    return DefaultIcon;
  }
}

// Custom painter for progress arc
class ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressArcPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Start from top (-90 degrees) and sweep based on progress
    const double startAngle = -1.5708;
    final double sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ProgressArcPainter oldDelegate) {
    final bool hasProgressChanged = progress != oldDelegate.progress;
    final bool hasColorChanged = color != oldDelegate.color;

    return hasProgressChanged || hasColorChanged;
  }
}
