// Bumps /courses/{courseId}.timesPurchased by one.
//
// The Flutter client (FirebaseCourseService.incrementTimesPurchased)
// calls this on a successful unlock. Direct client writes to /courses
// are denied by firestore.rules, so the bump must run server-side via
// the Admin SDK. FieldValue.increment keeps concurrent purchases from
// multiple devices race-free without read-modify-write.
//
// Purchase verification: the caller's purchasedCourses array must
// contain an entry for the given courseId, proving they actually
// purchased the course. Without this check, any authenticated user
// could inflate the counter for any course.

import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const COURSES_COLLECTION = "courses";
const USERS_COLLECTION = "users";

interface IncrementTimesPurchasedData {
  courseId?: unknown;
}

interface PurchasedCourseEntry {
  courseId: string;
}

export const incrementTimesPurchased = onCall<IncrementTimesPurchasedData>(
  async (request) => {
    const callerNotSignedIn = !request.auth;

    if (callerNotSignedIn) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to record a purchase."
      );
    }

    const userId = request.auth!.uid;

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

    // * Verify the course exists

    const courseRef = firestore.collection(COURSES_COLLECTION).doc(courseId);
    const courseSnapshot = await courseRef.get();

    const courseNotFound = !courseSnapshot.exists;

    if (courseNotFound) {
      throw new HttpsError("not-found", `Course ${courseId} does not exist.`);
    }

    // * Verify the caller actually purchased this course

    const userRef = firestore.collection(USERS_COLLECTION).doc(userId);
    const userSnapshot = await userRef.get();

    const userNotFound = !userSnapshot.exists;

    if (userNotFound) {
      throw new HttpsError("permission-denied", "User profile not found.");
    }

    const userData = userSnapshot.data()!;
    const rawPurchasedCourses = userData["purchasedCourses"] as Array<PurchasedCourseEntry> | undefined;
    const purchasedCourses = rawPurchasedCourses ?? [];
    const purchaseEntry = purchasedCourses.find(
      (entry) => entry.courseId === courseId
    );

    const hasNotPurchased = !purchaseEntry;

    if (hasNotPurchased) {
      throw new HttpsError(
        "permission-denied",
        "Cannot increment purchase count without a purchase record."
      );
    }

    // * Increment the counter

    await courseRef.update({ timesPurchased: FieldValue.increment(1) });

    return { ok: true };
  }
);
