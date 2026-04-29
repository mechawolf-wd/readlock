// Home screen — a single "Surprise me" entry point that opens a random course.

import 'dart:math';

import 'package:flutter/material.dart';
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
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/MainNavigation.dart';
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CourseRoadmapScreen(courseId: courseId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(0.0, 1.0);
          const Offset end = Offset.zero;
          const Curve curve = Curves.easeInOut;

          final Animatable<Offset> tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          final Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void handleRandomBookTap() {
    final bool hasCourses = availableCourses.isNotEmpty;

    if (!hasCourses) {
      return;
    }

    // RLCard fires its own haptic on tap — no need for a second one here.
    final int randomIndex = Random().nextInt(availableCourses.length);
    final JSONMap randomCourse = availableCourses[randomIndex];
    final String randomCourseId = randomCourse['course-id'] as String;

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
    return RLTypography.bodyMedium(
      RLUIStrings.CONTINUE_READING_TITLE,
      color: RLDS.textSecondary,
    );
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

    void onCardTap() => navigateToCourse(courseId);

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
      navigateToCourse(courseId);
    }

    final Widget continueLabel = RLTypography.bodyLarge(
      RLUIStrings.CONTINUE_BUTTON_LABEL,
      color: RLDS.green,
    );

    return GestureDetector(
      onTap: onContinueTap,
      behavior: HitTestBehavior.opaque,
      child: RLLunarBlur(
        surfaceColor: RLDS.green,
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

  // Top-N courses by lifetime purchases, rendered as a row of three
  // circular books. Hidden when the catalogue is sparse (<3 results from
  // the orderBy query) so we never render a broken half-row.
  Widget PopularCoursesSection() {
    final bool hasEnoughForRow = popularCourses.length >= POPULAR_COURSES_COUNT;

    if (!hasEnoughForRow) {
      return const SizedBox.shrink();
    }

    final List<Widget> popularBookCircles = popularCourses
        .map<Widget>(PopularCourseCircle)
        .toList();

    return Div.column([
      const Spacing.height(RLDS.spacing24),

      PopularCoursesHeading(),

      const Spacing.height(RLDS.spacing16),

      Div.row(
        popularBookCircles,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget PopularCoursesHeading() {
    return RLTypography.bodyMedium(
      RLUIStrings.FOR_YOUR_PERSONALITY_TITLE,
      color: RLDS.textSecondary,
    );
  }

  // Single circular book + title pair. Circle is a tinted disc with the
  // course's palette book floated in the centre, so the row reads as a
  // small "tap one of these" picker without competing visually with the
  // larger Surprise Me card above.
  Widget PopularCourseCircle(JSONMap course) {
    final String courseTitle = course['title'] as String? ?? '';
    final String courseId = course['course-id'] as String? ?? '';
    final String? courseColor = course['color'] as String?;

    void onCircleTap() => navigateToCourse(courseId);

    final BoxDecoration circleDecoration = BoxDecoration(
      color: RLDS.glass10(RLDS.info),
      shape: BoxShape.circle,
      border: Border.all(color: RLDS.glass15(RLDS.info)),
    );

    final Widget circleArt = Container(
      width: POPULAR_CIRCLE_DIAMETER,
      height: POPULAR_CIRCLE_DIAMETER,
      decoration: circleDecoration,
      alignment: Alignment.center,
      child: RLCourseBookImage(courseColor: courseColor, size: POPULAR_BOOK_SIZE),
    );

    return GestureDetector(
      onTap: onCircleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: POPULAR_CIRCLE_DIAMETER,
        child: Div.column([
          circleArt,

          const Spacing.height(RLDS.spacing8),

          RLTypography.bodyMedium(
            courseTitle,
            color: RLDS.textPrimary,
            textAlign: TextAlign.center,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),
      ),
    );
  }
}

// Circle geometry. Diameter sits a touch above the icon scale so the
// pixel-art book reads cleanly inside the disc; book size is tuned so the
// art floats with comfortable padding rather than touching the rim.
const double POPULAR_CIRCLE_DIAMETER = 88.0;
const double POPULAR_BOOK_SIZE = 56.0;
