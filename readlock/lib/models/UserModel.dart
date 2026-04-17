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

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.language = 'en',
    this.fcmToken,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
    this.hasReaderPass = false,
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
