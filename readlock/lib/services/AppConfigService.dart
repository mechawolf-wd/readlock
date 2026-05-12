// Fetches and caches the remote app configuration from Firestore.
//
// Call fetchConfig() on cold start (main.dart) for a guaranteed-fresh config
// before runApp, and fetchConfigIfStale() on app resume (MainNavigation) to
// pick up backend changes without hammering Firestore on every foreground.
// Falls back to AppConfig.defaults() on any fetch failure so the app never
// crashes due to a missing or unreachable config document.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/models/AppConfig.dart';

class AppConfigService {
  static AppConfig cachedConfig = AppConfig.defaults();
  static DateTime? lastFetchedAt;

  // Re-fetch if the in-memory config is older than this window.
  static const Duration cacheTtl = Duration(minutes: 30);

  static AppConfig get config => cachedConfig;

  static Future<void> fetchConfig() async {
    try {
      final DocumentReference<JSONMap> configDoc = FirebaseFirestore.instance
          .collection(FirebaseConfig.CONFIG_COLLECTION)
          .doc(FirebaseConfig.CONFIG_APP_DOCUMENT);

      final DocumentSnapshot<JSONMap> snapshot = await configDoc.get();

      final bool hasData = snapshot.exists && snapshot.data() != null;

      if (hasData) {
        cachedConfig = AppConfig.fromJson(snapshot.data()!);
      }

      lastFetchedAt = DateTime.now();
    } on Exception catch (error) {
      debugPrint('AppConfigService: fetch failed, using defaults. $error');
    }
  }

  // Skips the network round-trip when the cache is still within the TTL.
  static Future<void> fetchConfigIfStale() async {
    final bool hasFetched = lastFetchedAt != null;
    final bool isFresh =
        hasFetched && DateTime.now().difference(lastFetchedAt!) < cacheTtl;

    if (isFresh) {
      return;
    }

    await fetchConfig();
  }
}
