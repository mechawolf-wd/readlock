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
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';

// * Search tuning — debounce keeps us from hitting Firestore on every keystroke.
const Duration SEARCH_DEBOUNCE_DURATION = Duration(milliseconds: 350);

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

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Timer? searchDebounce;

  @override
  void initState() {
    super.initState();
    fetchAvailableCourses();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAvailableCourses() async {
    try {
      final JSONList courses = await CourseDataService.fetchAvailableCourses();

      if (!mounted) {
        return;
      }

      setState(() {
        availableCourses = courses;
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
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CoursesBody(),
      ),
    );
  }

  Widget CoursesBody() {
    if (isCoursesLoading) {
      return const RLLoadingIndicator.bird();
    }

    return Padding(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Div.column([
        RLTypography.headingLarge(RLUIStrings.SEARCH_TAB_LABEL),

        const Spacing.height(RLDS.spacing40),

        SearchBar(),

        const Spacing.height(RLDS.spacing16),

        Expanded(child: ResultsArea()),
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
    final JSONList locallyFiltered = getLocallyFilteredCourses();
    final bool hasLocalMatches = locallyFiltered.isNotEmpty;

    if (hasLocalMatches) {
      return CoursesScrollList(locallyFiltered);
    }

    if (isRemoteSearching) {
      return const RLLoadingIndicator.text();
    }

    final bool hasRemoteMatches = remoteSearchResults.isNotEmpty;

    if (hasRemoteMatches) {
      return CoursesScrollList(remoteSearchResults);
    }

    return EmptyStateMessage();
  }

  Widget CoursesScrollList(JSONList courses) {
    return SingleChildScrollView(
      child: Div.column(
        CourseCards(courses),
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  List<Widget> CourseCards(JSONList courses) {
    return courses.map((course) {
      final String courseTitle = course['title'] as String? ?? '';
      final String courseAuthor = course['author'] as String? ?? '';
      final String? coverImagePath = course['cover-image-path'] as String?;
      final String courseId = course['course-id'] as String? ?? '';

      return BookListCard(
        title: courseTitle,
        author: courseAuthor,
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
