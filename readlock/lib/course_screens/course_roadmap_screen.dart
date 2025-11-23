// Course roadmap screen displaying a simple list of course sections
// Clean card-based layout showing course information
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/course_detail_screen.dart';
import 'package:readlock/course_screens/data/course_data.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/course_loading_screen.dart';

// Constants
const String COURSE_ROADMAP_DEFAULT_TITLE = 'Course Roadmap';
const String COURSE_DEFAULT_COLOR = 'green';
const String COURSE_SUBTITLE_TEXT =
    'Master design psychology fundamentals';
const String AHA_COUNTER_TEXT = '30 Aha';
const String QUESTIONS_COUNTER_TEXT = '29 questions';

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
  List<Map<String, dynamic>> courseSections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourseData();
  }

  Future<void> loadCourseData() async {
    try {
      courseData = await CourseData.getCourseById(widget.courseId);

      if (courseData != null) {
        courseSections = List<Map<String, dynamic>>.from(
          courseData!['sections'] ?? [],
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
      color: AppTheme.backgroundDark,
      child: SafeArea(
        child: Div.column([
          RoadmapHeader(),

          const Spacing.height(24),

          Expanded(
            child: ListView(
              padding: Style.listViewPadding,
              children: LevelCardsList(),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Div.column([
        Div.row([
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: Style.backButtonRadius,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),

          const Spacer(),
        ]),

        const Spacing.height(20),

        Div.column([
          Container(
            padding: Style.courseIconPadding,
            decoration: courseIconDecoration,
            child: Icon(
              Icons.psychology_outlined,
              color: getColorFromString(courseColor),
              size: 48,
            ),
          ),

          const Spacing.height(16),

          Typography.headingLarge(courseTitle),

          const Spacing.height(4),

          Typography.bodyMedium(
            COURSE_SUBTITLE_TEXT,
            textAlign: TextAlign.center,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),

        const Spacing.height(16),

        Div.row(
          CounterRow(),
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  List<Widget> CounterRow() {
    return [
      const Spacer(),

      Div.row([
        Style.AhaIcon,

        const Spacing.width(4),

        Typography.bodyMedium(AHA_COUNTER_TEXT),
      ]),

      const Spacing.width(20),

      Div.row([
        Style.QuestionIcon,

        const Spacing.width(4),

        Typography.bodyMedium(QUESTIONS_COUNTER_TEXT),
      ]),

      const Spacer(),
    ];
  }

  List<Widget> LevelCardsList() {
    return [
      LevelCard(
        levelNumber: 1,
        title: DESIGN_PRINCIPLES_TITLE,
        subtitle: CORE_FUNDAMENTALS_SUBTITLE,
        isCompleted: true,
        onTap: () => navigateToCourseContent(0, 0),
      ),

      LevelCard(
        levelNumber: 2,
        title: PSYCHOLOGY_OF_DESIGN_TITLE,
        subtitle: MENTAL_MODELS_SUBTITLE,
        isCompleted: true,
        onTap: () => navigateToCourseContent(0, 0),
      ),

      LevelCard(
        levelNumber: 3,
        title: AFFORDANCES_TITLE,
        subtitle: VISUAL_CUES_SUBTITLE,
        isCompleted: false,
        isCurrentLevel: true,
        onTap: () => navigateToCourseContent(0, 0),
      ),

      LevelCard(
        levelNumber: 4,
        title: FEEDBACK_SYSTEMS_TITLE,
        subtitle: USER_RESPONSES_SUBTITLE,
        isCompleted: false,
        onTap: () => navigateToCourseContent(0, 0),
      ),

      LevelCard(
        levelNumber: 5,
        title: ADVANCED_CONCEPTS_TITLE,
        subtitle: MASTER_LEVEL_SUBTITLE,
        isCompleted: false,
        onTap: () => navigateToCourseContent(0, 0),
      ),
    ];
  }

  Color getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return AppTheme.primaryGreen;
      case 'purple':
        return Colors.purple;
      case 'blue':
        return AppTheme.primaryBlue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return AppTheme.primaryGreen;
    }
  }

  void navigateToCourseContent(int sectionIndex, int contentIndex) {
    showLoadingScreenThenNavigate(sectionIndex, contentIndex);
  }

  void showLoadingScreenThenNavigate(
    int sectionIndex,
    int contentIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseLoadingScreen(),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          AppTheme.fadeTransition(
            CourseDetailScreen(
              courseId: widget.courseId,
              initialSectionIndex: sectionIndex,
              initialContentIndex: contentIndex,
            ),
          ),
        );
      }
    });
  }
}

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrentLevel;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isCurrentLevel = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: buildCardDecoration(),
        child: Div.row([
          LevelBadge(),

          const Spacing.width(16),

          Expanded(child: LevelContent()),

          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 20,
          ),
        ]),
      ),
    );
  }

  BoxDecoration buildCardDecoration() {
    final Color cardColor = getCardColor();
    final Color borderColor = getBorderColor();

    return LevelCardStyle.cardDecoration.copyWith(
      color: cardColor,
      border: Border.all(color: borderColor),
    );
  }

  Color getCardColor() {
    if (isCurrentLevel) {
      return AppTheme.primaryGreen.withValues(alpha: 0.1);
    }
    return Colors.grey.withValues(alpha: 0.05);
  }

  Color getBorderColor() {
    if (isCurrentLevel) {
      return AppTheme.primaryGreen.withValues(alpha: 0.3);
    }
    return Colors.grey.withValues(alpha: 0.1);
  }

  Widget LevelBadge() {
    final BoxDecoration badgeDecoration = LevelCardStyle.badgeDecoration
        .copyWith(color: getBadgeColor());

    return Container(
      width: LevelCardStyle.badgeSize,
      height: LevelCardStyle.badgeSize,
      decoration: badgeDecoration,
      child: Center(child: BadgeContent()),
    );
  }

  Color getBadgeColor() {
    if (isCompleted) {
      return AppTheme.primaryGreen;
    }

    if (isCurrentLevel) {
      return AppTheme.primaryGreen.withValues(alpha: 0.2);
    }

    return Colors.grey.withValues(alpha: 0.2);
  }

  Widget BadgeContent() {
    return RenderIf.condition(
      isCompleted,
      const Icon(Icons.check, color: Colors.white, size: 20),
      Typography.bodyMedium(
        levelNumber.toString(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget LevelContent() {
    return Div.column([
      Typography.headingMedium('$LEVEL_PREFIX$levelNumber: $title'),

      const Spacing.height(4),

      Typography.bodyMedium(subtitle),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }
}

class Style {
  static final BoxDecoration courseIconDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
  );

  static final BorderRadius backButtonRadius = BorderRadius.circular(
    12,
  );

  static const EdgeInsets courseIconPadding = EdgeInsets.all(16);

  static const EdgeInsets listViewPadding = EdgeInsets.symmetric(
    horizontal: 20,
  );

  static const Icon AhaIcon = Icon(
    Icons.lightbulb,
    color: AppTheme.primaryGreen,
    size: 16,
  );

  static const Icon QuestionIcon = Icon(
    Icons.quiz,
    color: AppTheme.primaryBlue,
    size: 16,
  );
}

class LevelCardStyle {
  static final BoxDecoration cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
  );

  static final BoxDecoration badgeDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
  );

  static const double badgeSize = 40.0;
}
