// Course roadmap screen with winding path
// One long scrollable list with sticky segment tiles

import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/bottom_sheets/NightShiftBottomSheet.dart';
import 'package:readlock/bottom_sheets/course/CoursePurchaseBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/FeathersBottomSheet.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLFeatherIcon.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLSegmentTabs.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/constants/RLCoursePalette.dart';
import 'package:readlock/constants/RLLatestCourse.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/models/CourseProgressModel.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/services/purchases/PurchaseService.dart';
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
  bool isPurchasing = false;

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

    // React to purchase state changes (the only "live" state on this
    // screen). When the user taps Purchase, PurchaseService flips the
    // notifier, this listener fires a setState, and the bottom bar
    // swaps from Purchase to Continue + tiles unlock in the same frame.
    purchasedCoursesNotifier.addListener(handlePurchasedCoursesChanged);

    // The frontier-tile gate (i.e. "you must finish lesson N before
    // lesson N+1 unlocks") reads currentLessonIndex out of the per-course
    // progress notifier, so the roadmap needs to rebuild whenever a
    // Finish-button tap bumps it.
    courseProgressNotifier.addListener(handlePurchasedCoursesChanged);

    progressRingController = AnimationController(
      vsync: this,
      duration: RLDS.opacityFadeDurationIntro,
    );

    progressRingAnimation = Tween<double>(
      begin: 0.0,
      end: roadmapTargetProgress,
    ).animate(CurvedAnimation(parent: progressRingController, curve: Curves.easeOutCubic));

    breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    breathingAnimation = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(parent: breathingController, curve: Curves.easeInOut));

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
      HapticsService.lightImpact();
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

  void handlePurchasedCoursesChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  bool getIsCoursePurchased() {
    return PurchaseService.isCoursePurchased(widget.courseId);
  }

  // The highest lesson index the reader has reached on this course. Used
  // by the path to gate which tiles are tappable (i <= frontier) and to
  // mark the active node. Returns 0 for a fresh purchase (lesson 0
  // tappable, rest locked) and stays 0 for unpurchased courses too —
  // the purchase gate already overrides everything in that case.
  int getCurrentLessonFrontier() {
    final CourseProgressModel? progress = courseProgressNotifier.value[widget.courseId];

    if (progress == null) {
      return 0;
    }

    return progress.currentLessonIndex;
  }

  @override
  void dispose() {
    purchasedCoursesNotifier.removeListener(handlePurchasedCoursesChanged);
    courseProgressNotifier.removeListener(handlePurchasedCoursesChanged);
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

    // Lessons from selected segment. Tile-lock state combines the
    // per-lesson `isFree` flag with the course-wide purchase gate, so
    // every tile reads as locked until the reader buys the course —
    // except lessons explicitly marked free in the JSON, which stay
    // unlocked as previews.
    final bool isCoursePurchased = getIsCoursePurchased();

    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
          child: PathWithNodes(
            lessons: courseLessons,
            lessonKeys: lessonKeys,
            accentColor: getCourseAccentColor(),
            isCoursePurchased: isCoursePurchased,
            currentLessonFrontier: getCurrentLessonFrontier(),
            onLessonTap: navigateToLesson,
            breathingAnimation: breathingAnimation,
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

                // Continue / purchase CTA pinned to the bottom — always
                // visible, painted as a standalone surface-coloured pill
                // (no card chrome behind it).
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

  // Floating bottom bar — bare button, no RLCard chrome. The button
  // itself owns its full surface treatment (RLDS.surface fill + white
  // label), so the bar reads as a single floating pill rather than a
  // tinted button nested inside a card.
  Widget BottomFloatingBar() {
    final bool isCoursePurchased = getIsCoursePurchased();

    if (isCoursePurchased) {
      return ContinueButton();
    }

    return PurchaseButton();
  }

  // Feather-priced purchase button. Reads cost from PurchaseConstants so
  // the price label and the deduction always agree. Tapping fires
  // PurchaseService.purchaseCourse which optimistically flips the
  // notifier (continue button replaces this in the next frame) and
  // writes both Firestore mutations atomically.
  //
  // Frosted LunarBlur surface (same defaults as the HeroCard and the
  // book-ring disc) so every floating surface in this screen reads as
  // the same family. Label adopts the course's accent so the CTA
  // colour-matches the book it belongs to.
  Widget PurchaseButton() {
    final Color accentColor = getCourseAccentColor();

    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: RLDS.spacing16,
      horizontal: RLDS.spacing24,
    );

    final List<Widget> labelChildren;

    if (isPurchasing) {
      labelChildren = [
        RLTypography.bodyLarge(RLUIStrings.ROADMAP_PURCHASE_LOADING_LABEL, color: accentColor),
      ];
    } else {
      // Same "Buy for 10 <plume>" shape as the CoursePurchaseBottomSheet
      // button so both surfaces read as the same family.
      final String labelWithCost =
          '${RLUIStrings.ROADMAP_PURCHASE_LABEL} '
          '${PurchaseConstants.COURSE_PURCHASE_COST}';

      labelChildren = [
        RLTypography.bodyLarge(labelWithCost, color: accentColor),

        const Spacing.width(RLDS.spacing8),

        const RLFeatherIcon(size: RLDS.iconSmall),
      ];
    }

    void onButtonTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      handlePurchaseTap();
    }

    final VoidCallback? buttonTap = isPurchasing ? null : onButtonTap;

    // Outer GestureDetector with HitTestBehavior.opaque so the entire
    // padded surface picks up taps (the inner Div has no fill, so empty
    // space between the label and the icon would otherwise swallow hits).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: buttonTap,
      child: RLLunarBlur(
        borderRadius: RLDS.borderRadiusSmall,
        borderColor: RLDS.transparent,
        child: Div.row(
          labelChildren,
          width: double.infinity,
          padding: buttonPadding,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Future<void> handlePurchaseTap() async {
    if (isPurchasing) {
      return;
    }

    setState(() {
      isPurchasing = true;
    });

    final PurchaseResult result = await PurchaseService.purchaseCourse(widget.courseId);

    if (!mounted) {
      return;
    }

    setState(() {
      isPurchasing = false;
    });

    if (result == PurchaseResult.success) {
      SoundService.playPurchase();
      RLToast.success(context, RLUIStrings.ROADMAP_PURCHASE_SUCCESS, playSound: false);
      return;
    }

    if (result == PurchaseResult.insufficientFeathers) {
      // Out of feathers — push them straight to the Feathers Plan sheet
      // so they can top up without leaving the roadmap.
      FeathersBottomSheet.show(context);
      return;
    }

    RLToast.error(context, RLUIStrings.ERROR_UNKNOWN);
  }

  static final Widget BackChevronIcon = const Icon(
    Pixel.chevrondown,
    color: RLDS.textPrimary,
    size: RLDS.iconLarge,
  );

  // Warm amber moon — same accent the Settings, Night Session row uses,
  // sourced from NightShiftBottomSheet so all three surfaces stay in sync.
  static final Widget NightShiftHeaderIcon = const Icon(
    Pixel.moon,
    color: NIGHT_SHIFT_WARM_COLOR,
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

        // Back button + Night Shift entry. Single row above the book,
        // anchored to the screen-edge inset. Night Shift sits at the right
        // edge so the reader can warm the screen from the roadmap before
        // diving into a lesson.
        Padding(
          padding: roadmapHeaderSidePadding,
          child: Div.row([
            Div.row(
              [BackChevronIcon],
              padding: RLDS.spacing8,
              radius: RLDS.borderRadiusCircle,
              onTap: handleBackTap,
            ),

            Div.row(
              [NightShiftHeaderIcon],
              padding: RLDS.spacing8,
              radius: RLDS.borderRadiusCircle,
              onTap: handleNightShiftTap,
            ),
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
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
  static final BorderRadius bookRingPaneRadius = BorderRadius.circular(progressRingSize / 2);

  Widget BookRingPane() {
    return SizedBox(
      width: progressRingSize,
      height: progressRingSize,
      child: ScaleTransition(
        scale: breathingAnimation,
        child: RLLunarBlur(
          borderRadius: bookRingPaneRadius,
          borderColor: RLDS.transparent,
          child: ProgressRing(),
        ),
      ),
    );
  }

  static const double progressRingStrokeWidth = 6.0;
  static const double progressRingSize = 176.0;
  // Book assets are square (64x64). 96 = 1.5x the source — a clean nearest-
  // neighbour scale (handled inside RLSkillBookImage) that keeps the
  // pixel-art edges crisp without swallowing the progress ring around it.
  static const double skillBookSize = 96.0;

  Widget CourseBookImage() {
    return RLSkillBookImage(courseColor: courseData?['color'] as String?, size: skillBookSize);
  }

  // While the course is locked the entire frosted disc gets a darkening
  // film + a centred lock glyph stacked on top — sized and shaped to
  // match the book-ring pane (a circle at progressRingSize) so the gate
  // reads as "the whole disc is locked" instead of "a square box
  // pasted on the book". Plain Stack, no blur — the book cover and the
  // progress arc still show through the dim. Drops the moment a
  // purchase flips purchasedCoursesNotifier and the parent rebuilds.
  static const double discLockOverlayAlpha = 0.55;
  static const double discLockGlyphSize = RLDS.iconXXLarge;

  Widget LockedDiscOverlay() {
    final Color overlayColor = RLDS.black.withValues(alpha: discLockOverlayAlpha);

    const Widget LockGlyph = Icon(Pixel.lock, color: RLDS.white, size: discLockGlyphSize);

    final BoxDecoration overlayDecoration = BoxDecoration(
      color: overlayColor,
      shape: BoxShape.circle,
    );

    return GestureDetector(
      onTap: handleLockTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: progressRingSize,
        height: progressRingSize,
        decoration: overlayDecoration,
        alignment: Alignment.center,
        child: LockGlyph,
      ),
    );
  }

  // Routes the lock-disc tap to whichever sheet matches the reader's
  // wallet state. Enough feathers, the standard purchase sheet opens with
  // the live course payload so they can confirm the buy. Not enough, we
  // skip the purchase sheet entirely and go straight to the Feathers Plan
  // sheet so the next action is "top up", not "be told no".
  void handleLockTap() {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    final JSONMap? course = courseData;
    final bool hasNoCourseData = course == null;

    if (hasNoCourseData) {
      return;
    }

    final int currentBalance = userBalanceNotifier.value;
    final int courseCost = PurchaseConstants.COURSE_PURCHASE_COST;
    final bool hasEnoughFeathers = currentBalance >= courseCost;

    if (!hasEnoughFeathers) {
      FeathersBottomSheet.show(context);
      return;
    }

    CoursePurchaseBottomSheet.show(context, course: course);
  }

  Widget ProgressRing() {
    final Color accentColor = getCourseAccentColor();
    final bool isCoursePurchased = getIsCoursePurchased();

    final List<Widget> ringLayers = [
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
          color: RLDS.glass70(accentColor),
          strokeWidth: progressRingStrokeWidth,
        ),
      ),

      // Book cover in centre — always rendered; the locked-disc overlay
      // sits on top so the cover art still reads through the dim.
      CourseBookImage(),
    ];

    if (!isCoursePurchased) {
      ringLayers.add(LockedDiscOverlay());
    }

    return SizedBox(
      width: progressRingSize,
      height: progressRingSize,
      child: Stack(alignment: Alignment.center, children: ringLayers),
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

      tabOptions.add(
        RLSegmentTabOption<int>(
          value: segmentIndex,
          label: segmentTitle,
          unselectedIcon: Pixel.eye,
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

    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: RLDS.spacing16,
      horizontal: RLDS.spacing24,
    );

    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      borderColor: RLDS.transparent,
      child: Div.row(
        [RLTypography.bodyLarge(RLUIStrings.ROADMAP_CONTINUE_LABEL, color: accentColor)],
        width: double.infinity,
        padding: buttonPadding,
        mainAxisAlignment: MainAxisAlignment.center,
        onTap: handleContinueTap,
      ),
    );
  }

  void handleContinueTap() {
    const int currentLessonIndex = 0;
    const int currentContentIndex = 0;
    navigateToLesson(currentLessonIndex, currentContentIndex);
  }

  void handleBackTap() {
    SoundService.playRandomTextClick();
    Navigator.of(context).pop();
  }

  void handleNightShiftTap() {
    SoundService.playRandomTextClick();

    NightShiftBottomSheet.show(context);
  }

  // Navigates straight into the lesson. The destination's own loading
  // gate (CourseContentViewer paints CourseLoadingScreen while
  // `isLoading` is true) handles the slow path, so this surface no longer
  // forces an intermediate "Chirping" screen for 500ms when there's
  // nothing to wait for.
  //
  // `lessonIndex` is segment-local (the index inside the path the reader
  // is looking at). CourseDetailScreen indexes into the FLATTENED list
  // of every segment's lessons, so we add the cumulative length of every
  // earlier segment before pushing — otherwise tapping lesson 0 in any
  // segment past the first would always open the course's very first
  // lesson.
  void navigateToLesson(int lessonIndex, int contentIndex) {
    SoundService.playEnter();

    // Mark this course as the latest opened. The notifier is updated
    // optimistically so HomeScreen's "Reading now…" card reflects the
    // tap immediately when the user pops back; the Firestore write
    // catches up async so a fresh launch on another device sees the
    // same course pinned at the top.
    lastOpenedCourseIdNotifier.value = widget.courseId;
    UserService.updateLastOpenedCourseId(widget.courseId);

    final int absoluteLessonIndex = computeAbsoluteLessonIndex(lessonIndex);

    Navigator.push(
      context,
      RLDS.slowFadeTransition(
        CourseDetailScreen(
          courseId: widget.courseId,
          initialLessonIndex: absoluteLessonIndex,
          initialContentIndex: contentIndex,
        ),
      ),
    );
  }

  // Sums lesson counts of every segment before the active one, then adds
  // the segment-local index. Returns the position in the flattened
  // course-wide lesson list that CourseDetailScreen expects.
  int computeAbsoluteLessonIndex(int localLessonIndex) {
    int precedingLessonCount = 0;

    for (int segmentIdx = 0; segmentIdx < selectedSegmentIndex; segmentIdx++) {
      final JSONMap segment = courseSegments[segmentIdx];
      final JSONList segmentLessons = JSONList.from(segment['lessons'] ?? []);

      precedingLessonCount += segmentLessons.length;
    }

    return precedingLessonCount + localLessonIndex;
  }
}

// Path with connected lesson nodes. Two locks gate each tile:
//   1. Course purchase gate — every tile is locked until the course is
//      bought, except lessons flagged `isFree: true` in the course JSON
//      which stay tappable as previews.
//   2. Frontier gate — once purchased, only tiles up to and including
//      `currentLessonFrontier` are tappable, so the reader has to finish
//      the active lesson (which then bumps the frontier) before the
//      next one unlocks.
// Both notifiers (purchasedCoursesNotifier, courseProgressNotifier) drive
// a setState on the parent so the path re-renders the moment either
// changes.
class PathWithNodes extends StatelessWidget {
  final List<dynamic> lessons;
  final List<GlobalKey> lessonKeys;
  final Color accentColor;
  final bool isCoursePurchased;
  final int currentLessonFrontier;
  final Function(int, int) onLessonTap;
  // Shared with the BookRingPane so every lesson tile breathes in lock-step
  // with the book disc — one heartbeat across the screen instead of N
  // independently driven controllers.
  final Animation<double> breathingAnimation;

  const PathWithNodes({
    super.key,
    required this.lessons,
    required this.lessonKeys,
    required this.accentColor,
    required this.isCoursePurchased,
    required this.currentLessonFrontier,
    required this.onLessonTap,
    required this.breathingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: PathNodes());
  }

  List<Widget> PathNodes() {
    final List<Widget> nodes = [];

    for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
      final JSONMap lesson = lessons[lessonIndex] as JSONMap;
      final bool isFreePreview = (lesson['isFree'] as bool?) ?? false;

      // Tile-lock = course-wide purchase gate (with isFree preview
      // exemption) OR frontier gate (lesson sits past the highest
      // unlocked one for a purchased course).
      final bool failsPurchaseGate = !isCoursePurchased && !isFreePreview;
      final bool failsFrontierGate = isCoursePurchased && lessonIndex > currentLessonFrontier;
      final bool isLocked = failsPurchaseGate || failsFrontierGate;
      final bool isActiveFrontier = isCoursePurchased && lessonIndex == currentLessonFrontier;

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
          // Title-blur signal: only fire when the course itself is locked
          // (purchase gate failed), so a paid-up reader's frontier-gated
          // lessons keep their titles legible as a "what's next" preview.
          shouldBlurTitle: failsPurchaseGate,
          isActiveFrontier: isActiveFrontier,
          onTap: () => onLessonTap(lessonIndex, 0),
          breathingAnimation: breathingAnimation,
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
  // When true the lesson title renders behind the same Gaussian blur the
  // bird picker uses for locked-bird captions, so the silhouette of the
  // word reads as "there's a lesson here" without giving away its name.
  final bool shouldBlurTitle;
  // True for the single tile that sits at the reader's current frontier
  // (the tappable one furthest down the path). The tile reuses the
  // existing unlocked styling but the parent could later overlay a
  // distinct marker if the design wants the active lesson called out
  // beyond "tappable".
  final bool isActiveFrontier;
  final VoidCallback onTap;
  final Animation<double> breathingAnimation;

  const PathLessonNode({
    super.key,
    required this.lesson,
    required this.alignment,
    required this.accentColor,
    required this.isLocked,
    required this.shouldBlurTitle,
    required this.isActiveFrontier,
    required this.onTap,
    required this.breathingAnimation,
  });

  @override
  State<PathLessonNode> createState() => PathLessonNodeState();
}

class PathLessonNodeState extends State<PathLessonNode> {
  static const double roadmapTileShadowOffset = 4.0;
  static const double roadmapTileIconSize = RLDS.iconXLarge;

  bool isPressed = false;

  void handleTapDown(TapDownDetails details) {
    if (widget.isLocked) {
      return;
    }

    HapticsService.lightImpact();

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
    final String title = widget.lesson['title'] ?? RLUIStrings.ROADMAP_DEFAULT_LESSON_LABEL;
    final double offsetX = getOffsetForAlignment();
    final Color titleColor = getTitleColor();

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Column(
        children: [
          // Pixel-style square tile — opaque hit-test so the entire box
          // (including the shadow inset) registers presses. Wrapped in the
          // shared breathing animation so the tile pulses in lock-step
          // with the book disc above it.
          ScaleTransition(
            scale: widget.breathingAnimation,
            child: GestureDetector(
              onTapDown: handleTapDown,
              onTapUp: handleTapUp,
              onTapCancel: handleTapCancel,
              onTap: handleTap,
              behavior: HitTestBehavior.opaque,
              child: NodeTile(),
            ),
          ),

          const Spacing.height(RLDS.spacing8),

          // Lesson title in 8-bit font. Frosted with the bird-picker
          // locked-caption blur when the course gate is locked so the
          // title shape teases the lesson without spoiling it.
          SizedBox(
            width: lessonTitleWidth,
            child: LessonTitleLabel(title: title, color: titleColor),
          ),
        ],
      ),
    );
  }

  // Pixel label wrapped in the shared locked-text blur when the parent
  // has flagged the title as gated. Same ImageFilter sigma the bird
  // picker uses for locked-bird captions.
  Widget LessonTitleLabel({required String title, required Color color}) {
    final Widget label = RLTypography.pixelLabel(
      title,
      color: color,
      textAlign: TextAlign.center,
    );

    if (!widget.shouldBlurTitle) {
      return label;
    }

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: RLDS.lockedTextBlurSigma,
        sigmaY: RLDS.lockedTextBlurSigma,
      ),
      child: label,
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
      return RLDS.glass50(RLDS.textSecondary);
    }

    return RLDS.textPrimary;
  }

  Widget NodeTile() {
    final Color bgColor = getBackgroundColor();
    final Widget nodeContent = NodeIcon();

    // Borderless circular tile.
    final BoxDecoration tileDecoration = BoxDecoration(color: bgColor, shape: BoxShape.circle);

    // Circular drop shadow offset down+right.
    final BoxDecoration shadowDecoration = BoxDecoration(
      color: RLDS.glass50(RLDS.black),
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

    return RLDS.glass15(widget.accentColor);
  }

  // * Tile glyphs — 32px so they land on pixelarticons' 16×16 grid (2x).

  static final Widget LockedIcon = Icon(
    Pixel.lock,
    color: RLDS.glass40(RLDS.textSecondary),
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
