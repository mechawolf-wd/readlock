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
  typingSound: json['typingSound'] as bool? ?? true,
  sounds: json['sounds'] as bool? ?? true,
  haptics: json['haptics'] as bool? ?? true,
  reveal: json['reveal'] as bool? ?? false,
  blur: json['blur'] as bool? ?? true,
  coloredText: json['coloredText'] as bool? ?? true,
  bionic: json['bionic'] as bool? ?? false,
  rsvp: json['rsvp'] as bool? ?? false,
  readingFont: json['readingFont'] as String? ?? 'serif',
  readingColumn: json['readingColumn'] as String? ?? 'narrow',
  rsvpWordsPerMinute: (json['rsvpWordsPerMinute'] as num?)?.toInt() ?? 300,
  nightShiftLevel: (json['nightShiftLevel'] as num?)?.toInt() ?? 0,
  birdName: json['birdName'] as String? ?? 'Sparrow',
  savedCourseIds:
      (json['savedCourseIds'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ??
      <String>[],
  purchasedCourses:
      (json['purchasedCourses'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ??
      <String>[],
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  courseProgress:
      (json['courseProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              CourseProgressModel.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
      <String, CourseProgressModel>{},
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'email': instance.email,
  'nickname': instance.nickname,
  'language': instance.language,
  'fcmToken': instance.fcmToken,
  'createdAt': timestampToJson(instance.createdAt),
  'hasCompletedOnboarding': instance.hasCompletedOnboarding,
  'hasReaderPass': instance.hasReaderPass,
  'typingSound': instance.typingSound,
  'sounds': instance.sounds,
  'haptics': instance.haptics,
  'reveal': instance.reveal,
  'blur': instance.blur,
  'coloredText': instance.coloredText,
  'bionic': instance.bionic,
  'rsvp': instance.rsvp,
  'readingFont': instance.readingFont,
  'readingColumn': instance.readingColumn,
  'rsvpWordsPerMinute': instance.rsvpWordsPerMinute,
  'nightShiftLevel': instance.nightShiftLevel,
  'birdName': instance.birdName,
  'savedCourseIds': instance.savedCourseIds,
  'purchasedCourses': instance.purchasedCourses,
  'balance': instance.balance,
  'courseProgress': instance.courseProgress.map(
    (key, value) => MapEntry(key, value.toJson()),
  ),
};
