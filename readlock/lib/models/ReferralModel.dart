// Read model for a single referral code document.
// Populated from Firestore snapshots in ReferralService.
// redeemedByUid == null means the code is still available.

import 'package:readlock/constants/DartAliases.dart';

class ReferralModel {
  final String code;
  final bool isRedeemed;

  const ReferralModel({
    required this.code,
    required this.isRedeemed,
  });

  static ReferralModel fromFirestore(String documentId, JSONMap data) {
    final bool isRedeemed = data['redeemedByUid'] != null;

    return ReferralModel(code: documentId, isRedeemed: isRedeemed);
  }
}
