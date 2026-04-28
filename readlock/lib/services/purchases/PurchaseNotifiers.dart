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
import 'package:readlock/models/UserModel.dart';

final ValueNotifier<int> userBalanceNotifier = ValueNotifier<int>(0);

final ValueNotifier<Set<String>> purchasedCoursesNotifier = ValueNotifier<Set<String>>(
  const <String>{},
);

void hydratePurchaseStateFromUser(UserModel user) {
  userBalanceNotifier.value = user.balance;
  purchasedCoursesNotifier.value = Set<String>.from(user.purchasedCourses);
}

void resetPurchaseState() {
  userBalanceNotifier.value = 0;
  purchasedCoursesNotifier.value = const <String>{};
}
