// Courses screen — fetches /courses from Firestore and lists every course.
// A search bar on top filters the fetched list by title. When the local filter
// returns nothing, falls back to a prefix search against Firestore.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';

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

  @override
  void initState() {
    super.initState();
    fetchInitialCoursesPage();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
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

  // Local title filter over the already-fetched list.
  JSONList getLocallyFilteredCourses() {
    final String query = searchQuery.trim().toLowerCase();
    final bool hasNoQuery = query.isEmpty;

    if (hasNoQuery) {
      return availableCourses;
    }

    return availableCourses.where((course) {
      final String courseTitle = (course['title'] as String? ?? '').toLowerCase();
      return courseTitle.contains(query);
    }).toList();
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
  Future<void> triggerRemoteSearchIfNeeded() async {
    final String query = searchQuery.trim();
    final bool hasNoQuery = query.isEmpty;

    if (hasNoQuery) {
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
        RLTypography.headingLarge(RLUIStrings.SEARCH_TAB_LABEL),

        const Spacing.height(RLDS.spacing24),

        // Results take the bulk of the screen; search bar pinned at the
        // bottom under the list so the input sits in thumb reach and the
        // books read top-down without a header bar between them.
        Expanded(child: ResultsArea()),

        const Spacing.height(RLDS.spacing16),

        SearchBar(),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
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
    final bool isDefaultListing = searchQuery.trim().isEmpty;

    if (isDefaultListing) {
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
