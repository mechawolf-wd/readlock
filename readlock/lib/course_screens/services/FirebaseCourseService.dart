// Firestore service for reading course data from /courses collection
// Replaces JSONCourseDataService (local asset loading)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';

class FirebaseCourseService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // * Fetch all courses from the /courses collection

  static Future<JSONList> fetchCourses() async {
    final QuerySnapshot<JSONMap> snapshot = await firestore
        .collection(FirebaseConfig.COURSES_COLLECTION)
        .get();

    return snapshot.docs.map((doc) {
      final JSONMap data = doc.data();

      data['course-id'] ??= doc.id;

      return data;
    }).toList();
  }

  // * Search courses by title prefix (case-sensitive) in Firestore.
  //
  // Used as a fallback when the locally cached list does not contain a match
  // for the query. Firestore does not support case-insensitive contains out of
  // the box, so this does a prefix range query on the `title` field.

  static Future<JSONList> searchCoursesByTitle(String titlePrefix) async {
    final String trimmed = titlePrefix.trim();
    final bool hasNoQuery = trimmed.isEmpty;

    if (hasNoQuery) {
      return [];
    }

    final String endBoundary = '$trimmed\uf8ff';

    final QuerySnapshot<JSONMap> snapshot = await firestore
        .collection(FirebaseConfig.COURSES_COLLECTION)
        .where('title', isGreaterThanOrEqualTo: trimmed)
        .where('title', isLessThan: endBoundary)
        .get();

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
    final DocumentSnapshot<JSONMap> document = await firestore
        .collection(FirebaseConfig.COURSES_COLLECTION)
        .doc(courseId)
        .get();

    final bool hasNoDocument = !document.exists;

    if (hasNoDocument) {
      return null;
    }

    final JSONMap data = document.data()!;

    data['course-id'] ??= document.id;

    return data;
  }
}
