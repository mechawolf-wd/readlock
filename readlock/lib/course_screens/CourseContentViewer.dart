// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    color: progressChromeColor,
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
    ScreenProtectionService.disableProtection();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowLoadingScreen = isLoading;

    if (shouldShowLoadingScreen) {
      return LoadingScreen();
    }

    return SelectionContainer.disabled(child: MainCourseScreen());
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

    HapticFeedback.lightImpact();

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

  // Vertical page view for course content
  Widget CourseContentPageView() {
    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: allContent.length,
      onPageChanged: handlePageChanged,
      itemBuilder: ContentItem,
    );
  }

  // Empty state message when no content available
  Widget EmptyContentMessage() {
    return Center(child: RLTypography.bodyMedium(RLUIStrings.NO_CONTENT_AVAILABLE_MESSAGE));
  }

  // Top navigation bar with progress indicator
  Widget TopProgressBar() {
    return Div.row(
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

  // Show quit confirmation dialog — frosted LunarBlur surface (matches the
  // Support bottom sheet), icon-cancel layout so Pause reads as a compact
  // red glyph on the left and Read fills the rest as the primary action.
  void showQuitConfirmationSheet() {
    HapticFeedback.lightImpact();

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
    HapticFeedback.lightImpact();

    NightShiftBottomSheet.show(context);
  }
}

// Bottom sheet for quit confirmation
