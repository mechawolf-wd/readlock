// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseProgressModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseProgressModel _$CourseProgressModelFromJson(Map<String, dynamic> json) =>
    CourseProgressModel(
      courseId: json['courseId'] as String,
      currentLessonIndex: (json['currentLessonIndex'] as num?)?.toInt() ?? 0,
      unlockedPackageIds:
          (json['unlockedPackageIds'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          <String>[],
    );

Map<String, dynamic> _$CourseProgressModelToJson(
        CourseProgressModel instance) =>
    <String, dynamic>{
      'courseId': instance.courseId,
      'currentLessonIndex': instance.currentLessonIndex,
      'unlockedPackageIds': instance.unlockedPackageIds,
    };
