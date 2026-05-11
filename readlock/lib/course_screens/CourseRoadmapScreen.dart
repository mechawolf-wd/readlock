// Course roadmap screen with winding path
// One long scrollable list with sticky segment tiles

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readlock/design_system/RLChargeBar.dart';
import 'package:readlock/design_system/RLStaggerReveal.dart';
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
import 'package:readlock/models/PurchasedCourseModel.dart';
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
  bool isCharging = false;

  // Battery icon animation for the charge button. Cycles through
  // empty → 1 bar → 2 bars → full on a timer to convey "recharge".
  static const List<IconData> batteryAnimationFrames = [
    Pixel.battery,
    Pixel.battery1,
    Pixel.battery2,
    Pixel.batteryfull,
  ];

  int batteryFrameIndex = 0;
  Timer? batteryAnimationTimer;

  // Absolute frontier before the latest progress notifier fire. -1 until
  // fetchCourseData sets the initial value (prevents false detection).
  int previousFrontier = -1;

  // Segment-local index of a lesson held as locked until the scroll and
  // reveal sequence finishes. Null when no unlock animation is pending.
  int? newlyUnlockedLessonIndex;

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

    // Tween starts at zero; real target is set in fetchCourseData once
    // the segment list and frontier are known.
    progressRingAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
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

    // Detect whether the lesson frontier just advanced so the roadmap
    // can scroll to and animate the newly unlocked node.
    final int currentFrontier = getCurrentLessonFrontier();
    final bool isInitialized = previousFrontier >= 0;
    final bool frontierAdvanced = isInitialized && currentFrontier > previousFrontier;
    final int totalLessons = getTotalLessonCount();
    final bool hasNextLesson = currentFrontier < totalLessons;
    final bool isCoursePurchased = getIsCoursePurchased();
    final bool shouldAnimateUnlock = frontierAdvanced && hasNextLesson && isCoursePurchased;

    if (shouldAnimateUnlock) {
      final int segmentLocalFrontier = computeSegmentLocalFrontier();
      final bool isInCurrentSegment =
          segmentLocalFrontier >= 0 && segmentLocalFrontier < courseLessons.length;

      if (isInCurrentSegment) {
        newlyUnlockedLessonIndex = segmentLocalFrontier;
        scheduleUnlockReveal(segmentLocalFrontier);
      } else {
        // The frontier crossed into a different segment (typically the
        // next one after finishing the last lesson of the current segment).
        // Switch the tab so the reader sees the newly unlocked lesson.
        final int targetSegment = getSegmentForAbsoluteIndex(currentFrontier);
        final bool isDifferentSegment = targetSegment != selectedSegmentIndex;

        if (isDifferentSegment) {
          selectedSegmentIndex = targetSegment;
          loadSegmentLessons(targetSegment);
          lastLessonAtThreshold = -1;

          final int newLocalFrontier = computeSegmentLocalFrontier();
          final bool isValidLocalFrontier =
              newLocalFrontier >= 0 && newLocalFrontier < courseLessons.length;

          if (isValidLocalFrontier) {
            newlyUnlockedLessonIndex = newLocalFrontier;
            scheduleUnlockReveal(newLocalFrontier);
          }
        }
      }
    }

    previousFrontier = currentFrontier;
    updateProgressRing();
    setState(() {});
  }

  // Waits for the pop transition to settle, scrolls the path so the
  // newly unlocked node is centred, then clears the lock override so
  // the node transitions from locked to available.
  void scheduleUnlockReveal(int segmentLocalIndex) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) {
        return;
      }

      scrollToLesson(segmentLocalIndex);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) {
          return;
        }

        HapticsService.lightImpact();

        setState(() {
          newlyUnlockedLessonIndex = null;
        });
      });
    });
  }

  void scrollToLesson(int segmentLocalIndex) {
    final bool isOutOfBounds = segmentLocalIndex < 0 || segmentLocalIndex >= lessonKeys.length;

    if (isOutOfBounds) {
      return;
    }

    final GlobalKey key = lessonKeys[segmentLocalIndex];
    final BuildContext? keyContext = key.currentContext;

    if (keyContext == null) {
      return;
    }

    isProgrammaticScroll = true;

    Scrollable.ensureVisible(
      keyContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      alignment: 0.5,
    ).then((_) {
      isProgrammaticScroll = false;
    });
  }

  bool getIsCoursePurchased() {
    return PurchaseService.isCoursePurchased(widget.courseId);
  }

  // Live read of the rental's expires timestamp. Null means the user
  // doesn't own the course at all (purchase gate still applies); when
  // the entry exists but expires has lapsed the book is "discharged"
  // and only the resurrect/charge action can move forward.
  PurchasedCourseModel? getPurchasedEntry() {
    return PurchaseService.findPurchasedEntry(purchasedCoursesNotifier.value, widget.courseId);
  }

  bool getIsSkillbookCharged() {
    return PurchaseService.isCourseActive(widget.courseId);
  }

  // Time left on the current rental. Floors at zero so the discharged
  // state never reports a negative duration to the bar / label.
  Duration getChargeRemainingDuration() {
    final PurchasedCourseModel? entry = getPurchasedEntry();

    if (entry == null) {
      return Duration.zero;
    }

    final Duration remaining = entry.expires.difference(DateTime.now());
    final bool hasExpired = remaining.isNegative;

    if (hasExpired) {
      return Duration.zero;
    }

    return remaining;
  }

  // Fraction of the rental window still on the meter. 1.0 right after a
  // fresh purchase or a successful charge, 0.0 once the timer has lapsed.
  // Drives the progress bar fill on the charge pill.
  double getChargeFraction() {
    final Duration remaining = getChargeRemainingDuration();
    final Duration window = const Duration(days: PurchaseConstants.COURSE_RENTAL_DAYS);

    final double rawFraction = remaining.inSeconds / window.inSeconds;
    final double clampedFraction = rawFraction.clamp(0.0, 1.0).toDouble();

    return clampedFraction;
  }

  // Human-readable "X days left" / "1 day left" / "8 hours left" suffix.
  // Falls through to hours under a day so the last-day stretch still
  // reads as a moving number rather than a stuck "0 days left".
  String getChargeRemainingLabel() {
    final Duration remaining = getChargeRemainingDuration();
    final int totalDays = remaining.inDays;
    final int totalHours = remaining.inHours;

    if (totalDays > 1) {
      return '$totalDays ${RLUIStrings.ROADMAP_DAYS_LEFT_SUFFIX}';
    }

    if (totalDays == 1) {
      return '1 ${RLUIStrings.ROADMAP_DAY_LEFT_SUFFIX}';
    }

    return '$totalHours ${RLUIStrings.ROADMAP_HOURS_LEFT_SUFFIX}';
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

  // Total lesson count across every segment in the course.
  int getTotalLessonCount() {
    int total = 0;

    for (int segmentIdx = 0; segmentIdx < courseSegments.length; segmentIdx++) {
      final JSONMap segment = courseSegments[segmentIdx];
      final JSONList segmentLessons = JSONList.from(segment['lessons'] ?? []);

      total += segmentLessons.length;
    }

    return total;
  }

  // Fraction of the course the reader has reached (frontier / total).
  // 0.0 for a fresh start, approaches 1.0 as the reader nears the end.
  double getProgressFraction() {
    final int total = getTotalLessonCount();
    final bool hasNoLessons = total == 0;

    if (hasNoLessons) {
      return 0.0;
    }

    final int frontier = getCurrentLessonFrontier();
    final double fraction = frontier / total;

    return fraction.clamp(0.0, 1.0);
  }

  // Rebuilds the progress ring tween from the current animation value
  // to the live progress fraction so the arc animates smoothly to its
  // new target whenever the frontier advances.
  void updateProgressRing() {
    final double currentValue = progressRingAnimation.value;
    final double targetProgress = getProgressFraction();

    progressRingAnimation = Tween<double>(
      begin: currentValue,
      end: targetProgress,
    ).animate(CurvedAnimation(parent: progressRingController, curve: Curves.easeOutCubic));

    progressRingController.forward(from: 0.0);
  }

  @override
  void dispose() {
    batteryAnimationTimer?.cancel();
    purchasedCoursesNotifier.removeListener(handlePurchasedCoursesChanged);
    courseProgressNotifier.removeListener(handlePurchasedCoursesChanged);
    scrollController.removeListener(handleScrollUpdate);
    scrollController.dispose();
    progressRingController.dispose();
    breathingController.dispose();
    super.dispose();
  }

  void startBatteryAnimation() {
    final bool alreadyRunning = batteryAnimationTimer != null;

    if (alreadyRunning) {
      return;
    }

    batteryAnimationTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          batteryFrameIndex = (batteryFrameIndex + 1) % batteryAnimationFrames.length;
        });
      },
    );
  }

  void stopBatteryAnimation() {
    batteryAnimationTimer?.cancel();
    batteryAnimationTimer = null;
    batteryFrameIndex = 0;
  }

  Future<void> fetchCourseData() async {
    try {
      courseData = await CourseDataService.fetchCourseById(widget.courseId);

      final bool hasCourseData = courseData != null;

      if (hasCourseData) {
        courseSegments = JSONList.from(courseData!['segments'] ?? []);

        // Open the segment that contains the reader's frontier so
        // returning to a mid-course book lands on the right tab.
        final int frontierIndex = getCurrentLessonFrontier();
        final int frontierSegment = getSegmentForAbsoluteIndex(frontierIndex);

        selectedSegmentIndex = frontierSegment;
        loadSegmentLessons(frontierSegment);
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isCourseDataLoading = false;
      });
      updateProgressRing();
      previousFrontier = getCurrentLessonFrontier();
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
      newlyUnlockedLessonIndex = null;
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
            isSkillbookCharged: getIsSkillbookCharged(),
            currentLessonFrontier: computeSegmentLocalFrontier(),
            onLessonTap: navigateToLesson,
            breathingAnimation: breathingAnimation,
            newlyUnlockedLessonIndex: newlyUnlockedLessonIndex,
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
    final bool isSkillbookCharged = getIsSkillbookCharged();
    final bool isOwnedAndDischarged = isCoursePurchased && !isSkillbookCharged;

    if (isOwnedAndDischarged) {
      startBatteryAnimation();
      return ChargeButton();
    } else {
      stopBatteryAnimation();
    }

    final int currentFrontier = getCurrentLessonFrontier();
    final bool hasStartedCourse = currentFrontier > 0;
    final bool shouldShowContinue = isCoursePurchased && hasStartedCourse;

    if (shouldShowContinue) {
      return ContinueButton();
    }

    if (!isCoursePurchased) {
      return PurchaseButton();
    }

    return const SizedBox.shrink();
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

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: buttonTap,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          borderColor: RLDS.transparent,
          child: Div.row(
            labelChildren,
            padding: buttonPadding,
          ),
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

  // * Skillbook charge button — shown when the course is owned but its
  // rental has lapsed. Green animated battery icon cycles from empty to
  // full on a loop so the button reads as "recharge me". Tapping fires
  // PurchaseService.resurrectCourse which optimistically extends the
  // entry's expires timestamp; success flips the bar back to
  // ContinueButton in the next frame.
  Widget ChargeButton() {
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: RLDS.spacing12,
      horizontal: RLDS.spacing16,
    );

    final IconData currentBatteryFrame = batteryAnimationFrames[batteryFrameIndex];

    final Widget batteryIcon = Icon(
      currentBatteryFrame,
      color: RLDS.green,
      size: RLDS.iconLarge,
    );

    final List<Widget> labelChildren;

    if (isCharging) {
      labelChildren = [
        batteryIcon,

        const Spacing.width(RLDS.spacing8),

        RLTypography.bodyLarge(RLUIStrings.ROADMAP_CHARGE_LOADING_LABEL, color: RLDS.green),
      ];
    } else {
      final String costLabel = '${PurchaseConstants.COURSE_RESURRECT_COST}';

      labelChildren = [
        batteryIcon,

        const Spacing.width(RLDS.spacing8),

        RLTypography.bodyLarge(costLabel, color: RLDS.green),

        const Spacing.width(RLDS.spacing4),

        const RLFeatherIcon(size: RLDS.iconSmall),
      ];
    }

    void onButtonTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      handleChargeTap();
    }

    final VoidCallback? buttonTap = isCharging ? null : onButtonTap;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: buttonTap,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          borderColor: RLDS.transparent,
          child: Div.row(
            labelChildren,
            padding: buttonPadding,
          ),
        ),
      ),
    );
  }

  Future<void> handleChargeTap() async {
    if (isCharging) {
      return;
    }

    setState(() {
      isCharging = true;
    });

    final ResurrectResult result = await PurchaseService.resurrectCourse(widget.courseId);

    if (!mounted) {
      return;
    }

    setState(() {
      isCharging = false;
    });

    if (result == ResurrectResult.success) {
      SoundService.playPurchase();
      RLToast.success(context, RLUIStrings.ROADMAP_CHARGE_SUCCESS, playSound: false);
      return;
    }

    if (result == ResurrectResult.insufficientFeathers) {
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

        const Spacing.height(RLDS.spacing16),

        // Charge meter — sits directly under the book disc so the
        // skillbook's rental state reads as an attribute of the cover
        // itself. Hidden for unowned courses; the lock-disc overlay
        // already telegraphs the purchase gate up there.
        Padding(padding: roadmapHeaderSidePadding, child: ChargeStatusPanel()),

        const Spacing.height(RLDS.spacing16),

        // Hero card — full-bleed, no side padding, so it stretches the
        // full width of the screen. Intentional violation of the page
        // padding.
        HeroCard(
          courseTitle: courseTitle,
          courseAuthor: courseAuthor,
          courseDescription: courseDescription,
          isCoursePurchased: getIsCoursePurchased(),
        ),
      ],
    );
  }

  // * Charge meter — pixel-font label over a thin progress bar, both
  // tinted with the course's own accent. The bar wears a soft halo
  // mirroring the surprise-me button on HomeScreen (RLDS.glowDecoration
  // with glass40-tinted brand color, blurRadius 12, spreadRadius 1) so
  // the meter reads as a charged piece of the skillbook rather than
  // chrome stacked on top.
  static const double chargeGlowBlurRadius = 12.0;
  static const double chargeGlowSpreadRadius = 1.0;

  Widget ChargeStatusPanel() {
    final bool isCoursePurchased = getIsCoursePurchased();

    if (!isCoursePurchased) {
      return const SizedBox.shrink();
    }

    final bool isSkillbookCharged = getIsSkillbookCharged();
    final double chargeFraction = getChargeFraction();

    return Div.column([
      ChargeStatusHeadline(
        chargeFraction: chargeFraction,
        isSkillbookCharged: isSkillbookCharged,
      ),

      const Spacing.height(RLDS.spacing8),

      RLChargeBar(fraction: chargeFraction),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  static const double chargeHeadlineBatterySize = RLDS.iconMedium;

  IconData getBatteryIconForFraction(double fraction) {
    if (fraction >= 0.75) {
      return Pixel.batteryfull;
    }

    if (fraction >= 0.50) {
      return Pixel.battery2;
    }

    if (fraction >= 0.25) {
      return Pixel.battery1;
    }

    final bool isCompletelyEmpty = fraction <= 0;

    if (isCompletelyEmpty) {
      return Pixel.battery;
    }

    return Pixel.battery1;
  }

  Widget ChargeStatusHeadline({
    required double chargeFraction,
    required bool isSkillbookCharged,
  }) {
    final int chargePercent = (chargeFraction * 100).round();
    final String chargePercentLabel = '$chargePercent%';
    final IconData batteryIcon = getBatteryIconForFraction(chargeFraction);

    // Left side: battery icon + percentage
    final Widget chargeIndicator = Div.row([
      Icon(batteryIcon, color: RLDS.white, size: chargeHeadlineBatterySize),

      const Spacing.width(RLDS.spacing4),

      RLTypography.pixelLabel(chargePercentLabel, color: RLDS.white),
    ]);

    final List<Widget> rowChildren = [chargeIndicator];

    // Right side: remaining time when charged, "Recharge" when discharged
    if (isSkillbookCharged) {
      rowChildren.add(RLTypography.pixelLabel(getChargeRemainingLabel(), color: RLDS.white));
    } else {
      rowChildren.add(
        RLTypography.pixelLabel(RLUIStrings.ROADMAP_DISCHARGED_LABEL, color: RLDS.white),
      );
    }

    return Div.row(rowChildren, mainAxisAlignment: MainAxisAlignment.spaceBetween);
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
      // ring. Painted in the course's full accent so it reads as a
      // confident pour of color. Driven off progressRingAnimation so
      // the arc sweeps from 0 to its target with an ease-out curve on
      // screen open.
      SizedBox(
        width: progressRingSize,
        height: progressRingSize,
        child: AnimatedProgressArc(
          animation: progressRingAnimation,
          color: accentColor,
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
    required bool isCoursePurchased,
  }) {
    final bool hasDescription = courseDescription.isNotEmpty;
    final bool shouldBlurDescription = !isCoursePurchased;

    final Widget descriptionLabel = RLTypography.bodyMedium(
      courseDescription,
      color: RLDS.textMuted,
      textAlign: TextAlign.center,
    );

    final Widget descriptionContent = shouldBlurDescription
        ? ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: RLDS.lockedTextBlurSigma,
              sigmaY: RLDS.lockedTextBlurSigma,
            ),
            child: descriptionLabel,
          )
        : descriptionLabel;

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
          // doesn't show empty padding under the author line. Blurred
          // when the course is locked so the text teases without spoiling.
          RenderIf.condition(
            hasDescription,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [const Spacing.height(RLDS.spacing16), descriptionContent],
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
        showBorder: false,
      ),
    );
  }

  static const double continueButtonSize = 56.0;

  static final Widget ContinuePlayIcon = const Icon(
    Pixel.play,
    color: RLDS.white,
    size: RLDS.iconLarge,
  );

  Widget ContinueButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: handleContinueTap,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          borderColor: RLDS.transparent,
          padding: const EdgeInsets.all(RLDS.spacing16),
          child: ContinuePlayIcon,
        ),
      ),
    );
  }

  void handleContinueTap() {
    final int frontierLessonIndex = getCurrentLessonFrontier();

    SoundService.playEnter();

    lastOpenedCourseIdNotifier.value = widget.courseId;
    UserService.updateLastOpenedCourseId(widget.courseId);

    Navigator.push(
      context,
      RLDS.slowFadeTransition(
        CourseDetailScreen(courseId: widget.courseId, initialLessonIndex: frontierLessonIndex),
      ),
    );
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

  // Finds which segment contains the given absolute (course-wide)
  // lesson index by walking the segment array and summing lesson
  // counts. Returns the segment index, clamped to the last segment
  // when the index sits beyond the final lesson.
  int getSegmentForAbsoluteIndex(int absoluteIndex) {
    int cumulativeLessonCount = 0;

    for (int segmentIdx = 0; segmentIdx < courseSegments.length; segmentIdx++) {
      final JSONMap segment = courseSegments[segmentIdx];
      final JSONList segmentLessons = JSONList.from(segment['lessons'] ?? []);

      cumulativeLessonCount += segmentLessons.length;

      final bool isInThisSegment = absoluteIndex < cumulativeLessonCount;

      if (isInThisSegment) {
        return segmentIdx;
      }
    }

    final int lastSegmentIndex = (courseSegments.length - 1).clamp(0, courseSegments.length);

    return lastSegmentIndex;
  }

  // Inverse of computeAbsoluteLessonIndex: converts the course-wide
  // absolute frontier into a segment-local index for the currently
  // selected segment. When the frontier falls in a preceding segment
  // the result is negative, which makes every tile in the current
  // segment fail the frontier gate (lessonIndex > negative is true).
  // When the frontier is past the current segment, the result exceeds
  // the segment length, so every tile passes.
  int computeSegmentLocalFrontier() {
    final int absoluteFrontier = getCurrentLessonFrontier();
    int precedingLessonCount = 0;

    for (int segmentIdx = 0; segmentIdx < selectedSegmentIndex; segmentIdx++) {
      final JSONMap segment = courseSegments[segmentIdx];
      final JSONList segmentLessons = JSONList.from(segment['lessons'] ?? []);

      precedingLessonCount += segmentLessons.length;
    }

    return absoluteFrontier - precedingLessonCount;
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

const nodeStaggerStepDuration = Duration(milliseconds: 100);

class PathWithNodes extends StatelessWidget {
  final List<dynamic> lessons;
  final List<GlobalKey> lessonKeys;
  final Color accentColor;
  final bool isCoursePurchased;
  final bool isSkillbookCharged;
  final int currentLessonFrontier;
  final Function(int, int) onLessonTap;
  // Shared with the BookRingPane so every lesson tile breathes in lock-step
  // with the book disc, one heartbeat across the screen instead of N
  // independently driven controllers.
  final Animation<double> breathingAnimation;
  // Segment-local index of a lesson whose unlock is being staged. When set,
  // the node at this index renders as locked until the scroll and reveal
  // sequence clears it.
  final int? newlyUnlockedLessonIndex;

  const PathWithNodes({
    super.key,
    required this.lessons,
    required this.lessonKeys,
    required this.accentColor,
    required this.isCoursePurchased,
    required this.isSkillbookCharged,
    required this.currentLessonFrontier,
    required this.onLessonTap,
    required this.breathingAnimation,
    this.newlyUnlockedLessonIndex,
  });

  @override
  Widget build(BuildContext context) {
    return RLStaggerReveal(
      step: nodeStaggerStepDuration,
      fadeWindow: nodeStaggerStepDuration,
      itemCount: lessons.length,
      builder: (BuildContext context, List<double> revealScales) {
        return Column(children: PathNodes(revealScales: revealScales));
      },
    );
  }

  List<Widget> PathNodes({required List<double> revealScales}) {
    final List<Widget> nodes = [];

    for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
      final JSONMap lesson = lessons[lessonIndex] as JSONMap;
      final bool isFreePreview = (lesson['isFree'] as bool?) ?? false;

      // Tile-lock = course-wide purchase gate (with isFree preview
      // exemption) OR frontier gate (lesson sits past the highest
      // unlocked one for a purchased course) OR discharge gate
      // (owned but rental lapsed, every tile locks).
      final bool failsPurchaseGate = !isCoursePurchased && !isFreePreview;
      final bool failsFrontierGate = isCoursePurchased && lessonIndex > currentLessonFrontier;
      final bool failsDischargeGate = isCoursePurchased && !isSkillbookCharged;

      // When a lesson is being staged for the unlock reveal, keep it
      // visually locked until the scroll and animation sequence clears.
      final bool isHeldForUnlock = lessonIndex == newlyUnlockedLessonIndex;
      final bool isLocked =
          failsPurchaseGate || failsFrontierGate || failsDischargeGate || isHeldForUnlock;
      final bool isActiveFrontier =
          isCoursePurchased && lessonIndex == currentLessonFrontier && !isHeldForUnlock;

      // Determine horizontal alignment (zigzag pattern)
      final PathNodeAlignment alignment = getAlignmentForIndex(lessonIndex);

      // Add spacing before node (except first)
      final bool isNotFirstNode = lessonIndex > 0;

      if (isNotFirstNode) {
        nodes.add(const Spacing.height(roadmapNodeVerticalSpacing));
      }

      // Add the lesson node, scaled by the stagger reveal progress
      nodes.add(
        Transform.scale(
          scale: revealScales[lessonIndex],
          child: PathLessonNode(
            key: lessonKeys[lessonIndex],
            lesson: lesson,
            alignment: alignment,
            accentColor: accentColor,
            isCoursePurchased: isCoursePurchased,
            isLocked: isLocked,
            isDischarged: failsDischargeGate,
            // Title-blur signal: only fire when the course itself is locked
            // (purchase gate failed), so a paid-up reader's frontier-gated
            // lessons keep their titles legible as a "what's next" preview.
            shouldBlurTitle: failsPurchaseGate,
            isActiveFrontier: isActiveFrontier,
            onTap: () => onLessonTap(lessonIndex, 0),
            breathingAnimation: breathingAnimation,
          ),
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
  final bool isCoursePurchased;
  final bool isLocked;
  // When true the tile shows a battery-empty icon instead of the lock,
  // signalling "owned but rental lapsed" rather than "not purchased".
  final bool isDischarged;
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
    required this.isCoursePurchased,
    required this.isLocked,
    required this.isDischarged,
    required this.shouldBlurTitle,
    required this.isActiveFrontier,
    required this.onTap,
    required this.breathingAnimation,
  });

  @override
  State<PathLessonNode> createState() => PathLessonNodeState();
}

class PathLessonNodeState extends State<PathLessonNode> with SingleTickerProviderStateMixin {
  static const double roadmapTileShadowOffset = 4.0;
  static const double roadmapTileIconSize = RLDS.iconXLarge;

  bool isPressed = false;

  late AnimationController unlockController;
  late Animation<double> unlockScale;

  @override
  void initState() {
    super.initState();

    unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    unlockScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: unlockController, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(PathLessonNode oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool justUnlocked = oldWidget.isLocked && !widget.isLocked;

    if (justUnlocked) {
      unlockController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    unlockController.dispose();
    super.dispose();
  }

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
            child: ScaleTransition(
              scale: unlockScale,
              child: GestureDetector(
                onTapDown: handleTapDown,
                onTapUp: handleTapUp,
                onTapCancel: handleTapCancel,
                onTap: handleTap,
                behavior: HitTestBehavior.opaque,
                child: NodeTile(),
              ),
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
    final Widget nodeContent = NodeIcon();

    // Borderless circular tile painted with the course accent on
    // unlocked tiles. Locked tiles swap this out below for an
    // RLLunarBlur disc so the foreground matches the Continue
    // button's frosted surface.
    final BoxDecoration tileDecoration = BoxDecoration(
      color: getBackgroundColor(),
      shape: BoxShape.circle,
    );

    // Circular drop shadow offset down+right. Same color for locked
    // and unlocked tiles — only the foreground fill changes — so the
    // shadow reads as a consistent grounding mark across the path.
    final BoxDecoration shadowDecoration = BoxDecoration(
      color: RLDS.glass50(RLDS.black),
      shape: BoxShape.circle,
    );

    // When pressed, the foreground tile slides into the shadow's slot
    // and the shadow itself fades out — the result reads as the tile
    // being physically pushed down and to the right by the shadow
    // distance. Locked tiles never receive taps, so isPressed stays
    // false and the rig sits at rest for them.
    final double tileLeftOffset = isPressed ? roadmapTileShadowOffset : 0.0;
    final double tileTopOffset = isPressed ? roadmapTileShadowOffset : 0.0;
    final double shadowOpacity = isPressed ? 0.0 : 1.0;

    final BorderRadius foregroundRadius = BorderRadius.circular(roadmapNodeSize / 2);

    final Widget foregroundTile = widget.isLocked
        ? SizedBox(
            width: roadmapNodeSize,
            height: roadmapNodeSize,
            child: RLLunarBlur(
              borderRadius: foregroundRadius,
              borderColor: RLDS.transparent,
              child: Center(child: nodeContent),
            ),
          )
        : Container(
            width: roadmapNodeSize,
            height: roadmapNodeSize,
            decoration: tileDecoration,
            child: Center(child: nodeContent),
          );

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
            child: foregroundTile,
          ),
        ],
      ),
    );
  }

  Color getBackgroundColor() {
    return RLDS.glass15(widget.accentColor);
  }

  // * Tile glyphs — 32px so they land on pixelarticons' 16×16 grid (2x).

  static final Widget LockedIcon = Icon(
    Pixel.lock,
    color: RLDS.glass40(RLDS.textSecondary),
    size: roadmapTileIconSize,
  );

  static final Widget DischargedIcon = Icon(
    Pixel.battery,
    color: RLDS.glass40(RLDS.textSecondary),
    size: roadmapTileIconSize,
  );

  Widget PlayIcon() {
    return Icon(Pixel.play, color: widget.accentColor, size: roadmapTileIconSize);
  }

  Widget CompletedIcon() {
    return Icon(Pixel.check, color: widget.accentColor, size: roadmapTileIconSize);
  }

  Widget NodeIcon() {
    if (widget.isLocked) {
      return LockedIcon;
    }

    if (widget.isDischarged) {
      return DischargedIcon;
    }

    // Purchased courses: frontier lesson gets play, earlier ones get checkmark.
    // Unpurchased courses: free preview lessons always get play.
    final bool isCompletedLesson = widget.isCoursePurchased && !widget.isActiveFrontier;

    if (isCompletedLesson) {
      return CompletedIcon();
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
