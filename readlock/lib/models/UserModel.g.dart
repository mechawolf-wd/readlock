// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  nickname: json['nickname'] as String,
  language: json['language'] as String? ?? 'en',
  fcmToken: json['fcmToken'] as String?,
  createdAt: timestampFromJson(json['createdAt']),
  hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
  hasReaderPass: json['hasReaderPass'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'email': instance.email,
  'nickname': instance.nickname,
  'language': instance.language,
  'fcmToken': instance.fcmToken,
  'createdAt': timestampToJson(instance.createdAt),
  'hasCompletedOnboarding': instance.hasCompletedOnboarding,
  'hasReaderPass': instance.hasReaderPass,
};
