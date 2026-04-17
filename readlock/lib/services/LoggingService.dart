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

  // * Logging methods

  void info(String operation, String message) {
    debugPrint('🔵 $prefix: [$operation] $message');
  }

  void success(String operation, [String? details]) {
    final String message = details != null ? 'Success - $details' : 'Success';

    debugPrint('🟢 $prefix: [$operation] $message');
  }

  void failure(String operation, String error) {
    debugPrint('🔴 $prefix: [$operation] Failed - $error');
  }

  void warning(String operation, String message) {
    debugPrint('🟡 $prefix: [$operation] Warning - $message');
  }
}

T fallback<T>(T? value, T defaultValue) => value ?? defaultValue;
