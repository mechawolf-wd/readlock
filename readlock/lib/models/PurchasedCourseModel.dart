import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/models/UserModel.dart';

part 'PurchasedCourseModel.g.dart';

// One library entry on the UserModel. Stored as an element of the
// purchasedCourses array on /users/{id}, so the courseId travels inside
// the record rather than living as the map key. Each entry carries the
// rental's expiry: every purchase grants COURSE_RENTAL_DAYS and the
// resurrect flow (COURSE_RESURRECT_COST feathers, only after the
// expires timestamp has passed) extends it by another window.
@JsonSerializable(explicitToJson: true)
class PurchasedCourseModel {
  final String courseId;

  @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
  final DateTime expires;

  // When the reader first bought this course. Null on entries that
  // pre-date this field so the badge only shows on fresh purchases.
  @JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson)
  final DateTime? purchasedAt;

  const PurchasedCourseModel({
    required this.courseId,
    required this.expires,
    this.purchasedAt,
  });

  factory PurchasedCourseModel.fromJson(JSONMap json) =>
      _$PurchasedCourseModelFromJson(json);

  JSONMap toJson() => _$PurchasedCourseModelToJson(this);

  bool isActiveAt(DateTime now) {
    return now.isBefore(expires);
  }

  PurchasedCourseModel copyWith({
    String? courseId,
    DateTime? expires,
    DateTime? purchasedAt,
  }) {
    return PurchasedCourseModel(
      courseId: courseId ?? this.courseId,
      expires: expires ?? this.expires,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}

// Nullable variants of the Timestamp converters from UserModel. Used for
// purchasedAt which is absent on entries written before this field existed.
DateTime? nullableTimestampFromJson(dynamic value) {
  if (value == null) {
    return null;
  }

  return timestampFromJson(value);
}

dynamic nullableTimestampToJson(DateTime? value) {
  if (value == null) {
    return null;
  }

  return timestampToJson(value);
}
