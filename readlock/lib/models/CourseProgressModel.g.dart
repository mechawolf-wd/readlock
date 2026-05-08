// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseProgressModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseProgressModel _$CourseProgressModelFromJson(Map<String, dynamic> json) =>
    CourseProgressModel(
      courseId: json['courseId'] as String,
      currentLessonIndex: (json['currentLessonIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CourseProgressModelToJson(
        CourseProgressModel instance) =>
    <String, dynamic>{
      'courseId': instance.courseId,
      'currentLessonIndex': instance.currentLessonIndex,
    };
