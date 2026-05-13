// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PurchasedCourseModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchasedCourseModel _$PurchasedCourseModelFromJson(
  Map<String, dynamic> json,
) => PurchasedCourseModel(
  courseId: json['courseId'] as String,
  expires: timestampFromJson(json['expires']),
  purchasedAt: nullableTimestampFromJson(json['purchasedAt']),
);

Map<String, dynamic> _$PurchasedCourseModelToJson(
  PurchasedCourseModel instance,
) => <String, dynamic>{
  'courseId': instance.courseId,
  'expires': timestampToJson(instance.expires),
  'purchasedAt': nullableTimestampToJson(instance.purchasedAt),
};
