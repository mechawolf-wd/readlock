// Centralised online/offline tracker. Wraps connectivity_plus's stream of
// transport types (wifi, mobile, ethernet, vpn, none, ...) into a single
// boolean notifier any surface can subscribe to. Surfaces that need data
// from the network (eg. CoursesScreen, which fetches course pages from
// Firestore) listen so they can swap to an offline state instead of
// hanging on a network call that will never resolve.
//
// Treats every non-`none` result as online — including `vpn` and `bluetooth`
// — because the only state we care about is "is there a transport at all".
// Firebase / HTTP failures still get caught at the call site; this notifier
// is just the up-front "don't even try" signal.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  // True whenever the device reports at least one transport. Defaults to
  // true so cold-start UI doesn't flash an offline state before the first
  // probe resolves.
  static final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);

  static StreamSubscription<List<ConnectivityResult>>? subscription;

  // Wires the connectivity_plus stream + a one-shot probe so the notifier
  // is correct from the first frame. Safe to call more than once — the
  // existing subscription is reused.
  static Future<void> initialize() async {
    final bool isAlreadyInitialised = subscription != null;

    if (isAlreadyInitialised) {
      return;
    }

    final Connectivity connectivity = Connectivity();

    final List<ConnectivityResult> initialResults = await connectivity.checkConnectivity();
    isOnlineNotifier.value = isOnlineForResults(initialResults);

    subscription = connectivity.onConnectivityChanged.listen(handleConnectivityChange);
  }

  static void handleConnectivityChange(List<ConnectivityResult> results) {
    isOnlineNotifier.value = isOnlineForResults(results);
  }

  // Connectivity_plus reports a list of active transports. Treat the device
  // as online whenever at least one entry is something other than `none`.
  static bool isOnlineForResults(List<ConnectivityResult> results) {
    for (final ConnectivityResult result in results) {
      final bool isReachable = result != ConnectivityResult.none;

      if (isReachable) {
        return true;
      }
    }

    return false;
  }

  static Future<void> dispose() async {
    await subscription?.cancel();
    subscription = null;
  }
}
