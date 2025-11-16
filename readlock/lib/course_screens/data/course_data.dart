import 'package:relevant/course_screens/services/json_course_data_service.dart';

class CourseData {
  static Future<List<Map<String, dynamic>>> get availableCourses async {
    return await JsonCourseDataService.getCourses();
  }

  static Future<Map<String, dynamic>?> getCourseById(String courseId) {
    return JsonCourseDataService.getCourseById(courseId);
  }

  static Future<List<Map<String, dynamic>>> getCourseSections(
    String courseId,
  ) {
    return JsonCourseDataService.getCourseSections(courseId);
  }

  static Future<List<Map<String, dynamic>>> getSectionContent(
    String courseId,
    String sectionId,
  ) {
    return JsonCourseDataService.getSectionContent(courseId, sectionId);
  }

  static Future<Map<String, dynamic>?> getContentItem(
    String courseId,
    String sectionId,
    String contentId,
  ) {
    return JsonCourseDataService.getContentItem(
      courseId,
      sectionId,
      contentId,
    );
  }

  static void clearCache() {
    // No cache to clear - data is loaded fresh each time
  }
}
