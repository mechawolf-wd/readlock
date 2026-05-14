// Firebase configuration and Firestore collection paths
// Centralised constants per CLAUDE.md rule @39

import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  // * Firebase options for the web platform

  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: 'AIzaSyAcKL7UCkGiWASDXBs080RjcVt8pPQfc5k',
    authDomain: 'readlock-production.firebaseapp.com',
    projectId: 'readlock-production',
    storageBucket: 'readlock-production.firebasestorage.app',
    messagingSenderId: '976267746377',
    appId: '1:976267746377:web:8bd98125ac35c3cd507398',
  );

  // * Firestore collection paths

  static const String COURSES_COLLECTION = 'courses';
  static const String USERS_COLLECTION = 'users';
  static const String CONFIG_COLLECTION = 'config';
  static const String CONFIG_APP_DOCUMENT = 'app';

  // * Cloud Function names

  static const String CLOUD_FUNCTION_DELETE_ACCOUNT = 'deleteAccount';
  static const String CLOUD_FUNCTION_INCREMENT_TIMES_PURCHASED = 'incrementTimesPurchased';
  static const String CLOUD_FUNCTION_GENERATE_REFERRAL_CODE = 'generateReferralCode';
  static const String CLOUD_FUNCTION_REDEEM_REFERRAL_CODE = 'redeemReferralCode';
  static const String CLOUD_FUNCTION_FETCH_LESSON_CONTENT = 'fetchLessonContent';
  static const String CLOUD_FUNCTION_PURCHASE_COURSE = 'purchaseCourse';
  static const String CLOUD_FUNCTION_RESURRECT_COURSE = 'resurrectCourse';

  // * Referral codes collection

  static const String REFERRAL_CODES_COLLECTION = 'referral-codes';

  // * Platform signature (used for content integrity checks)

  static const String PLATFORM_SIGNATURE = 'rl-9762-prod';
}
