// Referral code service. All mutations (generate, redeem) go through
// Cloud Functions so the referral-codes collection stays locked to
// direct client writes. The Firestore read (fetching the user's own
// codes) goes direct because the rules allow authenticated reads
// where creatorUid matches.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/models/ReferralModel.dart';
import 'package:readlock/services/LoggingService.dart';
import 'package:readlock/services/auth/AuthService.dart';

enum ReferralRedeemResult {
  success,
  notFound,
  selfReferral,
  error,
}

class ReferralService {
  static final ServiceLogger logger = ServiceLogger.forService('ReferralService');

  static CollectionReference<JSONMap> get referralCodesCollection {
    return FirebaseFirestore.instance.collection(
      FirebaseConfig.REFERRAL_CODES_COLLECTION,
    );
  }

  // Fetches all codes created by the current user. Returns an empty list
  // when no codes exist yet or when the user is not signed in.
  static Future<List<ReferralModel>> fetchMyCodes() async {
    final String? userId = AuthService.currentUserId;
    final bool hasNoUser = userId == null;

    if (hasNoUser) {
      logger.info('fetchMyCodes', 'No user logged in');
      return [];
    }

    try {
      final QuerySnapshot<JSONMap> snapshot = await referralCodesCollection
          .where('creatorUid', isEqualTo: userId)
          .get();

      final List<ReferralModel> codes = snapshot.docs.map((doc) {
        return ReferralModel.fromFirestore(doc.id, doc.data());
      }).toList();

      logger.success('fetchMyCodes', 'count=${codes.length}');

      return codes;
    } on Exception catch (error) {
      logger.failure('fetchMyCodes', '$error');
      return [];
    }
  }

  // Calls the generateReferralCode Cloud Function. Returns the new code
  // string on success, null on failure (limit reached or network error).
  static Future<String?> generateCode() async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        FirebaseConfig.CLOUD_FUNCTION_GENERATE_REFERRAL_CODE,
      );

      final HttpsCallableResult result = await callable.call();
      final JSONMap responseData = JSONMap.from(result.data as Map);
      final String? code = responseData['code'] as String?;

      logger.success('generateCode', 'code=$code');

      return code;
    } on FirebaseFunctionsException catch (error) {
      logger.failure('generateCode', '${error.code}: ${error.message}');
      return null;
    } on Exception catch (error) {
      logger.failure('generateCode', '$error');
      return null;
    }
  }

  // Calls the redeemReferralCode Cloud Function. Returns a typed result
  // so the caller can show the right error copy without string-matching.
  static Future<ReferralRedeemResult> redeemCode(String code) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        FirebaseConfig.CLOUD_FUNCTION_REDEEM_REFERRAL_CODE,
      );

      await callable.call({'code': code});

      logger.success('redeemCode', 'code=$code');

      return ReferralRedeemResult.success;
    } on FirebaseFunctionsException catch (error) {
      logger.failure('redeemCode', '${error.code}: ${error.message}');

      if (error.code == 'not-found') {
        return ReferralRedeemResult.notFound;
      }

      if (error.code == 'failed-precondition') {
        return ReferralRedeemResult.selfReferral;
      }

      return ReferralRedeemResult.error;
    } on Exception catch (error) {
      logger.failure('redeemCode', '$error');
      return ReferralRedeemResult.error;
    }
  }
}
