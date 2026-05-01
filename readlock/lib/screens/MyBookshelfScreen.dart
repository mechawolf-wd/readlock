// Bookshelf screen — shows the courses the reader owns. A course
// becomes owned the moment PurchaseService.purchaseCourse succeeds
// (writes /users/{id}.purchasedCourses). The list paginates in pages
// of BOOKSHELF_PAGE_SIZE via a Load more button so the shelf doesn't
// eagerly render every owned course.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBalancePill.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
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
import 'package:readlock/bottom_sheets/user/SettingsBottomSheet.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';
import 'package:readlock/MainNavigation.dart';

import 'package:pixelarticons/pixel.dart';

// How many bookshelf cards are rendered before the Load more button is shown.
// Tapping Load more reveals another BOOKSHELF_PAGE_SIZE courses.
const int BOOKSHELF_PAGE_SIZE = 5;

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => BookshelfScreenState();
}

class BookshelfScreenState extends State<BookshelfScreen> {
  static final Widget SettingsIcon = const Icon(
    Pixel.menu,
    color: RLDS.textSecondary,
    size: RLDS.iconLarge,
  );

  JSONList savedCourses = [];
  bool isBookshelfLoading = true;
  int visibleCoursesCount = BOOKSHELF_PAGE_SIZE;

  // Local filter state — same shape as CoursesScreen's. Genre chips +
  // title query are layered over the savedCourses list at render time.
  // Hidden behind the filter affordance so the shelf stays calm by
  // default and only reveals the filter pane when the reader asks.
  final TextEditingController filterSearchController = TextEditingController();
  Set<String> selectedFilterGenres = <String>{};
  String filterSearchQuery = '';
  bool isFilterPanelOpen = false;

  // Bumped every time this tab becomes active. Used as the typewriter
  // heading's ValueKey so a fresh activation remounts the widget and
  // re-runs its character-by-character reveal.
  int titleAnimationVersion = 0;

  // Re-entrancy guard. fetchSavedCourses ends up writing to
  // purchasedCoursesNotifier via hydratePurchaseStateFromUser, which would
  // re-fire handlePurchasedCoursesChanged below and recurse. The flag
  // short-circuits the listener while a fetch is already in flight.
  bool isFetchingSavedCourses = false;

  @override
  void initState() {
    super.initState();
    fetchSavedCourses();
    activeTabIndexNotifier.addListener(handleTabActivated);
    purchasedCoursesNotifier.addListener(handlePurchasedCoursesChanged);
  }

  @override
  void dispose() {
    activeTabIndexNotifier.removeListener(handleTabActivated);
    purchasedCoursesNotifier.removeListener(handlePurchasedCoursesChanged);
    filterSearchController.dispose();
    super.dispose();
  }

  // * Filter handlers — local state only, no Firestore round-trip. The
  // saved-courses list is rendered through getFilteredSavedCourses() so
  // a chip toggle or query change just rebuilds with a fresh slice.

  void handleFilterToggleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      isFilterPanelOpen = !isFilterPanelOpen;
    });
  }

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
  // succeeds. Re-pulls /users/{id}.purchasedCourses so the bookshelf
  // shows the freshly-owned course as soon as the reader switches back
  // to this tab, instead of waiting for an app restart.
  void handlePurchasedCoursesChanged() {
    fetchSavedCourses();
  }

  Future<void> fetchSavedCourses() async {
    if (isFetchingSavedCourses) {
      return;
    }

    isFetchingSavedCourses = true;

    try {
      final UserModel? user = await UserService.getCurrentUserProfile();
      final List<String> ownedIds = user?.purchasedCourses ?? const <String>[];
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

    // The Bookshelf heading + settings icon always sits at the top once
    // loading is done. The body below swaps between the saved-courses list
    // and the empty-state bird; the header never disappears.
    return Padding(
      key: const ValueKey('bookshelf-content'),
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Div.column([
        BookshelfHeaderWithSettings(),

        const Spacing.height(RLDS.spacing40),

        Expanded(child: BookshelfBodyContent()),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  Widget BookshelfBodyContent() {
    final bool hasNoSavedCourses = savedCourses.isEmpty;

    if (hasNoSavedCourses) {
      return EmptyBookshelfMessage();
    }

    return SavedCoursesList();
  }

  Widget SavedCoursesList() {
    final List<Widget> listChildren = [
      OwnedHeadingRow(),

      RenderIf.condition(isFilterPanelOpen, const Spacing.height(RLDS.spacing12)),

      RenderIf.condition(isFilterPanelOpen, FilterPanel()),

      const Spacing.height(RLDS.spacing12),

      ...SavedCourseCards(),

      LoadMoreSlot(),
    ];

    return SingleChildScrollView(
      child: Div.column(listChildren, crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Section heading + filter affordance. Heading uses the same muted
  // bodyMedium treatment as HomeScreen's "Reading now…" so the two
  // surfaces feel like part of one family. The filter icon sits flush
  // right; tapping it toggles the shared filter pane below.
  Widget OwnedHeadingRow() {
    final bool hasActiveFilters =
        selectedFilterGenres.isNotEmpty || filterSearchQuery.trim().isNotEmpty;
    final Color filterIconColor = hasActiveFilters ? RLDS.primary : RLDS.textSecondary;

    final Widget filterIcon = Icon(Pixel.sliders, color: filterIconColor, size: RLDS.iconLarge);

    return Div.row([
      RLTypography.bodyMedium(RLUIStrings.BOOKSHELF_OWNED_HEADING, color: RLDS.textSecondary),

      const Spacer(),

      GestureDetector(
        onTap: handleFilterToggleTap,
        behavior: HitTestBehavior.opaque,
        child: filterIcon,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Same frosted filter pane the Search screen uses. Mounted under the
  // Owned heading when the reader has tapped the filter icon, hidden
  // otherwise so the bookshelf stays calm by default.
  Widget FilterPanel() {
    return RLCourseFilterPanel(
      availableGenres: COURSE_GENRES,
      selectedGenres: selectedFilterGenres,
      onGenreToggled: handleFilterGenreToggled,
      searchController: filterSearchController,
      onSearchChanged: handleFilterSearchChanged,
      searchPlaceholder: RLUIStrings.SEARCH_PLACEHOLDER,
    );
  }

  List<Widget> SavedCourseCards() {
    final JSONList filteredCourses = getFilteredSavedCourses();
    final int totalCourses = filteredCourses.length;
    final int cardsToRender = visibleCoursesCount.clamp(0, totalCourses);
    final JSONList visibleCourses = JSONList.from(filteredCourses.take(cardsToRender));

    return visibleCourses.map<Widget>(CourseCard).toList();
  }

  // * Course row geometry — circle diameter mirrors BookListCard's
  // 48px book + 12px padding so the bookshelf book sits at the same
  // scale as the search/home cards. Both halves of the row are
  // pinned to the same height via the SizedBox so the title/author
  // pane lines up with the circle.
  static const double bookshelfBookSize = LIST_CARD_BOOK_SIZE;
  static const double bookshelfCircleDiameter = bookshelfBookSize + RLDS.spacing12 * 2;
  static const double bookshelfCardSurfaceAlpha = 0.05;

  // Stroke width for the per-book progress arc. Scaled down from the
  // roadmap's 6.0 because the bookshelf disc is roughly 0.4× the size
  // of the roadmap one — keeps the same visual weight on the smaller
  // circle.
  static const double bookshelfProgressStrokeWidth = 4.0;

  // MOCK — deterministic pseudo-random progress in [0.10, 0.95] keyed
  // by courseId so each book has a distinct ring without animation.
  // Replace with real per-course progress (read from
  // /users/{id}.courseProgress) once that pipeline is wired through.
  double mockProgressForCourseId(String courseId) {
    final int hash = courseId.hashCode.abs();
    final double normalized = (hash % 86) / 100.0;

    return 0.10 + normalized;
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
    final String? coverImagePath = course['cover-image-path'] as String?;
    final String? courseColor = course['color'] as String?;
    final String courseId = course['course-id'] as String? ?? '';

    final Color accentColor = resolveCourseAccentColor(courseColor);
    final double progress = mockProgressForCourseId(courseId);

    void onCardTap() {
      HapticFeedback.lightImpact();
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
                coverImagePath: coverImagePath,
                progress: progress,
              ),

              const Spacing.width(RLDS.spacing12),

              Expanded(
                child: TitleAuthorCard(
                  accentColor: accentColor,
                  title: courseTitle,
                  author: courseAuthor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mirrors CourseRoadmapScreen.getCourseAccentColor — normalises the
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

  // Circular pane on the left — holds the book PNG at the standard
  // list-card size, sized so the circle diameter matches the row.
  // The progress arc paints on top of the LunarBlur surface using the
  // same AnimatedProgressArc / ProgressArcPainter the roadmap screen
  // uses, so the visual treatment is consistent across surfaces.
  Widget BookCircleCard({
    required Color accentColor,
    required String? courseColor,
    required String? coverImagePath,
    required double progress,
  }) {
    final BorderRadius circleRadius = BorderRadius.circular(bookshelfCircleDiameter / 2);
    final bool hasCourseColor = courseColor != null && courseColor.isNotEmpty;

    final Widget bookImage = hasCourseColor
        ? RLCourseBookImage(courseColor: courseColor, size: bookshelfBookSize)
        : BookCoverThumbnail(coverImagePath: coverImagePath);

    final Widget bookSurface = RLLunarBlur(
      borderRadius: circleRadius,
      borderColor: RLDS.transparent,
      surfaceColor: accentColor,
      surfaceAlpha: bookshelfCardSurfaceAlpha,
      padding: const EdgeInsets.all(RLDS.spacing12),
      child: Center(child: bookImage),
    );

    // AlwaysStoppedAnimation so the painter renders the arc at its
    // mock value without spinning up an AnimationController per card.
    // When real progress lands, swap this for the per-course value.
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
              color: RLDS.glass70(accentColor),
              strokeWidth: bookshelfProgressStrokeWidth,
            ),
          ),
        ],
      ),
    );
  }

  // Rectangular pane on the right — title + author stacked, vertically
  // centered to line up with the circle. Title clamps to one line so a
  // long title doesn't break the row geometry; author wraps freely.
  Widget TitleAuthorCard({
    required Color accentColor,
    required String title,
    required String author,
  }) {
    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      borderColor: RLDS.transparent,
      surfaceColor: accentColor,
      surfaceAlpha: bookshelfCardSurfaceAlpha,
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
  }

  // Always rendered under the Owned list, matching the Search screen's
  // unfiltered Load more button. handleLoadMoreTap surfaces an info toast
  // when the visible window already covers the filtered list.
  Widget LoadMoreSlot() {
    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing16),
      child: RLButton.secondary(
        label: RLUIStrings.BOOKSHELF_LOAD_MORE_LABEL,
        onTap: handleLoadMoreTap,
      ),
    );
  }

  Widget BookshelfHeaderWithSettings() {
    void onSettingsTap() {
      HapticFeedback.lightImpact();
      SettingsBottomSheet.show(context);
    }

    return Div.row([
      RLTypewriterText(
        key: ValueKey<int>(titleAnimationVersion),
        text: RLUIStrings.BOOKSHELF_TITLE,
        style: RLTypography.headingLargeStyle,
      ),

      const Spacer(),

      const RLBalancePill(),

      const Spacing.width(RLDS.spacing16),

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
