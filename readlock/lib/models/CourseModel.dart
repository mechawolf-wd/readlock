// Course data structure that mirrors course_data.json

class CourseData {
  final String language;
  final List<Course> courses;

  const CourseData({
    required this.language,
    required this.courses,
  });
}

class Course {
  final String courseId;
  final String title;
  final String author;
  final String description;
  final String coverImagePath;
  final String color;
  final List<String> relevantFor;
  final List<String> genres;
  final List<String> preloadedAssets;
  final List<CourseSegment> segments;

  const Course({
    required this.courseId,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImagePath,
    required this.color,
    required this.relevantFor,
    required this.genres,
    required this.preloadedAssets,
    required this.segments,
  });
}

class CourseSegment {
  final String segmentId;
  final String segmentTitle;
  final String segmentDescription;
  final List<Lesson> lessons;

  const CourseSegment({
    required this.segmentId,
    required this.segmentTitle,
    required this.segmentDescription,
    required this.lessons,
  });
}

class Lesson {
  final String lessonId;
  final String title;
  final String lessonVersion;
  final List<LessonContent> content;

  const Lesson({
    required this.lessonId,
    required this.title,
    required this.lessonVersion,
    required this.content,
  });
}

enum LessonContentType {
  text,
  singleChoiceQuestion,
  trueFalseQuestion,
  estimatePercentageQuestion,
  estimatePercentage,
  emotionalSlide,
  designExamplesShowcase,
  reflection,
  skillCheck,
  intro,
  outro,
  fillGapQuestion,
  incorrectStatement,
}

class LessonContent {
  final LessonContentType entityType;
  final String? title;

  // Used by: text, intro, outro
  final List<String>? textSegments;

  // Used by: single-choice-question, true-false-question, estimate-percentage-question,
  // fill-gap-question, incorrect-statement
  final String? question;

  // Used by: single-choice-question, true-false-question, estimate-percentage-question,
  // fill-gap-question, incorrect-statement, estimate-percentage
  final String? explanation;

  // Used by: single-choice-question, true-false-question
  final String? hint;

  // Used by: single-choice-question, true-false-question (options with text and consequence-message)
  final List<QuestionOption>? questionOptions;

  // Used by: fill-gap-question, incorrect-statement (simple string options)
  final List<String>? stringOptions;

  // Used by: single-choice-question, true-false-question, estimate-percentage-question
  final List<int>? correctAnswerIndices;

  // Used by: fill-gap-question (correct answer as String)
  final String? correctAnswerString;

  // Used by: incorrect-statement, estimate-percentage (correct answer as int)
  final int? correctAnswerInt;

  // Used by: emotional-slide
  final String? text;
  final String? icon;

  // Used by: design-examples-showcase
  final String? heading;
  final String? graphic;
  final List<DesignExample>? examples;

  // Used by: reflection
  final String? prompt;
  final List<String>? thinkingPoints;

  const LessonContent({
    required this.entityType,
    this.title,
    this.textSegments,
    this.question,
    this.explanation,
    this.hint,
    this.questionOptions,
    this.stringOptions,
    this.correctAnswerIndices,
    this.correctAnswerString,
    this.correctAnswerInt,
    this.text,
    this.icon,
    this.heading,
    this.graphic,
    this.examples,
    this.prompt,
    this.thinkingPoints,
  });
}

class DesignExample {
  final String type;
  final String title;
  final String description;

  const DesignExample({
    required this.type,
    required this.title,
    required this.description,
  });
}

// Widget-compatible content types used by course content widgets

abstract class CourseContent {
  final String id;
  final String title;

  const CourseContent({
    required this.id,
    required this.title,
  });
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
  singleChoice,
  trueOrFalse,
  reflection,
  fillGap,
  incorrectStatement,
  estimatePercentage,
}

class QuestionOption {
  final String text;
  final String? emoji;
  final String? hint;
  final String? consequenceMessage;

  const QuestionOption({
    required this.text,
    this.emoji,
    this.hint,
    this.consequenceMessage,
  });
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
