// Generates a unique referral code for the calling user.
//
// Format: BIRD-XXXX where BIRD is a random bird name and XXXX is 4
// random uppercase alphanumeric characters (excluding 0/O/1/I to
// avoid visual confusion). The code string is used as the Firestore
// document ID for O(1) lookups on redemption.
//
// Enforces a 3-code lifetime cap per user. The count check and
// document creation run inside a Firestore transaction so two
// concurrent calls cannot both slip under the limit.

import { randomInt } from "node:crypto";
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
  const prefixIndex = randomInt(BIRD_PREFIXES.length);
  const prefix = BIRD_PREFIXES[prefixIndex];
  let suffix = "";

  for (let characterIndex = 0; characterIndex < 4; characterIndex++) {
    const charIndex = randomInt(ALPHANUMERIC_CHARS.length);

    suffix += ALPHANUMERIC_CHARS[charIndex];
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
  const firestore = getFirestore();

  // Attempt up to MAX_GENERATION_ATTEMPTS times to find an unused code.
  // Each attempt runs a transaction that atomically checks the lifetime
  // cap and creates the document if the code string is available.
  let attempt = 0;

  while (attempt < MAX_GENERATION_ATTEMPTS) {
    const code = generateCodeString();
    const codeDocumentRef = firestore.collection(REFERRAL_CODES_COLLECTION).doc(code);

    try {
      await firestore.runTransaction(async (transaction) => {
        // * Count check: query all codes by this user inside the transaction.
        // Admin SDK transactions support transaction.get(query), which
        // locks the result set and prevents concurrent calls from both
        // reading the same count.

        const existingCodesQuery = firestore
          .collection(REFERRAL_CODES_COLLECTION)
          .where("creatorUid", "==", userId);

        const existingCodesSnapshot = await transaction.get(existingCodesQuery);

        const hasReachedLimit = existingCodesSnapshot.size >= MAX_REFERRAL_CODES_PER_USER;

        if (hasReachedLimit) {
          throw new HttpsError(
            "resource-exhausted",
            "Referral code limit reached."
          );
        }

        const existingDocument = await transaction.get(codeDocumentRef);
        const codeAlreadyTaken = existingDocument.exists;

        if (codeAlreadyTaken) {
          throw new Error("CODE_COLLISION");
        }

        transaction.set(codeDocumentRef, {
          creatorUid: userId,
          createdAt: FieldValue.serverTimestamp(),
          redeemedByUid: null,
          redeemedAt: null,
        });
      });

      // Transaction succeeded, code was created.
      logger.info("generateReferralCode", { userId, code });

      return { code };
    } catch (error) {
      const isCollision = error instanceof Error && error.message === "CODE_COLLISION";

      if (isCollision) {
        attempt++;
        continue;
      }

      // Re-throw non-collision errors (including resource-exhausted).
      throw error;
    }
  }

  logger.error("generateReferralCode: collision loop exhausted", { userId });

  throw new HttpsError(
    "internal",
    "Failed to generate a unique code. Try again."
  );
});
