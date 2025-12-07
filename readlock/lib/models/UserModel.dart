class User {
  final String id;
  final String displayName;
  final String email;
  final DateTime registrationDate;
  final UserPreferences preferences;
  final UserProgress progress;
  final List<Achievement> achievements;
  final UserStats stats;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.registrationDate,
    required this.preferences,
    required this.progress,
    required this.achievements,
    required this.stats,
  });
}

class UserPreferences {
  final String selectedSoundType;
  final bool hapticsEnabled;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final int dailyReadingGoalMinutes;

  const UserPreferences({
    required this.selectedSoundType,
    required this.hapticsEnabled,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.dailyReadingGoalMinutes,
  });
}

class UserProgress {
  final int totalReadingTimeMinutes;
  final int lessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final int totalXP;
  final String currentLeagueRank;
  final List<String> completedCourseIds;
  final Map<String, CourseProgress> courseProgress;

  const UserProgress({
    required this.totalReadingTimeMinutes,
    required this.lessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXP,
    required this.currentLeagueRank,
    required this.completedCourseIds,
    required this.courseProgress,
  });
}

class CourseProgress {
  final String courseId;
  final int completedLessons;
  final int totalLessons;
  final DateTime lastAccessedDate;
  final Map<String, LessonProgress> lessonProgress;

  const CourseProgress({
    required this.courseId,
    required this.completedLessons,
    required this.totalLessons,
    required this.lastAccessedDate,
    required this.lessonProgress,
  });

  double get completionPercentage => completedLessons / totalLessons;
}

class LessonProgress {
  final String lessonId;
  final bool isCompleted;
  final DateTime? completionDate;
  final int timeSpentMinutes;
  final Map<String, bool> contentCompletionStatus;

  const LessonProgress({
    required this.lessonId,
    required this.isCompleted,
    this.completionDate,
    required this.timeSpentMinutes,
    required this.contentCompletionStatus,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int xpReward;
  final bool isEarned;
  final DateTime? earnedDate;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.isEarned,
    this.earnedDate,
  });
}

enum AchievementType { streak, reading, quiz, speed, insight, course }

class UserStats {
  final int totalBooksRead;
  final int totalHoursSpent;
  final int totalInsights;
  final Map<String, int> categoryReadingTime;

  const UserStats({
    required this.totalBooksRead,
    required this.totalHoursSpent,
    required this.totalInsights,
    required this.categoryReadingTime,
  });
}
