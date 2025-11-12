// Course detail screen displaying individual course content with navigation
// Supports various content types including text, questions, intro/outro, and design examples
import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/text_content_widget.dart';
import 'package:relevant/course_screens/widgets/question_content_widget.dart';
import 'package:relevant/course_screens/widgets/intro_content_widget.dart';
import 'package:relevant/course_screens/widgets/outro_content_widget.dart';
import 'package:relevant/course_screens/widgets/design_examples_showcase.dart';
import 'package:relevant/course_screens/widgets/reflection_content_widget.dart';
import 'package:relevant/constants/app_theme.dart';

const String NO_CONTENT_AVAILABLE_MESSAGE =
    'No content available for this course';
const String COLOR_BLUE = 'blue';
const String COLOR_GREEN = 'green';
const String COLOR_PURPLE = 'purple';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final int initialSectionIndex;
  final int initialContentIndex;

  const CourseDetailScreen({
    super.key,
    required this.course,
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

  @override
  void initState() {
    super.initState();

    currentSectionIndex = widget.initialSectionIndex;
    currentContentIndex = widget.initialContentIndex;

    pageController = PageController(initialPage: currentContentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: CourseBody(),
        bottomNavigationBar: ProgressBarSection(),
      ),
    );
  }

  Widget CourseBody() {
    final List<CourseContent> allContent = getAllContent();

    if (allContent.isEmpty) {
      return EmptyContentMessage();
    }

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: allContent.length,
      onPageChanged: handlePageChanged,
      itemBuilder: (context, contentItemIndex) {
        return ContentWidget(allContent[contentItemIndex]);
      },
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

  Widget ContentWidget(CourseContent content) {
    final bool isIntroContent = content is IntroContent;
    final bool isTextContent = content is TextContent;
    final bool isQuestionContent = content is QuestionContent;
    final bool isOutroContent = content is OutroContent;
    final bool isDesignExamplesContent =
        content is DesignExamplesShowcaseContent;
    final bool isReflectionContent = content is ReflectionContent;

    if (isIntroContent) {
      return IntroContentWidget(content: content);
    } else if (isTextContent) {
      return TextContentWidget(content: content);
    } else if (isQuestionContent) {
      return QuestionContentWidget(
        content: content,
        onAnswerSelected: handleQuestionAnswer,
      );
    } else if (isOutroContent) {
      return OutroContentWidget(content: content);
    } else if (isDesignExamplesContent) {
      return const DesignExamplesShowcase();
    } else if (isReflectionContent) {
      return ReflectionContentWidget(content: content);
    }

    return EmptyContentMessage();
  }

  Widget ProgressBarSection() {
    final List<CourseContent> allContent = getAllContent();

    return Container(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 16,
        top: 16,
      ),
      child: ProgressBar(allContent.length),
    );
  }

  Widget ProgressBar(int totalContent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (currentContentIndex + 1) / totalContent,
        backgroundColor: AppTheme.backgroundLight,
        valueColor: AlwaysStoppedAnimation<Color>(getCourseColor()),
        minHeight: 12,
      ),
    );
  }

  List<CourseContent> getAllContent() {
    final List<CourseContent> allContent = [];

    for (final CourseSection section in widget.course.sections) {
      allContent.addAll(section.content);
    }

    return allContent;
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
    switch (widget.course.color) {
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
