class User {
  final String id;
  final String displayName;
  final String email;
  final DateTime registrationDate;
  final UserPreferences preferences;
  final String? latestTitleRead;
  final List<String>? savedTitles;
  final List<CourseProgress>? courseProgressList;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.registrationDate,
    required this.preferences,
    this.latestTitleRead,
    required this.savedTitles,
    this.courseProgressList,
  });
}

class UserPreferences {
  final String selectedSoundType;
  final bool hapticsEnabled;
  final bool notificationsEnabled;

  const UserPreferences({
    required this.selectedSoundType,
    required this.hapticsEnabled,
    required this.notificationsEnabled,
  });
}

class CourseProgress {
  final String courseId;
  final double progressPercentage;
  final DateTime lastAccessed;

  const CourseProgress({
    required this.courseId,
    required this.progressPercentage,
    required this.lastAccessed,
  });
}
