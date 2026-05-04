// LoggingService - Centralized logging utilities
//
// Provides consistent logging methods for all services in the app.
// Use ServiceLogger.forService() to create a logger with a specific prefix.
//
// USAGE:
// final logger = ServiceLogger.forService('UserService');
// logger.info('fetchUser', 'Starting fetch');
// logger.success('fetchUser', 'userId=123');
// logger.failure('fetchUser', 'Network error');

import 'package:flutter/foundation.dart';

// * Service logger class

class ServiceLogger {
  final String prefix;

  const ServiceLogger(this.prefix);

  // Factory constructor for creating service-specific loggers
  static ServiceLogger forService(String serviceName) {
    return ServiceLogger(serviceName);
  }

  // * Logging methods.
  //
  // Every method short-circuits when the app is built in release mode so
  // the prefixed strings never reach the console of a shipped binary.
  // Flutter's `debugPrint` still fires in release; gating on `kDebugMode`
  // is the supported way to keep dev-only diagnostics out of production
  // builds (and out of any web devtools console).

  void info(String operation, String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('🔵 $prefix: [$operation] $message');
  }

  void success(String operation, [String? details]) {
    if (!kDebugMode) {
      return;
    }

    final String message = details != null ? 'Success - $details' : 'Success';

    debugPrint('🟢 $prefix: [$operation] $message');
  }

  void failure(String operation, String error) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('🔴 $prefix: [$operation] Failed - $error');
  }

  void warning(String operation, String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('🟡 $prefix: [$operation] Warning - $message');
  }
}

T fallback<T>(T? value, T defaultValue) => value ?? defaultValue;
