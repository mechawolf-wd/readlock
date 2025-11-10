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

enum QuestionType { multipleChoice, trueOrFalse, scenario, reflection }

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

  bool get hasMultipleCorrectAnswers => correctAnswerIndices.length > 1;

  int get correctAnswerIndex =>
      correctAnswerIndices.isNotEmpty ? correctAnswerIndices.first : -1;
}
