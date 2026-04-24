// My Bookshelf screen — shows the courses the reader has recently started.
// A course is appended to /users/{id}.savedCourseIds the moment the reader
// taps a lesson in the roadmap (see CourseRoadmapScreen.showLoadingScreenThenNavigate).
// The list paginates in pages of BOOKSHELF_PAGE_SIZE via a Load more button
// so the shelf doesn't eagerly render every saved course.

import 'package:flutter/material.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/bottom_sheets/user/SettingsBottomSheet.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/models/UserModel.dart';

import 'package:pixelarticons/pixel.dart';

// How many bookshelf cards are rendered before the Load more button is shown.
// Tapping Load more reveals another BOOKSHELF_PAGE_SIZE courses.
const int BOOKSHELF_PAGE_SIZE = 5;

class MyBookshelfScreen extends StatefulWidget {
  const MyBookshelfScreen({super.key});

  @override
  State<MyBookshelfScreen> createState() => MyBookshelfScreenState();
}

class MyBookshelfScreenState extends State<MyBookshelfScreen> {
  static final Widget SettingsIcon = const Icon(
    Pixel.sliders,
    color: RLDS.textSecondary,
    size: RLDS.iconLarge,
  );

  JSONList savedCourses = [];
  bool isBookshelfLoading = true;
  int visibleCoursesCount = BOOKSHELF_PAGE_SIZE;

  @override
  void initState() {
    super.initState();
    fetchSavedCourses();
  }

  Future<void> fetchSavedCourses() async {
    try {
      final UserModel? user = await UserService.getCurrentUserProfile();
      final List<String> savedIds = user?.savedCourseIds ?? const <String>[];
      final JSONList courses = await CourseDataService.fetchCoursesByIds(savedIds);

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
    }
  }

  void handleLoadMoreTap() {
    setState(() {
      visibleCoursesCount += BOOKSHELF_PAGE_SIZE;
    });
  }

  void navigateToCourse(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseRoadmapScreen(courseId: courseId)),
    );
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
    final List<Widget> listChildren = List<Widget>.from(SavedCourseCards());

    listChildren.add(LoadMoreSlot());

    return SingleChildScrollView(
      child: Div.column(listChildren, crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  List<Widget> SavedCourseCards() {
    final int totalCourses = savedCourses.length;
    final int cardsToRender = visibleCoursesCount.clamp(0, totalCourses);
    final JSONList visibleCourses = JSONList.from(savedCourses.take(cardsToRender));

    return visibleCourses.map<Widget>(CourseCard).toList();
  }

  Widget CourseCard(JSONMap course) {
    final String courseTitle = course['title'] as String? ?? '';
    final String courseAuthor = course['author'] as String? ?? '';
    final String? coverImagePath = course['cover-image-path'] as String?;
    final String? courseColor = course['color'] as String?;
    final String courseId = course['course-id'] as String? ?? '';

    void onCardTap() => navigateToCourse(courseId);

    return BookListCard(
      title: courseTitle,
      author: courseAuthor,
      courseColor: courseColor,
      coverImagePath: coverImagePath,
      onTap: onCardTap,
    );
  }

  // Rendered only when more saved courses exist than are currently visible.
  // Tapping it expands the visible window by BOOKSHELF_PAGE_SIZE.
  Widget LoadMoreSlot() {
    final bool hasMoreCoursesToShow = visibleCoursesCount < savedCourses.length;

    return RenderIf.condition(hasMoreCoursesToShow, LoadMoreButton());
  }

  Widget LoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing16),
      child: RLButton.secondary(
        label: RLUIStrings.BOOKSHELF_LOAD_MORE_LABEL,
        onTap: handleLoadMoreTap,
      ),
    );
  }

  Widget BookshelfHeaderWithSettings() {
    void onSettingsTap() => SettingsBottomSheet.show(context);

    return Div.row([
      RLTypography.headingLarge(RLUIStrings.BOOKSHELF_TITLE),

      const Spacer(),

      GestureDetector(onTap: onSettingsTap, child: SettingsIcon),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Empty-state bird — same selectedBirdNotifier source as Settings/Pause so
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
