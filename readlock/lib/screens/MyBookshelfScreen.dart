// My Bookshelf screen — shows the courses the user has saved.
// Source of truth is /users/{id}.savedCourseIds; the matching course documents
// are fetched from /courses and rendered with BookListCard.

import 'package:flutter/material.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
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
class MyBookshelfScreen extends StatefulWidget {
  const MyBookshelfScreen({super.key});

  @override
  State<MyBookshelfScreen> createState() => MyBookshelfScreenState();
}

class MyBookshelfScreenState extends State<MyBookshelfScreen> {
  static final Widget SettingsIcon = const Icon(
    Pixel.sliders,
    color: RLDS.textSecondary,
    size: 24,
  );

  JSONList savedCourses = [];
  bool isBookshelfLoading = true;

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
        child: BookshelfBody(),
      ),
    );
  }

  Widget BookshelfBody() {
    return Padding(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Div.column([
        Align(alignment: Alignment.centerRight, child: BookshelfBird()),

        const Spacing.height(RLDS.spacing16),

        BookshelfHeaderWithSettings(),

        const Spacing.height(RLDS.spacing40),

        Expanded(child: BookshelfContent()),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  Widget BookshelfContent() {
    if (isBookshelfLoading) {
      return const RLLoadingIndicator.bird();
    }

    final bool hasNoSavedCourses = savedCourses.isEmpty;

    if (hasNoSavedCourses) {
      return EmptyBookshelfMessage();
    }

    return SavedCoursesList();
  }

  Widget SavedCoursesList() {
    return SingleChildScrollView(
      child: Div.column(
        SavedCourseCards(),
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  List<Widget> SavedCourseCards() {
    return savedCourses.map((course) {
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

  Widget BookshelfHeaderWithSettings() {
    return Div.row([
      RLTypography.headingLarge(RLUIStrings.BOOKSHELF_TITLE),

      const Spacer(),

      GestureDetector(
        onTap: () => SettingsBottomSheet.show(context),
        child: SettingsIcon,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  Widget BookshelfBird() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: BookshelfBirdBuilder,
    );
  }

  Widget BookshelfBirdBuilder(BuildContext context, BirdOption bird, Widget? _) {
    return BirdAnimationSprite(
      bird: bird,
      previewSize: BIRD_CONTENT_SIZE,
    );
  }

  Widget EmptyBookshelfMessage() {
    return Center(
      child: RLTypography.bodyMedium(
        RLUIStrings.BOOKSHELF_EMPTY_MESSAGE,
        color: RLDS.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }
}
