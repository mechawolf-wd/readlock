// Firestore service for reading course data from /courses collection

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';

// Paginated page of courses. `cursor` is opaque to callers, pass it back
// as-is to fetchCoursesPage to get the next page.
class CoursesPage {
  final JSONList courses;
  final Object? cursor;
  final bool hasMore;

  const CoursesPage({
    required this.courses,
    required this.cursor,
    required this.hasMore,
  });
}

class FirebaseCourseService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // * Fetch all courses from the /courses collection
  //
  // Course documents only hold metadata (titles, segment structure,
  // isFree flags). Lesson content lives in a denied subcollection
  // (/courses/{id}/lessons/{index}) and is served by the
  // fetchLessonContent Cloud Function.

  static Future<JSONList> fetchCourses() async {
    final QuerySnapshot<JSONMap> snapshot =
        await firestore.collection(FirebaseConfig.COURSES_COLLECTION).get();

    return snapshot.docs.map((doc) {
      final JSONMap data = doc.data();

      data['course-id'] ??= doc.id;

      return data;
    }).toList();
  }

  // * Fetch a single page of courses.
  //
  // Pass `cursor` from a previous CoursesPage to fetch the next page. The
  // cursor is an opaque Firestore QueryDocumentSnapshot under the hood;
  // callers should treat it as unknown and only pass it back in.

  static Future<CoursesPage> fetchCoursesPage({
    required int pageSize,
    Object? cursor,
  }) async {
    Query<JSONMap> query =
        firestore.collection(FirebaseConfig.COURSES_COLLECTION).limit(pageSize);

    final bool hasCursor = cursor is QueryDocumentSnapshot<JSONMap>;

    if (hasCursor) {
      query = query.startAfterDocument(cursor);
    }

    final QuerySnapshot<JSONMap> snapshot = await query.get();

    final JSONList courses = snapshot.docs.map((doc) {
      final JSONMap data = doc.data();

      data['course-id'] ??= doc.id;

      return data;
    }).toList();

    final bool hasNoDocs = snapshot.docs.isEmpty;
    final QueryDocumentSnapshot<JSONMap>? nextCursor = hasNoDocs ? null : snapshot.docs.last;
    final bool hasMore = snapshot.docs.length == pageSize;

    return CoursesPage(courses: courses, cursor: nextCursor, hasMore: hasMore);
  }

  // * Search courses by title prefix (case-sensitive) in Firestore.
  //
  // Used as a fallback when the locally cached list does not contain a match
  // for the query. Firestore does not support case-insensitive contains out of
  // the box, so this does a prefix range query on the `title` field.

  static Future<JSONList> searchCoursesByTitle(String titlePrefix, {int? limit}) async {
    final String trimmed = titlePrefix.trim();
    final bool hasNoQuery = trimmed.isEmpty;

    if (hasNoQuery) {
      return [];
    }

    final String endBoundary = '$trimmed\uf8ff';

    Query<JSONMap> query = firestore
        .collection(FirebaseConfig.COURSES_COLLECTION)
        .where('title', isGreaterThanOrEqualTo: trimmed)
        .where('title', isLessThan: endBoundary);

    final bool hasLimit = limit != null;

    if (hasLimit) {
      query = query.limit(limit);
    }

    final QuerySnapshot<JSONMap> snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final JSONMap data = doc.data();

      data['course-id'] ??= doc.id;

      return data;
    }).toList();
  }

  // * Fetch courses by a list of course-ids (used for Bookshelf).

  static Future<JSONList> fetchCoursesByIds(List<String> courseIds) async {
    final bool hasNoIds = courseIds.isEmpty;

    if (hasNoIds) {
      return [];
    }

    // Firestore `whereIn` is capped at 30 items per query. Chunk the IDs so
    // bookshelves larger than 30 still resolve in a handful of round-trips.
    const int whereInChunkSize = 30;

    final JSONList fetchedCourses = [];

    for (int chunkStart = 0; chunkStart < courseIds.length; chunkStart += whereInChunkSize) {
      final int chunkEnd = (chunkStart + whereInChunkSize).clamp(0, courseIds.length);
      final List<String> idsChunk = courseIds.sublist(chunkStart, chunkEnd);

      final QuerySnapshot<JSONMap> snapshot = await firestore
          .collection(FirebaseConfig.COURSES_COLLECTION)
          .where(FieldPath.documentId, whereIn: idsChunk)
          .get();

      for (final doc in snapshot.docs) {
        final JSONMap data = doc.data();

        data['course-id'] ??= doc.id;

        fetchedCourses.add(data);
      }
    }

    return fetchedCourses;
  }

  // * Fetch a single course by its course ID

  static Future<JSONMap?> fetchCourseById(String courseId) async {
    final DocumentSnapshot<JSONMap> document =
        await firestore.collection(FirebaseConfig.COURSES_COLLECTION).doc(courseId).get();

    final bool hasNoDocument = !document.exists;

    if (hasNoDocument) {
      return null;
    }

    final JSONMap data = document.data()!;

    data['course-id'] ??= document.id;

    return data;
  }

  // * Top-N courses ranked by lifetime purchase count.
  //
  // Used by the home screen's "How about these?" row. Firestore's orderBy
  // skips documents where the field is missing, so courses that have
  // never had timesPurchased seeded (legacy docs that pre-date the field)
  // won't appear here until they're re-saved through Lockie.

  static Future<JSONList> fetchMostPurchasedCourses({required int limit}) async {
    final QuerySnapshot<JSONMap> snapshot = await firestore
        .collection(FirebaseConfig.COURSES_COLLECTION)
        .orderBy('timesPurchased', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final JSONMap data = doc.data();

      data['course-id'] ??= doc.id;

      return data;
    }).toList();
  }

  // * Bumps a course's lifetime purchase counter by one.
  //
  // Called by PurchaseService.purchaseCourse on a successful unlock so the
  // /courses doc tracks how many readers have bought it. Direct client
  // writes to /courses are blocked by firestore.rules, so the bump goes
  // through a callable cloud function that runs the FieldValue.increment
  // server-side via the Admin SDK.

  static Future<void> incrementTimesPurchased(String courseId) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      FirebaseConfig.CLOUD_FUNCTION_INCREMENT_TIMES_PURCHASED,
    );

    await callable.call({'courseId': courseId});
  }

  // * Fetches a single lesson's content array via the fetchLessonContent
  // Cloud Function. The function enforces auth, purchase, frontier, and
  // discharge gates server-side, so the raw content never travels to the
  // client unless the reader is allowed to view it.

  static Future<JSONList> fetchLessonContent({
    required String courseId,
    required int lessonIndex,
  }) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      FirebaseConfig.CLOUD_FUNCTION_FETCH_LESSON_CONTENT,
    );

    final HttpsCallableResult result = await callable.call({
      'courseId': courseId,
      'lessonIndex': lessonIndex,
    });

    final JSONMap data = JSONMap.from(result.data as Map);
    final List<dynamic> rawContent = data['content'] as List;
    final JSONList content = rawContent
        .map((item) => JSONMap.from(item as Map))
        .toList();

    return content;
  }
}
