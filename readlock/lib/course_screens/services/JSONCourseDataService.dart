// Simple JSON file service for course data - loads from assets
// Uses JSON file for development and testing

// ignore_for_file: prefer_single_quotes

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:readlock/constants/DartAliases.dart';

class JSONCourseDataService {
  static JSONMap? cachedData;

  static Future<JSONList> fetchCourses() async {
    // Try to load from actual JSON file first
    final bool hasNoCache = cachedData == null;

    if (hasNoCache) {
      final String jsonString = await rootBundle.loadString('assets/data/course_data.json');

      cachedData = json.decode(jsonString);
    }

    final List<dynamic> courses = cachedData!['courses'] ?? [];
    return JSONList.from(courses);
  }

  static Future<JSONMap?> fetchCourseById(String courseId) async {
    final JSONList courses = await fetchCourses();
    final JSONList matchingCourses = courses
        .where((course) => course['course-id'] == courseId)
        .toList();

    final bool hasNoMatchingCourse = matchingCourses.isEmpty;

    if (hasNoMatchingCourse) {
      return null;
    }

    return matchingCourses.first;
  }
}
