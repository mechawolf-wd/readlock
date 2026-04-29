// Courses screen — fetches /courses from Firestore and lists every course.
// A search bar on top filters the fetched list by title. When the local filter
// returns nothing, falls back to a prefix search against Firestore.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBalancePill.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLSelectableFilterChips.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/constants/RLCourseGenres.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';

// * Search tuning — debounce keeps us from hitting Firestore on every keystroke.
const Duration SEARCH_DEBOUNCE_DURATION = Duration(milliseconds: 350);

// Initial page size and load-more increment for the default course listing.
const int SEARCH_INITIAL_PAGE_SIZE = 5;
const int SEARCH_LOAD_MORE_PAGE_SIZE = 2;

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  JSONList availableCourses = [];
  JSONList remoteSearchResults = [];
  bool isCoursesLoading = true;
  bool isRemoteSearching = false;
  bool isLoadingMore = false;
  bool hasMoreCourses = true;
  Object? coursesCursor;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Timer? searchDebounce;

  // Active genre filters layered on top of the title search. Empty means
  // "no genre constraint" — every course passes the genre check.
  Set<String> selectedGenres = <String>{};

  // Bumped every time this tab becomes active. Used as the typewriter
  // heading's ValueKey so a fresh activation remounts the widget and
  // re-runs its character-by-character reveal.
  int titleAnimationVersion = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialCoursesPage();
    activeTabIndexNotifier.addListener(handleTabActivated);
  }

  @override
  void dispose() {
    activeTabIndexNotifier.removeListener(handleTabActivated);
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void handleTabActivated() {
    final bool isMyTabActive = activeTabIndexNotifier.value == TAB_INDEX_SEARCH;

    if (!isMyTabActive) {
      return;
    }

    setState(() {
      titleAnimationVersion++;
    });
  }

  Future<void> fetchInitialCoursesPage() async {
    try {
      final CoursesPage page = await CourseDataService.fetchCoursesPage(
        pageSize: SEARCH_INITIAL_PAGE_SIZE,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        availableCourses = page.courses;
        coursesCursor = page.cursor;
        hasMoreCourses = page.hasMore;
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

  Future<void> handleLoadMoreTap() async {
    final bool isAlreadyLoading = isLoadingMore;
    final bool hasNoCursor = coursesCursor == null;

    if (isAlreadyLoading || hasNoCursor || !hasMoreCourses) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final CoursesPage page = await CourseDataService.fetchCoursesPage(
        pageSize: SEARCH_LOAD_MORE_PAGE_SIZE,
        cursor: coursesCursor,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        availableCourses = JSONList.from([...availableCourses, ...page.courses]);
        coursesCursor = page.cursor;
        hasMoreCourses = page.hasMore;
        isLoadingMore = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // Local title + genre filter over the already-fetched list.
  JSONList getLocallyFilteredCourses() {
    final String query = searchQuery.trim().toLowerCase();
    final bool hasNoQuery = query.isEmpty;
    final bool hasNoGenres = selectedGenres.isEmpty;
    final bool hasNoFilters = hasNoQuery && hasNoGenres;

    if (hasNoFilters) {
      return availableCourses;
    }

    return availableCourses.where((course) {
      final String courseTitle = (course['title'] as String? ?? '').toLowerCase();
      final bool titleMatches = hasNoQuery || courseTitle.contains(query);
      final bool genreMatches = hasNoGenres || courseMatchesAnySelectedGenre(course);

      return titleMatches && genreMatches;
    }).toList();
  }

  // Returns the canonical closed list of genres (RLCourseGenres). The
  // chip row paints every possible filter even before any course tagged
  // with that genre has loaded, so the reader sees the full vocabulary
  // up-front instead of a partial set that fills in as more courses
  // arrive. The list is mirrored in rlockie's content rules — courses
  // can only tag with these entries.
  List<String> getAvailableGenres() {
    return COURSE_GENRES;
  }

  bool courseMatchesAnySelectedGenre(JSONMap course) {
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

      final bool isMatch = selectedGenres.contains(entry.trim());

      if (isMatch) {
        return true;
      }
    }

    return false;
  }

  void handleGenreToggled(String genre) {
    setState(() {
      final bool isAlreadySelected = selectedGenres.contains(genre);

      if (isAlreadySelected) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
  }

  void handleSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      remoteSearchResults = [];
      isRemoteSearching = false;
    });

    searchDebounce?.cancel();
    searchDebounce = Timer(SEARCH_DEBOUNCE_DURATION, triggerRemoteSearchIfNeeded);
  }

  // Only hit Firestore when the local list misses. Keeps the common case free.
  // Also skipped while a genre filter is active — the remote prefix search
  // doesn't honour genre constraints, so falling back to it would surface
  // results the user explicitly filtered out.
  Future<void> triggerRemoteSearchIfNeeded() async {
    final String query = searchQuery.trim();
    final bool hasNoQuery = query.isEmpty;
    final bool hasGenreFilter = selectedGenres.isNotEmpty;

    if (hasNoQuery || hasGenreFilter) {
      return;
    }

    final JSONList locallyFiltered = getLocallyFilteredCourses();
    final bool hasLocalMatch = locallyFiltered.isNotEmpty;

    if (hasLocalMatch) {
      return;
    }

    setState(() {
      isRemoteSearching = true;
    });

    try {
      final JSONList results = await CourseDataService.searchCoursesByTitle(query);
      final bool queryChanged = query != searchQuery.trim();

      if (!mounted || queryChanged) {
        return;
      }

      setState(() {
        remoteSearchResults = results;
        isRemoteSearching = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      setState(() {
        isRemoteSearching = false;
      });
    }
  }

  void navigateToCourse(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseRoadmapScreen(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.transparent,
      body: SafeArea(
        bottom: false,
        child: CoursesBody(),
      ),
    );
  }

  Widget CoursesBody() {
    return RLFadeSwitcher(child: CoursesBodyCurrent());
  }

  Widget CoursesBodyCurrent() {
    if (isCoursesLoading) {
      return const RLLoadingIndicator.bird(key: ValueKey('courses-loading'));
    }

    // SafeArea(bottom: false) on the screen lets the starfield paint under
    // the nav, but the bottom-pinned search bar would sit under it too.
    // MainNavigation's Scaffold uses extendBody: true, so MediaQuery's
    // bottom padding here = device safe area + nav-bar height — adding it
    // as the parent's bottom inset puts the search bar exactly above the
    // nav with no overlap.
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      RLDS.spacing24,
      RLDS.spacing24,
      RLDS.spacing24,
      RLDS.spacing16 + bottomInset,
    );

    return Padding(
      key: const ValueKey('courses-content'),
      padding: contentPadding,
      child: Div.column([
        SearchHeaderRow(),

        const Spacing.height(RLDS.spacing24),

        // Results take the bulk of the screen; the genre chips + search
        // input live in a single frosted panel pinned at the bottom so the
        // controls float over the main navigation in thumb reach.
        Expanded(child: ResultsArea()),

        const Spacing.height(RLDS.spacing16),

        FloatingFilterPanel(),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Page header — title on the left, live feather wallet on the right so
  // the reader can see their balance without leaving Search and tap straight
  // into the Feathers sheet to top up.
  Widget SearchHeaderRow() {
    return Div.row([
      RLTypewriterText(
        key: ValueKey<int>(titleAnimationVersion),
        text: RLUIStrings.SEARCH_TAB_LABEL,
        style: RLTypography.headingLargeStyle,
      ),

      const Spacer(),

      const RLBalancePill(),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Single frosted box hosting the genre chip row + the search input. The
  // shared LunarBlur surface ties the two controls together visually so they
  // read as one floating filter affordance hovering above the bottom nav.
  Widget FloatingFilterPanel() {
    final List<String> availableGenres = getAvailableGenres();
    final bool hasGenres = availableGenres.isNotEmpty;

    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusMedium,
      padding: const EdgeInsets.all(RLDS.spacing12),
      child: Div.column(
        [
          RenderIf.condition(hasGenres, GenreChipsRow(availableGenres)),

          RenderIf.condition(hasGenres, const Spacing.height(RLDS.spacing12)),

          SearchBar(),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  // Single horizontally-scrollable row for the closed genre list. Reads as
  // one long ribbon the user pans through, instead of stacking onto a
  // second line.
  Widget GenreChipsRow(List<String> availableGenres) {
    return ChipScrollRow(rowGenres: availableGenres);
  }

  Widget ChipScrollRow({required List<String> rowGenres}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: ChipRowChildren(rowGenres: rowGenres)),
    );
  }

  List<Widget> ChipRowChildren({required List<String> rowGenres}) {
    final List<Widget> children = [];

    for (int chipIndex = 0; chipIndex < rowGenres.length; chipIndex++) {
      final bool isFirstChip = chipIndex == 0;

      if (!isFirstChip) {
        children.add(const Spacing.width(RLDS.spacing8));
      }

      final String genre = rowGenres[chipIndex];
      final bool isSelected = selectedGenres.contains(genre);

      children.add(
        SelectableFilterChip(
          label: genre,
          isSelected: isSelected,
          onTap: () => handleGenreToggled(genre),
        ),
      );
    }

    return children;
  }

  Widget SearchBar() {
    return RLTextField(
      controller: searchController,
      hintText: RLUIStrings.SEARCH_PLACEHOLDER,
      leadingIcon: Pixel.search,
      onChanged: handleSearchChanged,
    );
  }

  Widget ResultsArea() {
    final bool hasNoQuery = searchQuery.trim().isEmpty;
    final bool hasNoGenres = selectedGenres.isEmpty;
    final bool isUnfilteredListing = hasNoQuery && hasNoGenres;

    if (isUnfilteredListing) {
      return CoursesScrollList(availableCourses, showLoadMore: true);
    }

    final JSONList locallyFiltered = getLocallyFilteredCourses();
    final bool hasLocalMatches = locallyFiltered.isNotEmpty;

    if (hasLocalMatches) {
      return CoursesScrollList(locallyFiltered, showLoadMore: false);
    }

    if (isRemoteSearching) {
      return const RLLoadingIndicator.text();
    }

    final bool hasRemoteMatches = remoteSearchResults.isNotEmpty;

    if (hasRemoteMatches) {
      return CoursesScrollList(remoteSearchResults, showLoadMore: false);
    }

    return EmptyStateMessage();
  }

  Widget CoursesScrollList(JSONList courses, {required bool showLoadMore}) {
    final List<Widget> listChildren = List<Widget>.from(CourseCards(courses));

    if (showLoadMore) {
      listChildren.add(LoadMoreSlot());
    }

    return SingleChildScrollView(
      child: Div.column(listChildren, crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  Widget LoadMoreSlot() {
    final bool hasNoMoreCourses = !hasMoreCourses;

    if (hasNoMoreCourses) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing16),
      child: LoadMoreControl(),
    );
  }

  Widget LoadMoreControl() {
    if (isLoadingMore) {
      return const Center(child: RLLoadingIndicator.text());
    }

    return RLButton.secondary(
      label: RLUIStrings.BOOKSHELF_LOAD_MORE_LABEL,
      onTap: handleLoadMoreTap,
    );
  }

  List<Widget> CourseCards(JSONList courses) {
    return courses.map((course) {
      final String courseTitle = course['title'] as String? ?? '';
      final String courseAuthor = course['author'] as String? ?? '';
      final String? coverImagePath = course['cover-image-path'] as String?;
      final String? courseColor = course['color'] as String?;
      final String courseId = course['course-id'] as String? ?? '';

      return BookListCard(
        title: courseTitle,
        author: courseAuthor,
        courseColor: courseColor,
        coverImagePath: coverImagePath,
        onTap: () => navigateToCourse(courseId),
      );
    }).toList();
  }

  Widget EmptyStateMessage() {
    return Center(
      child: RLTypography.headingMedium(
        RLUIStrings.NO_COURSES_MESSAGE,
        color: RLDS.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }
}
