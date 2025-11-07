import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/text_content_widget.dart';
import 'package:relevant/course_screens/widgets/question_content_widget.dart';

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

    pageController = PageController();
  }

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

  Widget EmptyStateMessage() {
    return const Center(
      child: Text(
        'No content available for this course',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget BuildContentWidget(CourseContent content) {
    if (content is TextContent) {
      return TextContentWidget(content: content);
    } else if (content is QuestionContent) {
      return QuestionContentWidget(
        content: content,
        onAnswerSelected: handleQuestionAnswer,
      );
    }

    return EmptyStateMessage();
  }

  Widget NavigationControls() {
    final List<CourseContent> allContent = getAllContent();
    final bool isFirstContent = currentContentIndex == 0;
    final bool isLastContent =
        currentContentIndex >= allContent.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          PreviousButton(isFirstContent),
          
          const SizedBox(width: 16),
          
          ProgressIndicator(allContent.length),
          
          const SizedBox(width: 16),
          
          NextButton(isLastContent),
        ],
      ),
    );
  }

  Widget PreviousButton(bool isDisabled) {
    return Flexible(
      child: ElevatedButton(
        onPressed: isDisabled ? null : goToPreviousContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
        ),
        child: const Icon(Icons.arrow_back_ios, size: 20),
      ),
    );
  }

  Widget ProgressIndicator(int totalContent) {
    return Flexible(
      flex: 2,
      child: LinearProgressIndicator(
        value: (currentContentIndex + 1) / totalContent,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(getCourseColor()),
      ),
    );
  }

  Widget NextButton(bool isDisabled) {
    return Flexible(
      child: ElevatedButton(
        onPressed: isDisabled ? completeCourse : goToNextContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.green
              : getCourseColor(),
          foregroundColor: Colors.white,
        ),
        child: Icon(
          isDisabled ? Icons.check : Icons.arrow_forward_ios,
          size: 20,
        ),
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

  void handlePageChanged(int contentIndex) {
    setState(() {
      currentContentIndex = contentIndex;
    });
  }

  void goToPreviousContent() {
    if (currentContentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNextContent() {
    final List<CourseContent> allContent = getAllContent();

    if (currentContentIndex < allContent.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void completeCourse() {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Course completed: ${widget.course.title}!',
        ),
        backgroundColor: getCourseColor(),
      ),
    );
  }

  void handleQuestionAnswer(int selectedIndex, bool isCorrect) {
    // Future implementation for tracking progress and answers
  }

  Color getCourseColor() {
    switch (widget.course.color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
