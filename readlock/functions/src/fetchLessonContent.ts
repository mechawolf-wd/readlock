// Serves a single lesson's content array from the lessons subcollection.
//
// Lesson content lives in /courses/{courseId}/lessons/{lessonId},
// keyed by compound lesson-id (e.g. "book:X;segment:0;lesson:1").
// Lockie writes content to the subcollection on publish; the Flutter
// client never reads it directly (Firestore rules deny client reads
// on the subcollection). This function is the only path to content.
//
// Steps (numbered to match inline comments in the code):
//   1. Authentication: caller must be signed in.
//   2. Input validation: courseId and lessonIndex must be well-formed.
//   3. Course existence: the courseId must resolve to a real document.
//   4. Lesson bounds: lessonIndex must be within the flat lesson list.
//   5. Free-lesson shortcut: if isFree === true, skip steps 6-9.
//   6. Read user document for purchase and progress data.
//   7. Purchase gate: purchasedCourses must contain this courseId.
//   8. Discharge gate: the purchase's expires must be in the future.
//   9. Frontier gate: lessonIndex must be <= currentLessonIndex.
//  10. Read content from the lessons subcollection and return it.
//
// Input:  { courseId: string, lessonIndex: number }
// Output: { payload: string }  (AES-256-CBC encrypted JSON)

import * as crypto from "crypto";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

// * AES-256-CBC content encryption
//
// Content is encrypted before leaving the function so it is opaque
// in transit even to proxy tools. The Flutter client holds the same
// key and decrypts on arrival. The key is derived from three seed
// strings via SHA-256 (seeds are scattered across the Flutter client
// to avoid a single grep-able constant).

const SEED_A = "rl-9762-prod";
const SEED_B = "accelerator-content-v2";
const SEED_C = "sowa-narrative-engine";

const CONTENT_ENCRYPTION_KEY = crypto
  .createHash("sha256")
  .update(SEED_A + SEED_B + SEED_C)
  .digest("hex");

const AES_ALGORITHM = "aes-256-cbc";

function encryptContent(content: JSONArray): string {
  const plaintext = JSON.stringify(content);
  const iv = crypto.randomBytes(16);
  const keyBuffer = Buffer.from(CONTENT_ENCRYPTION_KEY, "hex");
  const cipher = crypto.createCipheriv(AES_ALGORITHM, keyBuffer, iv);

  let encrypted = cipher.update(plaintext, "utf8", "hex");
  encrypted += cipher.final("hex");

  return iv.toString("hex") + ":" + encrypted;
}

const COURSES_COLLECTION = "courses";
const LESSONS_SUBCOLLECTION = "lessons";
const USERS_COLLECTION = "users";

interface FetchLessonContentData {
  courseId?: unknown;
  lessonIndex?: unknown;
}

interface PurchasedCourseEntry {
  courseId: string;
  expires: Timestamp;
}

interface CourseProgressEntry {
  courseId: string;
  currentLessonIndex: number;
}

type JSONArray = Array<Record<string, unknown>>

// Flattens segments[].lessons[] into a single ordered array, matching
// the client-side flat indexing so the lessonIndex is consistent
// across server and client.
function flattenLessons(segments: JSONArray): JSONArray {
  const lessons: JSONArray = [];

  for (const segment of segments) {
    const rawSegmentLessons = segment["lessons"] as JSONArray | undefined;
    const segmentLessons = rawSegmentLessons ?? [];
    lessons.push(...segmentLessons);
  }

  return lessons;
}

// Maps a flat lesson index to the compound lesson-id used as the
// subcollection document ID (e.g. "book:X;segment:0;lesson:1").
function resolveLessonDocId(
  courseId: string,
  segments: JSONArray,
  flatIndex: number,
): string {
  let remaining = flatIndex;

  for (let segmentIndex = 0; segmentIndex < segments.length; segmentIndex++) {
    const segment = segments[segmentIndex]!;
    const rawLessons = segment["lessons"] as JSONArray | undefined;
    const lessons = rawLessons ?? [];

    const isInThisSegment = remaining < lessons.length;

    if (isInThisSegment) {
      return `${courseId};segment:${segmentIndex};lesson:${remaining}`;
    }

    remaining -= lessons.length;
  }

  return String(flatIndex);
}

const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === "true";

export const fetchLessonContent = onCall<FetchLessonContentData>(
  { enforceAppCheck: !IS_EMULATOR, maxInstances: 100 },
  async (request) => {
    // * 1. Authentication gate

    const callerNotSignedIn = !request.auth;

    if (callerNotSignedIn) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to read lesson content."
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

    const rawLessonIndex = request.data?.lessonIndex;
    const lessonIndexInvalid =
      typeof rawLessonIndex !== "number" ||
      !Number.isInteger(rawLessonIndex) ||
      rawLessonIndex < 0;

    if (lessonIndexInvalid) {
      throw new HttpsError(
        "invalid-argument",
        "lessonIndex must be a non-negative integer."
      );
    }

    const courseId = (rawCourseId as string).trim();
    const lessonIndex = rawLessonIndex as number;

    // * 3. Read the course document (metadata only, content is in subcollection)

    const db = getFirestore();
    const courseRef = db.collection(COURSES_COLLECTION).doc(courseId);
    const courseSnapshot = await courseRef.get();

    const courseNotFound = !courseSnapshot.exists;

    if (courseNotFound) {
      throw new HttpsError("not-found", `Course ${courseId} does not exist.`);
    }

    const courseData = courseSnapshot.data()!;
    const rawSegments = courseData["segments"] as JSONArray | undefined;
    const segments = rawSegments ?? [];
    const allLessons = flattenLessons(segments);

    // * 4. Lesson bounds check

    const lessonOutOfBounds = lessonIndex >= allLessons.length;

    if (lessonOutOfBounds) {
      throw new HttpsError(
        "invalid-argument",
        `lessonIndex ${lessonIndex} is out of bounds (${allLessons.length} lessons).`
      );
    }

    const lessonMetadata = allLessons[lessonIndex];

    // * 5. Free-lesson shortcut (skip purchase/frontier gates)

    const isFreeLesson = lessonMetadata["isFree"] === true;

    if (!isFreeLesson) {
      // * 6. Read the user document for purchase and progress checks

      const userRef = db.collection(USERS_COLLECTION).doc(userId);
      const userSnapshot = await userRef.get();

      const userNotFound = !userSnapshot.exists;

      if (userNotFound) {
        throw new HttpsError(
          "permission-denied",
          "User profile not found."
        );
      }

      const userData = userSnapshot.data()!;

      // * 7. Purchase gate

      const rawPurchasedCourses = userData["purchasedCourses"] as Array<PurchasedCourseEntry> | undefined;
      const purchasedCourses = rawPurchasedCourses ?? [];
      const purchaseEntry = purchasedCourses.find(
        (entry) => entry.courseId === courseId
      );

      const hasNotPurchased = !purchaseEntry;

      if (hasNotPurchased) {
        throw new HttpsError(
          "permission-denied",
          "Course not purchased."
        );
      }

      // * 8. Discharge gate (rental expiry)

      const now = Timestamp.now();
      const expiresTimestamp = purchaseEntry!.expires;

      const rentalExpired = expiresTimestamp.seconds < now.seconds;

      if (rentalExpired) {
        throw new HttpsError(
          "permission-denied",
          "Course rental has expired."
        );
      }

      // * 9. Frontier gate

      const rawCourseProgress = userData["courseProgress"] as Record<string, CourseProgressEntry> | undefined;
      const courseProgress = rawCourseProgress ?? {};
      const progressEntry = courseProgress[courseId];
      const hasProgressEntry = progressEntry !== undefined;
      const currentFrontier = hasProgressEntry ? progressEntry.currentLessonIndex : 0;

      const beyondFrontier = lessonIndex > currentFrontier;

      if (beyondFrontier) {
        throw new HttpsError(
          "permission-denied",
          "Lesson not yet unlocked."
        );
      }
    }

    // * 10. All gates passed. Read content from the subcollection.
    //
    // Try the compound lesson-id first (new format). If the document
    // does not exist, fall back to the flat numeric index for courses
    // that have not been re-saved from Lockie yet.

    const compoundDocId = resolveLessonDocId(courseId, segments, lessonIndex);

    const subcollectionRef = db
      .collection(COURSES_COLLECTION)
      .doc(courseId)
      .collection(LESSONS_SUBCOLLECTION);

    let lessonDocument = await subcollectionRef.doc(compoundDocId).get();

    const compoundNotFound = !lessonDocument.exists;

    if (compoundNotFound) {
      lessonDocument = await subcollectionRef.doc(String(lessonIndex)).get();
    }

    const lessonNotFound = !lessonDocument.exists;

    if (lessonNotFound) {
      throw new HttpsError(
        "not-found",
        `Lesson content not found for index ${lessonIndex}.`
      );
    }

    const lessonData = lessonDocument.data()!;
    const rawContent = lessonData["content"] as JSONArray | undefined;
    const content = rawContent ?? [];

    const payload = encryptContent(content);

    return { payload };
  }
);
