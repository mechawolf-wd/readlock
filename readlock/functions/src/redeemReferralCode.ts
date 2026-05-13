// Redeems a referral code on behalf of the calling user.
//
// The entire read-validate-delete-credit flow runs inside a Firestore
// transaction so two concurrent calls cannot both succeed (the second
// caller's transaction aborts because the document was modified).
//
// Guards: authentication required, code must exist, code must not
// already be redeemed, and the caller must not be the code's creator
// (no self-referral). On success, feathers are credited to both
// parties (if the creator's account still exists).
//
// Error codes returned to the Flutter client:
//   not-found           -> code does not exist (or already redeemed)
//   failed-precondition -> caller is the code's creator (self-referral)
//   failed-precondition -> code was already redeemed

import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const REFERRAL_CODES_COLLECTION = "referral-codes";
const USERS_COLLECTION = "users";
const REDEEMER_FEATHER_REWARD = 10;
const CREATOR_FEATHER_REWARD = 20;

export const redeemReferralCode = onCall(async (request) => {
  const callerNotSignedIn = !request.auth;

  if (callerNotSignedIn) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to redeem a referral code."
    );
  }

  const rawCode = request.data?.code;
  const codeInvalid = typeof rawCode !== "string" || rawCode.trim().length === 0;

  if (codeInvalid) {
    throw new HttpsError(
      "invalid-argument",
      "code must be a non-empty string."
    );
  }

  const code = (rawCode as string).trim().toUpperCase();
  const redeemerUserId = request.auth!.uid;

  const firestore = getFirestore();
  const codeDocumentRef = firestore.collection(REFERRAL_CODES_COLLECTION).doc(code);
  const redeemerDocumentRef = firestore.collection(USERS_COLLECTION).doc(redeemerUserId);

  // * Transaction: atomic read-validate-delete-credit

  await firestore.runTransaction(async (transaction) => {
    const codeSnapshot = await transaction.get(codeDocumentRef);

    const codeNotFound = !codeSnapshot.exists;

    if (codeNotFound) {
      throw new HttpsError("not-found", "Referral code not found.");
    }

    const codeData = codeSnapshot.data()!;
    const creatorUserId = codeData.creatorUid as string;

    const alreadyRedeemed = codeData.redeemedByUid !== null;

    if (alreadyRedeemed) {
      throw new HttpsError(
        "failed-precondition",
        "Referral code has already been redeemed."
      );
    }

    const isSelfReferral = creatorUserId === redeemerUserId;

    if (isSelfReferral) {
      throw new HttpsError(
        "failed-precondition",
        "Cannot redeem your own referral code."
      );
    }

    // Mark the code as redeemed (instead of deleting, so the creator
    // can see their codes' history and the lifetime cap stays accurate).
    transaction.update(codeDocumentRef, {
      redeemedByUid: redeemerUserId,
      redeemedAt: FieldValue.serverTimestamp(),
    });

    // Credit feathers to the redeemer.
    transaction.update(redeemerDocumentRef, {
      balance: FieldValue.increment(REDEEMER_FEATHER_REWARD),
    });

    // Credit feathers to the creator only if their account still exists.
    const creatorDocumentRef = firestore.collection(USERS_COLLECTION).doc(creatorUserId);
    const creatorSnapshot = await transaction.get(creatorDocumentRef);

    const creatorExists = creatorSnapshot.exists;

    if (creatorExists) {
      transaction.update(creatorDocumentRef, {
        balance: FieldValue.increment(CREATOR_FEATHER_REWARD),
      });
    } else {
      logger.warn("redeemReferralCode: creator account no longer exists, skipping creator reward", {
        code,
        creatorUserId,
      });
    }
  });

  logger.info("redeemReferralCode", { code, redeemerUserId });

  return { ok: true };
});
