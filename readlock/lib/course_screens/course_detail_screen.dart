// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples
import 'package:flutter/material.dart';
import 'package:readlock/course_screens/widgets/json_content_widget_factory.dart';
import 'package:readlock/course_screens/data/course_data.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/main_navigation.dart';

const String NO_CONTENT_AVAILABLE_MESSAGE =
    'No content available for this course';
const String ERROR_LOADING_COURSE_DATA = 'Error loading course data';
const String COLOR_BLUE = 'blue';
const String COLOR_GREEN = 'green';
const String COLOR_PURPLE = 'purple';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final int initialSectionIndex;
  final int initialContentIndex;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.initialSectionIndex = 0,
    this.initialContentIndex = 0,
  });

  @override
  State<CourseDetailScreen> createState() => CourseDetailScreenState();
}

class CourseDetailScreenState extends State<CourseDetailScreen> {
  late PageController pageController;
  late int currentContentIndex;
  late int currentSectionIndex;

  List<Map<String, dynamic>> allContent = [];
  Map<String, dynamic>? courseData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    currentSectionIndex = widget.initialSectionIndex;
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
    } catch (e) {
      // Handle error
      print('$ERROR_LOADING_COURSE_DATA: $e');
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
      const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      ),
      SafeArea(
        child: Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          body: Column(
            children: [
              TopProgressBar(),
              Expanded(child: CourseBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget CourseBody() {
    return RenderIf.condition(
      allContent.isEmpty,
      EmptyContentMessage(),
      PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: allContent.length,
        onPageChanged: handlePageChanged,
        itemBuilder: (context, contentItemIndex) {
          return ContentWidget(allContent[contentItemIndex]);
        },
      ),
    );
  }

  Widget EmptyContentMessage() {
    return const Center(
      child: Text(
        NO_CONTENT_AVAILABLE_MESSAGE,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget ContentWidget(Map<String, dynamic> content) {
    return JsonContentWidgetFactory.createContentWidget(content);
  }

  Widget TopProgressBar() {
    final double progress = allContent.isNotEmpty
        ? (currentContentIndex + 1) / allContent.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(AppTheme.fadeTransition(const MainNavigation()));
            },
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.textPrimary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.backgroundLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  getCourseColor(),
                ),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAllContent() async {
    if (courseData == null) {
      return [];
    }

    final sections = List<Map<String, dynamic>>.from(
      courseData!['sections'] ?? [],
    );

    return sections
        .expand(
          (section) =>
              List<Map<String, dynamic>>.from(section['content'] ?? []),
        )
        .toList();
  }

  void handlePageChanged(int contentItemIndex) {
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
}
