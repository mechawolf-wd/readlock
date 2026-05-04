// Bumps /courses/{courseId}.timesPurchased by one.
//
// The Flutter client (FirebaseCourseService.incrementTimesPurchased)
// calls this on a successful unlock. Direct client writes to /courses
// are denied by firestore.rules, so the bump must run server-side via
// the Admin SDK. FieldValue.increment keeps concurrent purchases from
// multiple devices race-free without read-modify-write.

import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const COURSES_COLLECTION = "courses";

interface IncrementTimesPurchasedData {
  courseId?: unknown;
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
    const courseRef = getFirestore().collection(COURSES_COLLECTION).doc(courseId);
    const courseSnapshot = await courseRef.get();

    if (!courseSnapshot.exists) {
      throw new HttpsError("not-found", `Course ${courseId} does not exist.`);
    }

    await courseRef.update({ timesPurchased: FieldValue.increment(1) });

    return { ok: true };
  }
);
