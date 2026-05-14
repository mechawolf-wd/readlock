// Uploads a translation document for a given locale.
//
// Lockie (admin) calls this with a locale code, a display label,
// and the full set of translated UI strings. The function writes
// the strings to /translations/{locale} and updates the locale
// manifest at /config/locales so the Flutter app can discover
// available languages without downloading every translation document.
//
// Input:  { locale: string, label: string, strings: Record<string, string> }
// Output: { ok: true }

import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const TRANSLATIONS_COLLECTION = "translations";
const CONFIG_COLLECTION = "config";
const LOCALES_DOCUMENT = "locales";
const ADMIN_EMAIL = "support@readlock.org";

interface UploadTranslationsData {
  locale?: unknown;
  label?: unknown;
  strings?: unknown;
}

interface LocaleEntry {
  code: string;
  label: string;
}

// TODO: Re-enable when App Check is configured in Firebase Console.
// const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === "true";

export const uploadTranslations = onCall<UploadTranslationsData>(
  { enforceAppCheck: false, maxInstances: 10 },
  async (request) => {
    // * 1. Authentication gate

    const callerNotSignedIn = !request.auth;

    if (callerNotSignedIn) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to upload translations."
      );
    }

    // * 2. Admin gate

    const callerEmail = request.auth!.token.email;
    const callerNotAdmin = callerEmail !== ADMIN_EMAIL;

    if (callerNotAdmin) {
      throw new HttpsError(
        "permission-denied",
        "Only admin can upload translations."
      );
    }

    // * 3. Input validation

    const rawLocale = request.data?.locale;
    const localeInvalid =
      typeof rawLocale !== "string" || rawLocale.trim().length === 0;

    if (localeInvalid) {
      throw new HttpsError(
        "invalid-argument",
        "locale must be a non-empty string."
      );
    }

    const rawLabel = request.data?.label;
    const labelInvalid =
      typeof rawLabel !== "string" || rawLabel.trim().length === 0;

    if (labelInvalid) {
      throw new HttpsError(
        "invalid-argument",
        "label must be a non-empty string."
      );
    }

    const rawStrings = request.data?.strings;
    const stringsInvalid =
      typeof rawStrings !== "object" ||
      rawStrings === null ||
      Array.isArray(rawStrings);

    if (stringsInvalid) {
      throw new HttpsError(
        "invalid-argument",
        "strings must be a non-null object."
      );
    }

    const locale = (rawLocale as string).trim().toLowerCase();
    const label = (rawLabel as string).trim();
    const strings = rawStrings as Record<string, string>;

    const firestore = getFirestore();

    // * 4. Write translation document and update locale manifest

    const translationRef = firestore
      .collection(TRANSLATIONS_COLLECTION)
      .doc(locale);

    const localesRef = firestore
      .collection(CONFIG_COLLECTION)
      .doc(LOCALES_DOCUMENT);

    await firestore.runTransaction(async (transaction) => {
      const localesSnapshot = await transaction.get(localesRef);

      const existingData = localesSnapshot.exists
        ? localesSnapshot.data()
        : { available: [] };

      const available = (existingData?.available ?? []) as LocaleEntry[];

      // Update or add the locale entry in the manifest
      const existingIndex = available.findIndex(
        (entry) => entry.code === locale
      );

      const localeEntry: LocaleEntry = { code: locale, label };

      const entryAlreadyExists = existingIndex !== -1;

      if (entryAlreadyExists) {
        available[existingIndex] = localeEntry;
      } else {
        available.push(localeEntry);
      }

      // Write translation strings
      transaction.set(translationRef, { strings });

      // Write updated locale manifest
      transaction.set(localesRef, { available });
    });

    const keyCount = Object.keys(strings).length;

    logger.info("uploadTranslations", { locale, label, keyCount });

    return { ok: true };
  }
);
