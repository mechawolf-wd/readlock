// Loads and caches translations from Firestore.
//
// Translations live at /translations/{locale} with a manifest at
// /config/locales listing available locales and their display labels.
// English is always available as the inline fallback in RLUIStrings,
// so the service only fetches non-English translations on demand.
//
// Usage: TranslationService.translate('KEY', 'fallback')
// RLUIStrings.translated() wraps this for the centralized string API.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/services/LoggingService.dart';

// * Available locale entry (code + native label for the picker)

class LocaleOption {
  final String code;
  final String label;

  const LocaleOption({required this.code, required this.label});
}

// * Default locale (English is always available without Firestore)

const LocaleOption DEFAULT_LOCALE = LocaleOption(code: 'en', label: 'English');

// * Global notifier for the active locale code

final ValueNotifier<String> currentLocaleNotifier = ValueNotifier<String>('en');

class TranslationService {
  static final ServiceLogger logger = ServiceLogger.forService('TranslationService');

  // Cached translations for the active locale.
  // Empty when English is selected (inline fallbacks used instead).
  static Map<String, String> cachedStrings = {};

  // Cached list of available locales from the /config/locales manifest.
  static List<LocaleOption> localeOptions = [DEFAULT_LOCALE];

  // * Resolve a translated string for the current locale

  static String translate(String key, String fallback) {
    final bool isEnglish = currentLocaleNotifier.value == 'en';

    if (isEnglish) {
      return fallback;
    }

    final String? translated = cachedStrings[key];
    final bool hasTranslation = translated != null;

    if (hasTranslation) {
      return translated;
    }

    return fallback;
  }

  // * Fetch available locales from /config/locales

  static Future<List<LocaleOption>> fetchAvailableLocales() async {
    try {
      final DocumentSnapshot<JSONMap> snapshot = await FirebaseFirestore.instance
          .collection(FirebaseConfig.CONFIG_COLLECTION)
          .doc(FirebaseConfig.CONFIG_LOCALES_DOCUMENT)
          .get();

      final bool hasNoDocument = !snapshot.exists;

      if (hasNoDocument) {
        logger.info('fetchAvailableLocales', 'No locales manifest found');
        return [DEFAULT_LOCALE];
      }

      final JSONMap data = snapshot.data()!;
      final List<dynamic> rawAvailable = data['available'] as List<dynamic>;

      final List<LocaleOption> locales = [];

      for (final entry in rawAvailable) {
        final JSONMap localeMap = entry as JSONMap;
        final String code = localeMap['code'] as String;
        final String label = localeMap['label'] as String;

        locales.add(LocaleOption(code: code, label: label));
      }

      // Ensure English is always in the list
      final bool hasEnglish = locales.any((locale) => locale.code == 'en');

      if (!hasEnglish) {
        locales.insert(0, DEFAULT_LOCALE);
      }

      localeOptions = locales;

      logger.success('fetchAvailableLocales', 'count=${locales.length}');

      return locales;
    } on Exception catch (error) {
      logger.failure('fetchAvailableLocales', '$error');
      return [DEFAULT_LOCALE];
    }
  }

  // * Load translations for a specific locale from /translations/{locale}

  static Future<bool> fetchTranslations(String locale) async {
    final bool isEnglish = locale == 'en';

    if (isEnglish) {
      cachedStrings = {};
      currentLocaleNotifier.value = 'en';
      return true;
    }

    try {
      final DocumentSnapshot<JSONMap> snapshot = await FirebaseFirestore.instance
          .collection(FirebaseConfig.TRANSLATIONS_COLLECTION)
          .doc(locale)
          .get();

      final bool hasNoDocument = !snapshot.exists;

      if (hasNoDocument) {
        logger.info('fetchTranslations', 'No translations for locale=$locale');
        return false;
      }

      final JSONMap data = snapshot.data()!;
      final JSONMap rawStrings = data['strings'] as JSONMap;

      final Map<String, String> strings = {};

      for (final entry in rawStrings.entries) {
        final bool isString = entry.value is String;

        if (isString) {
          strings[entry.key] = entry.value as String;
        }
      }

      cachedStrings = strings;
      currentLocaleNotifier.value = locale;

      logger.success('fetchTranslations', 'locale=$locale keys=${strings.length}');

      return true;
    } on Exception catch (error) {
      logger.failure('fetchTranslations', '$error');
      return false;
    }
  }

  // * Switch to a new locale (fetch + apply)

  static Future<bool> setLocale(String locale) async {
    return fetchTranslations(locale);
  }

  // * Reset to English (called on sign-out)

  static void reset() {
    cachedStrings = {};
    currentLocaleNotifier.value = 'en';
  }
}
