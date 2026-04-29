import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/models/CourseProgressModel.dart';

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

  @JsonKey(defaultValue: false)
  final bool justifiedReading;

  // * Reader-pickable enums and tunables — persisted as primitives so the
  // generated json_serializable round-trips without custom converters.
  // Each consumer parses its own enum from the stored name (eg.
  // readingFontFromName), with a sensible fallback for unknown values.

  @JsonKey(defaultValue: 'serif')
  final String readingFont;

  @JsonKey(defaultValue: 'narrow')
  final String readingColumn;

  @JsonKey(defaultValue: 300)
  final int rsvpWordsPerMinute;

  @JsonKey(defaultValue: 0)
  final int nightShiftLevel;

  @JsonKey(defaultValue: 'Sparrow')
  final String birdName;

  // * Bookshelf, course-ids the user has saved from search or the roadmap.
  @JsonKey(defaultValue: <String>[])
  final List<String> savedCourseIds;

  // * Course-ids the user has purchased with feathers. Roadmap unlocks
  // the lesson tiles and the continue button only when the course's id
  // is in this list; otherwise the roadmap shows a feather-priced
  // purchase button instead.
  @JsonKey(defaultValue: <String>[])
  final List<String> purchasedCourses;

  // * Feather wallet, count of feathers the user owns. Spent on course
  // purchases, topped up by tier purchases in the Feathers sheet.
  // Stored as an int in Firestore. Default 0 so existing user docs
  // without the field read cleanly through the generated fromJson.
  @JsonKey(defaultValue: 0)
  final int balance;

  // * Per-course reading progress, keyed by courseId. Each entry tracks
  // the last package the reader opened in that course and the set of
  // packages they've unlocked so far. Empty until the user opens their
  // first package; new entries are added as they progress.
  @JsonKey(defaultValue: <String, CourseProgressModel>{})
  final Map<String, CourseProgressModel> courseProgress;

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
    this.justifiedReading = false,
    this.readingFont = 'serif',
    this.readingColumn = 'narrow',
    this.rsvpWordsPerMinute = 300,
    this.nightShiftLevel = 0,
    this.birdName = 'Sparrow',
    this.savedCourseIds = const <String>[],
    this.purchasedCourses = const <String>[],
    this.balance = 0,
    this.courseProgress = const <String, CourseProgressModel>{},
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
    bool? justifiedReading,
    String? readingFont,
    String? readingColumn,
    int? rsvpWordsPerMinute,
    int? nightShiftLevel,
    String? birdName,
    List<String>? savedCourseIds,
    List<String>? purchasedCourses,
    int? balance,
    Map<String, CourseProgressModel>? courseProgress,
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
      justifiedReading: justifiedReading ?? this.justifiedReading,
      readingFont: readingFont ?? this.readingFont,
      readingColumn: readingColumn ?? this.readingColumn,
      rsvpWordsPerMinute: rsvpWordsPerMinute ?? this.rsvpWordsPerMinute,
      nightShiftLevel: nightShiftLevel ?? this.nightShiftLevel,
      birdName: birdName ?? this.birdName,
      savedCourseIds: savedCourseIds ?? this.savedCourseIds,
      purchasedCourses: purchasedCourses ?? this.purchasedCourses,
      balance: balance ?? this.balance,
      courseProgress: courseProgress ?? this.courseProgress,
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
