import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/models/CourseProgressModel.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/services/LoggingService.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';

// Preference field names stored under /users/{id}.
// Matches UserModel.toJson so reads round-trip cleanly.
class UserPreferenceField {
  static const String TYPING_SOUND = 'typingSound';
  static const String SOUNDS = 'sounds';
  static const String HAPTICS = 'haptics';
  static const String REVEAL = 'reveal';
  static const String BLUR = 'blur';
  static const String COLORED_TEXT = 'coloredText';
  static const String BIONIC = 'bionic';
  static const String RSVP = 'rsvp';
  static const String JUSTIFIED_READING = 'justifiedReading';
  static const String READING_FONT = 'readingFont';
  static const String READING_COLUMN = 'readingColumn';
  static const String RSVP_WORDS_PER_MINUTE = 'rsvpWordsPerMinute';
  static const String NIGHT_SHIFT_LEVEL = 'nightShiftLevel';
  static const String NIGHT_SHIFT_SCHEDULE_ENABLED = 'nightShiftScheduleEnabled';
  static const String NIGHT_SHIFT_SCHEDULE_FROM_MINUTES = 'nightShiftScheduleFromMinutes';
  static const String NIGHT_SHIFT_SCHEDULE_TO_MINUTES = 'nightShiftScheduleToMinutes';
  static const String BIRD_NAME = 'birdName';
  static const String LAST_OPENED_COURSE_ID = 'lastOpenedCourseId';
  static const String PURCHASED_COURSES = 'purchasedCourses';
  static const String BALANCE = 'balance';
  static const String TIME_SPENT_READING = 'timeSpentReading';
  static const String COURSE_PROGRESS = 'courseProgress';
}

// * Starter feather balance credited to every new user document on
// registration so first-time readers can buy their first coursebook
// (10 feathers each) without topping up.
const int NEW_USER_STARTING_BALANCE = 10;

// * Seeded reading time credited on profile creation. Roughly how long it
// takes to walk the 7-step onboarding (bird, font, column, reveal, blur,
// colored text, bionic) at a casual pace, so the bookshelf stopwatch and
// the bird-unlock economy already reflect the work the reader has done
// to get this far. 3:30 ~= 210 seconds.
const int NEW_USER_STARTING_TIME_SPENT_READING_SECONDS = 3 * 60 + 30;

class UserService {
  static final ServiceLogger logger = ServiceLogger.forService('UserService');

  // * Collection / document helpers

  static CollectionReference<JSONMap> get usersCollection {
    return FirebaseFirestore.instance.collection(FirebaseConfig.USERS_COLLECTION);
  }

  static DocumentReference<JSONMap> userDoc(String userId) {
    return usersCollection.doc(userId);
  }

  // * Fetch current user profile

  static Future<UserModel?> getCurrentUserProfile() async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('getCurrentUserProfile', 'No user logged in');
      return null;
    }

    return getUserProfileById(userId);
  }

  static Future<UserModel?> getUserProfileById(String userId) async {
    try {
      const GetOptions serverOptions = GetOptions(source: Source.server);

      final DocumentSnapshot<JSONMap> snapshot = await userDoc(userId).get(serverOptions);

      final bool profileMissing = !snapshot.exists;

      if (profileMissing) {
        logger.info('getUserProfileById', 'Profile not found for userId=$userId');
        return null;
      }

      final UserModel user = UserModel.fromFirestore(snapshot);

      logger.success('getUserProfileById', 'userId=$userId');

      return user;
    } on Exception catch (error) {
      logger.failure('getUserProfileById', '$error');
      return null;
    }
  }

  // * Stream current user profile

  static Stream<UserModel?> getCurrentUserProfileStream() {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      return Stream.value(null);
    }

    return userDoc(userId).snapshots().map((snapshot) {
      final bool profileMissing = !snapshot.exists;

      if (profileMissing) {
        return null;
      }

      return UserModel.fromFirestore(snapshot);
    });
  }

  // * Profile existence check

  static Future<bool> userProfileExists(String userId) async {
    final DocumentSnapshot<JSONMap> snapshot = await userDoc(userId).get();

    return snapshot.exists;
  }

  // * Create new user document

  static Future<bool> createUser({
    required String userId,
    required String email,
    String language = 'en',
  }) async {
    try {
      final JSONMap profileData = {
        'email': email,
        'language': language,
        'hasCompletedOnboarding': false,
        'hasReaderPass': false,
        'createdAt': FieldValue.serverTimestamp(),
        // Preference defaults — mirror UserModel constructor defaults.
        UserPreferenceField.TYPING_SOUND: true,
        UserPreferenceField.SOUNDS: true,
        UserPreferenceField.HAPTICS: true,
        UserPreferenceField.REVEAL: false,
        UserPreferenceField.BLUR: true,
        UserPreferenceField.COLORED_TEXT: true,
        UserPreferenceField.BIONIC: false,
        UserPreferenceField.RSVP: false,
        UserPreferenceField.JUSTIFIED_READING: true,
        UserPreferenceField.READING_FONT: 'serif',
        UserPreferenceField.READING_COLUMN: 'narrow',
        UserPreferenceField.RSVP_WORDS_PER_MINUTE: 300,
        UserPreferenceField.NIGHT_SHIFT_LEVEL: 0,
        UserPreferenceField.NIGHT_SHIFT_SCHEDULE_ENABLED: true,
        UserPreferenceField.NIGHT_SHIFT_SCHEDULE_FROM_MINUTES: 1140,
        UserPreferenceField.NIGHT_SHIFT_SCHEDULE_TO_MINUTES: 360,
        UserPreferenceField.BIRD_NAME: 'Sparrow',
        UserPreferenceField.LAST_OPENED_COURSE_ID: null,
        UserPreferenceField.PURCHASED_COURSES: <String>[],
        UserPreferenceField.BALANCE: NEW_USER_STARTING_BALANCE,
        UserPreferenceField.TIME_SPENT_READING: NEW_USER_STARTING_TIME_SPENT_READING_SECONDS,
      };

      await userDoc(userId).set(profileData);

      logger.success('createUser', 'userId=$userId');

      return true;
    } on Exception catch (error) {
      logger.failure('createUser', '$error');
      return false;
    }
  }

  // * Preference updates — one field per call, cheap and round-trippable.

  static Future<bool> updateTypingSound(bool enabled) {
    return updateField(UserPreferenceField.TYPING_SOUND, enabled, 'updateTypingSound');
  }

  static Future<bool> updateSounds(bool enabled) {
    return updateField(UserPreferenceField.SOUNDS, enabled, 'updateSounds');
  }

  static Future<bool> updateHaptics(bool enabled) {
    return updateField(UserPreferenceField.HAPTICS, enabled, 'updateHaptics');
  }

  static Future<bool> updateReveal(bool enabled) {
    return updateField(UserPreferenceField.REVEAL, enabled, 'updateReveal');
  }

  static Future<bool> updateBlur(bool enabled) {
    return updateField(UserPreferenceField.BLUR, enabled, 'updateBlur');
  }

  static Future<bool> updateColoredText(bool enabled) {
    return updateField(UserPreferenceField.COLORED_TEXT, enabled, 'updateColoredText');
  }

  static Future<bool> updateBionic(bool enabled) {
    return updateField(UserPreferenceField.BIONIC, enabled, 'updateBionic');
  }

  static Future<bool> updateRsvp(bool enabled) {
    return updateField(UserPreferenceField.RSVP, enabled, 'updateRsvp');
  }

  static Future<bool> updateJustifiedReading(bool enabled) {
    return updateField(
      UserPreferenceField.JUSTIFIED_READING,
      enabled,
      'updateJustifiedReading',
    );
  }

  static Future<bool> updateReadingFont(String fontName) {
    return updateField(UserPreferenceField.READING_FONT, fontName, 'updateReadingFont');
  }

  static Future<bool> updateReadingColumn(String columnName) {
    return updateField(UserPreferenceField.READING_COLUMN, columnName, 'updateReadingColumn');
  }

  static Future<bool> updateRsvpWordsPerMinute(int wpm) {
    return updateField(
      UserPreferenceField.RSVP_WORDS_PER_MINUTE,
      wpm,
      'updateRsvpWordsPerMinute',
    );
  }

  static Future<bool> updateNightShiftLevel(int level) {
    return updateField(
      UserPreferenceField.NIGHT_SHIFT_LEVEL,
      level,
      'updateNightShiftLevel',
    );
  }

  static Future<bool> updateNightShiftScheduleEnabled(bool enabled) {
    return updateField(
      UserPreferenceField.NIGHT_SHIFT_SCHEDULE_ENABLED,
      enabled,
      'updateNightShiftScheduleEnabled',
    );
  }

  static Future<bool> updateNightShiftScheduleFromMinutes(int minutes) {
    return updateField(
      UserPreferenceField.NIGHT_SHIFT_SCHEDULE_FROM_MINUTES,
      minutes,
      'updateNightShiftScheduleFromMinutes',
    );
  }

  static Future<bool> updateNightShiftScheduleToMinutes(int minutes) {
    return updateField(
      UserPreferenceField.NIGHT_SHIFT_SCHEDULE_TO_MINUTES,
      minutes,
      'updateNightShiftScheduleToMinutes',
    );
  }

  static Future<bool> updateBirdName(String birdName) {
    return updateField(UserPreferenceField.BIRD_NAME, birdName, 'updateBirdName');
  }

  // * Field updates

  static Future<bool> updateLanguage(String language) async {
    return updateField('language', language, 'updateLanguage');
  }

  static Future<bool> markOnboardingComplete() async {
    return updateField('hasCompletedOnboarding', true, 'markOnboardingComplete');
  }

  static Future<bool> updateReaderPass(bool hasReaderPass) async {
    return updateField('hasReaderPass', hasReaderPass, 'updateReaderPass');
  }

  // * Latest opened course — set every time the reader taps a roadmap
  // node. Drives the home screen's "Reading now…" card.
  static Future<bool> updateLastOpenedCourseId(String courseId) {
    return updateField(
      UserPreferenceField.LAST_OPENED_COURSE_ID,
      courseId,
      'updateLastOpenedCourseId',
    );
  }

  // * Feather wallet (balance) and course purchases.
  //
  // Both writes are atomic Firestore operations: balance uses
  // FieldValue.increment so concurrent ticks add up cleanly, and
  // purchasedCourses uses arrayUnion so re-running a purchase is
  // idempotent. Callers (PurchaseService) should still update the
  // local notifiers optimistically for instant UI feedback.

  static Future<bool> incrementBalance(int delta) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('incrementBalance', 'No user logged in');
      return false;
    }

    try {
      await userDoc(userId).update({
        UserPreferenceField.BALANCE: FieldValue.increment(delta),
      });

      logger.success('incrementBalance', 'delta=$delta');

      return true;
    } on Exception catch (error) {
      logger.failure('incrementBalance', '$error');
      return false;
    }
  }

  // Atomic FieldValue.increment write for the cumulative reading-time
  // counter. Called when the reader taps Finish on the lesson finish
  // screen with the elapsed seconds spent inside that lesson, so the
  // counter accumulates across sessions without requiring a read-modify-
  // write round-trip.
  static Future<bool> incrementTimeSpentReading(int seconds) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('incrementTimeSpentReading', 'No user logged in');
      return false;
    }

    // Optimistic bump so subscribers (the bookshelf reading-time counter)
    // see the new total the moment a session ends, without waiting for the
    // Firestore round-trip below.
    timeSpentReadingNotifier.value = timeSpentReadingNotifier.value + seconds;

    try {
      await userDoc(userId).update({
        UserPreferenceField.TIME_SPENT_READING: FieldValue.increment(seconds),
      });

      logger.success('incrementTimeSpentReading', 'seconds=$seconds');

      return true;
    } on Exception catch (error) {
      logger.failure('incrementTimeSpentReading', '$error');
      return false;
    }
  }

  // * Course progress writers.
  //
  // Both writers mutate the courseProgress map's per-course entry via a
  // dotted-path Firestore update (`courseProgress.{courseId}`) so a single
  // round-trip touches one course's record without overwriting siblings.
  // The local courseProgressNotifier is updated optimistically first, so
  // the roadmap (and any other listener) sees the new state in the same
  // frame the writer fires; a Firestore failure is logged but not rolled
  // back since the user can retry the action and the field is monotonic.

  // Seeds a fresh CourseProgressModel for a course the reader has just
  // bought. currentLessonIndex starts at 0 (lesson 0 tappable, rest
  // locked); subsequent advances ride the Finish button.
  static Future<bool> initializeCourseProgress(String courseId) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('initializeCourseProgress', 'No user logged in');
      return false;
    }

    final CourseProgressModel seed = CourseProgressModel(courseId: courseId);
    final Map<String, CourseProgressModel> nextProgress = {
      ...courseProgressNotifier.value,
      courseId: seed,
    };

    courseProgressNotifier.value = nextProgress;

    try {
      await userDoc(userId).update({
        '${UserPreferenceField.COURSE_PROGRESS}.$courseId': seed.toJson(),
      });

      logger.success('initializeCourseProgress', 'courseId=$courseId');

      return true;
    } on Exception catch (error) {
      logger.failure('initializeCourseProgress', '$error');
      return false;
    }
  }

  // Bumps `currentLessonIndex` if the supplied next-frontier value beats
  // what's already stored. The max() guard makes the writer idempotent
  // and monotonic — finishing an old lesson can't roll the frontier
  // backwards, so the call site doesn't have to check first.
  static Future<bool> advanceCourseProgress({
    required String courseId,
    required int nextLessonIndex,
  }) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('advanceCourseProgress', 'No user logged in');
      return false;
    }

    final Map<String, CourseProgressModel> currentProgress =
        courseProgressNotifier.value;
    final CourseProgressModel? existing = currentProgress[courseId];
    final CourseProgressModel base =
        existing ?? CourseProgressModel(courseId: courseId);

    final bool isAlreadyAhead = base.currentLessonIndex >= nextLessonIndex;

    if (isAlreadyAhead) {
      return true;
    }

    final CourseProgressModel updated =
        base.copyWith(currentLessonIndex: nextLessonIndex);
    final Map<String, CourseProgressModel> nextProgress = {
      ...currentProgress,
      courseId: updated,
    };

    courseProgressNotifier.value = nextProgress;

    try {
      await userDoc(userId).update({
        '${UserPreferenceField.COURSE_PROGRESS}.$courseId': updated.toJson(),
      });

      logger.success('advanceCourseProgress', 'courseId=$courseId index=$nextLessonIndex');

      return true;
    } on Exception catch (error) {
      logger.failure('advanceCourseProgress', '$error');
      return false;
    }
  }

  static Future<bool> addPurchasedCourse(String courseId) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('addPurchasedCourse', 'No user logged in');
      return false;
    }

    try {
      await userDoc(userId).update({
        UserPreferenceField.PURCHASED_COURSES: FieldValue.arrayUnion([courseId]),
      });

      logger.success('addPurchasedCourse', 'courseId=$courseId');

      return true;
    } on Exception catch (error) {
      logger.failure('addPurchasedCourse', '$error');
      return false;
    }
  }

  // * FCM token management

  static Future<bool> updateFcmToken(String token) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('updateFcmToken', 'No user logged in');
      return false;
    }

    try {
      await userDoc(userId).set({'fcmToken': token}, SetOptions(merge: true));

      logger.success('updateFcmToken');

      return true;
    } on Exception catch (error) {
      logger.failure('updateFcmToken', '$error');
      return false;
    }
  }

  static Future<bool> clearFcmToken() async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('clearFcmToken', 'No user logged in');
      return false;
    }

    try {
      await userDoc(userId).update({'fcmToken': FieldValue.delete()});

      logger.success('clearFcmToken');

      return true;
    } on Exception catch (error) {
      logger.failure('clearFcmToken', '$error');
      return false;
    }
  }

  // * Generic field update helper

  static Future<bool> updateField(String field, dynamic value, String operationLabel) async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info(operationLabel, 'No user logged in');
      return false;
    }

    try {
      await userDoc(userId).update({field: value});

      logger.success(operationLabel);

      return true;
    } on Exception catch (error) {
      logger.failure(operationLabel, '$error');
      return false;
    }
  }
}
