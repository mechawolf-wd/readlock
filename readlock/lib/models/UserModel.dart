import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';

part 'UserModel.g.dart';

// * Reading-speed enum persisted on the user profile.
//
// Stored as the JSON string value (careful / classic / speed) so Firestore
// documents stay human-readable. Use TextSpeedExtension.fromLabel to map the
// UI label strings (RLUIStrings.SPEED_*) back to the enum.

enum TextSpeed {
  @JsonValue('careful')
  careful,

  @JsonValue('classic')
  classic,

  @JsonValue('speed')
  speed,
}

extension TextSpeedExtension on TextSpeed {
  String get storageValue {
    switch (this) {
      case TextSpeed.careful:
        {
          return 'careful';
        }
      case TextSpeed.classic:
        {
          return 'classic';
        }
      case TextSpeed.speed:
        {
          return 'speed';
        }
    }
  }

  static TextSpeed fromStorage(String? raw) {
    switch (raw) {
      case 'careful':
        {
          return TextSpeed.careful;
        }
      case 'speed':
        {
          return TextSpeed.speed;
        }
      default:
        {
          return TextSpeed.classic;
        }
    }
  }
}

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
  final bool haptics;

  @JsonKey(defaultValue: false)
  final bool reveal;

  @JsonKey(defaultValue: true)
  final bool blur;

  @JsonKey(defaultValue: true)
  final bool coloredText;

  @JsonKey(defaultValue: TextSpeed.classic)
  final TextSpeed textSpeed;

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
    this.haptics = true,
    this.reveal = false,
    this.blur = true,
    this.coloredText = true,
    this.textSpeed = TextSpeed.classic,
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
    bool? haptics,
    bool? reveal,
    bool? blur,
    bool? coloredText,
    TextSpeed? textSpeed,
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
      haptics: haptics ?? this.haptics,
      reveal: reveal ?? this.reveal,
      blur: blur ?? this.blur,
      coloredText: coloredText ?? this.coloredText,
      textSpeed: textSpeed ?? this.textSpeed,
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
