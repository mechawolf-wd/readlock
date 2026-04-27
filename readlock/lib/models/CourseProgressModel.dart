import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';

part 'CourseProgressModel.g.dart';

// Per-course reading progress for a single user. Stored on the UserModel
// as a `Map<String, CourseProgressModel>` keyed by courseId — every course
// the user has touched has one entry, courses they've never opened have
// none. Reading the bookshelf decorates each saved-course card with the
// last-opened package and the unlocked-package list from this map.
//
// `lastPackageId` is null until the user opens any package in the course.
// `unlockedPackageIds` always contains at least the entry packages the
// user has reached so far; gating logic checks membership on tap.
@JsonSerializable(explicitToJson: true)
class CourseProgressModel {
  final String courseId;

  final String? lastPackageId;

  @JsonKey(defaultValue: <String>[])
  final List<String> unlockedPackageIds;

  const CourseProgressModel({
    required this.courseId,
    this.lastPackageId,
    this.unlockedPackageIds = const <String>[],
  });

  factory CourseProgressModel.fromJson(JSONMap json) =>
      _$CourseProgressModelFromJson(json);

  JSONMap toJson() => _$CourseProgressModelToJson(this);

  CourseProgressModel copyWith({
    String? lastPackageId,
    List<String>? unlockedPackageIds,
  }) {
    return CourseProgressModel(
      courseId: courseId,
      lastPackageId: lastPackageId ?? this.lastPackageId,
      unlockedPackageIds: unlockedPackageIds ?? this.unlockedPackageIds,
    );
  }
}
