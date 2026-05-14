// Atomically purchases a course for the calling user.
//
// Reads the user's balance and purchasedCourses, validates affordability
// and non-duplicate ownership, then deducts feathers, appends the new
// library entry, initializes course progress, and bumps the course's
// timesPurchased counter. All mutations run inside a single Firestore
// transaction so no TOCTOU race can produce a free purchase or a
// double-buy.
//
// The purchase cost (bookFeatherPrice) is read from /config/app
// server-side, not from client input, so price manipulation is
// impossible.
//
// Input:  { courseId: string }
// Output: { ok: true, balance: number }

import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const COURSES_COLLECTION = "courses";
const USERS_COLLECTION = "users";
const CONFIG_COLLECTION = "config";
const CONFIG_APP_DOCUMENT = "app";
const DEFAULT_BOOK_FEATHER_PRICE = 10;
const COURSE_RENTAL_DAYS = 14;

interface PurchaseCourseData {
  courseId?: unknown;
}

interface PurchasedCourseEntry {
  courseId: string;
  expires: Timestamp;
  purchasedAt?: Timestamp;
}

// TODO: Re-enable when App Check is configured in Firebase Console.
// const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === "true";

export const purchaseCourse = onCall<PurchaseCourseData>(
  { enforceAppCheck: false, maxInstances: 50 },
  async (request) => {
    // * 1. Authentication gate

    const callerNotSignedIn = !request.auth;

    if (callerNotSignedIn) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to purchase a course."
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

    // * 3. Read server-authoritative pricing from /config/app

    const configRef = firestore.collection(CONFIG_COLLECTION).doc(CONFIG_APP_DOCUMENT);
    const configSnapshot = await configRef.get();
    const configData = configSnapshot.exists ? configSnapshot.data() : undefined;
    const purchaseCost = (configData?.["bookFeatherPrice"] as number) ?? DEFAULT_BOOK_FEATHER_PRICE;

    // * 4. Verify the course exists

    const courseRef = firestore.collection(COURSES_COLLECTION).doc(courseId);
    const courseSnapshot = await courseRef.get();

    const courseNotFound = !courseSnapshot.exists;

    if (courseNotFound) {
      throw new HttpsError("not-found", `Course ${courseId} does not exist.`);
    }

    // * 5. Transaction: validate, deduct, append, seed progress, bump counter

    const userRef = firestore.collection(USERS_COLLECTION).doc(userId);

    const newBalance = await firestore.runTransaction(async (transaction) => {
      const userSnapshot = await transaction.get(userRef);

      const userNotFound = !userSnapshot.exists;

      if (userNotFound) {
        throw new HttpsError("permission-denied", "User profile not found.");
      }

      const userData = userSnapshot.data()!;

      // Check for duplicate purchase
      const rawPurchasedCourses = userData["purchasedCourses"] as Array<PurchasedCourseEntry> | undefined;
      const purchasedCourses = rawPurchasedCourses ?? [];
      const existingEntry = purchasedCourses.find(
        (entry) => entry.courseId === courseId
      );

      const alreadyPurchased = existingEntry !== undefined;

      if (alreadyPurchased) {
        throw new HttpsError("failed-precondition", "Course already purchased.");
      }

      // Check balance
      const currentBalance = (userData["balance"] as number) ?? 0;
      const insufficientBalance = currentBalance < purchaseCost;

      if (insufficientBalance) {
        throw new HttpsError("failed-precondition", "Insufficient feather balance.");
      }

      // Build the new library entry
      const now = Timestamp.now();
      const rentalMilliseconds = COURSE_RENTAL_DAYS * 24 * 60 * 60 * 1000;
      const expiresDate = new Date(now.toDate().getTime() + rentalMilliseconds);

      const newEntry: PurchasedCourseEntry = {
        courseId,
        expires: Timestamp.fromDate(expiresDate),
        purchasedAt: now,
      };

      const updatedPurchasedCourses = [...purchasedCourses, newEntry];

      // Deduct balance, append library entry, seed course progress
      transaction.update(userRef, {
        balance: FieldValue.increment(-purchaseCost),
        purchasedCourses: updatedPurchasedCourses,
        [`courseProgress.${courseId}`]: { courseId, currentLessonIndex: 0 },
      });

      // Bump the course's lifetime purchase counter
      transaction.update(courseRef, {
        timesPurchased: FieldValue.increment(1),
      });

      return currentBalance - purchaseCost;
    });

    logger.info("purchaseCourse", { userId, courseId, newBalance });

    return { ok: true, balance: newBalance };
  }
);
