import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';

part 'CourseProgressModel.g.dart';

// Per-course reading progress for a single user. Stored on the UserModel
// as a `Map<String, CourseProgressModel>` keyed by courseId, one entry
// per course the reader has purchased. The roadmap consults this map to
// gate which lesson tiles are tappable, so a fresh purchase produces a
// new record with currentLessonIndex == 0 (only lesson 0 is tappable)
// and the index advances by exactly one every time the reader hits the
// Finish button on the active lesson.
//
// Tile i is tappable iff `i <= currentLessonIndex`, so the frontier and
// the highest unlocked tile are the same number. Finishing lesson N
// when N == currentLessonIndex bumps the index to N + 1; finishing an
// already-completed lesson is a no-op (the max() guard in the writer
// keeps the field monotonic).
@JsonSerializable(explicitToJson: true)
class CourseProgressModel {
  final String courseId;

  @JsonKey(defaultValue: 0)
  final int currentLessonIndex;

  const CourseProgressModel({
    required this.courseId,
    this.currentLessonIndex = 0,
  });

  factory CourseProgressModel.fromJson(JSONMap json) =>
      _$CourseProgressModelFromJson(json);

  JSONMap toJson() => _$CourseProgressModelToJson(this);

  CourseProgressModel copyWith({int? currentLessonIndex}) {
    return CourseProgressModel(
      courseId: courseId,
      currentLessonIndex: currentLessonIndex ?? this.currentLessonIndex,
    );
  }
}
