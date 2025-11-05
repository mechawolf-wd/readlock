import 'package:relevant/constants/app_theme.dart';

/// @Class: Course model representing a learning course with sections
class Course {
  final String id;
  final String title;
  final String description;
  final String coverImagePath;
  final List<CourseSection> sections;
  final CourseThemeColor color;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImagePath,
    required this.sections,
    required this.color,
  });
}

/// @Class: Course section containing multiple content items
class CourseSection {
  final String id;
  final String title;
  final List<CourseContent> content;

  const CourseSection({
    required this.id,
    required this.title,
    required this.content,
  });
}

/// @Class: Abstract base class for course content items
abstract class CourseContent {
  final String id;
  final String title;

  const CourseContent({required this.id, required this.title});
}

/// @Class: Story content with text and optional image
class StoryContent extends CourseContent {
  final String text;
  final String? imageUrl;

  const StoryContent({
    required super.id,
    required super.title,
    required this.text,
    this.imageUrl,
  });
}

/// @Class: Reflection content with prompts and insights
class ReflectionContent extends CourseContent {
  final String prompt;
  final String insight;
  final List<String> thinkingPoints;

  const ReflectionContent({
    required super.id,
    required super.title,
    required this.prompt,
    required this.insight,
    required this.thinkingPoints,
  });
}

// @Enum: Question types for different engagement styles
enum QuestionType { multipleChoice, trueOrFalse, scenario, reflection }

/// @Class: Question option with additional metadata
class QuestionOption {
  final String text;
  final String? emoji;
  final String? hint;

  const QuestionOption({required this.text, this.emoji, this.hint});
}

/// @Class: Interactive question content with multiple choice options
class QuestionContent extends CourseContent {
  final String question;
  final List<QuestionOption> options;
  final List<int> correctAnswerIndices;
  final String explanation;
  final QuestionType type;
  final String? scenarioContext;
  final List<String>? followUpPrompts;

  const QuestionContent({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndices,
    required this.explanation,
    this.type = QuestionType.multipleChoice,
    this.scenarioContext,
    this.followUpPrompts,
  });

  /// @Method: Check if question has multiple correct answers
  bool get hasMultipleCorrectAnswers => correctAnswerIndices.length > 1;

  /// @Method: Get primary correct answer for backward compatibility
  int get correctAnswerIndex =>
      correctAnswerIndices.isNotEmpty ? correctAnswerIndices.first : -1;
}

/// @Class: Real-world example with context and outcome
class RealWorldExample {
  final String context;
  final String application;
  final String outcome;

  const RealWorldExample({
    required this.context,
    required this.application,
    required this.outcome,
  });
}

/// @Class: Course introduction with compelling question and overview
class IntroContent extends CourseContent {
  final String question;
  final String overview;
  final List<String> learningPoints;

  const IntroContent({
    required super.id,
    required super.title,
    required this.question,
    required this.overview,
    required this.learningPoints,
  });
}

/// @Class: Transition content for smooth flow between sections
class TransitionContent extends CourseContent {
  final String message;
  final String callToAction;

  const TransitionContent({
    required super.id,
    required super.title,
    required this.message,
    required this.callToAction,
  });
}

/// @Class: Course completion summary with key insights and examples
class SummaryContent extends CourseContent {
  final String mainInsight;
  final List<RealWorldExample> examples;

  const SummaryContent({
    required super.id,
    required super.title,
    required this.mainInsight,
    required this.examples,
  });
}
