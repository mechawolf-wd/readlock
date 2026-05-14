// Pushes the loaded user's persisted preferences into the global notifiers
// every reading surface listens to. Called once after the profile resolves
// (MainNavigation hydrates on auth, ProfileContent re-applies on sheet open)
// so a fresh launch picks up the same font/column/wpm/night-shift/bird the
// reader last set on any device, plus the bionic and RSVP toggles so reading
// surfaces reflect saved settings even before Profile is opened.
//
// The remaining booleans (typingSound, sounds, haptics, reveal, blur,
// coloredText) live as local state on ProfileContent only, so ProfileScreen
// reads them directly into setState when the sheet opens.

import 'package:readlock/constants/RLLatestCourse.dart';
import 'package:readlock/services/TranslationService.dart';
import 'package:readlock/constants/RLNightShift.dart';
import 'package:readlock/constants/RLReadingColumn.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/constants/RLReadingSettings.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';

void hydrateUserPreferenceNotifiersFromUser(UserModel user) {
  selectedReadingFontNotifier.value = readingFontFromName(user.readingFont);

  selectedReadingColumnNotifier.value = readingColumnFromName(user.readingColumn);

  rsvpWordsPerMinuteNotifier.value = user.rsvpWordsPerMinute;

  nightShiftLevelNotifier.value = user.nightShiftLevel;

  nightShiftScheduleEnabledNotifier.value = user.nightShiftScheduleEnabled;
  nightShiftScheduleFromMinutesNotifier.value = user.nightShiftScheduleFromMinutes;
  nightShiftScheduleToMinutesNotifier.value = user.nightShiftScheduleToMinutes;

  selectedBirdNotifier.value = birdOptionFromName(user.birdName);

  justifiedReadingEnabledNotifier.value = user.justifiedReading;

  bionicEnabledNotifier.value = user.bionic;

  rsvpEnabledNotifier.value = user.rsvp;

  revealAllEnabledNotifier.value = user.reveal;
  blurEnabledNotifier.value = user.blur;
  coloredTextEnabledNotifier.value = user.coloredText;

  lastOpenedCourseIdNotifier.value = user.lastOpenedCourseId;

  // Load translations for the user's preferred language (fire-and-forget).
  // English is instant (no fetch needed), other locales load from Firestore.
  TranslationService.fetchTranslations(user.language);

  // Feedback master switches — drive every UI sound and haptic in the app.
  SoundService.soundsEnabledNotifier.value = user.sounds;
  SoundService.typingSoundEnabledNotifier.value = user.typingSound;
  HapticsService.userHapticsEnabledNotifier.value = user.haptics;
}

// Resets every preference notifier touched by the hydrator back to its
// build-time default. Called from AuthService.signOut and deleteAccount so
// the next user (or the login sheet's own surfaces) never sees the previous
// reader's state leak through.
void resetUserPreferenceNotifiers() {
  selectedReadingFontNotifier.value = DEFAULT_READING_FONT;

  selectedReadingColumnNotifier.value = DEFAULT_READING_COLUMN;

  rsvpWordsPerMinuteNotifier.value = RSVP_DEFAULT_WORDS_PER_MINUTE;

  nightShiftLevelNotifier.value = NIGHT_SHIFT_OFF_LEVEL;

  nightShiftScheduleEnabledNotifier.value = false;
  nightShiftScheduleFromMinutesNotifier.value = NIGHT_SHIFT_SCHEDULE_DEFAULT_FROM_MINUTES;
  nightShiftScheduleToMinutesNotifier.value = NIGHT_SHIFT_SCHEDULE_DEFAULT_TO_MINUTES;

  selectedBirdNotifier.value = BIRD_OPTIONS.first;

  justifiedReadingEnabledNotifier.value = true;

  bionicEnabledNotifier.value = false;

  rsvpEnabledNotifier.value = false;

  revealAllEnabledNotifier.value = false;
  blurEnabledNotifier.value = true;
  coloredTextEnabledNotifier.value = true;

  lastOpenedCourseIdNotifier.value = null;

  // Reset the feedback switches to their build-time defaults so the next
  // user (or the unauthenticated state) hears every sound and feels every
  // haptic until they sign in and their saved preferences hydrate.
  SoundService.soundsEnabledNotifier.value = true;
  SoundService.typingSoundEnabledNotifier.value = true;
  HapticsService.userHapticsEnabledNotifier.value = true;
}

// One-shot wipe of every in-process user-scoped notifier. Intentionally
// synchronous and Firestore-free so it's safe to call any time, including
// after FirebaseAuth has already signed the user out.
//
// Call sites:
//   - AuthService.signOut and AuthService.deleteAccount, before the
//     auth listener runs, so live screens see a clean slate immediately.
//   - MainNavigation's auth state listener whenever user becomes null,
//     as a safety net for sessions that end without going through our
//     explicit teardown (token expiry, server-side disable, etc.).
//
// Anything new that holds user-scoped local state (notifiers, flags,
// caches) must be wired into this helper so future signouts pick it up.
void wipeLocalUserSessionState() {
  resetPurchaseState();
  resetUserPreferenceNotifiers();
  TranslationService.reset();
}
