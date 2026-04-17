import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/services/LoggingService.dart';
import 'package:readlock/services/auth/AuthService.dart';

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
    required String nickname,
    String language = 'en',
  }) async {
    try {
      final JSONMap profileData = {
        'email': email,
        'nickname': nickname,
        'language': language,
        'hasCompletedOnboarding': false,
        'hasReaderPass': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userDoc(userId).set(profileData);

      logger.success('createUser', 'userId=$userId');

      return true;
    } on Exception catch (error) {
      logger.failure('createUser', '$error');
      return false;
    }
  }

  // * Field updates

  static Future<bool> updateNickname(String nickname) async {
    return updateField('nickname', nickname, 'updateNickname');
  }

  static Future<bool> updateLanguage(String language) async {
    return updateField('language', language, 'updateLanguage');
  }

  static Future<bool> markOnboardingComplete() async {
    return updateField('hasCompletedOnboarding', true, 'markOnboardingComplete');
  }

  static Future<bool> updateReaderPass(bool hasReaderPass) async {
    return updateField('hasReaderPass', hasReaderPass, 'updateReaderPass');
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
