// Home screen — a single "Surprise me" entry point that opens a random course.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/course_screens/data/CourseData.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

import 'package:pixelarticons/pixel.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  JSONList availableCourses = [];
  bool isCoursesLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableCourses();
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

    HapticFeedback.lightImpact();

    final int randomIndex = Random().nextInt(availableCourses.length);
    final JSONMap randomCourse = availableCourses[randomIndex];
    final String randomCourseId = randomCourse['course-id'] as String;

    navigateToCourse(randomCourseId);
  }

  static final Widget ChevronRightIcon = const Icon(
    Pixel.chevronright,
    color: RLDS.textSecondary,
    size: 24.0,
  );

  static final Widget ShuffleIcon = const Icon(
    Pixel.shuffle,
    color: RLDS.info,
    size: 24.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: HomeBody(),
      ),
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
      child: Div.column(
        [
          RLTypography.headingLarge(RLUIStrings.HOME_TAB_LABEL),

          const Spacing.height(RLDS.spacing40),

          Expanded(child: HomeContent()),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
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

    return Div.column(
      [
        RandomLessonSection(),
      ],
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }

  Widget RandomLessonSection() {
    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing16),
      onTap: handleRandomBookTap,
      child: Div.row([
        ShuffleIcon,

        const Spacing.width(12.0),

        Expanded(child: RLTypography.bodyLarge(RLUIStrings.SURPRISE_ME_LABEL)),

        ChevronRightIcon,
      ], crossAxisAlignment: CrossAxisAlignment.center),
    );
  }
}
