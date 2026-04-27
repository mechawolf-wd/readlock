import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';

part 'UserModel.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(includeToJson: false)
  final String id;

  final String email;

  final String nickname;

  @JsonKey(defaultValue: 'en')
  final String language;

  final String? fcmToken;

  @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
  final DateTime createdAt;

  @JsonKey(defaultValue: false)
  final bool hasCompletedOnboarding;

  @JsonKey(defaultValue: false)
  final bool hasReaderPass;

  // * Reading preferences — persisted to Firestore.

  @JsonKey(defaultValue: true)
  final bool typingSound;

  @JsonKey(defaultValue: true)
  final bool sounds;

  @JsonKey(defaultValue: true)
  final bool haptics;

  @JsonKey(defaultValue: false)
  final bool reveal;

  @JsonKey(defaultValue: true)
  final bool blur;

  @JsonKey(defaultValue: true)
  final bool coloredText;

  @JsonKey(defaultValue: false)
  final bool bionic;

  @JsonKey(defaultValue: false)
  final bool rsvp;

  // * Bookshelf — course-ids the user has saved from search or the roadmap.
  @JsonKey(defaultValue: <String>[])
  final List<String> savedCourseIds;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.language = 'en',
    this.fcmToken,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
    this.hasReaderPass = false,
    this.typingSound = true,
    this.sounds = true,
    this.haptics = true,
    this.reveal = false,
    this.blur = true,
    this.coloredText = true,
    this.bionic = false,
    this.rsvp = false,
    this.savedCourseIds = const <String>[],
  });

  factory UserModel.fromJson(JSONMap json) => _$UserModelFromJson(json);

  JSONMap toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot<JSONMap> snapshot) {
    final JSONMap data = snapshot.data() ?? {};
    final JSONMap dataWithId = {...data, 'id': snapshot.id};

    return UserModel.fromJson(dataWithId);
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      nickname: '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  UserModel copyWith({
    String? email,
    String? nickname,
    String? language,
    String? fcmToken,
    bool? hasCompletedOnboarding,
    bool? hasReaderPass,
    bool? typingSound,
    bool? sounds,
    bool? haptics,
    bool? reveal,
    bool? blur,
    bool? coloredText,
    bool? bionic,
    bool? rsvp,
    List<String>? savedCourseIds,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasReaderPass: hasReaderPass ?? this.hasReaderPass,
      typingSound: typingSound ?? this.typingSound,
      sounds: sounds ?? this.sounds,
      haptics: haptics ?? this.haptics,
      reveal: reveal ?? this.reveal,
      blur: blur ?? this.blur,
      coloredText: coloredText ?? this.coloredText,
      bionic: bionic ?? this.bionic,
      rsvp: rsvp ?? this.rsvp,
      savedCourseIds: savedCourseIds ?? this.savedCourseIds,
    );
  }
}

// Firestore Timestamp converters for json_serializable
DateTime timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    return DateTime.parse(value);
  }

  return DateTime.now();
}

dynamic timestampToJson(DateTime value) => Timestamp.fromDate(value);
