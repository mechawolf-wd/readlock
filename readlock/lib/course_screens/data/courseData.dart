// Course data facade — abstracts the data source for course loading.
// Reads from Firestore /courses collection via FirebaseCourseService.

import 'package:readlock/course_screens/services/FirebaseCourseService.dart';
import 'package:readlock/constants/DartAliases.dart';

export 'package:readlock/course_screens/services/FirebaseCourseService.dart'
    show CoursesPage;

class CourseDataService {
  static Future<JSONList> fetchAvailableCourses() async {
    return await FirebaseCourseService.fetchCourses();
  }

  static Future<CoursesPage> fetchCoursesPage({required int pageSize, Object? cursor}) {
    return FirebaseCourseService.fetchCoursesPage(pageSize: pageSize, cursor: cursor);
  }

  static Future<JSONMap?> fetchCourseById(String courseId) {
    return FirebaseCourseService.fetchCourseById(courseId);
  }

  static Future<JSONList> searchCoursesByTitle(String titlePrefix, {int? limit}) {
    return FirebaseCourseService.searchCoursesByTitle(titlePrefix, limit: limit);
  }

  static Future<JSONList> fetchCoursesByIds(List<String> courseIds) {
    return FirebaseCourseService.fetchCoursesByIds(courseIds);
  }

  static Future<JSONList> fetchMostPurchasedCourses({required int limit}) {
    return FirebaseCourseService.fetchMostPurchasedCourses(limit: limit);
  }

  static Future<JSONList> fetchLessonContent({
    required String courseId,
    required int lessonIndex,
  }) {
    return FirebaseCourseService.fetchLessonContent(
      courseId: courseId,
      lessonIndex: lessonIndex,
    );
  }
}
