// Course detail screen — hosts the vertical PageView of CC swipe widgets
// for a single lesson and owns the reading stopwatch, progress chrome,
// and navigation back to the roadmap.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/course_screens/CourseAccentScope.dart';
import 'package:readlock/course_screens/CourseLoadingScreen.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';
import 'package:readlock/course_screens/widgets/CCJSONContentFactory.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/constants/RLCoursePalette.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingColumn.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/bottom_sheets/NightShiftBottomSheet.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLFeedbackSnackbar.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLConfirmationDialog.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/feedback/SoundService.dart';

import 'package:pixelarticons/pixel.dart';

class CourseDetailScreen extends StatefulWidget {
  // Course identifier to load
  final String courseId;

  // Initial lesson to display (0-based index)
  final int initialLessonIndex;

  // Initial content item within the lesson (0-based index)
  final int initialContentIndex;

  // Accent color for the course (passed from the roadmap or home screen
  // so the viewer does not need to fetch the full course document)
  final Color accentColor;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.initialLessonIndex = 0,
    this.initialContentIndex = 0,
    this.accentColor = COURSE_FALLBACK_COLOR,
  });

  @override
  State<CourseDetailScreen> createState() => CourseDetailScreenState();
}

class CourseDetailScreenState extends State<CourseDetailScreen> {
  late PageController pageController;

  late int currentContentIndex;
  late int currentLessonIndex;

  JSONList allContent = [];

  bool isLoading = true;

  // Cumulative reading clock for this course session. Started once the
  // content actually appears (so the loading screen doesn't pad the count)
  // and committed back to the user model in dispose, so the write fires on
  // real course exit, not on the lesson finish screen.
  final Stopwatch readingStopwatch = Stopwatch();

  // Progress bar reveal state (tap chrome to reveal; tap elsewhere to blur)
  bool isProgressBarRevealed = false;
  final GlobalKey progressBarKey = GlobalKey();
  final GlobalKey topChromeKey = GlobalKey();

  // Icon definitions — share the muted grey used across the progress chrome
  static const Color progressChromeColor = Color.fromARGB(255, 157, 157, 157);

  static const Icon BackNavigationIcon = Icon(
    Pixel.close,
    color: progressChromeColor,
    size: RLDS.iconLarge,
  );

  static const Icon NightShiftIcon = Icon(
    Pixel.moon,
    color: RLDS.warning,
    size: RLDS.iconXLarge,
  );

  @override
  void initState() {
    super.initState();

    currentLessonIndex = widget.initialLessonIndex;
    currentContentIndex = widget.initialContentIndex;

    pageController = PageController(initialPage: currentContentIndex);

    fetchLessonContent();

    // Hide the status bar clock/indicators while reading so the swipe
    // takes the full screen. Only the home-indicator bar is kept.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.bottom],
    );
  }

  @override
  void dispose() {
    commitReadingTime();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    pageController.dispose();
    super.dispose();
  }

  // Stops the in-session stopwatch and bumps /users/{id}.timeSpentReading
  // by the elapsed seconds. Fire-and-forget by design: the screen is
  // already tearing down, and UserService logs any write failure for
  // diagnostics. Skips zero-second exits (e.g. immediate quit during the
  // loading screen) so noise doesn't reach Firestore.
  // Credited seconds are capped at MAX_SESSION_CREDITED_SECONDS to prevent
  // idle-tab abuse of the feather economy. The finish screen still shows
  // the real stopwatch value — only the write is capped.
  void commitReadingTime() {
    readingStopwatch.stop();

    final int elapsedSeconds = readingStopwatch.elapsed.inSeconds;
    final bool hasElapsedTime = elapsedSeconds > 0;

    if (!hasElapsedTime) {
      return;
    }

    final int creditedSeconds = elapsedSeconds.clamp(
      0,
      PurchaseConstants.MAX_SESSION_CREDITED_SECONDS,
    );

    UserService.incrementTimeSpentReading(creditedSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowLoadingScreen = isLoading;

    if (shouldShowLoadingScreen) {
      return LoadingScreen();
    }

    final Color courseAccentColor = widget.accentColor;

    return CourseAccentScope(
      accentColor: courseAccentColor,
      child: SelectionContainer.disabled(child: MainCourseScreen()),
    );
  }

  // Loading screen widget — shares CourseLoadingScreen so the picked bird
  // (not a stale pigeon image or a raw spinner) greets the reader here too.
  Widget LoadingScreen() {
    return const CourseLoadingScreen();
  }

  // Main course content screen — Scaffold hosts a three-layer stack: the
  // drifting pixel starfield at the bottom, a full-bleed LunarBlur pane that
  // frosts the stars so they read as a calm atmospheric background rather
  // than competing with the text, and the safe-area content (top chrome +
  // PageView) painted on top.
  Widget MainCourseScreen() {
    return Scaffold(
      backgroundColor: STARFIELD_BACKGROUND_COLOR,
      body: Stack(
        children: [
          const Positioned.fill(child: RLStarfieldBackground()),

          const Positioned.fill(
            child: RLLunarBlur(borderRadius: BorderRadius.zero, child: SizedBox.expand()),
          ),

          SafeArea(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: handleGlobalPointerDown,
              child: Div.column([
                // Progress bar and navigation header
                TopProgressBar(),

                // Main course content area
                Expanded(child: CourseBody()),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Re-blur the top chrome when the user taps outside of it. "Outside" means
  // outside the whole TopProgressBar row (back button, progress bar, night
  // shift toggle), not just the progress bar itself. Otherwise a tap on
  // close/night-shift would re-blur first, then the rebuilt GestureDetector
  // would route the tap back to reveal instead of firing the intended action.
  void handleGlobalPointerDown(PointerDownEvent event) {
    if (!isProgressBarRevealed) {
      return;
    }

    final RenderBox? topChromeBox =
        topChromeKey.currentContext?.findRenderObject() as RenderBox?;

    if (topChromeBox == null) {
      return;
    }

    final Offset chromeOrigin = topChromeBox.localToGlobal(Offset.zero);
    final Rect chromeRect = chromeOrigin & topChromeBox.size;
    final bool isTapInsideChrome = chromeRect.contains(event.position);

    if (isTapInsideChrome) {
      return;
    }

    setState(() {
      isProgressBarRevealed = false;
    });
  }

  void handleProgressBarTap() {
    final bool isAlreadyRevealed = isProgressBarRevealed;

    if (isAlreadyRevealed) {
      return;
    }

    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    setState(() {
      isProgressBarRevealed = true;
    });
  }

  // Course body containing page view or empty state
  Widget CourseBody() {
    final bool hasNoContent = allContent.isEmpty;

    if (hasNoContent) {
      return EmptyContentMessage();
    }

    return CourseContentPageView();
  }

  // Vertical page view for course content. The list grows by one extra
  // page (the finish screen) so the reader can swipe past the last
  // content item and land on the Finish CTA without leaving the viewer.
  Widget CourseContentPageView() {
    final int totalPageCount = allContent.length + 1;

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: totalPageCount,
      onPageChanged: handlePageChanged,
      itemBuilder: ContentOrFinishItem,
    );
  }

  // Routes the PageView's itemBuilder either to the regular content
  // factory or to the finish page when the index lands on the trailing
  // slot. Keeps the existing ContentItem signature unchanged so the
  // ColumnFrame layout still wraps every reading page identically.
  Widget ContentOrFinishItem(BuildContext context, int pageIndex) {
    final bool isFinishPage = pageIndex == allContent.length;

    if (isFinishPage) {
      return FinishPage();
    }

    return ContentItem(context, pageIndex);
  }

  // The trailing finish page. Stops the in-session stopwatch the moment
  // the page paints (handlePageChanged also stops it on arrival, but the
  // first frame should display the same frozen readout the button writes
  // back), and renders the profile bird, the stopwatch readout, and the
  // Finish button. Tapping Finish bumps this lesson's frontier on the
  // CourseProgressModel and pops back to the roadmap; the dispose path
  // still commits the elapsed seconds to /users/{id}.timeSpentReading.
  Widget FinishPage() {
    final int elapsedSeconds = readingStopwatch.elapsed.inSeconds;
    final Color accentColor = widget.accentColor;

    return LessonFinishScreen(
      elapsedSeconds: elapsedSeconds,
      accentColor: accentColor,
      onFinishTap: handleFinishTap,
    );
  }

  void handleFinishTap() {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    // Bump the frontier so the next lesson on the roadmap unlocks. The
    // writer is monotonic and idempotent, so re-running it on a lesson
    // the reader already passed is a no-op (max() guard inside
    // advanceCourseProgress drops the write).
    UserService.advanceCourseProgress(
      courseId: widget.courseId,
      nextLessonIndex: currentLessonIndex + 1,
    );

    navigateBackToRoadmap();
  }

  // Empty state message when no content available
  Widget EmptyContentMessage() {
    return Center(
      child: RLTypography.bodyLarge(
        RLUIStrings.NO_CONTENT_AVAILABLE_MESSAGE,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Top navigation bar with progress indicator.
  //
  // The whole row (its outer padding + the gaps between buttons) reveals the
  // chrome on tap while blurred, not just the icons themselves. An opaque
  // GestureDetector wraps the row so taps in the padding fall through to
  // handleProgressBarTap; the inner per-button GestureDetectors still claim
  // their own hits first, so back/night-shift fire their real action when
  // revealed and ride the reveal-on-first-tap path while blurred.
  Widget TopProgressBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleProgressBarTap,
      child: Div.row(
        [
          // Back navigation button
          BackNavigationButton(),

          const Spacing.width(RLDS.spacing20),

          // Course progress indicator
          Expanded(child: ProgressIndicator()),

          const Spacing.width(RLDS.spacing20),

          // Night Shift toggle (eye-strain overlay)
          NightShiftButton(),
        ],
        key: topChromeKey,
        padding: const [RLDS.spacing8, RLDS.spacing16, RLDS.spacing0, RLDS.spacing16],
      ),
    );
  }

  // Back button for navigation — matches the blurred progress chrome.
  // Only fires the quit-confirmation action when the chrome is revealed; if the
  // bar is still blurred, the first tap just reveals it (mirrors the progress
  // bar's reveal-on-first-tap behaviour).
  Widget BackNavigationButton() {
    final bool hasNoContent = allContent.isEmpty;
    final VoidCallback backAction = hasNoContent
        ? navigateBackToRoadmap
        : showQuitConfirmationSheet;
    final VoidCallback backTapHandler = getChromeTapHandler(backAction);

    return GestureDetector(
      onTap: backTapHandler,
      child: ChromeBlur(child: BackNavigationIcon),
    );
  }

  // Night Shift button. Opens the warmth picker with the same
  // reveal-before-action semantics as the close button.
  Widget NightShiftButton() {
    final VoidCallback nightShiftTapHandler = getChromeTapHandler(handleNightShiftTap);

    return GestureDetector(
      onTap: nightShiftTapHandler,
      child: ChromeBlur(child: NightShiftIcon),
    );
  }

  // Wraps a chrome action so the first tap on a blurred chrome element reveals
  // the whole top bar; only once revealed does the tap propagate to the real
  // action. Keeps the close and night-shift icons from firing through the blur.
  VoidCallback getChromeTapHandler(VoidCallback action) {
    final bool isRevealed = isProgressBarRevealed;

    if (isRevealed) {
      return action;
    }

    return handleProgressBarTap;
  }

  // Shared blur + dim treatment for the top chrome (close, progress, night-shift)
  Widget ChromeBlur({required Widget child}) {
    final bool isRevealed = isProgressBarRevealed;
    final double targetOpacity = isRevealed ? 1.0 : 0.25;
    final double blurSigma = isRevealed ? 0.0 : 6.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: targetOpacity,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: child,
      ),
    );
  }

  // Tap-highlight container for chrome icon buttons. Fades a glass10 white
  // rectangle in on press and out on release using the standard fast duration.

  // Progress indicator for course content — blurred and dimmed until tapped
  Widget ProgressIndicator() {
    final double progressValue = calculateProgress();
    final Color accentColor = widget.accentColor;

    final Widget progressBar = SizedBox(
      key: progressBarKey,
      height: RLDS.spacing8,
      child: ClipRRect(
        borderRadius: RLDS.borderRadiusLarge,
        child: LinearProgressIndicator(
          value: progressValue,
          backgroundColor: RLDS.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
      ),
    );

    return GestureDetector(
      onTap: handleProgressBarTap,
      child: ChromeBlur(child: progressBar),
    );
  }

  // Build content item widget for specific index. Every CC widget is wrapped
  // in a centered column whose max width is driven by the reader's choice in
  // Settings (selectedReadingColumnNotifier) — Newspaper (narrow) or
  // Classic (comfortable) — both cap line-length so the reading surface
  // stays within the 45–75 character target on wider phones.
  Widget ContentItem(BuildContext context, int contentItemIndex) {
    final JSONMap content = allContent[contentItemIndex];
    final Widget contentWidget = CCJSONContentFactory.createContentWidget(content);

    return ValueListenableBuilder<ReadingColumn>(
      valueListenable: selectedReadingColumnNotifier,
      builder: ColumnFrame,
      child: contentWidget,
    );
  }

  // Applies the selected column width as a max constraint. The width is
  // a fraction of the screen so the column scales across device sizes.
  Widget ColumnFrame(BuildContext context, ReadingColumn column, Widget? child) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fraction = widthFractionFor(column);
    final double maxWidth = screenWidth * fraction;
    final BoxConstraints columnConstraints = BoxConstraints(maxWidth: maxWidth);

    return Center(
      child: ConstrainedBox(constraints: columnConstraints, child: child),
    );
  }

  // Minimum time the "Preparing..." screen stays visible so the
  // transition never feels like a flash, even on fast connections.
  static const Duration minimumLoadingDuration = Duration(seconds: 1);

  // Fetches the current lesson's content via the fetchLessonContent
  // Cloud Function. The function enforces auth, purchase, frontier, and
  // discharge gates server-side, so raw content only arrives when the
  // reader is allowed to view it.
  Future<void> fetchLessonContent() async {
    final Future<void> minimumDelay = Future.delayed(minimumLoadingDuration);

    try {
      allContent = await CourseDataService.fetchLessonContent(
        courseId: widget.courseId,
        lessonIndex: currentLessonIndex,
      );
    } on Exception catch (error) {
      debugPrint('${RLUIStrings.ERROR_LOADING_COURSE_DATA}: $error');
    }

    // Wait for the minimum display time before revealing content
    await minimumDelay;

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      // Start the reading clock now that the content is actually
      // visible. Loading-screen seconds are not reading seconds.
      readingStopwatch.start();
    }
  }

  // Handle page change events. Stops the in-session stopwatch when the
  // reader reaches the trailing finish page so the elapsed-time readout
  // on that page stays frozen at the moment of arrival. The dispose
  // path still commits whatever value the stopwatch carries, so a later
  // close from the finish screen logs the same seconds the reader saw.
  void handlePageChanged(int contentItemIndex) {
    FeedbackSnackBar.clearSnackbars();

    final bool reachedFinishPage = contentItemIndex == allContent.length;

    if (reachedFinishPage) {
      readingStopwatch.stop();
    }

    if (mounted) {
      setState(() {
        currentContentIndex = contentItemIndex;
      });
    }
  }

  // Calculate current progress percentage. Caps at 1.0 once the reader
  // crosses onto the finish page so the bar reads as a full sweep
  // instead of overshooting past 100%.
  double calculateProgress() {
    final bool hasNoContent = allContent.isEmpty;

    if (hasNoContent) {
      return 0.0;
    }

    final int totalItems = allContent.length;
    final bool isOnFinishPage = currentContentIndex >= totalItems;

    if (isOnFinishPage) {
      return 1.0;
    }

    final int completedItems = currentContentIndex + 1;

    return completedItems / totalItems;
  }

  void navigateBackToRoadmap() {
    // Clear any lingering snackbars before leaving
    FeedbackSnackBar.clearSnackbars();

    Navigator.of(context).pop();
  }

  // Show quit confirmation dialog — frosted LunarBlur surface (matches the
  // Support bottom sheet), icon-cancel layout so Pause reads as a compact
  // red glyph on the left and Read fills the rest as the primary action.
  void showQuitConfirmationSheet() {
    HapticsService.lightImpact();
    SoundService.playNegative();

    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.QUIT_CONFIRMATION_TITLE,
      message: RLUIStrings.QUIT_CONFIRMATION_MESSAGE,
      layout: RLConfirmationLayout.iconCancel,
      cta: const RLConfirmationAction(
        label: '',
        variant: RLConfirmationVariant.success,
        icon: Pixel.play,
      ),
      cancel: RLConfirmationAction(
        label: RLUIStrings.QUIT_CONFIRMATION_PAUSE_BUTTON,
        variant: RLConfirmationVariant.destructive,
        icon: Pixel.pause,
        onTap: navigateBackToRoadmap,
      ),
    );
  }

  // Open the eye-strain (Night Shift) picker. Lives on the same chrome slot
  // the bookmark used to occupy.
  void handleNightShiftTap() {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    NightShiftBottomSheet.show(context);
  }
}

// Lesson finish page rendered as the trailing slot in the content PageView.
// Shows the reader's profile bird, a count-up stopwatch for the time spent
// on this lesson, and a Finish CTA using the shared CCContinueButton.
//
// Purely presentational: the page-change listener handles the stopwatch
// stop, and the parent passes a ready-to-fire onFinishTap that bumps the
// frontier and pops the screen.
//
// Count-up sweep: short and ease-out so the seconds fly past quickly
// and settle on the final value the moment the page lands.
const Duration LESSON_FINISH_TIME_COUNTUP_DURATION = Duration(milliseconds: 1200);

class LessonFinishScreen extends StatefulWidget {
  final int elapsedSeconds;
  final Color accentColor;
  final VoidCallback onFinishTap;

  const LessonFinishScreen({
    super.key,
    required this.elapsedSeconds,
    required this.accentColor,
    required this.onFinishTap,
  });

  @override
  State<LessonFinishScreen> createState() => LessonFinishScreenState();
}

class LessonFinishScreenState extends State<LessonFinishScreen> with TickerProviderStateMixin {
  late AnimationController timeCountUpController;
  late Animation<int> timeCountUpAnimation;

  @override
  void initState() {
    super.initState();

    // Lesson-done arrival cue. The success chime + a single light haptic
    // land in the same frame the screen mounts, so the reader hears and
    // feels the moment the finish surface takes over the swipe.
    SoundService.playSuccess();
    HapticsService.lightImpact();

    final int totalSeconds = widget.elapsedSeconds;

    timeCountUpController = AnimationController(
      vsync: this,
      duration: LESSON_FINISH_TIME_COUNTUP_DURATION,
    );

    timeCountUpAnimation = IntTween(
      begin: 0,
      end: totalSeconds,
    ).animate(CurvedAnimation(parent: timeCountUpController, curve: Curves.easeOut));

    timeCountUpController.forward();
  }

  @override
  void dispose() {
    timeCountUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget profileBird = ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: BirdPreviewBuilder,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24, vertical: RLDS.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: profileBird),

          const Spacing.height(RLDS.spacing24),

          // "Lesson done" reveals with the same one-shot typewriter the
          // bottom-nav screen titles use so the finish header reads as
          // part of the same family of "screen wakes up" headings.
          LessonDoneTitle(),

          const Spacing.height(RLDS.spacing16),

          RLTypography.bodyMedium(
            RLUIStrings.LESSON_FINISH_TIME_LABEL,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing4),

          AnimatedStopwatchReadout(),

          const Spacing.height(RLDS.spacing32),

          FinishButton(),
        ],
      ),
    );
  }

  Widget BirdPreviewBuilder(BuildContext context, BirdOption bird, Widget? unusedChild) {
    return BirdAnimationSprite(bird: bird);
  }

  Widget LessonDoneTitle() {
    return RLTypewriterText(
      text: RLUIStrings.LESSON_FINISH_TITLE,
      style: RLTypography.headingMediumStyle,
      textAlign: TextAlign.center,
    );
  }

  // Re-renders the readout each tick of the count-up so the seconds roll
  // from 0 up to the lesson's final elapsed value.
  Widget AnimatedStopwatchReadout() {
    return AnimatedBuilder(animation: timeCountUpAnimation, builder: StopwatchReadoutBuilder);
  }

  Widget StopwatchReadoutBuilder(BuildContext context, Widget? unusedChild) {
    final String tickReadout = formatBirdUnlockReadout(timeCountUpAnimation.value);

    return RLTypography.headingMedium(tickReadout, textAlign: TextAlign.center);
  }

  // Finish CTA reuses the shared CC continue button so the verb on the
  // last page reads with the same calm-text-only design as every other
  // swipe's continue affordance.
  Widget FinishButton() {
    return CCContinueButton(
      label: RLUIStrings.LESSON_FINISH_BUTTON_LABEL,
      onTap: widget.onFinishTap,
    );
  }
}
