// Mock purchase service.
//
// Wallet (balance) and library (purchasedCourses) writes still go straight
// to the user document via UserService, so a brief Future.delayed in front
// of them simulates the payment round-trip. When a real payment provider
// lands, the same call signatures stay and the body swaps for an
// HttpsCallable. The lifetime purchase counter on /courses already runs
// through the incrementTimesPurchased callable, since direct client writes
// to /courses are denied by firestore.rules.
//
// Local notifiers update optimistically before the Firestore write so
// the UI flips instantly, a failed write rolls them back.

import 'package:readlock/course_screens/services/FirebaseCourseService.dart';
import 'package:readlock/models/PurchasedCourseModel.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';

enum PurchaseResult {
  success,
  insufficientFeathers,
  alreadyOwned,
  notLoggedIn,
  failed,
}

enum ResurrectResult {
  success,
  insufficientFeathers,
  notOwned,
  notExpired,
  failed,
}

// Latency that the mock pretends a real payment round-trip would take.
// Visible enough that a "purchasing..." state on the button reads, short
// enough that it doesn't feel sluggish on a fake flow.
const Duration MOCK_PAYMENT_LATENCY = Duration(milliseconds: 600);

class PurchaseService {
  // * Feather top-up via plan tap in the Feathers sheet.
  //
  // Adds `feathersGranted` to the user's balance. Always succeeds in the
  // mock. Optimistic notifier bump first, then the Firestore increment.

  static Future<PurchaseResult> creditFeathers(int feathersGranted) async {
    await Future.delayed(MOCK_PAYMENT_LATENCY);

    final int previousBalance = userBalanceNotifier.value;
    userBalanceNotifier.value = previousBalance + feathersGranted;

    final bool wrote = await UserService.incrementBalance(feathersGranted);

    if (!wrote) {
      userBalanceNotifier.value = previousBalance;
      return PurchaseResult.failed;
    }

    return PurchaseResult.success;
  }

  // * Course unlock via roadmap purchase button.
  //
  // Deducts COURSE_PURCHASE_COST feathers and writes a fresh
  // PurchasedCourseModel (expires = now + COURSE_RENTAL_DAYS) under the
  // course's slot in the user's purchasedCourses map. Guards against
  // double-buy and insufficient balance. Optimistic notifier swap first,
  // then both Firestore writes; a write failure rolls back the local
  // state.

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

    await Future.delayed(MOCK_PAYMENT_LATENCY);

    final DateTime now = DateTime.now();

    final PurchasedCourseModel freshEntry = PurchasedCourseModel(
      courseId: courseId,
      expires: now.add(const Duration(days: PurchaseConstants.COURSE_RENTAL_DAYS)),
      purchasedAt: now,
    );
    final List<PurchasedCourseModel> nextLibrary = [...previousLibrary, freshEntry];

    userBalanceNotifier.value = currentBalance - courseCost;
    purchasedCoursesNotifier.value = nextLibrary;

    final bool balanceWrote = await UserService.incrementBalance(-courseCost);
    final bool listWrote = await UserService.savePurchasedCourses(nextLibrary);

    final bool eitherFailed = !balanceWrote || !listWrote;

    if (eitherFailed) {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = previousLibrary;

      return PurchaseResult.failed;
    }

    // Seed the per-course progress record so the roadmap unlocks lesson 0
    // immediately. Fire-and-forget — a transient failure doesn't block
    // the user-visible success path, and the writer is idempotent
    // (initializeCourseProgress overwrites with a fresh seed, then the
    // first Finish-tap advances the index). The local notifier is bumped
    // synchronously inside the call so the roadmap reads the new entry
    // on its next rebuild.
    UserService.initializeCourseProgress(courseId);

    // Lifetime purchase counter on the course doc, fire-and-forget so a
    // slow callable write doesn't gate the user-visible success path. The
    // bump runs server-side via FieldValue.increment in the cloud function,
    // so a missed write here only loses one tally, never the wallet or
    // library mutations above.
    FirebaseCourseService.incrementTimesPurchased(courseId);

    // Surface the bookshelf-tab red dot until the reader actually opens the
    // bookshelf. MainNavigation clears this flag on tab activation.
    bookshelfHasUnseenPurchaseNotifier.value = true;

    return PurchaseResult.success;
  }

  // * Resurrect an expired course rental.
  //
  // Charges COURSE_RESURRECT_COST feathers and pushes the entry's
  // expires forward by COURSE_RENTAL_DAYS from now. Only allowed when
  // the course is owned and its existing expires timestamp has already
  // passed: in-window rentals can't be top-up extended (would let
  // readers stockpile time), and unowned courses must go through
  // purchaseCourse first. Optimistic notifier swap, rollback on write
  // failure — matches purchaseCourse.

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

    await Future.delayed(MOCK_PAYMENT_LATENCY);

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

    final bool balanceWrote = await UserService.incrementBalance(-resurrectCost);
    final bool entryWrote = await UserService.savePurchasedCourses(nextLibrary);

    final bool eitherFailed = !balanceWrote || !entryWrote;

    if (eitherFailed) {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = currentLibrary;

      return ResurrectResult.failed;
    }

    return ResurrectResult.success;
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
