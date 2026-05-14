import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/models/CourseProgressModel.dart';
import 'package:readlock/models/PurchasedCourseModel.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';

part 'UserModel.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(includeToJson: false)
  final String id;

  final String email;

  @JsonKey(defaultValue: 'en')
  final String language;

  final String? fcmToken;

  @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
  final DateTime createdAt;

  @JsonKey(defaultValue: false)
  final bool hasCompletedOnboarding;

  // * Reading preferences, persisted to Firestore.

  @JsonKey(defaultValue: false)
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

  @JsonKey(defaultValue: true)
  final bool justifiedReading;

  // * Reader-pickable enums and tunables, persisted as primitives so the
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

  // * Night Shift schedule (Apple-style daily window). Default off; when
  // enabled the auto-applier in NightShiftScheduleService flips the
  // warmth level on/off at the window edges. Stored as minutes since
  // midnight so a 19:00..06:00 window round-trips without timezone
  // baggage.
  @JsonKey(defaultValue: true)
  final bool nightShiftScheduleEnabled;

  @JsonKey(defaultValue: 1140)
  final int nightShiftScheduleFromMinutes;

  @JsonKey(defaultValue: 360)
  final int nightShiftScheduleToMinutes;

  @JsonKey(defaultValue: 'Sparrow')
  final String birdName;

  // * Most recently opened course, set whenever the reader taps a node
  // (package) on a course's roadmap. Drives the "Reading now…" card on
  // the home screen. Null until the reader taps their first node.
  final String? lastOpenedCourseId;

  // * Library entries, a flat array of {courseId, expires} records.
  // Each entry carries the rental's expiry: a fresh purchase grants
  // COURSE_RENTAL_DAYS, the resurrect flow (COURSE_RESURRECT_COST
  // feathers, only after expiry) extends it by another window. The
  // roadmap unlocks lesson tiles and the continue button when the
  // course has an entry here; expired rows surface the resurrect
  // affordance instead of the purchase button.
  //
  // The custom fromJson absorbs three shapes Firestore could hold:
  //   1. The current array of objects (target shape).
  //   2. A legacy `List<String>` of course-ids written before the
  //      expiry mechanic landed.
  //   3. A transient `Map<String, dynamic>` shape from the brief
  //      keyed-map iteration of this field.
  // Cases 2 and 3 are silently migrated into the new array; legacy
  // ids get a fresh window from the moment the doc is read so a
  // schema change never strands a reader mid-course.
  @JsonKey(fromJson: purchasedCoursesFromJson, toJson: purchasedCoursesToJson)
  final List<PurchasedCourseModel> purchasedCourses;

  // * Feather wallet, count of feathers the user owns. Spent on course
  // purchases, topped up by tier purchases in the Feathers sheet.
  // Stored as an int in Firestore. Default 0 so existing user docs
  // without the field read cleanly through the generated fromJson.
  @JsonKey(defaultValue: 0)
  final int balance;

  // * Cumulative seconds the reader has spent inside the course content
  // viewer. Each lesson commits its elapsed delta when the reader taps
  // Finish on the lesson finish screen. Default 0 so existing user docs
  // without the field read cleanly.
  @JsonKey(defaultValue: 0)
  final int timeSpentReading;

  // * Per-course reading progress, keyed by courseId. Each entry tracks
  // the last package the reader opened in that course and the set of
  // packages they've unlocked so far. Empty until the user opens their
  // first package; new entries are added as they progress.
  @JsonKey(defaultValue: <String, CourseProgressModel>{})
  final Map<String, CourseProgressModel> courseProgress;

  const UserModel({
    required this.id,
    required this.email,
    this.language = 'en',
    this.fcmToken,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
    this.typingSound = false,
    this.sounds = true,
    this.haptics = true,
    this.reveal = false,
    this.blur = true,
    this.coloredText = true,
    this.bionic = false,
    this.rsvp = false,
    this.justifiedReading = true,
    this.readingFont = 'serif',
    this.readingColumn = 'narrow',
    this.rsvpWordsPerMinute = 300,
    this.nightShiftLevel = 0,
    this.nightShiftScheduleEnabled = true,
    this.nightShiftScheduleFromMinutes = 1140,
    this.nightShiftScheduleToMinutes = 360,
    this.birdName = 'Sparrow',
    this.lastOpenedCourseId,
    this.purchasedCourses = const <PurchasedCourseModel>[],
    this.balance = 0,
    this.timeSpentReading = 0,
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  UserModel copyWith({
    String? email,
    String? language,
    String? fcmToken,
    bool? hasCompletedOnboarding,
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
    bool? nightShiftScheduleEnabled,
    int? nightShiftScheduleFromMinutes,
    int? nightShiftScheduleToMinutes,
    String? birdName,
    String? lastOpenedCourseId,
    List<PurchasedCourseModel>? purchasedCourses,
    int? balance,
    int? timeSpentReading,
    Map<String, CourseProgressModel>? courseProgress,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
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
      nightShiftScheduleEnabled:
          nightShiftScheduleEnabled ?? this.nightShiftScheduleEnabled,
      nightShiftScheduleFromMinutes:
          nightShiftScheduleFromMinutes ?? this.nightShiftScheduleFromMinutes,
      nightShiftScheduleToMinutes:
          nightShiftScheduleToMinutes ?? this.nightShiftScheduleToMinutes,
      birdName: birdName ?? this.birdName,
      lastOpenedCourseId: lastOpenedCourseId ?? this.lastOpenedCourseId,
      purchasedCourses: purchasedCourses ?? this.purchasedCourses,
      balance: balance ?? this.balance,
      timeSpentReading: timeSpentReading ?? this.timeSpentReading,
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

// purchasedCourses converters. Tolerant of three Firestore shapes:
//
//   1. List<Map>    , current shape, an array of {courseId, expires}
//                      records, parsed straight through PurchasedCourseModel.
//   2. List<String> , legacy shape from before the expiry mechanic;
//                      migrated by granting each id a fresh
//                      COURSE_RENTAL_DAYS window from now.
//   3. Map<String,_>, transient shape from the brief keyed-map
//                      iteration; the map key is folded into the new
//                      record as the courseId.
//
// Anything else (or null) collapses to an empty library so a corrupt
// or missing field never crashes the profile load.
List<PurchasedCourseModel> purchasedCoursesFromJson(dynamic value) {
  if (value is List) {
    final List<PurchasedCourseModel> entries = <PurchasedCourseModel>[];
    final DateTime migratedExpires = DateTime.now().add(
      const Duration(days: PurchaseConstants.COURSE_RENTAL_DAYS),
    );

    for (final dynamic entry in value) {
      if (entry is Map) {
        final JSONMap entryMap = JSONMap.from(entry);
        final PurchasedCourseModel parsed = PurchasedCourseModel.fromJson(entryMap);

        // Defensive, earlier shape iterations of this field could have
        // landed Map entries in a list that didn't carry courseId
        // alongside expires. PurchasedCourseModel falls back to an
        // empty courseId rather than crashing, so we filter the
        // ghost row out here. The slot reappears the next time the
        // reader buys or charges the course.
        final bool hasCourseId = parsed.courseId.isNotEmpty;

        if (hasCourseId) {
          entries.add(parsed);
        }

        continue;
      }

      if (entry is String) {
        entries.add(PurchasedCourseModel(courseId: entry, expires: migratedExpires));
      }
    }

    return entries;
  }

  if (value is Map) {
    final List<PurchasedCourseModel> entries = <PurchasedCourseModel>[];

    value.forEach((dynamic key, dynamic raw) {
      final bool isValidEntry = key is String && raw is Map && key.isNotEmpty;

      if (isValidEntry) {
        final JSONMap entryMap = JSONMap.from(raw);
        final JSONMap entryWithId = {...entryMap, 'courseId': key};

        entries.add(PurchasedCourseModel.fromJson(entryWithId));
      }
    });

    return entries;
  }

  return <PurchasedCourseModel>[];
}

List<JSONMap> purchasedCoursesToJson(List<PurchasedCourseModel> value) {
  return value.map((PurchasedCourseModel entry) => entry.toJson()).toList();
}
