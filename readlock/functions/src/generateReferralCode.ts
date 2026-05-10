// Generates a unique referral code for the calling user.
//
// Format: BIRD-XXXX where BIRD is a random bird name and XXXX is 4
// random uppercase alphanumeric characters (excluding 0/O/1/I to
// avoid visual confusion). The code string is used as the Firestore
// document ID for O(1) lookups on redemption.
//
// Enforces a 3-code lifetime cap per user. Once a user has generated
// 3 codes, subsequent calls throw resource-exhausted regardless of
// how many have been redeemed.

import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const REFERRAL_CODES_COLLECTION = "referral-codes";
const MAX_REFERRAL_CODES_PER_USER = 3;
const MAX_GENERATION_ATTEMPTS = 5;

const BIRD_PREFIXES = [
  "ROBIN", "EAGLE", "FINCH", "SWIFT", "CRANE",
  "HERON", "WREN", "LARK", "RAVEN", "DOVE", "HAWK",
];

// Excludes 0, O, 1, I to prevent visual confusion when sharing codes.
const ALPHANUMERIC_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function generateCodeString(): string {
  const prefix = BIRD_PREFIXES[Math.floor(Math.random() * BIRD_PREFIXES.length)];
  let suffix = "";

  for (let i = 0; i < 4; i++) {
    suffix += ALPHANUMERIC_CHARS[Math.floor(Math.random() * ALPHANUMERIC_CHARS.length)];
  }

  return `${prefix}-${suffix}`;
}

export const generateReferralCode = onCall(async (request) => {
  const callerNotSignedIn = !request.auth;

  if (callerNotSignedIn) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to generate a referral code."
    );
  }

  const userId = request.auth!.uid;
  const firestore =getFirestore();

  // Count codes already created by this user (lifetime, not just active).
  const existingCodesSnapshot = await firestore
    .collection(REFERRAL_CODES_COLLECTION)
    .where("creatorUid", "==", userId)
    .get();

  const hasReachedLimit = existingCodesSnapshot.size >= MAX_REFERRAL_CODES_PER_USER;

  if (hasReachedLimit) {
    throw new HttpsError(
      "resource-exhausted",
      "Referral code limit reached."
    );
  }

  // Attempt up to MAX_GENERATION_ATTEMPTS times to find an unused code.
  let attempt = 0;

  while (attempt < MAX_GENERATION_ATTEMPTS) {
    const code = generateCodeString();
    const codeDocumentRef = firestore.collection(REFERRAL_CODES_COLLECTION).doc(code);
    const existingDocument = await codeDocumentRef.get();
    const codeIsAvailable = !existingDocument.exists;

    if (codeIsAvailable) {
      await codeDocumentRef.set({
        creatorUid: userId,
        createdAt: FieldValue.serverTimestamp(),
        redeemedByUid: null,
        redeemedAt: null,
      });

      logger.info("generateReferralCode", { userId, code });

      return { code };
    }

    attempt++;
  }

  logger.error("generateReferralCode: collision loop exhausted", { userId });

  throw new HttpsError(
    "internal",
    "Failed to generate a unique code. Try again."
  );
});
