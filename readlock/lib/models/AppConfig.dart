// Immutable snapshot of the remote /config/app Firestore document.
// Constructed via AppConfig.defaults() for the in-process fallback values,
// or AppConfig.fromJson() once the document has been fetched.
// Missing fields in the remote document fall back to the defaults factory
// so new fields can be added to the backend incrementally without
// forcing a simultaneous client release.

import 'package:readlock/constants/DartAliases.dart';

class AppConfig {
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final String eulaUrl;
  final int bookFeatherPrice;

  // Arbitrary feature flags keyed by name. Unknown keys return null
  // so callers can safely gate on a missing flag without crashing.
  final Map<String, bool> featureFlags;

  const AppConfig({
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.eulaUrl,
    required this.bookFeatherPrice,
    required this.featureFlags,
  });

  factory AppConfig.defaults() {
    return const AppConfig(
      privacyPolicyUrl: 'https://readlock.org/privacy-policy',
      termsOfServiceUrl: 'https://readlock.org/terms-of-service',
      eulaUrl: 'https://readlock.org/eula',
      bookFeatherPrice: 10,
      featureFlags: <String, bool>{},
    );
  }

  factory AppConfig.fromJson(JSONMap data) {
    final AppConfig fallback = AppConfig.defaults();

    final Map<String, bool> parsedFlags = Map<String, bool>.from(
      data['featureFlags'] as Map? ?? <String, bool>{},
    );

    return AppConfig(
      privacyPolicyUrl: data['privacyPolicyUrl'] as String? ?? fallback.privacyPolicyUrl,
      termsOfServiceUrl: data['termsOfServiceUrl'] as String? ?? fallback.termsOfServiceUrl,
      eulaUrl: data['eulaUrl'] as String? ?? fallback.eulaUrl,
      bookFeatherPrice: data['bookFeatherPrice'] as int? ?? fallback.bookFeatherPrice,
      featureFlags: parsedFlags,
    );
  }
}
