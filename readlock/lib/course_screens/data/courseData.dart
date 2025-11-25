import 'package:readlock/course_screens/services/JSONCourseDataService.dart';

class CourseData {
  static Future<List<Map<String, dynamic>>> get availableCourses async {
    return await JSONCourseDataService.getCourses();
  }

  static Future<Map<String, dynamic>?> getCourseById(String courseId) {
    return JSONCourseDataService.getCourseById(courseId);
  }

  static void clearCache() {
    // No cache to clear - data is loaded fresh each time
  }
}
