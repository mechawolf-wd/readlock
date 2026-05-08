// Global notifiers for the user's wallet (feather balance) and the set
// of purchased courses. Screens that need live values (Feathers sheet
// header, Bookshelf header pill, CourseRoadmapScreen tile-lock and
// continue-vs-purchase swap) subscribe via ValueListenableBuilder so
// they react instantly to PurchaseService writes without re-fetching
// the user profile from Firestore.
//
// Hydrate these notifiers from a freshly-loaded UserModel in any screen
// that fetches the profile (eg. MyBookshelfScreen.fetchSavedCourses).
// PurchaseService keeps them in sync after every write.

import 'package:flutter/foundation.dart';
import 'package:readlock/models/CourseProgressModel.dart';
import 'package:readlock/models/PurchasedCourseModel.dart';
import 'package:readlock/models/UserModel.dart';

final ValueNotifier<int> userBalanceNotifier = ValueNotifier<int>(0);

// Per-course progress, keyed by courseId. The roadmap consults this so a
// new purchase (entry with currentLessonIndex == 0) and a Finish-button
// commit (index bumped to N + 1) flip the tile-lock + active-tile state
// in the same frame the writer fires. Empty until the reader has bought
// at least one course.
final ValueNotifier<Map<String, CourseProgressModel>> courseProgressNotifier =
    ValueNotifier<Map<String, CourseProgressModel>>(
  const <String, CourseProgressModel>{},
);

// Cumulative seconds the reader has spent inside the course content viewer.
// Hydrated from /users/{id}.timeSpentReading on profile load and bumped
// optimistically by UserService.incrementTimeSpentReading on every session
// commit so the bookshelf counter reflects the latest session without a
// Firestore round-trip.
final ValueNotifier<int> timeSpentReadingNotifier = ValueNotifier<int>(0);

// Library entries — a flat array of {courseId, expires} records.
// The roadmap purchase gate, the bookshelf shelf and the home/store
// cart icons all read this list so a fresh purchase or a resurrect
// (writes a new expires) flips ownership state app-wide in the same
// frame.
final ValueNotifier<List<PurchasedCourseModel>> purchasedCoursesNotifier =
    ValueNotifier<List<PurchasedCourseModel>>(
  const <PurchasedCourseModel>[],
);

// Flips true on a successful course purchase and back to false the moment
// the reader lands on the bookshelf tab. Drives the red dot on the
// bookshelf nav icon so a fresh unlock is visibly waiting on the shelf
// without forcing the reader to remember they just bought one.
final ValueNotifier<bool> bookshelfHasUnseenPurchaseNotifier = ValueNotifier<bool>(false);

void hydratePurchaseStateFromUser(UserModel user) {
  userBalanceNotifier.value = user.balance;
  purchasedCoursesNotifier.value =
      List<PurchasedCourseModel>.from(user.purchasedCourses);
  timeSpentReadingNotifier.value = user.timeSpentReading;
  courseProgressNotifier.value = Map<String, CourseProgressModel>.from(user.courseProgress);
}

void resetPurchaseState() {
  userBalanceNotifier.value = 0;
  purchasedCoursesNotifier.value = const <PurchasedCourseModel>[];
  bookshelfHasUnseenPurchaseNotifier.value = false;
  timeSpentReadingNotifier.value = 0;
  courseProgressNotifier.value = const <String, CourseProgressModel>{};
}
