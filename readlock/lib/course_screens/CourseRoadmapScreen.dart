// Course roadmap screen displaying a simple list of course lessons
// Clean card-based layout showing course information
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/data/courseData.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/CourseLoadingScreen.dart';

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? courseData;
  List<Map<String, dynamic>> courseSegments = [];
  bool isLoading = true;

  TabController? tabController;
  late PageController pageController;
  int currentSegmentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    loadCourseData();
  }

  @override
  void dispose() {
    tabController?.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadCourseData() async {
    try {
      courseData = await CourseDataService.getCourseById(
        widget.courseId,
      );

      if (courseData != null) {
        courseSegments = List<Map<String, dynamic>>.from(
          courseData!['segments'] ?? [],
        );

        // Create tab controller with correct segment count
        if (mounted && courseSegments.isNotEmpty) {
          tabController = TabController(
            length: courseSegments.length,
            vsync: this,
            initialIndex: currentSegmentIndex,
          );
        }
      }
    } on Exception {
      // Handle error silently
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Material(
      color: RLTheme.backgroundDark,
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Div.column([
              // Header section with back button and course info
              RoadmapHeader(),

              const Spacing.height(16),

              // Segment page indicators
              SegmentPageIndicators(),

              const Spacing.height(24),

              // Horizontal page view for segments
              Expanded(child: SegmentPageView()),

              // Bottom spacing for floating button
              const Spacing.height(80),
            ]),

            // Floating continue button
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: ContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget RoadmapHeader() {
    final String courseTitle = courseData?['title'] ?? 'Course Roadmap';

    final Widget BackArrowIcon = const Icon(
      Icons.arrow_back,
      color: RLTheme.textPrimary,
      size: 24,
    );

    final Widget BookCover = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'covers/doet-cover.png',
        width: 100,
        height: 140,
        fit: BoxFit.cover,
      ),
    );

    return Div.column(
      [
        // Header navigation row
        Div.row([
          // Back button
          Div.row(
            [BackArrowIcon],
            padding: 8,
            radius: Style.backButtonRadius,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),

          const Spacer(),
        ]),

        const Spacing.height(16),

        // Course information section - horizontal layout
        Div.row([
          // Book cover on left
          BookCover,

          const Spacing.width(16),

          // Title and info on right
          Expanded(
            child: Div.column([
              // Course title
              RLTypography.headingLarge(courseTitle),

              const Spacing.height(4),

              // Course subtitle
              RLTypography.bodyMedium(
                'Master design psychology fundamentals',
                color: RLTheme.textSecondary,
              ),

              const Spacing.height(12),

              // Course statistics row
              Div.row([
                Style.ExperienceIcon,

                const Spacing.width(4),

                RLTypography.bodyMedium('37 lessons'),

                const Spacing.width(16),

                Style.QuestionIcon,

                const Spacing.width(4),

                RLTypography.bodyMedium('29 retentors'),
              ]),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: const [20, 16],
    );
  }

  // Floating continue button
  Widget ContinueButton() {
    return RLDesignSystem.BlockButton(
      children: [
        RLTypography.bodyLarge('Continue', color: RLTheme.white),
      ],
      backgroundColor: RLTheme.primaryGreen,
      margin: EdgeInsets.zero,
      onTap: handleContinueTap,
    );
  }

  // Handle continue button tap - navigate to current lesson
  void handleContinueTap() {
    // Current lesson is index 3 in segment 0 (mocked)
    const int currentLessonIndex = 3;
    const int currentContentIndex = 0;

    showLoadingScreenThenNavigate(currentLessonIndex, currentContentIndex);
  }

  // Page indicators showing segment position
  Widget SegmentPageIndicators() {
    final bool hasMultipleSegments = courseSegments.length > 1;
    final bool hasTabController = tabController != null;
    final bool shouldShowIndicators =
        hasMultipleSegments && hasTabController;

    return RenderIf.condition(
      shouldShowIndicators,
      Div.row(
        getSegmentIndicators(),
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  List<Widget> getSegmentIndicators() {
    const double activeIndicatorWidth = 24.0;
    const double inactiveIndicatorWidth = 16.0;
    const double indicatorHeight = 8.0;
    const double indicatorBorderRadius = 4.0;

    final Color activeIndicatorColor = RLTheme.primaryGreen;
    final Color inactiveIndicatorColor = Colors.grey.withValues(
      alpha: 0.3,
    );

    final List<Widget> indicators = [];

    for (
      int segmentIndex = 0;
      segmentIndex < courseSegments.length;
      segmentIndex++
    ) {
      final bool isActive = segmentIndex == currentSegmentIndex;
      final bool isNotFirstIndicator = segmentIndex > 0;

      if (isNotFirstIndicator) {
        indicators.add(const Spacing.width(6));
      }

      final Color indicatorColor = isActive
          ? activeIndicatorColor
          : inactiveIndicatorColor;
      final double indicatorWidth = isActive
          ? activeIndicatorWidth
          : inactiveIndicatorWidth;

      final BoxDecoration indicatorDecoration = BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(indicatorBorderRadius),
      );

      indicators.add(
        Container(
          width: indicatorWidth,
          height: indicatorHeight,
          decoration: indicatorDecoration,
        ),
      );
    }

    return indicators;
  }

  // Horizontal page view for segments
  Widget SegmentPageView() {
    return PageView.builder(
      controller: pageController,
      itemCount: courseSegments.length,
      onPageChanged: handleSegmentPageChanged,
      itemBuilder: getSegmentPage,
    );
  }

  // Handle segment page change events
  void handleSegmentPageChanged(int segmentIndex) {
    if (mounted) {
      setState(() {
        currentSegmentIndex = segmentIndex;

        final bool hasTabController = tabController != null;

        if (hasTabController) {
          tabController!.index = segmentIndex;
        }
      });
    }
  }

  // Get single segment page with its lessons
  Widget getSegmentPage(BuildContext context, int segmentIndex) {
    final Map<String, dynamic> segment = courseSegments[segmentIndex];

    return SegmentPage(
      segment: segment,
      segmentIndex: segmentIndex,
      onLessonTap: showLoadingScreenThenNavigate,
    );
  }

  Color getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return RLTheme.primaryGreen;
      case 'purple':
        return RLTheme.accentPurple;
      case 'blue':
        return RLTheme.primaryBlue;
      case 'red':
        return RLTheme.errorColor;
      case 'orange':
        return RLTheme.warningColor;
      default:
        return RLTheme.primaryGreen;
    }
  }

  void showLoadingScreenThenNavigate(
    int lessonIndex,
    int contentIndex,
  ) {
    // Navigate directly to course without showing XP dialog
    navigateToCourseWithLoading(lessonIndex, contentIndex);
  }

  void navigateToCourseWithLoading(int lessonIndex, int contentIndex) {
    // Show loading screen with slow fade transition
    Navigator.push(
      context,
      RLTheme.slowFadeTransition(const CourseLoadingScreen()),
    );

    // Navigate to course detail after delay
    void routeToCourse() {
      if (mounted) {
        final fadeTransition = RLTheme.slowFadeTransition(
          CourseDetailScreen(
            courseId: widget.courseId,
            initialLessonIndex: lessonIndex,
            initialContentIndex: contentIndex,
          ),
        );

        Navigator.pushReplacement(context, fadeTransition);
      }
    }

    Future.delayed(const Duration(milliseconds: 500), routeToCourse);
  }
}

// Single segment page with sticky header and scrollable lessons
class SegmentPage extends StatelessWidget {
  final Map<String, dynamic> segment;
  final int segmentIndex;
  final Function(int, int) onLessonTap;

  const SegmentPage({
    super.key,
    required this.segment,
    required this.segmentIndex,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final String segmentTitle =
        segment['segment-title'] ?? 'Unnamed Segment';
    final String segmentDescription =
        segment['segment-description'] ?? '';
    final List<dynamic> lessons = segment['lessons'] ?? [];

    return Column(
      children: [
        // Sticky segment header
        SegmentHeader(
          title: segmentTitle,
          description: segmentDescription,
        ),

        // Scrollable lessons list
        Expanded(
          child: ListView.builder(
            padding: Style.listViewPadding,
            itemCount: lessons.length,
            itemBuilder: (context, lessonIndex) {
              return getLessonCard(lessons, lessonIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget getLessonCard(List<dynamic> lessons, int lessonIndex) {
    final Map<String, dynamic> lesson = lessons[lessonIndex];
    final String lessonTitle = lesson['title'] ?? 'Unnamed Lesson';
    final String lessonId = lesson['lesson-id'] ?? '';

    // Determine lesson state (mocked for now)
    final bool isCompleted = segmentIndex == 0 && lessonIndex < 3;
    final bool isCurrentLevel = segmentIndex == 0 && lessonIndex == 3;
    final bool isLocked = segmentIndex > 0;
    final bool isFirstLesson = lessonIndex == 0;

    // Mock completion data for demonstration
    final int skillCheckQuestionsCompleted = getMockSkillCheckProgress(
      segmentIndex,
      lessonIndex,
    );

    return Column(
      children: [
        // Arrow connector (except for first lesson)
        RenderIf.condition(
          !isFirstLesson,
          LessonConnectorArrow(),
        ),

        // Lesson card
        LessonCard(
          title: lessonTitle,
          subtitle: lessonId,
          isCompleted: isCompleted,
          isCurrentLevel: isCurrentLevel,
          isLocked: isLocked,
          skillCheckQuestionsCompleted: skillCheckQuestionsCompleted,
          onTap: () => onLessonTap(lessonIndex, 0),
        ),
      ],
    );
  }

  Widget LessonConnectorArrow() {
    final Icon ArrowIcon = Icon(
      Icons.keyboard_arrow_down,
      color: RLTheme.textSecondary.withValues(alpha: 0.4),
      size: 24,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Center(child: ArrowIcon),
    );
  }

  // Mock skill check progress data for demonstration
  int getMockSkillCheckProgress(int segmentIndex, int lessonIndex) {
    if (segmentIndex == 0) {
      switch (lessonIndex) {
        case 0:
          return 3;
        case 1:
          return 2;
        case 2:
          return 2;
        case 3:
          return 2;
        case 4:
          return 1;
        case 5:
          return 0;
        default:
          return 0;
      }
    }
    return 0;
  }
}

class SegmentHeader extends StatelessWidget {
  final String title;
  final String description;

  const SegmentHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final String segmentLetter = getSegmentLetter();
    final String segmentTitle = getSegmentTitle();
    final Color segmentColor = getSegmentColor();

    final BoxDecoration letterDecoration = BoxDecoration(
      color: segmentColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: segmentColor.withValues(alpha: 0.3)),
    );

    final Widget StyledLetter = Div.column(
      [
        RLTypography.headingMedium(
          segmentLetter,
          color: segmentColor,
          textAlign: TextAlign.center,
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: letterDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return Div.column([
      const Spacing.height(8),

      // Letter and title row
      Div.row([
        StyledLetter,

        const Spacing.width(10),

        RLTypography.headingMedium(
          segmentTitle,
          color: RLTheme.textPrimary,
          textAlign: TextAlign.center,
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(12),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  String getSegmentLetter() {
    return title.split(' ').first; // Get first word (the letter)
  }

  String getSegmentTitle() {
    final List<String> parts = title.split(' ');
    return parts
        .skip(1)
        .join(' '); // Get everything after the first word
  }

  Color getSegmentColor() {
    final String letter = getSegmentLetter();
    switch (letter) {
      case 'A':
        return RLTheme.primaryGreen;
      case 'B':
        return RLTheme.primaryBlue;
      case 'C':
        return RLTheme.accentPurple;
      default:
        return RLTheme.primaryGreen;
    }
  }
}

class LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrentLevel;
  final bool isLocked;
  final int skillCheckQuestionsCompleted;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isCurrentLevel = false,
    this.isLocked = false,
    this.skillCheckQuestionsCompleted = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardOpacity = getCardOpacity();
    final Color borderColor = getCardBorderColor();
    final VoidCallback? tapHandler = isLocked ? null : onTap;

    return Opacity(
      opacity: cardOpacity,
      child: GestureDetector(
        onTap: tapHandler,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Status accent bar
                  AccentBar(),

                  // Card content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CardContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getCardOpacity() {
    if (isLocked) {
      return 0.5;
    }
    return 1.0;
  }

  Color getCardBorderColor() {
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.4);
    }
    return RLTheme.textSecondary.withValues(alpha: 0.1);
  }

  Widget AccentBar() {
    final Color accentColor = getAccentColor();

    return Container(
      width: 4,
      color: accentColor,
    );
  }

  Color getAccentColor() {
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.6);
    }
    if (isLocked) {
      return RLTheme.textSecondary.withValues(alpha: 0.2);
    }
    return RLTheme.textSecondary.withValues(alpha: 0.3);
  }

  Widget CardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: number + title + status icon
        Row(
          children: [
            // Lesson book badge
            LessonBadge(),

            const Spacing.width(12),

            // Title
            Expanded(
              child: RLTypography.bodyLarge(title),
            ),

            // Status icon
            StatusIcon(),
          ],
        ),

        const Spacing.height(6),

        // Subtitle
        RLTypography.bodyMedium(
          subtitle,
          color: RLTheme.textSecondary,
        ),

        // Skill dots (only if not locked and has progress)
        RenderIf.condition(
          !isLocked,
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SkillDots(),
          ),
        ),
      ],
    );
  }

  Widget LessonBadge() {
    final Color badgeColor = getBadgeColor();
    final Color badgeBorderColor = getBadgeBorderColor();
    final Color iconColor = getIconColor();

    final BoxDecoration badgeDecoration = BoxDecoration(
      color: badgeColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: badgeBorderColor),
    );

    final Icon BookIcon = Icon(
      Icons.auto_stories,
      color: iconColor,
      size: 18,
    );

    return Container(
      width: 36,
      height: 36,
      decoration: badgeDecoration,
      child: Center(child: BookIcon),
    );
  }

  Color getIconColor() {
    if (isCompleted) {
      return RLTheme.white;
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen;
    }
    return RLTheme.textSecondary;
  }

  Color getBadgeColor() {
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.15);
    }
    return RLTheme.textSecondary.withValues(alpha: 0.1);
  }

  Color getBadgeBorderColor() {
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.4);
    }
    return RLTheme.textSecondary.withValues(alpha: 0.2);
  }

  Widget StatusIcon() {
    if (!isLocked) {
      return const SizedBox.shrink();
    }

    final Icon LockIcon = Icon(
      Icons.lock_outline,
      color: RLTheme.textSecondary.withValues(alpha: 0.5),
      size: 18,
    );

    return LockIcon;
  }

  Widget SkillDots() {
    return Row(
      children: [
        RLTypography.text(
          'Mastery',
          color: RLTheme.textSecondary,
        ),

        const Spacing.width(8),

        // Three dots for skill progress
        SkillDotIndicator(dotIndex: 0),
        SkillDotIndicator(dotIndex: 1),
        SkillDotIndicator(dotIndex: 2),
      ],
    );
  }

  Widget SkillDotIndicator({required int dotIndex}) {
    final bool isDotCompleted = dotIndex < skillCheckQuestionsCompleted;
    final bool isNotFirstDot = dotIndex > 0;

    final Color dotColor = isDotCompleted
        ? RLTheme.primaryGreen
        : RLTheme.textSecondary.withValues(alpha: 0.2);

    final EdgeInsets dotPadding = isNotFirstDot
        ? const EdgeInsets.only(left: 4)
        : EdgeInsets.zero;

    final BoxDecoration dotDecoration = BoxDecoration(
      color: dotColor,
      shape: BoxShape.circle,
    );

    return Padding(
      padding: dotPadding,
      child: Container(
        width: 8,
        height: 8,
        decoration: dotDecoration,
      ),
    );
  }
}

class Style {
  static final BorderRadius backButtonRadius = BorderRadius.circular(
    36,
  );

  static const EdgeInsets listViewPadding = EdgeInsets.symmetric(
    horizontal: 20,
  );

  static const Icon ExperienceIcon = Icon(
    Icons.lightbulb,
    color: RLTheme.primaryGreen,
    size: 16,
  );

  static const Icon QuestionIcon = Icon(
    Icons.quiz,
    color: RLTheme.primaryBlue,
    size: 16,
  );
}
