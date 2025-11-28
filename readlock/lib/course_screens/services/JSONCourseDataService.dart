// Simple JSON file service for course data - loads from assets
// Uses JSON file for development and testing

// ignore_for_file: prefer_single_quotes

import 'dart:convert';
import 'package:flutter/services.dart';

class JSONCourseDataService {
  static Map<String, dynamic>? cachedData;

  static Future<List<Map<String, dynamic>>> getCourses() async {
    // Try to load from actual JSON file first
    if (cachedData == null) {
      final String jsonString = await rootBundle.loadString(
        'assets/data/course_data.json',
      );

      cachedData = json.decode(jsonString);
    }

    final List<dynamic> courses = cachedData!['courses'] ?? [];
    return List<Map<String, dynamic>>.from(courses);
  }

  static Future<Map<String, dynamic>?> getCourseById(
    String courseId,
  ) async {
    final List<Map<String, dynamic>> courses = await getCourses();
    final List<Map<String, dynamic>> matchingCourses = courses
        .where((course) => course['course-id'] == courseId)
        .toList();

    return matchingCourses.isEmpty ? null : matchingCourses.first;
  }
}
