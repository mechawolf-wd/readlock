// Bookshelf screen, shows the courses the reader owns. A course
// becomes owned the moment PurchaseService.purchaseCourse succeeds
// (writes /users/{id}.purchasedCourses). The list paginates in pages
// of BOOKSHELF_PAGE_SIZE via a Load more button so the shelf doesn't
// eagerly render every owned course.

import 'package:flutter/material.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLCourseFilterPanel.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/RLCourseGenres.dart';
import 'package:readlock/constants/RLCoursePalette.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/bottom_sheets/user/BirdPickerBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/SettingsBottomSheet.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/services/purchases/PurchaseService.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';
import 'package:readlock/MainNavigation.dart';

import 'package:pixelarticons/pixel.dart';

// How many bookshelf cards are rendered before the Load more button is shown.
// Tapping Load more reveals another BOOKSHELF_PAGE_SIZE courses.
const int BOOKSHELF_PAGE_SIZE = 5;

// Bottom inset on the saved-courses scroll view so the last card can clear
// the floating filter pane before bottoming out, mirroring the store's
// STORE_LIST_FILTER_OVERLAY_INSET.
const double BOOKSHELF_FILTER_OVERLAY_INSET = 148.0;

// Hours after purchase during which the NEW badge is displayed on the card.
const int BOOKSHELF_NEW_PURCHASE_WINDOW_HOURS = 24;

// How many pixels the NEW badge protrudes outside the circle corner.
const double BOOKSHELF_NEW_BADGE_OFFSET = 4.0;

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => BookshelfScreenState();
}

class BookshelfScreenState extends State<BookshelfScreen> {
  static final Widget SettingsIcon = const Icon(
    Pixel.menu,
    color: RLDS.textSecondary,
    size: RLDS.iconXLarge,
  );

  JSONList savedCourses = [];
  bool isBookshelfLoading = true;
  int visibleCoursesCount = BOOKSHELF_PAGE_SIZE;

  // Local filter state, same shape as CoursesScreen's. Genre chips +
  // title query are layered over the savedCourses list at render time.
  // Hidden behind the filter affordance so the shelf stays calm by
  // default and only reveals the filter pane when the reader asks.
  final TextEditingController filterSearchController = TextEditingController();
  Set<String> selectedFilterGenres = <String>{};
  String filterSearchQuery = '';

  // Bumped every time this tab becomes active. Used as the typewriter
  // heading's ValueKey so a fresh activation remounts the widget and
  // re-runs its character-by-character reveal.
  int titleAnimationVersion = 0;

  // Re-entrancy guard. fetchSavedCourses ends up writing to
  // purchasedCoursesNotifier via hydratePurchaseStateFromUser, which would
  // re-fire handlePurchasedCoursesChanged below and recurse. The flag
  // short-circuits the listener while a fetch is already in flight.
  bool isFetchingSavedCourses = false;

  // Same idea for the lighter listener-driven re-fetch path. Keeps
  // back-to-back purchase events from stacking up parallel queries.
  bool isRefreshingSavedCoursesFromNotifier = false;

  // Soft green halo behind the Load more button so it reads as the
  // bottom-of-list CTA. Tinted with success green to telegraph "fetch
  // more" rather than the surprise-me blue.
  static final BoxDecoration loadMoreGlowDecoration = RLDS.glowDecoration(
    color: RLDS.glass05(RLDS.white),
  );

  // Square box the bird is rendered into. Picked so the row aligns to
  // the same visual height as the bookshelf's title cards.
  static const double readingTimeBirdPreviewSize = 56.0;

  @override
  void initState() {
    super.initState();
    fetchSavedCourses();
    activeTabIndexNotifier.addListener(handleTabActivated);
    purchasedCoursesNotifier.addListener(handlePurchasedCoursesChanged);
    courseProgressNotifier.addListener(handleCourseProgressChanged);
  }

  @override
  void dispose() {
    activeTabIndexNotifier.removeListener(handleTabActivated);
    purchasedCoursesNotifier.removeListener(handlePurchasedCoursesChanged);
    courseProgressNotifier.removeListener(handleCourseProgressChanged);
    filterSearchController.dispose();
    super.dispose();
  }

  // * Filter handlers, local state only, no Firestore round-trip. The
  // saved-courses list is rendered through getFilteredSavedCourses() so
  // a chip toggle or query change just rebuilds with a fresh slice.

  void handleFilterGenreToggled(String genre) {
    setState(() {
      final bool isAlreadySelected = selectedFilterGenres.contains(genre);

      if (isAlreadySelected) {
        selectedFilterGenres.remove(genre);
      } else {
        selectedFilterGenres.add(genre);
      }

      visibleCoursesCount = BOOKSHELF_PAGE_SIZE;
    });
  }

  void handleFilterSearchChanged(String value) {
    setState(() {
      filterSearchQuery = value;
      visibleCoursesCount = BOOKSHELF_PAGE_SIZE;
    });
  }

  // Title-then-genre filter applied at render time over savedCourses.
  // Mirrors CoursesScreen.getLocallyFilteredCourses so both surfaces
  // behave the same: an empty filter passes the full list through, a
  // selected chip narrows by genre tag, a typed query narrows by title.
  JSONList getFilteredSavedCourses() {
    final String query = filterSearchQuery.trim().toLowerCase();
    final bool hasNoQuery = query.isEmpty;
    final bool hasNoGenres = selectedFilterGenres.isEmpty;
    final bool hasNoFilters = hasNoQuery && hasNoGenres;

    if (hasNoFilters) {
      return savedCourses;
    }

    return savedCourses.where((course) {
      final String courseTitle = (course['title'] as String? ?? '').toLowerCase();
      final bool titleMatches = hasNoQuery || courseTitle.contains(query);
      final bool genreMatches = hasNoGenres || courseMatchesAnySelectedFilterGenre(course);

      return titleMatches && genreMatches;
    }).toList();
  }

  bool courseMatchesAnySelectedFilterGenre(JSONMap course) {
    final dynamic raw = course['genres'];
    final bool isList = raw is List;

    if (!isList) {
      return false;
    }

    for (final dynamic entry in raw) {
      final bool isString = entry is String;

      if (!isString) {
        continue;
      }

      final bool isMatch = selectedFilterGenres.contains(entry.trim());

      if (isMatch) {
        return true;
      }
    }

    return false;
  }

  void handleTabActivated() {
    final bool isMyTabActive = activeTabIndexNotifier.value == TAB_INDEX_BOOKSHELF;

    if (!isMyTabActive) {
      return;
    }

    setState(() {
      titleAnimationVersion++;
    });
  }

  // Fired by PurchaseService.purchaseCourse the moment a course unlock
  // succeeds. Detects which course is new (so the card can slide in on
  // the next build) then refreshes the local list from the notifier
  // without re-reading the user profile. Re-reading the profile here
  // used to race the in-flight Firestore writes and overwrite the
  // optimistic notifier with the stale set, which made every screen
  // think the purchase had been undone.
  void handlePurchasedCoursesChanged() {
    refreshSavedCoursesFromNotifier();
  }

  // Fires when a lesson is finished and courseProgressNotifier advances.
  // Rebuilds the card arcs so the reader sees updated rings immediately
  // when they return to the shelf without waiting for a fresh fetch.
  void handleCourseProgressChanged() {
    setState(() {});
  }

  Future<void> fetchSavedCourses() async {
    if (isFetchingSavedCourses) {
      return;
    }

    isFetchingSavedCourses = true;

    try {
      final UserModel? user = await UserService.getCurrentUserProfile();
      final List<String> ownedIds =
          user?.purchasedCourses.map((entry) => entry.courseId).toList() ?? const <String>[];
      final JSONList courses = await CourseDataService.fetchCoursesByIds(ownedIds);

      if (user != null) {
        bionicEnabledNotifier.value = user.bionic;
        rsvpEnabledNotifier.value = user.rsvp;
        hydratePurchaseStateFromUser(user);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        savedCourses = courses;
        visibleCoursesCount = BOOKSHELF_PAGE_SIZE;
        isBookshelfLoading = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        isBookshelfLoading = false;
      });
    } finally {
      isFetchingSavedCourses = false;
    }
  }

  // Listener-driven refresh used after a purchase. Reads owned IDs from
  // the already-authoritative purchasedCoursesNotifier (no /users round
  // trip) and pulls the matching course docs so the freshly-bought
  // course appears on the shelf immediately.
  Future<void> refreshSavedCoursesFromNotifier() async {
    if (isRefreshingSavedCoursesFromNotifier) {
      return;
    }

    isRefreshingSavedCoursesFromNotifier = true;

    try {
      final List<String> ownedIds = purchasedCoursesNotifier.value
          .map((entry) => entry.courseId)
          .toList();
      final JSONList courses = await CourseDataService.fetchCoursesByIds(ownedIds);

      if (!mounted) {
        return;
      }

      setState(() {
        savedCourses = courses;
        isBookshelfLoading = false;
      });
    } on Exception {
      // Soft-fail: the next initState or tab activation re-fetches.
    } finally {
      isRefreshingSavedCoursesFromNotifier = false;
    }
  }

  void handleLoadMoreTap() {
    final int totalFilteredCount = getFilteredSavedCourses().length;
    final bool hasNothingMoreToLoad = visibleCoursesCount >= totalFilteredCount;

    if (hasNothingMoreToLoad) {
      RLToast.info(context, RLUIStrings.LOAD_MORE_NOTHING_LEFT);
      return;
    }

    setState(() {
      visibleCoursesCount += BOOKSHELF_PAGE_SIZE;
    });
  }

  void navigateToCourse(String courseId) {
    SoundService.playRandomTextClick();
    Navigator.push(context, RLDS.fadeTransition(CourseRoadmapScreen(courseId: courseId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.transparent,
      body: SafeArea(bottom: false, child: BookshelfBody()),
    );
  }

  Widget BookshelfBody() {
    return RLFadeSwitcher(child: BookshelfBodyCurrent());
  }

  Widget BookshelfBodyCurrent() {
    // Loading: show just the centred bird so it sits in the middle of the
    // screen, same as Home and Search. The header is deferred until the
    // content is ready.
    if (isBookshelfLoading) {
      return const RLLoadingIndicator.bird(key: ValueKey('bookshelf-loading'));
    }

    // SafeArea(bottom: false) lets the starfield paint under the nav, but
    // the bottom-pinned filter pane would sit under it too. Mirror the
    // CoursesScreen formula: device safe-area + nav-bar height becomes
    // MediaQuery's bottom padding here, and adding it as the parent's
    // bottom inset puts the floating panel exactly above the nav.
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      RLDS.spacing24,
      RLDS.spacing24,
      RLDS.spacing24,
      RLDS.spacing16 + bottomInset,
    );

    return Padding(
      key: const ValueKey('bookshelf-content'),
      padding: contentPadding,
      child: Div.column([
        BookshelfHeaderWithSettings(),

        const Spacing.height(RLDS.spacing24),

        // Reading-time stopwatch sits at the screen level so the counter
        // is visible on every shelf state (empty, populated, filter-empty),
        // including a brand-new user whose only contribution so far is the
        // onboarding-credited seed time.
        ReadingTimeCounter(),

        const Spacing.height(RLDS.spacing16),

        Expanded(child: BookshelfBodyArea()),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // The empty shelf collapses to just the bird greeting; the populated
  // shelf renders the list with the same floating filter + reset chip
  // CoursesScreen uses, so paging through your books and the store feels
  // like one surface.
  Widget BookshelfBodyArea() {
    final bool hasNoSavedCourses = savedCourses.isEmpty;

    if (hasNoSavedCourses) {
      return EmptyBookshelfMessage();
    }

    return Stack(
      children: [
        Positioned.fill(child: SavedCoursesList()),

        Positioned(left: 0, right: 0, bottom: 0, child: FilterPanelWithReset()),
      ],
    );
  }

  Widget SavedCoursesList() {
    final JSONList filteredCourses = getFilteredSavedCourses();
    final bool hasActiveFilters =
        selectedFilterGenres.isNotEmpty || filterSearchQuery.trim().isNotEmpty;
    final bool shouldShowFilterEmptyState = hasActiveFilters && filteredCourses.isEmpty;

    final List<Widget> listChildren = [];

    // When the filter narrows the shelf to nothing, swap the cards + Load
    // more block for the same bird used by the wholly-empty shelf so the
    // reader sees a familiar "nothing here" cue instead of a dead Load
    // more button. The floating filter still sits above the nav so they
    // can clear it.
    if (shouldShowFilterEmptyState) {
      listChildren.add(FilterEmptyBird());
    } else {
      listChildren.add(OwnedHeadingRow());
      listChildren.add(const Spacing.height(RLDS.spacing12));
      listChildren.addAll(SavedCourseCards());
      listChildren.add(LoadMoreSlot());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: BOOKSHELF_FILTER_OVERLAY_INSET),
      child: Div.column(listChildren, crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Bird + chirp caption shown when an active filter excludes every owned
  // course. Mirrors the wholly-empty shelf treatment so the two empty
  // surfaces feel like part of one family; the caption is filter-specific
  // so the reader doesn't read it as "your shelf is empty".
  Widget FilterEmptyBird() {
    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing40),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BookshelfBird(),

            const Spacing.height(RLDS.spacing16),

            RLTypography.bodyMedium(
              RLUIStrings.BOOKSHELF_FILTER_EMPTY_MESSAGE,
              color: RLDS.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Total reading time stat tile. Mirrors HomeScreen.RandomLessonSection
  // visually (starfield surface, info-blue tint, soft halo) so the two
  // tabs share a stat-row vocabulary. Subscribes to timeSpentReadingNotifier
  // so a session committed in CourseContentViewer.dispose updates the
  // counter the moment the reader returns to the bookshelf, even before
  // the Firestore write completes.
  Widget ReadingTimeCounter() {
    return ValueListenableBuilder<int>(
      valueListenable: timeSpentReadingNotifier,
      builder: ReadingTimeCounterBuilder,
    );
  }

  Widget ReadingTimeCounterBuilder(
    BuildContext context,
    int totalSeconds,
    Widget? unusedChild,
  ) {
    final String stopwatchLabel = formatStopwatchReadout(totalSeconds);
    // Subheader uses bodyMedium (JetBrains Mono) so the small caption
    // above the readout shares the digital-monospace vocabulary the
    // stopwatch digits speak.
    final Widget readingTimeSubheader = RLTypography.bodyMedium(
      RLUIStrings.BOOKSHELF_READING_TIME_LABEL,
      color: RLDS.textSecondary,
    );
    final Widget readingTimeReadout = RLTypography.headingMedium(stopwatchLabel);

    final Widget readingTimeStack = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [readingTimeSubheader, const Spacing.height(RLDS.spacing4), readingTimeReadout],
    );

    void onReadingTimeTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      BirdPickerBottomSheet.show(context);
    }

    // While the shelf is empty, the empty-state hero already paints the
    // reader's bird front-and-centre. Showing it again in the counter card
    // reads as a duplicate, so the inline bird (and its leading gap) drop
    // out until the reader owns at least one course.
    final bool shouldShowInlineBird = savedCourses.isNotEmpty;

    final List<Widget> counterChildren = [Expanded(child: readingTimeStack)];

    if (shouldShowInlineBird) {
      counterChildren.add(const Spacing.width(RLDS.spacing16));
      counterChildren.add(ReadingTimeBird());
    }

    final Widget counterCard = RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12, horizontal: RLDS.spacing16),
      child: Row(children: counterChildren),
    );

    return GestureDetector(
      onTap: onReadingTimeTap,
      behavior: HitTestBehavior.opaque,
      child: counterCard,
    );
  }

  // The reader's profile bird, rendered at the inline preview size used
  // by the stopwatch tile. Listens to selectedBirdNotifier so changing
  // birds in Settings updates the counter live.
  Widget ReadingTimeBird() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: ReadingTimeBirdBuilder,
    );
  }

  Widget ReadingTimeBirdBuilder(BuildContext context, BirdOption bird, Widget? unusedChild) {
    return SizedBox(
      width: readingTimeBirdPreviewSize,
      height: readingTimeBirdPreviewSize,
      child: BirdAnimationSprite(bird: bird, previewSize: readingTimeBirdPreviewSize),
    );
  }

  // Stopwatch readout: HH:MM:SS, zero-padded. Always rendered, even at
  // zero, so the tile reads as a fresh stopwatch waiting to start
  // instead of an empty card.
  String formatStopwatchReadout(int totalSeconds) {
    final int safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final int hours = safeSeconds ~/ 3600;
    final int minutes = (safeSeconds % 3600) ~/ 60;
    final int seconds = safeSeconds % 60;

    final String hoursLabel = hours.toString().padLeft(2, '0');
    final String minutesLabel = minutes.toString().padLeft(2, '0');
    final String secondsLabel = seconds.toString().padLeft(2, '0');

    return '$hoursLabel:$minutesLabel:$secondsLabel';
  }

  // Section heading. The filter affordance moved out of this row when the
  // panel switched to the floating bottom layout, the panel itself is
  // always visible above the nav, so the heading is just a label now.
  Widget OwnedHeadingRow() {
    return Div.row([
      RLTypography.bodyMedium(RLUIStrings.BOOKSHELF_OWNED_HEADING, color: RLDS.textSecondary),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Floating filter pane hovering above the bottom nav. Same shape as
  // CoursesScreen.FilterPanelWithReset: an optional LunarBlur X chip
  // anchored to the panel's top-right corner, mounted only when at least
  // one filter is active.
  Widget FilterPanelWithReset() {
    final bool hasActiveFilters =
        selectedFilterGenres.isNotEmpty || filterSearchQuery.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RenderIf.condition(hasActiveFilters, ClearFiltersChip()),

        RenderIf.condition(hasActiveFilters, const Spacing.height(RLDS.spacing8)),

        RLCourseFilterPanel(
          availableGenres: COURSE_GENRES,
          selectedGenres: selectedFilterGenres,
          onGenreToggled: handleFilterGenreToggled,
          searchController: filterSearchController,
          onSearchChanged: handleFilterSearchChanged,
          searchPlaceholder: RLUIStrings.SEARCH_PLACEHOLDER,
        ),
      ],
    );
  }

  // Frosted X chip that wipes the active filters in one tap. Mirrors
  // CoursesScreen.ClearFiltersChip so the two surfaces share one
  // affordance for "reset what's narrowing this list", just docked into
  // the heading row here instead of floating above the panel.
  Widget ClearFiltersChip() {
    return GestureDetector(
      onTap: handleClearFiltersTap,
      behavior: HitTestBehavior.opaque,
      child: RLLunarBlur(
        borderRadius: BorderRadius.circular(clearFiltersChipDiameter / 2),
        padding: const EdgeInsets.all(RLDS.spacing8),
        child: const Icon(Pixel.close, color: RLDS.textSecondary, size: RLDS.iconMedium),
      ),
    );
  }

  // Diameter of the reset chip, matches CoursesScreen so the affordance
  // reads identically across both surfaces.
  static const double clearFiltersChipDiameter = 40.0;

  void handleClearFiltersTap() {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();
    filterSearchController.clear();

    setState(() {
      selectedFilterGenres.clear();
      filterSearchQuery = '';
      visibleCoursesCount = BOOKSHELF_PAGE_SIZE;
    });
  }

  List<Widget> SavedCourseCards() {
    final JSONList filteredCourses = getFilteredSavedCourses();
    final int totalCourses = filteredCourses.length;
    final int cardsToRender = visibleCoursesCount.clamp(0, totalCourses);
    final JSONList visibleCourses = JSONList.from(filteredCourses.take(cardsToRender));

    return visibleCourses.map<Widget>(CourseCard).toList();
  }

  // * Course row geometry, circle diameter mirrors BookListCard's
  // 48px book + 12px padding so the bookshelf book sits at the same
  // scale as the search/home cards. Both halves of the row are
  // pinned to the same height via the SizedBox so the title/author
  // pane lines up with the circle.
  static const double bookshelfBookSize = LIST_CARD_BOOK_SIZE;
  static const double bookshelfCircleDiameter = bookshelfBookSize + RLDS.spacing12 * 2;
  static const double bookshelfCardSurfaceAlpha = 0.05;

  // Stroke width for the per-book progress arc. Scaled down from the
  // roadmap's 6.0 because the bookshelf disc is roughly 0.4× the size
  // of the roadmap one, keeps the same visual weight on the smaller
  // circle.
  static const double bookshelfProgressStrokeWidth = 4.0;

  // Sums the lesson count across every segment in the course JSON.
  // Falls back to 1 so the division below never produces NaN.
  int computeTotalLessonCount(JSONMap course) {
    final dynamic rawSegments = course['segments'];
    final bool hasSegments = rawSegments is List && rawSegments.isNotEmpty;

    if (!hasSegments) {
      return 1;
    }

    int total = 0;

    for (final dynamic segment in rawSegments) {
      final dynamic rawLessons = (segment as JSONMap)['lessons'];
      final bool hasLessons = rawLessons is List;

      if (hasLessons) {
        total += rawLessons.length;
      }
    }

    return total > 0 ? total : 1;
  }

  // Real progress fraction driven by courseProgressNotifier. Returns 0.0
  // when the course has not been started yet (fresh purchase, index == 0).
  double computeProgressForCourse(String courseId, JSONMap course) {
    final int currentLessonIndex =
        courseProgressNotifier.value[courseId]?.currentLessonIndex ?? 0;
    final int totalLessons = computeTotalLessonCount(course);

    return (currentLessonIndex / totalLessons).clamp(0.0, 1.0);
  }

  // Each course renders as two side-by-side cards on a tinted surface:
  // a circular pane holding the book PNG and a rounded-rect pane
  // holding the title + author. Both share a surfaceColor of the
  // course's accent at 0.05 alpha, so the row picks up a hint of the
  // book's identity without the heavy dark frost the rest of the app
  // uses for cards.
  Widget CourseCard(JSONMap course) {
    final String courseTitle = course['title'] as String? ?? '';
    final String courseAuthor = course['author'] as String? ?? '';
    final String? courseColor = course['color'] as String?;
    final String courseId = course['course-id'] as String? ?? '';

    final Color accentColor = resolveCourseAccentColor(courseColor);
    final double progress = computeProgressForCourse(courseId, course);
    final bool isNew = isNewlyPurchasedCourse(courseId);

    void onCardTap() {
      HapticsService.lightImpact();
      navigateToCourse(courseId);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: RLDS.spacing12),
      child: GestureDetector(
        onTap: onCardTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: bookshelfCircleDiameter,
          child: Row(
            children: [
              BookCircleCard(
                accentColor: accentColor,
                courseColor: courseColor,
                progress: progress,
              ),

              const Spacing.width(RLDS.spacing12),

              Expanded(
                child: TitleAuthorCard(
                  accentColor: accentColor,
                  title: courseTitle,
                  author: courseAuthor,
                  isNew: isNew,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isNewlyPurchasedCourse(String courseId) {
    final entry = PurchaseService.findPurchasedEntry(purchasedCoursesNotifier.value, courseId);
    final bool hasPurchasedAt = entry?.purchasedAt != null;

    if (!hasPurchasedAt) {
      return false;
    }

    final Duration elapsed = DateTime.now().difference(entry!.purchasedAt!);

    return elapsed.inHours < BOOKSHELF_NEW_PURCHASE_WINDOW_HOURS;
  }

  // Mirrors CourseRoadmapScreen.getCourseAccentColor, normalises the
  // hex, falls back to the palette default for unknown values, and to
  // RLDS.success if parsing fails. Kept local so the bookshelf doesn't
  // depend on the roadmap's State for a pure colour decision.
  Color resolveCourseAccentColor(String? rawCourseColor) {
    final String normalized = (rawCourseColor ?? '').replaceAll('#', '').trim().toUpperCase();
    final bool isKnown = KNOWN_COURSE_COLORS.contains(normalized);
    final String effectiveHex = isKnown ? normalized : COURSE_FALLBACK_COLOR_HEX;
    final Color? parsed = RLDS.parseHexColor(effectiveHex);

    return parsed ?? RLDS.success;
  }

  // Circular pane on the left, holds the book PNG at the standard
  // list-card size, sized so the circle diameter matches the row.
  // The progress arc paints on top of the LunarBlur surface using the
  // same AnimatedProgressArc / ProgressArcPainter the roadmap screen
  // uses, so the visual treatment is consistent across surfaces.
  static final BoxDecoration newBadgeDecoration = BoxDecoration(
    color: RLDS.success,
    borderRadius: BorderRadius.circular(RLDS.spacing4),
  );

  Widget BookCircleCard({
    required Color accentColor,
    required String? courseColor,
    required double progress,
  }) {
    final BorderRadius circleRadius = BorderRadius.circular(bookshelfCircleDiameter / 2);

    final Widget bookImage = RLSkillBookImage(
      courseColor: courseColor,
      size: bookshelfBookSize,
    );

    final Widget bookSurface = RLLunarBlur(
      borderRadius: circleRadius,
      borderColor: RLDS.transparent,
      surfaceColor: accentColor,
      surfaceAlpha: bookshelfCardSurfaceAlpha,
      padding: const EdgeInsets.all(RLDS.spacing12),
      child: Center(child: bookImage),
    );

    final Animation<double> staticProgress = AlwaysStoppedAnimation<double>(progress);

    return SizedBox(
      width: bookshelfCircleDiameter,
      height: bookshelfCircleDiameter,
      child: Stack(
        children: [
          Positioned.fill(child: bookSurface),

          Positioned.fill(
            child: AnimatedProgressArc(
              animation: staticProgress,
              color: accentColor,
              strokeWidth: bookshelfProgressStrokeWidth,
            ),
          ),
        ],
      ),
    );
  }

  Widget NewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing4, vertical: RLDS.spacing4),
      decoration: newBadgeDecoration,
      child: RLTypography.pixelLabel(RLUIStrings.BOOKSHELF_NEW_BADGE_LABEL, color: RLDS.white),
    );
  }

  // Rectangular pane on the right, title + author stacked, vertically
  // centered to line up with the circle. Title clamps to one line so a
  // long title doesn't break the row geometry; author wraps freely.
  Widget TitleAuthorCard({
    required Color accentColor,
    required String title,
    required String author,
    required bool isNew,
  }) {
    final Widget card = RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      borderColor: RLDS.transparent,
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing16, vertical: RLDS.spacing12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RLTypography.bodyLarge(title, maxLines: 1, overflow: TextOverflow.ellipsis),

          const Spacing.height(RLDS.spacing4),

          RLTypography.bodyMedium(author, color: RLDS.textSecondary),
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        card,

        Positioned(
          top: -BOOKSHELF_NEW_BADGE_OFFSET,
          right: -BOOKSHELF_NEW_BADGE_OFFSET,
          child: RenderIf.condition(isNew, NewBadge()),
        ),
      ],
    );
  }

  // Always rendered under the Owned list, matching the Search screen's
  // unfiltered Load more button. handleLoadMoreTap surfaces an info toast
  // when the visible window already covers the filtered list.
  Widget LoadMoreSlot() {
    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing16),
      child: Container(
        decoration: loadMoreGlowDecoration,
        child: RLButton.secondary(
          color: RLDS.white,
          label: RLUIStrings.BOOKSHELF_LOAD_MORE_LABEL,
          onTap: handleLoadMoreTap,
        ),
      ),
    );
  }

  Widget BookshelfHeaderWithSettings() {
    void onSettingsTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      SettingsBottomSheet.show(context);
    }

    return Div.row([
      RLTypewriterText(
        key: ValueKey<int>(titleAnimationVersion),
        text: RLUIStrings.BOOKSHELF_TITLE,
        style: RLTypography.headingLargeStyle,
      ),

      const Spacer(),

      GestureDetector(
        onTap: onSettingsTap,
        behavior: HitTestBehavior.opaque,
        child: SettingsIcon,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Empty-state bird, same selectedBirdNotifier source as Settings/Pause so
  // the shelf reflects whichever bird the reader has picked. Idle frames for
  // now (the only animation we have configured on every sprite sheet).
  Widget BookshelfBird() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: BookshelfBirdBuilder,
    );
  }

  Widget BookshelfBirdBuilder(BuildContext context, BirdOption bird, Widget? unusedChild) {
    return BirdAnimationSprite(bird: bird);
  }

  // Bird anchored to the top of the viewport (not vertically centred) so it
  // reads as a greeting that sits above the fold, with the rest of the
  // screen left intentionally empty until the reader starts a course.
  Widget EmptyBookshelfMessage() {
    return Padding(
      key: const ValueKey('bookshelf-empty'),
      padding: const EdgeInsets.only(top: RLDS.spacing40),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BookshelfBird(),

            const Spacing.height(RLDS.spacing16),

            RLTypography.bodyMedium(
              RLUIStrings.BOOKSHELF_EMPTY_MESSAGE,
              color: RLDS.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
