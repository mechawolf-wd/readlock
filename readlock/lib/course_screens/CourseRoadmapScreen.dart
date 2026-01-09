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

// Constants
const String COURSE_ROADMAP_DEFAULT_TITLE = 'Course Roadmap';
const String COURSE_DEFAULT_COLOR = 'green';
const String COURSE_SUBTITLE_TEXT =
    'Master design psychology fundamentals';
const String EXPERIENCE_COUNTER_TEXT = '30 xp';
const String QUESTIONS_COUNTER_TEXT = '29 questions';

// Dialog constants
const String DIALOG_TITLE = 'Ready to Learn?';
const String DIALOG_MESSAGE =
    'Start your journey into design psychology';
const String CONTINUE_BUTTON = 'Start';
const String POINTS_TEXT = ' +20 XP';

// Level constants
const String LEVEL_PREFIX = 'Level ';
const String DESIGN_PRINCIPLES_TITLE = 'Design Principles';
const String PSYCHOLOGY_OF_DESIGN_TITLE = 'Psychology of Design';
const String AFFORDANCES_TITLE = 'Affordances';
const String FEEDBACK_SYSTEMS_TITLE = 'Feedback Systems';
const String ADVANCED_CONCEPTS_TITLE = 'Advanced Concepts';

const String CORE_FUNDAMENTALS_SUBTITLE = 'Core fundamentals';
const String MENTAL_MODELS_SUBTITLE = 'Mental models';
const String VISUAL_CUES_SUBTITLE = 'Visual cues';
const String USER_RESPONSES_SUBTITLE = 'User responses';
const String MASTER_LEVEL_SUBTITLE = 'Master level';

class CourseRoadmapScreen extends StatefulWidget {
  final String courseId;

  const CourseRoadmapScreen({super.key, required this.courseId});

  @override
  State<CourseRoadmapScreen> createState() =>
      CourseRoadmapScreenState();
}

class CourseRoadmapScreenState extends State<CourseRoadmapScreen> {
  Map<String, dynamic>? courseData;
  List<Map<String, dynamic>> courseSegments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourseData();
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
        child: Div.column([
          // Header section with back button and course info
          RoadmapHeader(),

          const Spacing.height(24),

          // Scrollable lesson cards list
          Expanded(
            child: ListView(
              padding: Style.listViewPadding,
              children: LessonCards(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget RoadmapHeader() {
    final String courseTitle =
        courseData?['title'] ?? COURSE_ROADMAP_DEFAULT_TITLE;
    final String courseColor =
        courseData?['color'] ?? COURSE_DEFAULT_COLOR;

    final BoxDecoration courseIconDecoration = Style
        .courseIconDecoration
        .copyWith(
          color: getColorFromString(courseColor).withValues(alpha: 0.2),
        );

    final Widget BackArrowIcon = const Icon(
      Icons.arrow_back,
      color: RLTheme.textPrimary,
      size: 24,
    );

    final Widget CourseIcon = Icon(
      Icons.psychology_outlined,
      color: getColorFromString(courseColor),
      size: 48,
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

        const Spacing.height(20),

        // Course information section
        Div.column([
          // Course icon container
          Div.column(
            [CourseIcon],
            padding: Style.courseIconPadding,
            decoration: courseIconDecoration,
          ),

          const Spacing.height(16),

          // Course title
          RLTypography.headingLarge(courseTitle),

          const Spacing.height(4),

          // Course subtitle
          RLTypography.bodyMedium(
            COURSE_SUBTITLE_TEXT,
            textAlign: TextAlign.center,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),

        const Spacing.height(16),

        // Course statistics row
        Div.row(
          getCounterRow(),
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const [20, 16],
    );
  }

  List<Widget> getCounterRow() {
    return [
      const Spacer(),

      // Experience moments counter
      Div.row([
        Style.ExperienceIcon,

        const Spacing.width(4),

        RLTypography.bodyMedium(EXPERIENCE_COUNTER_TEXT),
      ]),

      const Spacing.width(20),

      // Questions counter
      Div.row([
        Style.QuestionIcon,

        const Spacing.width(4),

        RLTypography.bodyMedium(QUESTIONS_COUNTER_TEXT),
      ]),

      const Spacer(),
    ];
  }

  List<Widget> LessonCards() {
    final List<Widget> cards = [];
    int cardIndex = 0;

    // Loop through each segment
    for (
      int segmentIndex = 0;
      segmentIndex < courseSegments.length;
      segmentIndex++
    ) {
      final Map<String, dynamic> segment = courseSegments[segmentIndex];
      final String segmentTitle =
          segment['segment-title'] ?? 'Unnamed Segment';
      final String segmentDescription =
          segment['segment-description'] ?? '';
      final List<dynamic> lessons = segment['lessons'] ?? [];

      // Add segment header
      cards.add(
        SegmentHeader(
          title: segmentTitle,
          description: segmentDescription,
        ),
      );

      // Add lessons for this segment
      for (
        int lessonIndex = 0;
        lessonIndex < lessons.length;
        lessonIndex++
      ) {
        final Map<String, dynamic> lesson = lessons[lessonIndex];
        final String lessonTitle = lesson['title'] ?? 'Unnamed Lesson';
        final String lessonId = lesson['lesson-id'] ?? '';

        // Determine lesson state (mocked for now)
        final bool isCompleted =
            segmentIndex == 0 &&
            lessonIndex <
                3; // First 3 lessons of first segment are completed
        final bool isCurrentLevel =
            segmentIndex == 0 &&
            lessonIndex == 3; // 4th lesson of first segment is current
        final bool isLocked =
            segmentIndex > 0; // All other segments are locked

        // Mock completion data for demonstration
        final int skillCheckQuestionsCompleted =
            getMockSkillCheckProgress(segmentIndex, lessonIndex);

        cards.add(
          LessonCard(
            levelNumber: cardIndex + 1,
            title: lessonTitle,
            subtitle: lessonId,
            isCompleted: isCompleted,
            isCurrentLevel: isCurrentLevel,
            isLocked: isLocked,
            skillCheckQuestionsCompleted: skillCheckQuestionsCompleted,
            onTap: () => showLoadingScreenThenNavigate(lessonIndex, 0),
          ),
        );

        cardIndex++;
      }

      // Add spacing between segments
      if (segmentIndex < courseSegments.length - 1) {
        cards.add(const Spacing.height(20));
      }
    }

    return cards;
  }

  Color getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return RLTheme.primaryGreen;
      case 'purple':
        return Colors.purple;
      case 'blue':
        return RLTheme.primaryBlue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return RLTheme.primaryGreen;
    }
  }

  // Mock skill check progress data for demonstration
  int getMockSkillCheckProgress(int segmentIndex, int lessonIndex) {
    // First segment lessons: varied skill check progress emphasizing 2/3 completion
    if (segmentIndex == 0) {
      switch (lessonIndex) {
        case 0:
          return 3; // Lesson 1: all 3 skill check questions completed
        case 1:
          return 2; // Lesson 2: 2 out of 3 skill check questions completed
        case 2:
          return 2; // Lesson 3: 2 out of 3 skill check questions completed
        case 3:
          return 2; // Lesson 4: current lesson, 2 out of 3 completed
        case 4:
          return 1; // Lesson 5: 1 out of 3 skill check questions completed
        case 5:
          return 0; // Lesson 6: no skill check progress yet
        default:
          return 0;
      }
    }

    // Other segments: no progress (locked)
    return 0;
  }

  void showLoadingScreenThenNavigate(
    int lessonIndex,
    int contentIndex,
  ) {
    // Show experience points dialog first
    showExperiencePointsDialog(lessonIndex, contentIndex);
  }

  void showExperiencePointsDialog(int lessonIndex, int contentIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RLTheme.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Div.column(
              [
                // Continue button
                RLDesignSystem.BlockButton(
                  children: [
                    RLTypography.bodyMedium(
                      CONTINUE_BUTTON,
                      color: Colors.white,
                    ),

                    // Experience points badge
                    RLTypography.bodyMedium(
                      POINTS_TEXT,
                      color: Colors.white,
                    ),
                  ],
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    navigateToCourseWithLoading(
                      lessonIndex,
                      contentIndex,
                    );
                  },
                ),
              ],
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
            ),
          ],
        );
      },
    );
  }

  void navigateToCourseWithLoading(int lessonIndex, int contentIndex) {
    // Show loading screen first
    Navigator.push(
      context,
      RLTheme.slideUpTransition(const CourseLoadingScreen()),
    );

    // Navigate to course detail after delay
    void routeToCourse() {
      if (mounted) {
        final slideUpTransition = RLTheme.slideUpTransition(
          CourseDetailScreen(
            courseId: widget.courseId,
            initialLessonIndex: lessonIndex,
            initialContentIndex: contentIndex,
          ),
        );

        Navigator.pushReplacement(context, slideUpTransition);
      }
    }

    Future.delayed(const Duration(milliseconds: 500), routeToCourse);
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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: segmentColor.withValues(alpha: 0.3)),
    );

    final Widget StyledLetter = Div.column(
      [
        RLTypography.headingLarge(
          segmentLetter,
          color: segmentColor,
          textAlign: TextAlign.center,
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: letterDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return Div.column([
      const Spacing.height(24),

      // Letter and title row
      Div.row([
        StyledLetter,

        const Spacing.width(12),

        RLTypography.headingLarge(
          segmentTitle,
          color: RLTheme.textPrimary,
          textAlign: TextAlign.left,
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(16),
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
        return Colors.purple;
      default:
        return RLTheme.primaryGreen;
    }
  }
}

class LessonCard extends StatelessWidget {
  final int levelNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrentLevel;
  final bool isLocked;
  final int skillCheckQuestionsCompleted; // 0-3 questions completed
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.levelNumber,
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
    final BoxDecoration cardDecoration = getCardDecoration();
    final Widget ArrowIcon = const Icon(
      Icons.arrow_forward_ios,
      color: Colors.white54,
      size: 20,
    );

    return Div.column(
      [
        // Main card content row
        Div.row([
          // Level number badge
          LevelBadge(),

          const Spacing.width(16),

          // Level title and description
          Expanded(child: LevelContent()),

          // Navigation arrow
          ArrowIcon,
        ]),

        // Progress indicators (show only if not locked)
        if (!isLocked) ...[
          const Spacing.height(16),
          ProgressIndicators(),
        ],
      ],
      margin: 8,
      padding: 16,
      decoration: cardDecoration,
      onTap: isLocked ? () {} : onTap,
      radius: 36,
    );
  }

  BoxDecoration getCardDecoration() {
    final Color cardColor = getCardColor();
    final Color borderColor = getBorderColor();

    return LevelCardStyle.cardDecoration.copyWith(
      color: cardColor,
      border: Border.all(color: borderColor),
    );
  }

  Color getCardColor() {
    if (isLocked) {
      return Colors.grey.withValues(alpha: 0.02);
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.1);
    }
    return Colors.grey.withValues(alpha: 0.05);
  }

  Color getBorderColor() {
    if (isLocked) {
      return Colors.grey.withValues(alpha: 0.05);
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.3);
    }
    return Colors.grey.withValues(alpha: 0.1);
  }

  Widget LevelBadge() {
    final BoxDecoration badgeDecoration = LevelCardStyle.badgeDecoration
        .copyWith(color: getBadgeColor());

    return Div.column(
      [BadgeContent()],
      width: LevelCardStyle.badgeSize,
      height: LevelCardStyle.badgeSize,
      decoration: badgeDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Color getBadgeColor() {
    if (isLocked) {
      return Colors.grey.withValues(alpha: 0.1);
    }
    if (isCompleted) {
      return RLTheme.primaryGreen;
    }
    if (isCurrentLevel) {
      return RLTheme.primaryGreen.withValues(alpha: 0.2);
    }
    return Colors.grey.withValues(alpha: 0.2);
  }

  Widget BadgeContent() {
    final Widget CheckIcon = const Icon(
      Icons.check,
      color: Colors.white,
      size: 20,
    );

    final Widget LockIcon = const Icon(
      Icons.lock,
      color: Colors.grey,
      size: 16,
    );

    if (isLocked) {
      return LockIcon;
    }

    return RenderIf.condition(
      isCompleted,
      CheckIcon,
      RLTypography.bodyMedium(
        levelNumber.toString(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget LevelContent() {
    return Div.column([
      // Level title with number
      RLTypography.headingMedium(title),

      const Spacing.height(4),

      // Level description
      RLTypography.bodyMedium(subtitle),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  // Progress indicators showing skill check progress only
  Widget ProgressIndicators() {
    return Div.row([
      const Spacer(),
      
      // Skill check progress with wrapped container
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SkillCheckProgressIndicator(),
      ),
    ]);
  }

  // Skill check progress indicator with 3 boxes
  Widget SkillCheckProgressIndicator() {
    return Div.row([
      RLTypography.bodyMedium(
        'Skills:',
        color: Colors.grey.withValues(alpha: 0.8),
      ),

      const Spacing.width(10),

      // Three skill check boxes with improved styling
      ...List.generate(3, (index) {
        final bool isCompleted = index < skillCheckQuestionsCompleted;
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
          child: Container(
            width: 18,
            height: 14,
            decoration: BoxDecoration(
              color: isCompleted
                  ? RLTheme.primaryGreen
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isCompleted
                    ? RLTheme.primaryGreen
                    : Colors.grey.withValues(alpha: 0.4),
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 10)
                : null,
          ),
        );
      }),
    ]);
  }
}

class Style {
  static final BoxDecoration courseIconDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(36),
  );

  static final BorderRadius backButtonRadius = BorderRadius.circular(
    36,
  );

  static const double courseIconPadding = 16;

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

class LevelCardStyle {
  static final BoxDecoration cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(36),
  );

  static final BoxDecoration badgeDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(36),
  );

  static const double badgeSize = 40.0;
}
