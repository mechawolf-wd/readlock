// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples
import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/widgets/CCJSONContentFactory.dart';
import 'package:readlock/course_screens/data/courseData.dart';
import 'package:readlock/constants/appTheme.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/BottomNavigationBar.dart';
import 'package:readlock/constants/typography.dart';

const String NO_CONTENT_AVAILABLE_MESSAGE =
    'No content available for this course';
const String ERROR_LOADING_COURSE_DATA = 'Error loading course data';
const String COLOR_BLUE = 'blue';
const String COLOR_GREEN = 'green';
const String COLOR_PURPLE = 'purple';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final int initialLessonIndex;
  final int initialContentIndex;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.initialLessonIndex = 0,
    this.initialContentIndex = 0,
  });

  @override
  State<CourseDetailScreen> createState() => CourseDetailScreenState();
}

class CourseDetailScreenState extends State<CourseDetailScreen> {
  late PageController pageController;
  late int currentContentIndex;
  late int currentLessonIndex;

  List<Map<String, dynamic>> allContent = [];
  Map<String, dynamic>? courseData;
  bool isLoading = true;

  // Styling constants
  final EdgeInsets topBarPadding = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  final BorderRadius progressBarRadius = BorderRadius.circular(4);

  // Icon definitions
  Widget get BackIcon => const Icon(
    Icons.arrow_back,
    color: AppTheme.textPrimary,
    size: 24,
  );

  @override
  void initState() {
    super.initState();

    currentLessonIndex = widget.initialLessonIndex;
    currentContentIndex = widget.initialContentIndex;

    pageController = PageController(initialPage: currentContentIndex);
    loadCourseData();
  }

  Future<void> loadCourseData() async {
    try {
      courseData = await CourseData.getCourseById(widget.courseId);

      if (courseData != null) {
        allContent = await getAllContent();
      }
    } catch (error) {
      debugPrint('$ERROR_LOADING_COURSE_DATA: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RenderIf.condition(
      isLoading,
      // Loading screen
      const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      ),
      // Main course screen
      SafeArea(
        child: Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          body: Div.column([
            // Progress bar and navigation header
            TopProgressBar(),

            // Main course content area
            Expanded(child: CourseBody()),
          ]),
        ),
      ),
    );
  }

  Widget CourseBody() {
    return RenderIf.condition(
      allContent.isEmpty,
      // Empty state message
      EmptyContentMessage(),
      // Vertical page view with course content
      PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: allContent.length,
        onPageChanged: handlePageChanged,
        itemBuilder: getContentItem,
      ),
    );
  }

  Widget EmptyContentMessage() {
    return Center(
      child: Typography.bodyMedium(NO_CONTENT_AVAILABLE_MESSAGE),
    );
  }

  Widget getContentItem(BuildContext context, int contentItemIndex) {
    final Map<String, dynamic> content = allContent[contentItemIndex];
    return JsonContentWidgetFactory.createContentWidget(content);
  }

  Widget TopProgressBar() {
    return Div.row([
      // Back navigation button
      BackNavigationButton(),

      const Spacing.width(12),

      // Course progress indicator
      Expanded(child: ProgressIndicator()),
    ], padding: topBarPadding);
  }

  Future<List<Map<String, dynamic>>> getAllContent() async {
    if (courseData == null) {
      return [];
    }

    final List<Map<String, dynamic>> lessons =
        List<Map<String, dynamic>>.from(courseData!['lessons'] ?? []);

    return expandLessonsToContent(lessons);
  }

  void navigateToMainScreen() {
    Navigator.of(
      context,
    ).push(AppTheme.fadeTransition(const MainNavigation()));
  }

  List<Map<String, dynamic>> expandLessonsToContent(
    List<Map<String, dynamic>> lessons,
  ) {
    return lessons
        .expand(
          (lesson) =>
              List<Map<String, dynamic>>.from(lesson['content'] ?? []),
        )
        .toList();
  }

  void handlePageChanged(int contentItemIndex) {
    // Dismiss any active snackbar when user scrolls to next content
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      currentContentIndex = contentItemIndex;
    });
  }

  void handleQuestionAnswer(int selectedIndex, bool isCorrect) {
    // Future implementation for tracking progress and answers
  }

  Color getCourseColor() {
    final String courseColor = courseData?['color'] ?? 'green';

    switch (courseColor) {
      case COLOR_BLUE:
        {
          return Colors.blue;
        }
      case COLOR_GREEN:
        {
          return Colors.green;
        }
      case COLOR_PURPLE:
        {
          return Colors.purple;
        }
      default:
        {
          return Colors.blue;
        }
    }
  }

  double calculateProgress() {
    if (allContent.isEmpty) {
      return 0.0;
    }

    return (currentContentIndex + 1) / allContent.length;
  }

  Widget BackNavigationButton() {
    return Div.row([BackIcon], onTap: navigateToMainScreen);
  }

  Widget ProgressIndicator() {
    final double progressValue = calculateProgress();
    final Color courseColor = getCourseColor();

    return ClipRRect(
      borderRadius: progressBarRadius,
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: AppTheme.backgroundLight,
        valueColor: AlwaysStoppedAnimation<Color>(courseColor),
        minHeight: 8,
      ),
    );
  }
}
