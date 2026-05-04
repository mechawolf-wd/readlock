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
  // Deducts COURSE_PURCHASE_COST feathers and appends the course id to
  // purchasedCourses. Guards against double-buy and insufficient
  // balance. Optimistic notifier swap first, then both Firestore writes;
  // a write failure rolls back the local state.

  static Future<PurchaseResult> purchaseCourse(String courseId) async {
    final bool alreadyOwned = purchasedCoursesNotifier.value.contains(courseId);

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

    final Set<String> previousPurchased = purchasedCoursesNotifier.value;

    userBalanceNotifier.value = currentBalance - courseCost;
    purchasedCoursesNotifier.value = {...previousPurchased, courseId};

    final bool balanceWrote = await UserService.incrementBalance(-courseCost);
    final bool listWrote = await UserService.addPurchasedCourse(courseId);

    final bool eitherFailed = !balanceWrote || !listWrote;

    if (eitherFailed) {
      userBalanceNotifier.value = currentBalance;
      purchasedCoursesNotifier.value = previousPurchased;

      return PurchaseResult.failed;
    }

    // Lifetime purchase counter on the course doc, fire-and-forget so a
    // slow callable write doesn't gate the user-visible success path. The
    // bump runs server-side via FieldValue.increment in the cloud function,
    // so a missed write here only loses one tally, never the wallet or
    // library mutations above.
    FirebaseCourseService.incrementTimesPurchased(courseId);

    return PurchaseResult.success;
  }

  // Convenience read used by the roadmap tile-lock + button-swap logic.
  static bool isCoursePurchased(String courseId) {
    return purchasedCoursesNotifier.value.contains(courseId);
  }
}
