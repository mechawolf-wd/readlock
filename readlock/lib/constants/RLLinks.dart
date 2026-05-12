// Centralized external URL constants for the Readlock application.
// All outbound links: legal documents, support pages, etc.
// URLs are sourced from the remote AppConfig so they can be updated
// without a client release. Falls back to AppConfig.defaults() values
// when the fetch has not completed yet.
// Access via RLLinks.CONSTANT_NAME

import 'package:readlock/services/AppConfigService.dart';

class RLLinks {
  // * Legal documents
  static String get PRIVACY_POLICY_URL => AppConfigService.config.privacyPolicyUrl;
  static String get TERMS_OF_SERVICE_URL => AppConfigService.config.termsOfServiceUrl;
  static String get EULA_URL => AppConfigService.config.eulaUrl;
}
