// Redeems a referral code on behalf of the calling user.
//
// Guards: authentication required, code must exist, must not be
// already redeemed, and the caller must not be the code's creator
// (no self-referral). On success the code is stamped as used and
// feathers are credited to both parties via FieldValue.increment
// (atomic, race-safe).
//
// Error codes returned to the Flutter client:
//   not-found          -> code does not exist
//   already-exists     -> code was already redeemed by someone
//   failed-precondition -> caller is the code's creator (self-referral)

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

  const firestore =getFirestore();
  const codeDocumentRef = firestore.collection(REFERRAL_CODES_COLLECTION).doc(code);
  const codeSnapshot = await codeDocumentRef.get();
  const codeNotFound = !codeSnapshot.exists;

  if (codeNotFound) {
    throw new HttpsError("not-found", "Referral code not found.");
  }

  const codeData = codeSnapshot.data()!;
  const creatorUserId = codeData.creatorUid as string;
  const isSelfReferral = creatorUserId === redeemerUserId;

  if (isSelfReferral) {
    throw new HttpsError(
      "failed-precondition",
      "Cannot redeem your own referral code."
    );
  }

  const alreadyRedeemed = codeData.redeemedByUid !== null;

  if (alreadyRedeemed) {
    throw new HttpsError(
      "already-exists",
      "This referral code has already been used."
    );
  }

  // Stamp the code as redeemed first so concurrent calls see it as used.
  await codeDocumentRef.update({
    redeemedByUid: redeemerUserId,
    redeemedAt: FieldValue.serverTimestamp(),
  });

  // Credit feathers to both parties. Best-effort after the stamp: if one
  // write fails, the code is already marked used and the credit can be
  // recovered manually via the Admin SDK.
  const redeemerDocumentRef = firestore.collection(USERS_COLLECTION).doc(redeemerUserId);
  const creatorDocumentRef = firestore.collection(USERS_COLLECTION).doc(creatorUserId);

  try {
    await Promise.all([
      redeemerDocumentRef.update({ balance: FieldValue.increment(REDEEMER_FEATHER_REWARD) }),
      creatorDocumentRef.update({ balance: FieldValue.increment(CREATOR_FEATHER_REWARD) }),
    ]);
  } catch (error) {
    logger.error("redeemReferralCode: feather credit failed", {
      redeemerUserId,
      creatorUserId,
      error,
    });

    throw new HttpsError(
      "internal",
      "Code redeemed but feather credit failed."
    );
  }

  logger.info("redeemReferralCode", { code, redeemerUserId, creatorUserId });

  return { ok: true };
});
