// Resurrects an expired course rental for the calling user.
//
// Finds the courseId in the user's purchasedCourses array, verifies the
// rental has expired, deducts RESURRECT_COST feathers, and extends the
// entry's expires by COURSE_RENTAL_DAYS from now. Runs inside a
// transaction to prevent concurrent resurrect calls from both
// succeeding.
//
// Input:  { courseId: string }
// Output: { ok: true, balance: number }

import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const USERS_COLLECTION = "users";
const RESURRECT_COST = 3;
const COURSE_RENTAL_DAYS = 14;

interface ResurrectCourseData {
  courseId?: unknown;
}

interface PurchasedCourseEntry {
  courseId: string;
  expires: Timestamp;
  purchasedAt?: Timestamp;
}

// TODO: Re-enable when App Check is configured in Firebase Console.
// const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === "true";

export const resurrectCourse = onCall<ResurrectCourseData>(
  { enforceAppCheck: false, maxInstances: 50 },
  async (request) => {
    // * 1. Authentication gate

    const callerNotSignedIn = !request.auth;

    if (callerNotSignedIn) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to resurrect a course."
      );
    }

    const userId = request.auth!.uid;

    // * 2. Input validation

    const rawCourseId = request.data?.courseId;
    const courseIdInvalid =
      typeof rawCourseId !== "string" || rawCourseId.trim().length === 0;

    if (courseIdInvalid) {
      throw new HttpsError(
        "invalid-argument",
        "courseId must be a non-empty string."
      );
    }

    const courseId = (rawCourseId as string).trim();
    const firestore = getFirestore();

    // * 3. Transaction: validate expiry, deduct balance, extend rental

    const userRef = firestore.collection(USERS_COLLECTION).doc(userId);

    const newBalance = await firestore.runTransaction(async (transaction) => {
      const userSnapshot = await transaction.get(userRef);

      const userNotFound = !userSnapshot.exists;

      if (userNotFound) {
        throw new HttpsError("permission-denied", "User profile not found.");
      }

      const userData = userSnapshot.data()!;

      // Find the course in the library
      const rawPurchasedCourses = userData["purchasedCourses"] as Array<PurchasedCourseEntry> | undefined;
      const purchasedCourses = rawPurchasedCourses ?? [];
      const entryIndex = purchasedCourses.findIndex(
        (entry) => entry.courseId === courseId
      );

      const courseNotInLibrary = entryIndex === -1;

      if (courseNotInLibrary) {
        throw new HttpsError("not-found", "Course not found in library.");
      }

      // Verify the rental has expired
      const entry = purchasedCourses[entryIndex]!;
      const now = Timestamp.now();
      const rentalStillActive = entry.expires.seconds >= now.seconds;

      if (rentalStillActive) {
        throw new HttpsError(
          "failed-precondition",
          "Course rental has not expired."
        );
      }

      // Check balance
      const currentBalance = (userData["balance"] as number) ?? 0;
      const insufficientBalance = currentBalance < RESURRECT_COST;

      if (insufficientBalance) {
        throw new HttpsError(
          "failed-precondition",
          "Insufficient feather balance."
        );
      }

      // Build updated array with extended expiry
      const rentalMilliseconds = COURSE_RENTAL_DAYS * 24 * 60 * 60 * 1000;
      const expiresDate = new Date(now.toDate().getTime() + rentalMilliseconds);

      const updatedEntry: PurchasedCourseEntry = {
        ...entry,
        expires: Timestamp.fromDate(expiresDate),
      };

      const updatedPurchasedCourses = purchasedCourses.map(
        (existing, index) => index === entryIndex ? updatedEntry : existing
      );

      // Deduct balance and write updated library
      transaction.update(userRef, {
        balance: FieldValue.increment(-RESURRECT_COST),
        purchasedCourses: updatedPurchasedCourses,
      });

      return currentBalance - RESURRECT_COST;
    });

    logger.info("resurrectCourse", { userId, courseId, newBalance });

    return { ok: true, balance: newBalance };
  }
);
