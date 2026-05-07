// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/course_screens/CourseAccentScope.dart';
import 'package:readlock/course_screens/CourseLoadingScreen.dart';
import 'package:readlock/course_screens/widgets/CCJSONContentFactory.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
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
import 'package:readlock/services/ScreenProtectionService.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

import 'package:pixelarticons/pixel.dart';

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

  // Cumulative reading clock for this course session. Started once the
  // content actually appears (so the loading screen doesn't pad the count)
  // and committed back to the user model in dispose, so the write fires on
  // real course exit, not on the lesson finish screen.
  final Stopwatch readingStopwatch = Stopwatch();

  // Progress bar reveal state (tap chrome to reveal; tap elsewhere to blur)
  bool isProgressBarRevealed = false;
  final GlobalKey progressBarKey = GlobalKey();
  final GlobalKey topChromeKey = GlobalKey();

  Color getCourseAccentColor() {
    final String? hex = courseData?['color'] as String?;
    final Color? parsed = RLDS.parseHexColor(hex);

    return parsed ?? RLDS.success;
  }

  // Icon definitions — share the muted grey used across the progress chrome
  static const Color progressChromeColor = Color.fromARGB(255, 157, 157, 157);

  static const Icon BackNavigationIcon = Icon(
    Pixel.close,
    color: progressChromeColor,
    size: RLDS.iconMedium,
  );

  static const Icon NightShiftIcon = Icon(
    Pixel.moon,
    color: RLDS.warning,
    size: RLDS.iconLarge,
  );

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

    // Block screenshots while course content is visible
    ScreenProtectionService.enableProtection();

    // Hide the status bar clock/indicators while reading so the swipe
    // takes the full screen. Only the home-indicator bar is kept.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.bottom],
    );
  }

  // Cleanup resources when widget is disposed
  @override
  void dispose() {
    commitReadingTime();

    ScreenProtectionService.disableProtection();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    pageController.dispose();
    super.dispose();
  }

  // Stops the in-session stopwatch and bumps /users/{id}.timeSpentReading
  // by the elapsed seconds. Fire-and-forget by design: the screen is
  // already tearing down, and UserService logs any write failure for
  // diagnostics. Skips zero-second exits (e.g. immediate quit during the
  // loading screen) so noise doesn't reach Firestore.
  void commitReadingTime() {
    readingStopwatch.stop();

    final int elapsedSeconds = readingStopwatch.elapsed.inSeconds;
    final bool hasElapsedTime = elapsedSeconds > 0;

    if (!hasElapsedTime) {
      return;
    }

    UserService.incrementTimeSpentReading(elapsedSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowLoadingScreen = isLoading;

    if (shouldShowLoadingScreen) {
      return LoadingScreen();
    }

    final Color courseAccentColor = getCourseAccentColor();

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
    final Color accentColor = getCourseAccentColor();

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
    return Center(child: RLTypography.bodyMedium(RLUIStrings.NO_CONTENT_AVAILABLE_MESSAGE));
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

          const Spacing.width(RLDS.spacing12),

          // Course progress indicator
          Expanded(child: ProgressIndicator()),

          const Spacing.width(RLDS.spacing12),

          // Night Shift toggle (eye-strain overlay)
          NightShiftButton(),
        ],
        key: topChromeKey,
        padding: RLDS.spacing16,
      ),
    );
  }

  // Back button for navigation — matches the blurred progress chrome.
  // Only fires the quit-confirmation action when the chrome is revealed; if the
  // bar is still blurred, the first tap just reveals it (mirrors the progress
  // bar's reveal-on-first-tap behaviour).
  Widget BackNavigationButton() {
    final VoidCallback backTapHandler = getChromeTapHandler(showQuitConfirmationSheet);

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

  // Progress indicator for course content — blurred and dimmed until tapped
  Widget ProgressIndicator() {
    final double progressValue = calculateProgress();
    final Color accentColor = getCourseAccentColor();

    final Widget progressBar = SizedBox(
      key: progressBarKey,
      height: 12.0,
      child: ClipRRect(
        borderRadius: RLDS.borderRadiusXSmall,
        child: LinearProgressIndicator(
          value: progressValue,
          backgroundColor: RLDS.backgroundLight,
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

  // Applies the selected column width as a max constraint. Both options
  // (narrow / comfortable) are bounded so the child is always centred
  // inside a ConstrainedBox — no unconstrained branch.
  Widget ColumnFrame(BuildContext context, ReadingColumn column, Widget? child) {
    final double maxWidth = maxWidthFor(column);
    final BoxConstraints columnConstraints = BoxConstraints(maxWidth: maxWidth);

    return Center(
      child: ConstrainedBox(constraints: columnConstraints, child: child),
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
      debugPrint('${RLUIStrings.ERROR_LOADING_COURSE_DATA}: $error');
    } finally {
      // Update loading state
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Start the reading clock now that the content is actually
        // visible. Loading-screen seconds are not reading seconds.
        readingStopwatch.start();
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

  // Navigate back to course roadmap
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

// Lesson finish page rendered as the trailing slot in the content
// PageView. The reader's profile bird (live from selectedBirdNotifier),
// a stopwatch readout for the time spent on this lesson, and a Finish
// CTA that mirrors the roadmap's ContinueButton (RLLunarBlur surface,
// course accent label) so the two surfaces read as the same family.
//
// This widget is purely presentational — the page-change listener
// handles the stopwatch stop, and the parent passes a ready-to-fire
// onFinishTap that bumps the frontier and pops the screen.
class LessonFinishScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final String stopwatchReadout = formatBirdUnlockReadout(elapsedSeconds);

    final Widget profileBird = ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: BirdPreviewBuilder,
    );

    final Widget finishButton = FinishButton();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing24,
        vertical: RLDS.spacing24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: profileBird),

          const Spacing.height(RLDS.spacing24),

          RLTypography.headingMedium(
            RLUIStrings.LESSON_FINISH_TITLE,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing16),

          RLTypography.bodyMedium(
            RLUIStrings.LESSON_FINISH_TIME_LABEL,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing4),

          RLTypography.headingMedium(stopwatchReadout, textAlign: TextAlign.center),

          const Spacing.height(RLDS.spacing32),

          finishButton,
        ],
      ),
    );
  }

  Widget BirdPreviewBuilder(BuildContext context, BirdOption bird, Widget? unusedChild) {
    return BirdAnimationSprite(bird: bird);
  }

  Widget FinishButton() {
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: RLDS.spacing16,
      horizontal: RLDS.spacing24,
    );

    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      borderColor: RLDS.transparent,
      child: Div.row(
        [RLTypography.bodyLarge(RLUIStrings.LESSON_FINISH_BUTTON_LABEL, color: accentColor)],
        width: double.infinity,
        padding: buttonPadding,
        mainAxisAlignment: MainAxisAlignment.center,
        onTap: onFinishTap,
      ),
    );
  }
}

// Bottom sheet for quit confirmation
