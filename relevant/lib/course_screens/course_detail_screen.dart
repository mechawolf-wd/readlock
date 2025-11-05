import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/intro_content_widget.dart';
import 'package:relevant/course_screens/widgets/transition_content_widget.dart';
import 'package:relevant/course_screens/widgets/story_content_widget.dart';
import 'package:relevant/course_screens/widgets/reflection_content_widget.dart';
import 'package:relevant/course_screens/widgets/question_content_widget.dart';
import 'package:relevant/course_screens/widgets/summary_content_widget.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/constants/app_constants.dart';

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

  /// @Method: Initialize state with initial indices and page controller
  @override
  void initState() {
    super.initState();

    currentSectionIndex = widget.initialSectionIndex;
    currentContentIndex = widget.initialContentIndex;

    pageController = PageController();
  }

  /// @Method: Clean up page controller
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
      bottomNavigationBar: NavigationControls(),
    );
  }

  /// @Widget: Main content area with swipeable course content pages
  Widget Body() {
    final List<CourseContent> allContent = getAllContent();

    if (allContent.isEmpty) {
      return EmptyStateMessage();
    }

    return PageView.builder(
      controller: pageController,
      itemCount: allContent.length,
      onPageChanged: handlePageChanged,
      itemBuilder: (context, contentIndex) {
        return BuildContentWidget(allContent[contentIndex]);
      },
    );
  }

  /// @Widget: Placeholder message shown when course has no content
  Widget EmptyStateMessage() {
    return const Center(
      child: Text(
        'No content available for this course',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  /// @Widget: Dynamic content renderer that displays different content types
  Widget BuildContentWidget(CourseContent content) {
    if (content is IntroContent) {
      return IntroContentWidget(content: content);
    } else if (content is TransitionContent) {
      return TransitionContentWidget(content: content);
    } else if (content is StoryContent) {
      return StoryContentWidget(content: content);
    } else if (content is ReflectionContent) {
      return ReflectionContentWidget(
        content: content,
        onReflectionComplete: handleReflectionComplete,
      );
    } else if (content is QuestionContent) {
      return QuestionContentWidget(
        content: content,
        onAnswerSelected: handleQuestionAnswer,
      );
    } else if (content is SummaryContent) {
      return SummaryContentWidget(content: content);
    }

    return EmptyStateMessage();
  }

  /// @Widget: Bottom bar with previous/next buttons and progress indicator
  Widget NavigationControls() {
    final List<CourseContent> allContent = getAllContent();
    final bool isFirstContent = currentContentIndex == 0;
    final bool isLastContent =
        currentContentIndex >= allContent.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          PreviousButton(isFirstContent),

          const SizedBox(width: AppTheme.spacingL),

          ProgressIndicator(allContent.length),

          const SizedBox(width: AppTheme.spacingL),

          NextButton(isLastContent),
        ],
      ),
    );
  }

  /// @Widget: Button to navigate to the previous course content
  Widget PreviousButton(bool isDisabled) {
    return Expanded(
      child: ElevatedButton(
        onPressed: isDisabled ? null : goToPreviousContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.greyBackground,
          foregroundColor: AppTheme.textPrimary,
        ),
        child: const Icon(Icons.arrow_back_ios, size: 20),
      ),
    );
  }

  /// @Widget: Circular progress indicator showing course completion status
  Widget ProgressIndicator(int totalContent) {
    return Expanded(
      flex: 2,
      child: LinearProgressIndicator(
        value: (currentContentIndex + 1) / totalContent,
        backgroundColor: AppTheme.grey300,
        valueColor: AlwaysStoppedAnimation<Color>(getCourseColor()),
      ),
    );
  }

  /// @Widget: Button to advance to the next course content or complete
  Widget NextButton(bool isDisabled) {
    return Expanded(
      child: ElevatedButton(
        onPressed: isDisabled ? completeCourse : goToNextContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppTheme.primaryGreen
              : getCourseColor(),
          foregroundColor: AppTheme.white,
        ),
        child: Icon(
          isDisabled ? Icons.check : Icons.arrow_forward_ios,
          size: 20,
        ),
      ),
    );
  }

  /// @Method: Get all content from all sections
  List<CourseContent> getAllContent() {
    final List<CourseContent> allContent = [];

    for (final CourseSection section in widget.course.sections) {
      allContent.addAll(section.content);
    }

    return allContent;
  }

  /// @Method: Handle page changes
  void handlePageChanged(int contentIndex) {
    setState(() {
      currentContentIndex = contentIndex;
    });
  }

  /// @Method: Go to previous content
  void goToPreviousContent() {
    if (currentContentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// @Method: Go to next content
  void goToNextContent() {
    final List<CourseContent> allContent = getAllContent();

    if (currentContentIndex < allContent.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// @Method: Complete course and navigate back
  void completeCourse() {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppConstants.COURSE_COMPLETED_MESSAGE} ${widget.course.title}!',
        ),
        backgroundColor: getCourseColor(),
      ),
    );
  }

  /// @Method: Handle reflection completion
  void handleReflectionComplete() {
    // Future implementation for tracking progress
  }

  /// @Method: Handle question answer selection
  void handleQuestionAnswer(int selectedIndex, bool isCorrect) {
    // Future implementation for tracking progress and answers
  }

  /// @Method: Get course color based on course color enum
  Color getCourseColor() {
    switch (widget.course.color) {
      case CourseThemeColor.blue:
        {
          return AppTheme.primaryBlue;
        }
      case CourseThemeColor.green:
        {
          return AppTheme.primaryGreen;
        }
      case CourseThemeColor.purple:
        {
          return AppTheme.primaryBrown;
        }
    }
  }
}
