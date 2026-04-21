// Course roadmap screen with winding path
// One long scrollable list with sticky segment tiles

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/course_screens/CourseLoadingScreen.dart';
import 'package:readlock/constants/DartAliases.dart';

import 'package:pixelarticons/pixel.dart';
// * Roadmap layout constants
const double roadmapNodeSize = 72.0;
const double roadmapPathHorizontalOffset = 60.0;
const double roadmapNodeVerticalSpacing = 96.0;

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() => CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  JSONMap? courseData;
  JSONList courseLessons = [];
  bool isCourseDataLoading = true;
  int lastLessonAtThreshold = -1;
  bool isProgrammaticScroll = false;
  bool showBackToTop = false;

  List<GlobalKey> lessonKeys = [];
  late ScrollController scrollController;

  double? screenHeight;

  Color getCourseAccentColor() {
    final String? hex = courseData?['color'] as String?;
    final Color? parsed = RLDS.parseHexColor(hex);

    return parsed ?? RLDS.success;
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(handleScrollUpdate);
    fetchCourseData();
  }

  void handleScrollUpdate() {
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

  Future<void> fetchCourseData() async {
    try {
      courseData = await CourseDataService.fetchCourseById(widget.courseId);

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        final JSONList segments = JSONList.from(courseData!['segments'] ?? []);
        final bool hasSegments = segments.isNotEmpty;

        if (hasSegments) {
          courseLessons = JSONList.from(segments[0]['lessons'] ?? []);
        }

        lessonKeys = List.generate(courseLessons.length, (lessonIndex) => GlobalKey());
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isCourseDataLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    final bool shouldShowLoadingIndicator = isCourseDataLoading;

    if (shouldShowLoadingIndicator) {
      return const Center(child: CircularProgressIndicator());
    }

    // Build slivers list
    final List<Widget> slivers = [
      // Header
      SliverToBoxAdapter(child: RoadmapHeader()),

      // Lessons from first segment
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
          child: PathWithNodes(
            lessons: courseLessons,
            segmentIndex: 0,
            lessonKeys: lessonKeys,
            accentColor: getCourseAccentColor(),
            onLessonTap: showLoadingScreenThenNavigate,
          ),
        ),
      ),

      // Bottom padding for floating buttons
      const SliverToBoxAdapter(child: Spacing.height(180)),
    ];

    return Material(
      color: RLDS.surface,
      child: SafeArea(
        child: Stack(
          children: [
            // Scrollable content with sticky headers
            CustomScrollView(controller: scrollController, slivers: slivers),

            // Bottom floating column — back-to-top sits above and to the left of
            // the continue bar when scrolled; the continue bar is always shown.
            Positioned(
              left: RLDS.spacing24,
              right: RLDS.spacing24,
              bottom: RLDS.spacing24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RenderIf.condition(showBackToTop, BackToTopSlot()),

                  BottomFloatingBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final Widget ChevronUpIcon = const Icon(
    Pixel.chevronup,
    color: RLDS.textPrimary,
    size: 24,
  );

  Widget BackToTopSlot() {
    final Widget backToTopCard = RLCard.elevated(
      padding: const EdgeInsets.all(RLDS.spacing12),
      onTap: handleBackToTop,
      child: ChevronUpIcon,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        backToTopCard,

        const Spacing.height(RLDS.spacing12),
      ],
    );
  }

  void handleBackToTop() {
    HapticFeedback.lightImpact();

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Widget BottomFloatingBar() {
    return RLCard.elevated(
      padding: const EdgeInsets.all(RLDS.spacing16),
      child: ContinueButton(),
    );
  }

  static final Widget BackChevronIcon = const Icon(
    Pixel.chevrondown,
    color: RLDS.textPrimary,
    size: 28,
  );

  Widget RoadmapHeader() {
    final String courseTitle =
        courseData?['title'] as String? ?? RLUIStrings.ROADMAP_DEFAULT_TITLE;
    final String courseAuthor =
        courseData?['author'] as String? ?? RLUIStrings.ROADMAP_DEFAULT_AUTHOR;

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
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing24,
        vertical: RLDS.spacing12,
      ),
    );
  }

  static const double progressRingStrokeWidth = 6.0;

  static final BoxDecoration progressRingDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: RLDS.backgroundLight, width: progressRingStrokeWidth),
  );

  Widget ProgressRing() {
    final String? courseCoverPath = courseData?['cover-image-path'] as String?;
    final Color accentColor = getCourseAccentColor();

    final Widget bookCover = BookCoverThumbnail(
      coverImagePath: courseCoverPath,
      width: 52,
      height: 72,
    );

    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          Div.column(const [], width: 128, height: 128, decoration: progressRingDecoration),

          // Progress arc
          SizedBox(
            width: 128,
            height: 128,
            child: CustomPaint(
              painter: ProgressArcPainter(
                progress: 0.35,
                color: accentColor,
                strokeWidth: progressRingStrokeWidth,
              ),
            ),
          ),

          // Book cover in center
          bookCover,
        ],
      ),
    );
  }

  Widget PercentageChip() {
    final Color accentColor = getCourseAccentColor();

    final BoxDecoration chipDecoration = BoxDecoration(
      color: accentColor,
      borderRadius: RLDS.borderRadiusSmall,
    );

    return Div.column(
      [RLTypography.headingMedium('35%', color: RLDS.white)],
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing8,
        vertical: RLDS.spacing4,
      ),
      decoration: chipDecoration,
    );
  }

  Widget HeroCard({required String courseTitle, required String courseAuthor}) {
    return RLCard.elevated(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Book in a progress ring, centered on top
          Center(child: ProgressRing()),

          const Spacing.height(RLDS.spacing16),

          // Percentage chip (progress readout) centered under the book
          Center(child: PercentageChip()),

          const Spacing.height(RLDS.spacing16),

          // Title
          RLTypography.headingMedium(courseTitle, textAlign: TextAlign.center),

          const Spacing.height(RLDS.spacing4),

          // Author
          RLTypography.bodyMedium(
            courseAuthor,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing12),

          // Number of packages
          Center(child: PackageCountRow()),
        ],
      ),
    );
  }

  Widget PackageCountRow() {
    final int totalLessons = countTotalLessons();
    final String lessonsLabel = '$totalLessons packages';
    final Color accentColor = getCourseAccentColor();

    final Widget lessonIcon = Icon(Pixel.bookopen, color: accentColor, size: RLDS.iconMedium);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        lessonIcon,

        const Spacing.width(4),

        RLTypography.bodyMedium(lessonsLabel, color: RLDS.textSecondary),
      ],
    );
  }

  Widget ContinueButton() {
    final Color accentColor = getCourseAccentColor();

    return RLButton.primary(
      label: RLUIStrings.ROADMAP_CONTINUE_LABEL,
      color: accentColor,
      onTap: handleContinueTap,
    );
  }

  int countTotalLessons() {
    return courseLessons.length;
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

// Path with connected lesson nodes
class PathWithNodes extends StatelessWidget {
  final List<dynamic> lessons;
  final int segmentIndex;
  final List<GlobalKey> lessonKeys;
  final Color accentColor;
  final Function(int, int) onLessonTap;

  const PathWithNodes({
    super.key,
    required this.lessons,
    required this.segmentIndex,
    required this.lessonKeys,
    required this.accentColor,
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
          accentColor: accentColor,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLocked: isLocked,
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
}

enum PathNodeAlignment { left, center, right }

// Individual lesson node on the path
class PathLessonNode extends StatelessWidget {
  final JSONMap lesson;
  final int lessonIndex;
  final PathNodeAlignment alignment;
  final Color accentColor;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback onTap;

  const PathLessonNode({
    super.key,
    required this.lesson,
    required this.lessonIndex,
    required this.alignment,
    required this.accentColor,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
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
          // Pixel-style square tile
          GestureDetector(onTap: tapHandler, child: NodeTile()),

          const Spacing.height(10),

          // Lesson title in 8-bit font
          SizedBox(
            width: 128,
            child: RLTypography.pixelLabel(
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

  static const double roadmapTileShadowOffset = 4.0;

  Widget NodeTile() {
    final Color bgColor = getBackgroundColor();
    final Color borderColor = getBorderColor();
    final Widget nodeContent = NodeIcon();

    // Circular tile with a chunky 3px border.
    final BoxDecoration tileDecoration = BoxDecoration(
      color: bgColor,
      border: Border.all(color: borderColor, width: 3),
      shape: BoxShape.circle,
    );

    // Circular drop shadow offset down+right.
    final BoxDecoration shadowDecoration = BoxDecoration(
      color: RLDS.black.withValues(alpha: 0.5),
      shape: BoxShape.circle,
    );

    return SizedBox(
      width: roadmapNodeSize + roadmapTileShadowOffset,
      height: roadmapNodeSize + roadmapTileShadowOffset,
      child: Stack(
        children: [
          // Offset drop shadow
          Positioned(
            left: roadmapTileShadowOffset,
            top: roadmapTileShadowOffset,
            child: Container(
              width: roadmapNodeSize,
              height: roadmapNodeSize,
              decoration: shadowDecoration,
            ),
          ),

          // Foreground tile
          Container(
            width: roadmapNodeSize,
            height: roadmapNodeSize,
            decoration: tileDecoration,
            child: Center(child: nodeContent),
          ),
        ],
      ),
    );
  }

  Color getBackgroundColor() {
    if (isCompleted) {
      return accentColor;
    }

    if (isCurrent) {
      return accentColor.withValues(alpha: 0.15);
    }

    return RLDS.backgroundLight;
  }

  Color getBorderColor() {
    if (isCompleted) {
      return accentColor;
    }

    if (isCurrent) {
      return accentColor;
    }

    if (isLocked) {
      return RLDS.textSecondary.withValues(alpha: 0.2);
    }

    return RLDS.textSecondary.withValues(alpha: 0.3);
  }

  // * Tile glyphs — 32px so they land on pixelarticons' 16×16 grid (2x).

  static const double roadmapTileIconSize = 32.0;

  static final Widget CompletedCheckIcon = const Icon(
    Pixel.check,
    color: RLDS.white,
    size: roadmapTileIconSize,
  );

  static final Widget LockedIcon = Icon(
    Pixel.lock,
    color: RLDS.textSecondary.withValues(alpha: 0.4),
    size: roadmapTileIconSize,
  );

  Widget CurrentPlayIcon() {
    return Icon(
      Pixel.play,
      color: accentColor,
      size: roadmapTileIconSize,
    );
  }

  Widget DefaultLessonNumber() {
    final String lessonLabel = (lessonIndex + 1).toString();

    return RLTypography.pixelNumber(
      lessonLabel,
      color: RLDS.textSecondary,
    );
  }

  Widget NodeIcon() {
    if (isCompleted) {
      return CompletedCheckIcon;
    }

    if (isCurrent) {
      return CurrentPlayIcon();
    }

    if (isLocked) {
      return LockedIcon;
    }

    return DefaultLessonNumber();
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
