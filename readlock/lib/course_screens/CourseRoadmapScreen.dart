// Course roadmap screen with winding path
// One long scrollable list with sticky segment tiles

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLSegmentTabs.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/constants/RLCoursePalette.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/constants/DartAliases.dart';

import 'package:pixelarticons/pixel.dart';

// * Roadmap layout constants
const double roadmapNodeSize = 72.0;
const double roadmapPathHorizontalOffset = 60.0;
const double roadmapNodeVerticalSpacing = 96.0;
const double roadmapTileBorderWidth = 3.0;
const double lessonTitleWidth = 128.0;
const double floatingBarBottomClearance = 180.0;

// * Progress ring intro animation — the arc sweeps from 0 to the reader's
// current progress on screen open with an ease-out curve so the reveal
// reads as a single confident gesture rather than a linear fill. Duration
// pulled from the shared opacity-intro token in RLDS.
const double roadmapTargetProgress = 0.35;

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() => CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen>
    with TickerProviderStateMixin {
  JSONMap? courseData;
  JSONList courseSegments = [];
  JSONList courseLessons = [];
  int selectedSegmentIndex = 0;
  bool isCourseDataLoading = true;
  int lastLessonAtThreshold = -1;
  bool isProgrammaticScroll = false;

  List<GlobalKey> lessonKeys = [];
  late ScrollController scrollController;
  late AnimationController progressRingController;
  late Animation<double> progressRingAnimation;

  // Breathing pulse for the circular disc that hosts the progress ring.
  // A slow scale loop (0.97 ↔ 1.03) so the disc reads as gently alive
  // rather than a flat token sitting on the page.
  late AnimationController breathingController;
  late Animation<double> breathingAnimation;

  double? screenHeight;

  // Normalised course color — bare uppercase hex, empty string if missing.
  String getNormalizedCourseColor() {
    final String? raw = courseData?['color'] as String?;
    final bool hasNoColor = raw == null || raw.isEmpty;

    if (hasNoColor) {
      return '';
    }

    return raw.replaceAll('#', '').trim().toUpperCase();
  }

  bool isPaletteColor() {
    return KNOWN_COURSE_COLORS.contains(getNormalizedCourseColor());
  }

  // Fallback for when a segment doesn't ship a `segment-symbol`. Builds a
  // compact tab label from the segment title — first letter of every word
  // that starts with an uppercase character, joined and uppercased. So
  // "Mastery and Innovation" reads as "MI", "Design Fundamentals" as
  // "DF". Lowercase function words drop out so the compact label stays at
  // the recognised acronym length.
  String getSegmentAcronym(String segmentTitle) {
    final List<String> words = segmentTitle.trim().split(RegExp(r'\s+'));
    final StringBuffer acronymBuffer = StringBuffer();

    for (final String word in words) {
      final bool isEmptyWord = word.isEmpty;

      if (isEmptyWord) {
        continue;
      }

      final String firstChar = word[0];
      final bool isUppercaseLetter = firstChar == firstChar.toUpperCase()
          && firstChar.toUpperCase() != firstChar.toLowerCase();

      if (isUppercaseLetter) {
        acronymBuffer.write(firstChar.toUpperCase());
      }
    }

    return acronymBuffer.toString();
  }

  Color getCourseAccentColor() {
    final String normalized = getNormalizedCourseColor();
    final bool isKnown = KNOWN_COURSE_COLORS.contains(normalized);

    final String effectiveHex = isKnown ? normalized : COURSE_FALLBACK_COLOR_HEX;
    final Color? parsed = RLDS.parseHexColor(effectiveHex);

    return parsed ?? RLDS.success;
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(handleScrollUpdate);

    progressRingController = AnimationController(
      vsync: this,
      duration: RLDS.opacityFadeDurationIntro,
    );

    progressRingAnimation = Tween<double>(
      begin: 0.0,
      end: roadmapTargetProgress,
    ).animate(
      CurvedAnimation(parent: progressRingController, curve: Curves.easeOutCubic),
    );

    breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    breathingAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: breathingController, curve: Curves.easeInOut),
    );

    fetchCourseData();
  }

  void handleScrollUpdate() {
    checkLessonHaptic();
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
    progressRingController.dispose();
    breathingController.dispose();
    super.dispose();
  }

  Future<void> fetchCourseData() async {
    try {
      courseData = await CourseDataService.fetchCourseById(widget.courseId);

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        courseSegments = JSONList.from(courseData!['segments'] ?? []);
        loadSegmentLessons(0);
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isCourseDataLoading = false;
      });
      progressRingController.forward();
    }
  }

  void loadSegmentLessons(int segmentIndex) {
    final bool isSegmentAvailable = segmentIndex >= 0 && segmentIndex < courseSegments.length;

    if (!isSegmentAvailable) {
      courseLessons = [];
      lessonKeys = [];
      return;
    }

    final JSONMap segment = courseSegments[segmentIndex];
    courseLessons = JSONList.from(segment['lessons'] ?? []);
    lessonKeys = List.generate(courseLessons.length, (lessonIndex) => GlobalKey());
  }

  void handleSegmentTabTap(int segmentIndex) {
    final bool isSameSegment = segmentIndex == selectedSegmentIndex;

    if (isSameSegment) {
      return;
    }

    // Haptic is fired by RLSegmentTab's tap — no need for a second one here.

    setState(() {
      selectedSegmentIndex = segmentIndex;
      loadSegmentLessons(segmentIndex);
      lastLessonAtThreshold = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    final bool shouldShowLoadingIndicator = isCourseDataLoading;

    if (shouldShowLoadingIndicator) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final bool hasMultipleSegments = courseSegments.length > 1;

    // Build slivers list
    final List<Widget> slivers = [
      // Header
      SliverToBoxAdapter(child: RoadmapHeader()),

      // Gap under the book info
      const SliverToBoxAdapter(child: Spacing.height(RLDS.spacing24)),
    ];

    // Segment tabs (only when there are multiple segments)
    if (hasMultipleSegments) {
      slivers.add(SliverToBoxAdapter(child: SegmentTabs()));
      slivers.add(const SliverToBoxAdapter(child: Spacing.height(RLDS.spacing40)));
    }

    // Lessons from selected segment
    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
          child: PathWithNodes(
            lessons: courseLessons,
            lessonKeys: lessonKeys,
            accentColor: getCourseAccentColor(),
            onLessonTap: navigateToLesson,
          ),
        ),
      ),
    );

    // Bottom padding for floating buttons
    slivers.add(const SliverToBoxAdapter(child: Spacing.height(floatingBarBottomClearance)));

    return Material(
      color: RLDS.surface,
      child: Stack(
        children: [
          // Slow drifting pixel-star background behind everything — sits
          // outside SafeArea so the stars paint under the status bar too.
          const Positioned.fill(child: RLStarfieldBackground()),

          SafeArea(
            child: Stack(
              children: [
                // Scrollable content with sticky headers
                CustomScrollView(controller: scrollController, slivers: slivers),

                // Continue bar pinned to the bottom — always visible.
                Positioned(
                  left: RLDS.spacing24,
                  right: RLDS.spacing24,
                  bottom: RLDS.spacing24,
                  child: BottomFloatingBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget BottomFloatingBar() {
    return RLCard.elevated(
      padding: const EdgeInsets.all(RLDS.spacing12),
      child: ContinueButton(),
    );
  }

  static final Widget BackChevronIcon = const Icon(
    Pixel.chevrondown,
    color: RLDS.textPrimary,
    size: RLDS.iconLarge,
  );

  // Padding applied to each non-card sibling in the header. The HeroCard
  // deliberately does NOT get this inset — it spans the full screen width,
  // violating the page margin, so the info panel reads as a banner strip
  // anchored to both screen edges.
  static const EdgeInsets roadmapHeaderSidePadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing24,
  );

  Widget RoadmapHeader() {
    final String courseTitle =
        courseData?['title'] as String? ?? RLUIStrings.ROADMAP_DEFAULT_TITLE;
    final String courseAuthor =
        courseData?['author'] as String? ?? RLUIStrings.ROADMAP_DEFAULT_AUTHOR;
    final String courseDescription = (courseData?['description'] as String? ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacing.height(RLDS.spacing12),

        // Back button — its own row above the book, anchored to the
        // screen-edge inset.
        Padding(
          padding: roadmapHeaderSidePadding,
          child: Div.row(
            [BackChevronIcon],
            padding: RLDS.spacing8,
            radius: RLDS.borderRadiusCircle,
            onTap: handleBackTap,
          ),
        ),

        const Spacing.height(RLDS.spacing16),

        // Book + progress ring in its own circular LunarBlur pane,
        // centered, respecting the side padding.
        Padding(
          padding: roadmapHeaderSidePadding,
          child: Center(child: BookRingPane()),
        ),

        const Spacing.height(RLDS.spacing24),

        // Hero card — full-bleed, no side padding, so it stretches the
        // full width of the screen. Intentional violation of the page
        // padding.
        HeroCard(
          courseTitle: courseTitle,
          courseAuthor: courseAuthor,
          courseDescription: courseDescription,
        ),
      ],
    );
  }

  // Circular frosted disc that hosts the progress ring + book. Uses the
  // same RLLunarBlur surface as the HeroCard underneath — surface defaults
  // to RLDS.surface at the standard alpha — so the book pane and the info
  // card read as the same frosted family. Wrapped in a ScaleTransition
  // driven by breathingAnimation so the whole assembly subtly breathes
  // (0.97 ↔ 1.03) — gives the otherwise static token a heartbeat without
  // competing with page content for attention.
  static final BorderRadius bookRingPaneRadius = BorderRadius.circular(
    progressRingSize / 2,
  );

  Widget BookRingPane() {
    return SizedBox(
      width: progressRingSize,
      height: progressRingSize,
      child: ScaleTransition(
        scale: breathingAnimation,
        child: RLLunarBlur(
          borderRadius: bookRingPaneRadius,
          child: ProgressRing(),
        ),
      ),
    );
  }

  static const double progressRingStrokeWidth = 6.0;
  static const double progressRingSize = 176.0;
  // Book assets are square (64x64). 96 = 1.5x the source — a clean nearest-
  // neighbour scale (handled inside RLCourseBookImage) that keeps the
  // pixel-art edges crisp without swallowing the progress ring around it.
  static const double courseBookSize = 96.0;

  Widget CourseBookImage() {
    return RLCourseBookImage(
      courseColor: courseData?['color'] as String?,
      size: courseBookSize,
    );
  }

  Widget ProgressRing() {
    final Color accentColor = getCourseAccentColor();
    final Widget bookCover = CourseBookImage();

    return SizedBox(
      width: progressRingSize,
      height: progressRingSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress arc — the unfilled portion is left transparent so the
          // frosted-dark disc underneath shows through instead of a ghost
          // ring. Painted at 0.5 opacity so it reads as an atmospheric
          // halo rather than competing with the book cover at its centre.
          // Driven off progressRingAnimation so the arc sweeps from 0 to
          // its target with an ease-out curve on screen open.
          SizedBox(
            width: progressRingSize,
            height: progressRingSize,
            child: AnimatedProgressArc(
              animation: progressRingAnimation,
              color: accentColor.withValues(alpha: 0.75),
              strokeWidth: progressRingStrokeWidth,
            ),
          ),

          // Book cover in center
          bookCover,
        ],
      ),
    );
  }

  // Hero card is a text-only info panel that sits underneath the circular
  // book-ring pane. Renders as a full-bleed strip — no border radius, since
  // it touches the screen edges on both sides. Uses RLLunarBlur directly
  // (RLCard.elevated always rounds) with RL_CARD_ALPHA so the
  // frosted-dark tint still matches the BottomFloatingBar and the book disc.
  Widget HeroCard({
    required String courseTitle,
    required String courseAuthor,
    required String courseDescription,
  }) {
    final bool hasDescription = courseDescription.isNotEmpty;

    return RLLunarBlur(
      borderRadius: BorderRadius.zero,
      borderColor: RLDS.transparent,
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title (heading)
          RLTypography.headingMedium(courseTitle, textAlign: TextAlign.center),

          const Spacing.height(RLDS.spacing4),

          // Author (subheading)
          RLTypography.bodyMedium(
            courseAuthor,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),

          // Description — one-line course pitch from the rlockie front
          // matter. Hidden when the course doesn't supply one so the card
          // doesn't show empty padding under the author line.
          RenderIf.condition(
            hasDescription,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacing.height(RLDS.spacing16),

                RLTypography.bodyMedium(
                  courseDescription,
                  color: RLDS.textMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Full-width segment tab row — routes through the shared RLSegmentTabs
  // component so the selected tab gets the same frosted LunarBlur pill
  // treatment as the column-width picker in Settings. Accent colour is the
  // course's own accent so the selected label adopts its palette.
  Widget SegmentTabs() {
    final bool hasNoSegments = courseSegments.length <= 1;

    if (hasNoSegments) {
      return const SizedBox.shrink();
    }

    final List<RLSegmentTabOption<int>> tabOptions = [];

    for (int segmentIndex = 0; segmentIndex < courseSegments.length; segmentIndex++) {
      final JSONMap segment = courseSegments[segmentIndex];
      final String segmentTitle = segment['segment-title'] as String? ?? '';
      final String segmentSymbol = (segment['segment-symbol'] as String? ?? '').trim();
      final bool hasSymbol = segmentSymbol.isNotEmpty;
      final String compactLabel = hasSymbol ? segmentSymbol : getSegmentAcronym(segmentTitle);

      tabOptions.add(
        RLSegmentTabOption<int>(
          value: segmentIndex,
          label: segmentTitle,
          compactLabel: compactLabel,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
      child: RLSegmentTabs<int>(
        options: tabOptions,
        selectedValue: selectedSegmentIndex,
        onChanged: handleSegmentTabTap,
        selectedLabelColor: getCourseAccentColor(),
      ),
    );
  }

  Widget ContinueButton() {
    final Color accentColor = getCourseAccentColor();
    final Color dimmedBackground = accentColor.withValues(alpha: 0.15);

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: dimmedBackground,
      borderRadius: RLDS.borderRadiusSmall,
    );

    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: RLDS.spacing16,
      horizontal: RLDS.spacing24,
    );

    return Div.row(
      [RLTypography.bodyLarge(RLUIStrings.ROADMAP_CONTINUE_LABEL, color: accentColor)],
      width: double.infinity,
      padding: buttonPadding,
      decoration: buttonDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: handleContinueTap,
    );
  }

  void handleContinueTap() {
    const int currentLessonIndex = 0;
    const int currentContentIndex = 0;
    navigateToLesson(currentLessonIndex, currentContentIndex);
  }

  void handleBackTap() {
    Navigator.of(context).pop();
  }

  // Navigates straight into the lesson. The destination's own loading
  // gate (CourseContentViewer paints CourseLoadingScreen while
  // `isLoading` is true) handles the slow path, so this surface no longer
  // forces an intermediate "Chirping" screen for 500ms when there's
  // nothing to wait for.
  void navigateToLesson(int lessonIndex, int contentIndex) {
    // Fire-and-forget — the course is now in the reader's bookshelf as
    // "recently used" the moment they start a lesson. No need to await; the
    // Firestore arrayUnion is idempotent and the UI doesn't depend on it.
    UserService.addSavedCourseId(widget.courseId);

    Navigator.push(
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

// Path with connected lesson nodes
class PathWithNodes extends StatelessWidget {
  final List<dynamic> lessons;
  final List<GlobalKey> lessonKeys;
  final Color accentColor;
  final Function(int, int) onLessonTap;

  const PathWithNodes({
    super.key,
    required this.lessons,
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
      final bool isFreeLesson = lesson['isFree'] == true;
      final bool isLocked = !isFreeLesson;

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
          alignment: alignment,
          accentColor: accentColor,
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

// Individual lesson node on the path. Stateful so it can track the
// press-and-release window — when held, the foreground tile shifts to
// where the shadow sits (right + down by roadmapTileShadowOffset) so the
// node visibly "settles" into the shadow on press, then springs back on
// release. Haptic fires once on tap-down.
class PathLessonNode extends StatefulWidget {
  final JSONMap lesson;
  final PathNodeAlignment alignment;
  final Color accentColor;
  final bool isLocked;
  final VoidCallback onTap;

  const PathLessonNode({
    super.key,
    required this.lesson,
    required this.alignment,
    required this.accentColor,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<PathLessonNode> createState() => PathLessonNodeState();
}

class PathLessonNodeState extends State<PathLessonNode> {
  static const double roadmapTileShadowOffset = 4.0;
  static const double roadmapTileIconSize = 32.0;

  bool isPressed = false;

  void handleTapDown(TapDownDetails details) {
    if (widget.isLocked) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      isPressed = true;
    });
  }

  void handleTapUp(TapUpDetails details) {
    if (!isPressed) {
      return;
    }

    setState(() {
      isPressed = false;
    });
  }

  void handleTapCancel() {
    if (!isPressed) {
      return;
    }

    setState(() {
      isPressed = false;
    });
  }

  void handleTap() {
    if (widget.isLocked) {
      return;
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.lesson['title'] ?? RLUIStrings.ROADMAP_DEFAULT_LESSON_LABEL;
    final double offsetX = getOffsetForAlignment();
    final Color titleColor = getTitleColor();

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Column(
        children: [
          // Pixel-style square tile — opaque hit-test so the entire box
          // (including the shadow inset) registers presses.
          GestureDetector(
            onTapDown: handleTapDown,
            onTapUp: handleTapUp,
            onTapCancel: handleTapCancel,
            onTap: handleTap,
            behavior: HitTestBehavior.opaque,
            child: NodeTile(),
          ),

          const Spacing.height(RLDS.spacing8),

          // Lesson title in 8-bit font
          SizedBox(
            width: lessonTitleWidth,
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
    switch (widget.alignment) {
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
    if (widget.isLocked) {
      return RLDS.textSecondary.withValues(alpha: 0.5);
    }

    return RLDS.textPrimary;
  }

  Widget NodeTile() {
    final Color bgColor = getBackgroundColor();
    final Widget nodeContent = NodeIcon();

    // Borderless circular tile.
    final BoxDecoration tileDecoration = BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
    );

    // Circular drop shadow offset down+right.
    final BoxDecoration shadowDecoration = BoxDecoration(
      color: RLDS.black.withValues(alpha: 0.5),
      shape: BoxShape.circle,
    );

    // When pressed, the foreground tile slides into the shadow's slot and
    // the shadow itself fades out — the result reads as the tile being
    // physically pushed down and to the right by the shadow distance.
    final double tileLeftOffset = isPressed ? roadmapTileShadowOffset : 0.0;
    final double tileTopOffset = isPressed ? roadmapTileShadowOffset : 0.0;
    final double shadowOpacity = isPressed ? 0.0 : 1.0;

    return SizedBox(
      width: roadmapNodeSize + roadmapTileShadowOffset,
      height: roadmapNodeSize + roadmapTileShadowOffset,
      child: Stack(
        children: [
          // Offset drop shadow — hidden while pressed so the foreground
          // tile reads as having "landed" on top of it.
          Positioned(
            left: roadmapTileShadowOffset,
            top: roadmapTileShadowOffset,
            child: Opacity(
              opacity: shadowOpacity,
              child: Container(
                width: roadmapNodeSize,
                height: roadmapNodeSize,
                decoration: shadowDecoration,
              ),
            ),
          ),

          // Foreground tile — animates between resting (top-left) and
          // pressed (shadow slot) over a single short window so the
          // press feels tactile rather than instantaneous.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            left: tileLeftOffset,
            top: tileTopOffset,
            child: Container(
              width: roadmapNodeSize,
              height: roadmapNodeSize,
              decoration: tileDecoration,
              child: Center(child: nodeContent),
            ),
          ),
        ],
      ),
    );
  }

  Color getBackgroundColor() {
    if (widget.isLocked) {
      return RLDS.backgroundLight;
    }

    return widget.accentColor.withValues(alpha: 0.15);
  }

  // * Tile glyphs — 32px so they land on pixelarticons' 16×16 grid (2x).

  static final Widget LockedIcon = Icon(
    Pixel.lock,
    color: RLDS.textSecondary.withValues(alpha: 0.4),
    size: roadmapTileIconSize,
  );

  Widget PlayIcon() {
    return Icon(Pixel.play, color: widget.accentColor, size: roadmapTileIconSize);
  }

  Widget NodeIcon() {
    if (widget.isLocked) {
      return LockedIcon;
    }

    return PlayIcon();
  }
}

// Thin CustomPaint wrapper that listens to the screen's intro animation and
// hands its eased value to ProgressArcPainter via the painter's `repaint`
// listenable — only the canvas repaints, the widget tree stays still.
class AnimatedProgressArc extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  const AnimatedProgressArc({
    super.key,
    required this.animation,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ProgressArcPainter(
        progressListenable: animation,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

// Custom painter for progress arc
class ProgressArcPainter extends CustomPainter {
  final Animation<double> progressListenable;
  final Color color;
  final double strokeWidth;

  ProgressArcPainter({
    required this.progressListenable,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: progressListenable);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Start from top (-90 degrees) and sweep based on progress
    const double startAngle = -1.5708;
    final double sweepAngle = 2 * 3.14159 * progressListenable.value;

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
    final bool hasProgressChanged = progressListenable != oldDelegate.progressListenable;
    final bool hasColorChanged = color != oldDelegate.color;

    return hasProgressChanged || hasColorChanged;
  }
}
