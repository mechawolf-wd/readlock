// Home screen — a single "Surprise me" entry point that opens a random course.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/course/CoursePurchaseBottomSheet.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/constants/RLLatestCourse.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:flutter/services.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';

import 'package:pixelarticons/pixel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

// Number of "How about these?" suggestions rendered as circular books
// underneath the Surprise Me row. Three reads as a curated row without
// flooding the home surface; matches what the brief asks for.
const int POPULAR_COURSES_COUNT = 3;

class HomeScreenState extends State<HomeScreen> {
  JSONList availableCourses = [];
  JSONList popularCourses = [];
  bool isCoursesLoading = true;

  // Bumped every time this tab becomes active. Used as the typewriter
  // heading's ValueKey so a fresh activation remounts the widget and
  // re-runs its character-by-character reveal.
  int titleAnimationVersion = 0;

  @override
  void initState() {
    super.initState();
    fetchAvailableCourses();
    activeTabIndexNotifier.addListener(handleTabActivated);
  }

  @override
  void dispose() {
    activeTabIndexNotifier.removeListener(handleTabActivated);
    super.dispose();
  }

  void handleTabActivated() {
    final bool isMyTabActive = activeTabIndexNotifier.value == TAB_INDEX_HOME;

    if (!isMyTabActive) {
      return;
    }

    setState(() {
      titleAnimationVersion++;
    });
  }

  Future<void> fetchAvailableCourses() async {
    try {
      // Two parallel fetches: the catalogue (drives Surprise Me + Reading
      // Now lookup) and the top-N by lifetime purchases (drives the new
      // "How about these?" row). The Future.wait unblocks the build the
      // moment both land instead of serialising two round-trips.
      final List<dynamic> results = await Future.wait([
        CourseDataService.fetchAvailableCourses(),
        CourseDataService.fetchMostPurchasedCourses(limit: POPULAR_COURSES_COUNT),
      ]);

      final JSONList catalogueCourses = results[0] as JSONList;
      final JSONList mostPurchasedCourses = results[1] as JSONList;

      if (!mounted) {
        return;
      }

      setState(() {
        availableCourses = catalogueCourses;
        popularCourses = mostPurchasedCourses;
        isCoursesLoading = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        isCoursesLoading = false;
      });
    }
  }

  void navigateToCourse(String courseId) {
    Navigator.push(
      context,
      RLDS.fadeTransition(CourseRoadmapScreen(courseId: courseId)),
    );
  }

  // Picks a random course the reader does NOT already own. "Try out
  // something new" should never resurface a course already on their
  // shelf, so we filter the catalogue against purchasedCoursesNotifier
  // before drawing. When every course is owned (or the catalogue is
  // empty) we surface an info toast so the tap doesn't read as a dead
  // button. The toast is the only feedback in that case — the success
  // chime only plays when a fresh course is actually picked.
  void handleRandomBookTap() {
    final Set<String> ownedCourseIds = purchasedCoursesNotifier.value;

    final JSONList unownedCourses = availableCourses.where((course) {
      final String courseId = course['course-id'] as String? ?? '';

      return !ownedCourseIds.contains(courseId);
    }).toList();

    final bool hasUnownedCourses = unownedCourses.isNotEmpty;

    if (!hasUnownedCourses) {
      RLToast.info(context, RLUIStrings.SURPRISE_ME_NO_RESULTS_TOAST);
      return;
    }

    // RLCard fires its own haptic on tap — no need for a second one here.
    final int randomIndex = Random().nextInt(unownedCourses.length);
    final JSONMap randomCourse = unownedCourses[randomIndex];
    final String randomCourseId = randomCourse['course-id'] as String;

    SoundService.playPurchased();
    navigateToCourse(randomCourseId);
  }

  static final Widget ChevronRightIcon = const Icon(
    Pixel.chevronright,
    color: RLDS.textSecondary,
    size: RLDS.iconLarge,
  );

  static final Widget ShuffleIcon = const Icon(
    Pixel.shuffle,
    color: RLDS.info,
    size: RLDS.iconLarge,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.transparent,
      body: SafeArea(bottom: false, child: HomeBody()),
    );
  }

  Widget HomeBody() {
    return RLFadeSwitcher(child: HomeBodyCurrent());
  }

  Widget HomeBodyCurrent() {
    if (isCoursesLoading) {
      return const RLLoadingIndicator.bird(key: ValueKey('home-loading'));
    }

    return Padding(
      key: const ValueKey('home-content'),
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Div.column([
        RLTypewriterText(
          key: ValueKey<int>(titleAnimationVersion),
          text: RLUIStrings.HOME_TAB_LABEL,
          style: RLTypography.headingLargeStyle,
        ),

        const Spacing.height(RLDS.spacing40),

        Expanded(child: HomeContent()),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  Widget HomeContent() {
    final bool hasNoCourses = availableCourses.isEmpty;

    if (hasNoCourses) {
      return Center(
        child: RLTypography.bodyMedium(
          RLUIStrings.NO_COURSES_MESSAGE,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Div.column([
      LatestCourseSection(),

      RandomLessonSection(),

      PopularCoursesSection(),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  // "Reading now…" card — pinned above the Surprise Me row when the
  // reader has tapped a roadmap node before. Re-builds reactively as the
  // global lastOpenedCourseIdNotifier changes, so popping back from a
  // course refreshes this card without HomeScreen having to refetch.
  // Hidden entirely when the notifier is null or the matching course is
  // not in availableCourses (e.g. course removed from the catalogue).
  Widget LatestCourseSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: lastOpenedCourseIdNotifier,
      builder: (context, latestCourseId, _) {
        final JSONMap? latestCourse = findCourseById(latestCourseId);
        final bool hasLatestCourse = latestCourse != null;

        if (!hasLatestCourse) {
          return const SizedBox.shrink();
        }

        return Div.column([
          LatestCourseHeading(),

          const Spacing.height(RLDS.spacing12),

          LatestCourseCard(latestCourse),

          const Spacing.height(RLDS.spacing24),
        ], crossAxisAlignment: CrossAxisAlignment.stretch);
      },
    );
  }

  Widget LatestCourseHeading() {
    return const LatestCourseDotsHeading();
  }

  // Custom Reading-Now card. Mirrors BookListCard's top row (cover + title
  // + author) but stacks the green Continue CTA inside the same frosted
  // pane so the resume-reading action lives with the book it belongs to,
  // instead of floating below as a separate element.
  Widget LatestCourseCard(JSONMap course) {
    final String courseTitle = course['title'] as String? ?? '';
    final String courseAuthor = course['author'] as String? ?? '';
    final String? courseColor = course['color'] as String?;
    final String courseId = course['course-id'] as String? ?? '';

    void onCardTap() {
      SoundService.playRandomTextClick();
      navigateToCourse(courseId);
    }

    final Widget bookRow = Div.row([
      RLCourseBookImage(courseColor: courseColor, size: LIST_CARD_BOOK_SIZE),

      const Spacing.width(RLDS.spacing12),

      Expanded(
        child: Div.column([
          RLTypography.bodyLarge(courseTitle, maxLines: 1, overflow: TextOverflow.ellipsis),

          const Spacing.height(RLDS.spacing4),

          RLTypography.bodyMedium(courseAuthor, color: RLDS.textSecondary),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    ]);

    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing12),
      onTap: onCardTap,
      child: Div.column([
        bookRow,

        const Spacing.height(RLDS.spacing24),

        LatestCourseContinueButton(course),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Returns the JSON for `courseId` from the already-fetched list, or
  // null if the id is missing / not in the catalogue. Cheap linear scan;
  // availableCourses is small.
  JSONMap? findCourseById(String? courseId) {
    if (courseId == null) {
      return null;
    }

    for (final dynamic raw in availableCourses) {
      final bool isMap = raw is JSONMap;

      if (!isMap) {
        continue;
      }

      final JSONMap candidate = raw;
      final String? candidateId = candidate['course-id'] as String?;
      final bool isMatch = candidateId == courseId;

      if (isMatch) {
        return candidate;
      }
    }

    return null;
  }

  // Explicit "Continue" CTA under the Reading-Now card. The card itself
  // is still tappable, but the button gives the resume-reading flow a
  // visible primary action so it doesn't depend on the user knowing the
  // card is interactive.
  //
  // Built on RLLunarBlur (frosted surface tinted green) instead of
  // RLButton because the brief asked for a glassy green pane rather than
  // the solid filled-button look RLButton.primary ships with.
  Widget LatestCourseContinueButton(JSONMap course) {
    final String courseId = course['course-id'] as String? ?? '';

    void onContinueTap() {
      HapticFeedback.lightImpact();
      SoundService.playEnter();
      navigateToCourse(courseId);
    }

    final Widget continueLabel = RLTypography.bodyLarge(
      RLUIStrings.CONTINUE_BUTTON_LABEL,
      color: RLDS.markupGreen,
    );

    return GestureDetector(
      onTap: onContinueTap,
      behavior: HitTestBehavior.opaque,
      child: RLLunarBlur(
        surfaceColor: RLDS.markupGreen,
        surfaceAlpha: 0.05,
        padding: const EdgeInsets.symmetric(
          vertical: RLDS.spacing16,
          horizontal: RLDS.spacing24,
        ),
        child: Center(child: continueLabel),
      ),
    );
  }

  Widget RandomLessonSection() {
    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing16),
      onTap: handleRandomBookTap,
      child: Div.row([
        ShuffleIcon,

        const Spacing.width(RLDS.spacing12),

        Expanded(child: RLTypography.bodyLarge(RLUIStrings.SURPRISE_ME_LABEL)),

        ChevronRightIcon,
      ], crossAxisAlignment: CrossAxisAlignment.center),
    );
  }

  // Top-N courses by lifetime purchases, rendered as the same horizontal
  // BookListCard rows used on the search screen so the home and search
  // surfaces feel like one family. Wrapped in a ValueListenableBuilder
  // on purchasedCoursesNotifier so the cart icon disappears the moment
  // a course is bought from any surface in the app. Hidden when the
  // catalogue is sparse (<POPULAR_COURSES_COUNT results from the
  // orderBy query) so we never render a broken half-list.
  Widget PopularCoursesSection() {
    final bool hasEnoughForList = popularCourses.length >= POPULAR_COURSES_COUNT;

    if (!hasEnoughForList) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<Set<String>>(
      valueListenable: purchasedCoursesNotifier,
      builder: PopularCoursesContent,
    );
  }

  Widget PopularCoursesContent(
    BuildContext context,
    Set<String> purchasedCourses,
    Widget? unusedChild,
  ) {
    final List<Widget> popularBookCards = popularCourses
        .map<Widget>((JSONMap course) => PopularCourseCard(course, purchasedCourses))
        .toList();

    return Div.column([
      const Spacing.height(RLDS.spacing24),

      PopularCoursesHeading(),

      const Spacing.height(RLDS.spacing12),

      ...popularBookCards,
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget PopularCoursesHeading() {
    return RLTypography.bodyMedium(
      RLUIStrings.FOR_YOUR_PERSONALITY_TITLE,
      color: RLDS.textSecondary,
    );
  }

  // Single popular course rendered as the shared horizontal book row,
  // identical to the search screen's listing — cover + title + author,
  // tap navigates straight into the course. The cart icon is wired only
  // for courses the reader does NOT already own; tapping it opens the
  // purchase sheet without firing the row's navigate-to-roadmap onTap.
  Widget PopularCourseCard(JSONMap course, Set<String> purchasedCourses) {
    final String courseTitle = course['title'] as String? ?? '';
    final String courseAuthor = course['author'] as String? ?? '';
    final String? courseColor = course['color'] as String?;
    final String? coverImagePath = course['cover-image-path'] as String?;
    final String courseId = course['course-id'] as String? ?? '';

    final bool isOwned = purchasedCourses.contains(courseId);
    final VoidCallback? onBuyTap = isOwned
        ? null
        : () => CoursePurchaseBottomSheet.show(context, course: course);

    void onCardTap() {
      SoundService.playRandomTextClick();
      navigateToCourse(courseId);
    }

    return BookListCard(
      title: courseTitle,
      author: courseAuthor,
      courseColor: courseColor,
      coverImagePath: coverImagePath,
      onTap: onCardTap,
      onBuyTap: onBuyTap,
    );
  }
}

// "Reading now" heading with three trailing dots that fade in one-by-one
// over a single cycle, then loop. Reuses the dot-count + cycle tuning
// from RLLoadingIndicator so the rhythm matches the "Chirping…" loader,
// keeping the family of "live, in-progress" indicators consistent.
class LatestCourseDotsHeading extends StatefulWidget {
  const LatestCourseDotsHeading({super.key});

  @override
  State<LatestCourseDotsHeading> createState() => LatestCourseDotsHeadingState();
}

class LatestCourseDotsHeadingState extends State<LatestCourseDotsHeading>
    with SingleTickerProviderStateMixin {
  late AnimationController dotsController;

  @override
  void initState() {
    super.initState();

    dotsController = AnimationController(vsync: this, duration: LOADING_DOT_CYCLE_DURATION);

    dotsController.repeat();
  }

  @override
  void dispose() {
    dotsController.dispose();
    super.dispose();
  }

  // Three discrete steps: ".", "..", "...", then loop back to ".".
  // No empty phase — the reader never sees the heading without dots.
  int getActiveDotsCount() {
    final int phase = (dotsController.value * LOADING_DOT_COUNT).floor();
    final int clampedPhase = phase.clamp(0, LOADING_DOT_COUNT - 1);

    return clampedPhase + 1;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: dotsController, builder: HeadingFrame);
  }

  Widget HeadingFrame(BuildContext context, Widget? unusedChild) {
    final int activeDots = getActiveDotsCount();

    final List<Widget> rowChildren = [
      RLTypography.bodyMedium(
        RLUIStrings.CONTINUE_READING_TITLE,
        color: RLDS.textSecondary,
      ),
    ];

    // One Opacity-wrapped dot per slot. Flutter sees three distinct
    // children every frame, so a phase change produces a clean rebuild
    // (no TextSpan-tree caching surprises). Each dot still occupies its
    // slot at opacity 0, so the heading width stays stable across the
    // cycle.
    for (int dotIndex = 0; dotIndex < LOADING_DOT_COUNT; dotIndex++) {
      final bool isActive = dotIndex < activeDots;
      final double dotOpacity = isActive ? 1.0 : 0.0;

      rowChildren.add(
        Opacity(
          opacity: dotOpacity,
          child: RLTypography.bodyMedium('.', color: RLDS.textSecondary),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: rowChildren);
  }
}
