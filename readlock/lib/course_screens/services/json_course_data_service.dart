// Service class for loading and managing course data from JSON assets
// Provides caching and structured access to course information

import 'dart:convert';
import 'package:flutter/services.dart';

const String COURSE_DATA_ASSET_PATH = 'assets/data/course_data.json';
const String COURSES_KEY = 'courses';
const String SECTIONS_KEY = 'sections';
const String CONTENT_KEY = 'content';
const String ID_KEY = 'id';
const String COURSE_DATA_LOAD_ERROR_MESSAGE =
    'Failed to load course data: ';

class JsonCourseDataService {
  static Future<Map<String, dynamic>> loadCourseData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        COURSE_DATA_ASSET_PATH,
      );
      final Map<String, dynamic> decodedData = jsonDecode(jsonString);

      return decodedData;
    } catch (exception) {
      throw Exception('$COURSE_DATA_LOAD_ERROR_MESSAGE$exception');
    }
  }

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final Map<String, dynamic> courseData = await loadCourseData();
    final List<dynamic> coursesFromData = courseData[COURSES_KEY] ?? [];

    return List<Map<String, dynamic>>.from(coursesFromData);
  }

  static Future<Map<String, dynamic>?> getCourseById(
    String courseId,
  ) async {
    final List<Map<String, dynamic>> availableCourses =
        await getCourses();

    try {
      final Map<String, dynamic> targetCourse = availableCourses
          .firstWhere((course) => course[ID_KEY] == courseId);

      return targetCourse;
    } on Exception {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getCourseSections(
    String courseId,
  ) async {
    final Map<String, dynamic>? targetCourse = await getCourseById(
      courseId,
    );
    final bool courseNotFound = targetCourse == null;

    if (courseNotFound) {
      return [];
    }

    final List<dynamic> sectionsFromCourse =
        targetCourse[SECTIONS_KEY] ?? [];

    return List<Map<String, dynamic>>.from(sectionsFromCourse);
  }

  static Future<List<Map<String, dynamic>>> getSectionContent(
    String courseId,
    String sectionId,
  ) async {
    final List<Map<String, dynamic>> availableSections =
        await getCourseSections(courseId);

    try {
      final Map<String, dynamic> targetSection = availableSections
          .firstWhere((section) => section[ID_KEY] == sectionId);
      final List<dynamic> contentFromSection =
          targetSection[CONTENT_KEY] ?? [];

      return List<Map<String, dynamic>>.from(contentFromSection);
    } on Exception {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getContentItem(
    String courseId,
    String sectionId,
    String contentId,
  ) async {
    final List<Map<String, dynamic>> availableContent =
        await getSectionContent(courseId, sectionId);

    try {
      final Map<String, dynamic> targetContentItem = availableContent
          .firstWhere(
            (contentItem) => contentItem[ID_KEY] == contentId,
          );

      return targetContentItem;
    } on Exception {
      return null;
    }
  }
}
