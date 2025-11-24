class Course {
  final String id;
  final String title;
  final String description;
  final String coverImagePath;
  final List<CourseSection> sections;
  final String color;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImagePath,
    required this.sections,
    required this.color,
  });
}

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

abstract class CourseContent {
  final String id;
  final String title;

  const CourseContent({required this.id, required this.title});
}

class IntroContent extends CourseContent {
  final List<String> introTextSegments;

  const IntroContent({
    required super.id,
    required super.title,
    required this.introTextSegments,
  });
}

class TextContent extends CourseContent {
  final List<String> textSegments;
  final String? text;

  const TextContent({
    required super.id,
    required super.title,
    required this.textSegments,
    this.text,
  });
}

class OutroContent extends CourseContent {
  final List<String> outroTextSegments;

  const OutroContent({
    required super.id,
    required super.title,
    required this.outroTextSegments,
  });
}

class DesignExamplesShowcaseContent extends CourseContent {
  const DesignExamplesShowcaseContent({
    required super.id,
    required super.title,
  });
}

class ReflectionContent extends CourseContent {
  final String prompt;
  final List<String> thinkingPoints;
  final String? emoji;

  const ReflectionContent({
    required super.id,
    required super.title,
    required this.prompt,
    required this.thinkingPoints,
    this.emoji,
  });
}

class QuoteContent extends CourseContent {
  final String quote;
  final String author;

  const QuoteContent({
    required super.id,
    required super.title,
    required this.quote,
    required this.author,
  });
}

enum QuestionType {
  multipleChoice,
  trueOrFalse,
  scenario,
  reflection,
  fillGap,
  incorrectStatement,
  estimatePercentage,
}

class QuestionOption {
  final String text;
  final String? emoji;
  final String? hint;

  const QuestionOption({required this.text, this.emoji, this.hint});
}

class QuestionContent extends CourseContent {
  final String question;
  final List<QuestionOption> options;
  final List<int> correctAnswerIndices;
  final String explanation;
  final String? hint;
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
    this.hint,
    this.type = QuestionType.multipleChoice,
    this.scenarioContext,
    this.followUpPrompts,
  });

  bool get hasMultipleCorrectAnswers => correctAnswerIndices.length > 1;

  int get correctAnswerIndex =>
      correctAnswerIndices.isNotEmpty ? correctAnswerIndices.first : -1;
}

class EstimatePercentageContent extends CourseContent {
  final String question;
  final int correctPercentage;
  final String explanation;
  final String? hint;
  final int closeThreshold;

  const EstimatePercentageContent({
    required super.id,
    required super.title,
    required this.question,
    required this.correctPercentage,
    required this.explanation,
    this.hint,
    this.closeThreshold = 10,
  });
}
