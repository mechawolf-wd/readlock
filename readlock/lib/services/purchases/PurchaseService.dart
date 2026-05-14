// Purchase service.
//
// Feather top-ups (creditFeathers) delegate to StoreKitService for real
// App Store subscription purchases. Course unlocks (purchaseCourse) and
// resurrections (resurrectCourse) run server-side via Cloud Functions
// that atomically validate balance, deduct feathers, and write the
// library entry. This prevents client-side tampering of purchasedCourses
// or balance.
//
// Local notifiers update optimistically before the callable fires so
// the UI flips instantly; a server failure rolls them back.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:readlock/course_screens/services/FirebaseCourseService.dart';
import 'package:readlock/models/CourseProgressModel.dart';
import 'package:readlock/models/PurchasedCourseModel.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/services/purchases/StoreKitService.dart';

enum PurchaseResult {
  success,
  insufficientFeathers,
  alreadyOwned,
  notLoggedIn,
  cancelled,
  failed,
}

enum ResurrectResult {
  success,
  insufficientFeathers,
  notOwned,
  notExpired,
  failed,
}

class PurchaseService {
  // * Feather top-up via plan tap in the Feathers sheet.
  //
  // Delegates to StoreKitService for a real App Store subscription
  // purchase. The feather credit and Firestore write happen inside the
  // StoreKit purchase stream handler (handleSuccessfulPurchase), so this
  // method is a thin mapping from StoreKit status to PurchaseResult.

  static Future<PurchaseResult> creditFeathers(String productId) async {
    final StoreKitPurchaseStatus result = await StoreKitService.buyProduct(productId);

    switch (result) {
      case StoreKitPurchaseStatus.success: {
        return PurchaseResult.success;
      }
      case StoreKitPurchaseStatus.cancelled: {
        return PurchaseResult.cancelled;
      }
      case StoreKitPurchaseStatus.pending: {
        return PurchaseResult.success;
      }
      case StoreKitPurchaseStatus.failed: {
        return PurchaseResult.failed;
      }
      case StoreKitPurchaseStatus.storeUnavailable: {
        return PurchaseResult.failed;
      }
    }
  }

  // * Course unlock via roadmap purchase button.
  //
  // The purchaseCourse Cloud Function atomically validates balance,
  // deducts feathers, appends the library entry, seeds course progress,
  // and bumps the course's purchase counter. Client-side guards for
  // double-buy and insufficient balance are kept as fast-path rejections
  // so the UI never waits on a network call for obvious failures.
  // Optimistic notifier swap first, callable second, rollback on failure.

  static Future<PurchaseResult> purchaseCourse(String courseId) async {
    final List<PurchasedCourseModel> previousLibrary = purchasedCoursesNotifier.value;
    final bool alreadyOwned = findPurchasedEntry(previousLibrary, courseId) != null;

    if (alreadyOwned) {
      return PurchaseResult.alreadyOwned;
    }

    final int currentBalance = userBalanceNotifier.value;
    final int courseCost = PurchaseConstants.COURSE_PURCHASE_COST;
    final bool cannotAfford = currentBalance < courseCost;

    if (cannotAfford) {
      return PurchaseResult.insufficientFeathers;
    }

    // * Optimistic UI update

    final DateTime now = DateTime.now();

    final PurchasedCourseModel freshEntry = PurchasedCourseModel(
      courseId: courseId,
      expires: now.add(const Duration(days: PurchaseConstants.COURSE_RENTAL_DAYS)),
      purchasedAt: now,
    );
    final List<PurchasedCourseModel> nextLibrary = [...previousLibrary, freshEntry];

    userBalanceNotifier.value = currentBalance - courseCost;
    purchasedCoursesNotifier.value = nextLibrary;

    // * Server-side purchase (atomic transaction)

    try {
      final int serverBalance = await FirebaseCourseService.purchaseCourse(courseId);

      // Reconcile balance from server (authoritative source of truth)
      userBalanceNotifier.value = serverBalance;

      // Seed local course progress (server already wrote it to Firestore)
      final Map<String, CourseProgressModel> nextProgress = {
        ...courseProgressNotifier.value,
        courseId: CourseProgressModel(courseId: courseId),
      };

      courseProgressNotifier.value = nextProgress;

      // Surface the bookshelf-tab red dot
      bookshelfHasUnseenPurchaseNotifier.value = true;

      return PurchaseResult.success;
    } on FirebaseFunctionsException catch (error) {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = previousLibrary;

      final String errorCode = error.code;
      final String errorMessage = error.message ?? '';

      final bool isAlreadyPurchased =
          errorCode == 'failed-precondition' && errorMessage.contains('already purchased');

      if (isAlreadyPurchased) {
        return PurchaseResult.alreadyOwned;
      }

      final bool isInsufficientBalance =
          errorCode == 'failed-precondition' && errorMessage.contains('Insufficient');

      if (isInsufficientBalance) {
        return PurchaseResult.insufficientFeathers;
      }

      return PurchaseResult.failed;
    } on Exception {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = previousLibrary;

      return PurchaseResult.failed;
    }
  }

  // * Resurrect an expired course rental.
  //
  // The resurrectCourse Cloud Function atomically validates expiry,
  // deducts COURSE_RESURRECT_COST feathers, and extends the rental
  // window by COURSE_RENTAL_DAYS. Client-side guards for ownership,
  // expiry, and balance are fast-path rejections only. Optimistic
  // notifier swap, callable second, rollback on failure.

  static Future<ResurrectResult> resurrectCourse(String courseId) async {
    final List<PurchasedCourseModel> currentLibrary = purchasedCoursesNotifier.value;
    final PurchasedCourseModel? existing = findPurchasedEntry(currentLibrary, courseId);
    final bool isNotOwned = existing == null;

    if (isNotOwned) {
      return ResurrectResult.notOwned;
    }

    final DateTime now = DateTime.now();
    final bool isStillActive = existing.isActiveAt(now);

    if (isStillActive) {
      return ResurrectResult.notExpired;
    }

    final int currentBalance = userBalanceNotifier.value;
    final int resurrectCost = PurchaseConstants.COURSE_RESURRECT_COST;
    final bool cannotAfford = currentBalance < resurrectCost;

    if (cannotAfford) {
      return ResurrectResult.insufficientFeathers;
    }

    // * Optimistic UI update

    final PurchasedCourseModel revivedEntry = PurchasedCourseModel(
      courseId: courseId,
      expires: now.add(const Duration(days: PurchaseConstants.COURSE_RENTAL_DAYS)),
    );
    final List<PurchasedCourseModel> nextLibrary = currentLibrary
        .map((PurchasedCourseModel entry) {
          final bool isMatch = entry.courseId == courseId;
          return isMatch ? revivedEntry : entry;
        })
        .toList();

    userBalanceNotifier.value = currentBalance - resurrectCost;
    purchasedCoursesNotifier.value = nextLibrary;

    // * Server-side resurrect (atomic transaction)

    try {
      final int serverBalance = await FirebaseCourseService.resurrectCourse(courseId);

      // Reconcile balance from server
      userBalanceNotifier.value = serverBalance;

      return ResurrectResult.success;
    } on FirebaseFunctionsException {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = currentLibrary;

      return ResurrectResult.failed;
    } on Exception {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = currentLibrary;

      return ResurrectResult.failed;
    }
  }

  // Convenience read used by the roadmap tile-lock + button-swap logic.
  // Returns true when the user has an entry at all, regardless of whether
  // the rental window is still active. Use isCourseActive for the
  // "tiles tappable / continue button shown" check.
  static bool isCoursePurchased(String courseId) {
    return findPurchasedEntry(purchasedCoursesNotifier.value, courseId) != null;
  }

  // True when the course is owned AND the rental window has not lapsed.
  // Drives the choice between "Continue" and the resurrect affordance.
  static bool isCourseActive(String courseId) {
    final PurchasedCourseModel? entry = findPurchasedEntry(
      purchasedCoursesNotifier.value,
      courseId,
    );

    if (entry == null) {
      return false;
    }

    return entry.isActiveAt(DateTime.now());
  }

  // Linear scan over the library array for the matching courseId. The
  // library is bounded by the catalogue size (small N), so a sequential
  // walk reads cleaner than a transient lookup map at every call site.
  static PurchasedCourseModel? findPurchasedEntry(
    List<PurchasedCourseModel> library,
    String courseId,
  ) {
    for (final PurchasedCourseModel entry in library) {
      final bool isMatch = entry.courseId == courseId;

      if (isMatch) {
        return entry;
      }
    }

    return null;
  }
}
