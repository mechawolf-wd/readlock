import 'package:readlock/course_screens/services/JSONCourseDataService.dart';
import 'package:readlock/constants/DartAliases.dart';

class CourseDataService {
  static Future<JSONList> fetchAvailableCourses() async {
    return await JSONCourseDataService.fetchCourses();
  }

  static Future<JSONMap?> fetchCourseById(String courseId) {
    return JSONCourseDataService.fetchCourseById(courseId);
  }

  static void clearCache() {
    // No cache to clear - data is loaded fresh each time
  }
}
