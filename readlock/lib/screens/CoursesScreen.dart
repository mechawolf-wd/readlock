// Courses screen — fetches /courses from Firestore and lists every course.
// A search bar on top filters the fetched list by title. When the local filter
// returns nothing, falls back to a prefix search against Firestore.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/course/CoursePurchaseBottomSheet.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBalancePill.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLCourseFilterPanel.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/constants/RLCourseGenres.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/services/ConnectivityService.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';

import 'package:pixelarticons/pixel.dart';

// * Search tuning — debounce keeps us from hitting Firestore on every keystroke.
const Duration SEARCH_DEBOUNCE_DURATION = Duration(milliseconds: 350);

// Initial page size and load-more increment for the default course listing.
const int SEARCH_INITIAL_PAGE_SIZE = 5;
const int SEARCH_LOAD_MORE_PAGE_SIZE = 2;

// Bottom inset for the results scroll view so the last entry can scroll
// past the floating filter panel before bottoming out. Just enough that
// the last card clears the panel's frosted edge without leaving a tall
// dead zone underneath the Load more button.
const double STORE_LIST_FILTER_OVERLAY_INSET = 148.0;

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

  // Soft green halo behind the Load more button so it reads as the
  // bottom-of-list CTA. Tinted with success green to telegraph "fetch
  // more" rather than the surprise-me blue.
  static final BoxDecoration loadMoreGlowDecoration = RLDS.glowDecoration(
    color: RLDS.glass05(RLDS.white),
  );

  @override
  void initState() {
    super.initState();
    fetchInitialCoursesPage();
    activeTabIndexNotifier.addListener(handleTabActivated);

    // When the device drops offline a fetch in flight will fail and the
    // listing stays empty. Re-run the initial page fetch the moment we
    // come back online so the store recovers without a manual reload.
    ConnectivityService.isOnlineNotifier.addListener(handleConnectivityChange);
  }

  @override
  void dispose() {
    activeTabIndexNotifier.removeListener(handleTabActivated);
    ConnectivityService.isOnlineNotifier.removeListener(handleConnectivityChange);
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void handleConnectivityChange() {
    final bool isBackOnline = ConnectivityService.isOnlineNotifier.value;
    final bool needsRefetch = isBackOnline && availableCourses.isEmpty;

    if (needsRefetch) {
      fetchInitialCoursesPage();
    }
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

    if (isAlreadyLoading) {
      return;
    }

    final bool hasNothingMoreToLoad = coursesCursor == null || !hasMoreCourses;

    if (hasNothingMoreToLoad) {
      RLToast.info(context, RLUIStrings.LOAD_MORE_NOTHING_LEFT);
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
      final String courseAuthor = (course['author'] as String? ?? '').toLowerCase();
      final bool textMatches =
          hasNoQuery || courseTitle.contains(query) || courseAuthor.contains(query);
      final bool genreMatches = hasNoGenres || courseMatchesAnySelectedGenre(course);

      return textMatches && genreMatches;
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

  // Wipes the search query and every selected genre chip in one tap, also
  // tearing down the in-flight remote search so a stale result can't land
  // after the reset. Mirrors the close-clears-filters affordance the
  // bookshelf uses, except here the panel itself is always mounted, so
  // the reset is exposed as its own floating button above the panel.
  void handleClearFiltersTap() {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();
    searchDebounce?.cancel();
    searchController.clear();

    setState(() {
      searchQuery = '';
      selectedGenres.clear();
      remoteSearchResults = [];
      isRemoteSearching = false;
    });
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
    SoundService.playRandomTextClick();
    Navigator.push(context, RLDS.fadeTransition(CourseRoadmapScreen(courseId: courseId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.transparent,
      body: SafeArea(bottom: false, child: CoursesBody()),
    );
  }

  Widget CoursesBody() {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService.isOnlineNotifier,
      builder: (BuildContext context, bool isOnline, Widget? _) {
        return RLFadeSwitcher(child: CoursesBodyCurrent(isOnline: isOnline));
      },
    );
  }

  Widget CoursesBodyCurrent({required bool isOnline}) {
    // The store is the only screen that depends entirely on a live network
    // fetch (Firestore page reads, remote search). Show a dedicated offline
    // state instead of a stuck loader so the reader knows why the list is
    // empty and that reconnecting will bring it back.
    if (!isOnline) {
      return const OfflineMessage(key: ValueKey('courses-offline'));
    }

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

        // Results take the bulk of the screen; the filter panel floats on
        // top via a Stack so the list scrolls underneath it (the panel's
        // LunarBlur surface frosts whatever passes behind). The list adds
        // its own bottom inset so the last entry can clear the panel.
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: ResultsArea()),

              Positioned(left: 0, right: 0, bottom: 0, child: FilterPanelWithReset()),
            ],
          ),
        ),
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

  // Floating filter pane hovering above the bottom nav. Wraps the shared
  // RLCourseFilterPanel so the bookshelf can mount the same UI when its
  // own filter affordance is toggled.
  Widget FloatingFilterPanel() {
    return RLCourseFilterPanel(
      availableGenres: getAvailableGenres(),
      selectedGenres: selectedGenres,
      onGenreToggled: handleGenreToggled,
      searchController: searchController,
      onSearchChanged: handleSearchChanged,
      searchPlaceholder: RLUIStrings.SEARCH_PLACEHOLDER,
    );
  }

  // The filter panel plus an optional reset chip floating just above its
  // top-right corner. The chip only mounts when at least one filter is
  // active, so the panel reads clean by default and the X only appears
  // when there is something to clear.
  Widget FilterPanelWithReset() {
    final bool hasActiveFilters = selectedGenres.isNotEmpty || searchQuery.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RenderIf.condition(hasActiveFilters, ClearFiltersChip()),

        RenderIf.condition(hasActiveFilters, const Spacing.height(RLDS.spacing8)),

        FloatingFilterPanel(),
      ],
    );
  }

  // Frosted X chip that wipes the active filters. Sized to a comfortable
  // tap target; uses the same LunarBlur surface as the panel below so the
  // two read as part of one stack.
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

  // Diameter of the floating reset chip — matches a 4-pixel-rule tap
  // target while staying small enough to read as an affordance, not a
  // button.
  static const double clearFiltersChipDiameter = 40.0;

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

  // Wrapped in a ValueListenableBuilder so a purchase made via the
  // CoursePurchaseBottomSheet flips purchasedCoursesNotifier and the cart
  // icon disappears from that course's row in the same frame.
  Widget CoursesScrollList(JSONList courses, {required bool showLoadMore}) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: purchasedCoursesNotifier,
      builder: (BuildContext context, Set<String> purchasedCourses, Widget? _) {
        final List<Widget> listChildren = List<Widget>.from(
          CourseCards(courses, purchasedCourses),
        );

        if (showLoadMore) {
          listChildren.add(LoadMoreSlot());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: STORE_LIST_FILTER_OVERLAY_INSET),
          child: Div.column(listChildren, crossAxisAlignment: CrossAxisAlignment.stretch),
        );
      },
    );
  }

  Widget LoadMoreSlot() {
    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing16),
      child: LoadMoreControl(),
    );
  }

  Widget LoadMoreControl() {
    if (isLoadingMore) {
      return const Center(child: RLLoadingIndicator.text());
    }

    return Container(
      decoration: loadMoreGlowDecoration,
      child: RLButton.secondary(
        color: RLDS.white,
        label: RLUIStrings.BOOKSHELF_LOAD_MORE_LABEL,
        onTap: handleLoadMoreTap,
      ),
    );
  }

  // Renders one BookListCard per course. Cart icon is wired only when the
  // course is NOT already in the user's purchasedCourses set, so owned
  // courses read as "in your collection" without a redundant buy
  // affordance. Tapping the cart opens the purchase sheet without
  // triggering the row's navigate-to-roadmap onTap.
  List<Widget> CourseCards(JSONList courses, Set<String> purchasedCourses) {
    return courses.map((course) {
      final String courseTitle = course['title'] as String? ?? '';
      final String courseAuthor = course['author'] as String? ?? '';
      final String? coverImagePath = course['cover-image-path'] as String?;
      final String? courseColor = course['color'] as String?;
      final String courseId = course['course-id'] as String? ?? '';

      final bool isOwned = purchasedCourses.contains(courseId);

      void openPurchaseSheet() {
        SoundService.playRandomTextClick();
        CoursePurchaseBottomSheet.show(context, course: course);
      }

      final VoidCallback? buyHandler = isOwned ? null : openPurchaseSheet;

      return BookListCard(
        title: courseTitle,
        author: courseAuthor,
        courseColor: courseColor,
        coverImagePath: coverImagePath,
        onTap: () => navigateToCourse(courseId),
        onBuyTap: buyHandler,
      );
    }).toList();
  }

  // Same bird + chirp caption the bookshelf shows when its own filter
  // narrows to nothing. Anchored to the top of the results area so it
  // mirrors the bookshelf's FilterEmptyBird placement and the two empty
  // surfaces feel like one family.
  Widget EmptyStateMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing40),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CoursesBird(),

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

  // Reflects whichever bird the reader has picked, same source the
  // bookshelf empty state reads from so a profile change updates both
  // surfaces in lockstep.
  Widget CoursesBird() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: (BuildContext context, BirdOption bird, Widget? _) {
        return BirdAnimationSprite(bird: bird);
      },
    );
  }
}

// Stand-in for the entire Search/Store body when the device is offline.
// Heading + chirp message in the same shape the bookshelf empty state uses
// so the two empty surfaces feel like part of one family.
class OfflineMessage extends StatelessWidget {
  const OfflineMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RLTypography.headingMedium(
              RLUIStrings.STORE_OFFLINE_TITLE,
              color: RLDS.textPrimary,
              textAlign: TextAlign.center,
            ),

            const Spacing.height(RLDS.sheetHeadingToSubheadingSpacing),

            RLTypography.bodyMedium(
              RLUIStrings.STORE_OFFLINE_MESSAGE,
              color: RLDS.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
