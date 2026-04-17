// Course data facade — abstracts the data source for course loading
// Currently reads from Firestore /courses collection

import 'package:readlock/course_screens/services/FirebaseCourseService.dart';
import 'package:readlock/constants/DartAliases.dart';

class CourseDataService {
  static Future<JSONList> fetchAvailableCourses() async {
    return await FirebaseCourseService.fetchCourses();
  }

  static Future<JSONMap?> fetchCourseById(String courseId) {
    return FirebaseCourseService.fetchCourseById(courseId);
  }
}
