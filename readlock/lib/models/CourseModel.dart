// Course data structure that mirrors Firestore /courses collection
// Top-level models use json_serializable for clean API serialization
// Content-level models (Swipe subclasses) are parsed by CCJSONContentFactory

import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';

part 'CourseModel.g.dart';

// * Top-level serializable models

@JsonSerializable(explicitToJson: true)
class Accelerator {
  @JsonKey(name: 'course-id')
  final String courseId;

  final String title;

  final String author;

  final String description;

  @JsonKey(name: 'cover-image-path')
  final String coverImagePath;

  final String color;

  @JsonKey(name: 'relevant-for')
  final List<String> relevantFor;

  final List<String> genres;

  @JsonKey(name: 'preloaded-assets', defaultValue: [])
  final List<String> preloadedAssets;

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
    required this.preloadedAssets,
    required this.segments,
  });

  factory Accelerator.fromJson(JSONMap json) => _$AcceleratorFromJson(json);

  JSONMap toJson() => _$AcceleratorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Segment {
  @JsonKey(name: 'segment-id')
  final String segmentId;

  @JsonKey(name: 'segment-title')
  final String segmentTitle;

  @JsonKey(name: 'segment-symbol', defaultValue: '')
  final String segmentSymbol;

  @JsonKey(name: 'lessons')
  final List<Package> lessons;

  const Segment({
    required this.segmentId,
    required this.segmentTitle,
    required this.segmentSymbol,
    required this.lessons,
  });

  factory Segment.fromJson(JSONMap json) => _$SegmentFromJson(json);

  JSONMap toJson() => _$SegmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Package {
  @JsonKey(name: 'lesson-id')
  final String lessonId;

  final String title;

  @JsonKey(name: 'lesson-version', defaultValue: '1.0')
  final String lessonVersion;

  final bool isFree;

  @JsonKey(fromJson: _contentFromJson)
  final List<JSONMap> content;

  const Package({
    required this.lessonId,
    required this.title,
    required this.lessonVersion,
    required this.isFree,
    required this.content,
  });

  factory Package.fromJson(JSONMap json) => _$PackageFromJson(json);

  JSONMap toJson() => _$PackageToJson(this);

  static List<JSONMap> _contentFromJson(dynamic json) {
    if (json == null) {
      return [];
    }

    return (json as List).map((item) => JSONMap.from(item as Map)).toList();
  }
}

// * Content type identifiers — matches lockie PackageTextParser entity types

enum LessonContentType {
  text,
  question,
  trueFalseQuestion,
  estimate,
  pause,
  reflect,
  quote,
}

// * Widget-compatible content types used by course content widgets

abstract class Swipe {
  final String id;
  final String title;

  const Swipe({required this.id, required this.title});
}

class TextSwipe extends Swipe {
  final List<String> textSegments;
  final String? text;

  const TextSwipe({
    required super.id,
    required super.title,
    required this.textSegments,
    this.text,
  });
}

class ReflectSwipe extends Swipe {
  final String prompt;
  final List<String> thinkingPoints;
  final String? emoji;

  const ReflectSwipe({
    required super.id,
    required super.title,
    required this.prompt,
    required this.thinkingPoints,
    this.emoji,
  });
}

class QuoteSwipe extends Swipe {
  final String quote;
  final String author;

  const QuoteSwipe({
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

class QuestionSwipe extends Swipe {
  final String question;
  final List<QuestionOption> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? hint;

  const QuestionSwipe({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.hint,
  });
}

class TrueFalseSwipe extends Swipe {
  final String question;
  final List<QuestionOption> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? hint;

  const TrueFalseSwipe({
    required super.id,
    required super.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.hint,
  });
}

class EstimateSwipe extends Swipe {
  final String question;
  final int correctPercentage;
  final String explanation;
  final String? hint;
  final int closeThreshold;

  const EstimateSwipe({
    required super.id,
    required super.title,
    required this.question,
    required this.correctPercentage,
    required this.explanation,
    this.hint,
    this.closeThreshold = 10,
  });
}
