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
