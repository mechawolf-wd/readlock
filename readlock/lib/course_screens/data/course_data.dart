import 'package:relevant/course_screens/services/json_course_data_service.dart';

class CourseData {
  static Future<List<Map<String, dynamic>>> get availableCourses async {
    return await JsonCourseDataService.getCourses();
  }

  static Future<Map<String, dynamic>?> getCourseById(String courseId) {
    return JsonCourseDataService.getCourseById(courseId);
  }

  static void clearCache() {
    // No cache to clear - data is loaded fresh each time
  }
}
