// Course data structure that mirrors course_data.json

class CourseData {
  final String language;
  final List<Accelerator> courses;

  const CourseData({required this.language, required this.courses});
}

class Accelerator {
  // The course identificator (eg. book:atomic-habits)
  final String courseId;

  // Display title (eg. "Atomic Habits")
  final String title;

  // Display author name (eg. "James Clear")
  final String author;

  // Display description (eg. "The book that describes...")
  final String description;

  // Network image path (eg. https://example.com/atomic-habits)
  final String coverImagePath;

  // Color of the course later used for UI elements (eg. "#ffffff")
  final String color;

  // List of people for whom the course would be relevant for
  // (eg. Entrepreneurs - building products that users intuitively understand)
  final List<String> relevantFor;

  // List of genres later used for personalization
  final List<String> genres;

  // List of course segments (eg. "Fundamentals", "Adanced", ...)
  final List<Segment> segments;

  const Accelerator({
    required this.courseId,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImagePath,
    required this.color,
    required this.relevantFor,
    required this.genres,
    required this.segments,
  });
}

class Segment {
  // Segment identificator (eg. ""book:atomic-habits;segment:1)
  final String segmentId;

  // Display title
  final String segmentTitle;

  // Display description
  final String segmentDescription;

  // List of lessons
  final List<Package> units;

  const Segment({
    required this.segmentId,
    required this.segmentTitle,
    required this.segmentDescription,
    required this.units,
  });
}

class Package {
  final String lessonId;
  final String title;
  final String lessonVersion;
  final bool isFree;
  final List<Swipe> slides;

  const Package({
    required this.lessonId,
    required this.title,
    required this.lessonVersion,
    required this.isFree,
    required this.slides,
  });
}

enum LessonContentType {
  text,
  singleChoiceQuestion,
  trueFalseQuestion,
  estimatePercentageQuestion,
  estimatePercentage,
  emotionalSlide,
  reflection,
  intro,
  outro,
}

// Widget-compatible content types used by course content widgets

abstract class Swipe {
  final String id;
  final String title;

  const Swipe({required this.id, required this.title});
}

class IntroContent extends Swipe {
  final List<String> introTextSegments;

  const IntroContent({
    required super.id,
    required super.title,
    required this.introTextSegments,
  });
}

class TextContent extends Swipe {
  final List<String> textSegments;
  final String? text;

  const TextContent({
    required super.id,
    required super.title,
    required this.textSegments,
    this.text,
  });
}

class OutroContent extends Swipe {
  final List<String> outroTextSegments;

  const OutroContent({
    required super.id,
    required super.title,
    required this.outroTextSegments,
  });
}

class ReflectionContent extends Swipe {
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

class QuoteContent extends Swipe {
  final String quote;
  final String author;

  const QuoteContent({
    required super.id,
    required super.title,
    required this.quote,
    required this.author,
  });
}

class QuestionOption {
  final String text;
  final String? emoji;
  final String? hint;
  final String? consequenceMessage;

  const QuestionOption({required this.text, this.emoji, this.hint, this.consequenceMessage});
}

// * Question content entities — one per question type

class MultipleChoiceQuestionContent extends Swipe {
  final String question;
  final List<QuestionOption> options;
  final List<int> correctAnswerIndices;
  final String explanation;
  final String? hint;

  const MultipleChoiceQuestionContent({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndices,
    required this.explanation,
    this.hint,
  });
}

class SingleChoiceQuestionContent extends Swipe {
  final String question;
  final List<QuestionOption> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? hint;

  const SingleChoiceQuestionContent({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.hint,
  });
}

class TrueFalseQuestionContent extends Swipe {
  final String question;
  final List<QuestionOption> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? hint;

  const TrueFalseQuestionContent({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.hint,
  });
}

class ReflectionQuestionContent extends Swipe {
  final String question;
  final List<QuestionOption> options;
  final List<int> correctAnswerIndices;
  final String explanation;

  const ReflectionQuestionContent({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndices,
    required this.explanation,
  });
}

class EstimatePercentageContent extends Swipe {
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
