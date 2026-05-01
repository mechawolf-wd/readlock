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
import 'package:readlock/constants/RLNightShift.dart';
import 'package:readlock/constants/RLReadingColumn.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';

void hydrateUserPreferenceNotifiersFromUser(UserModel user) {
  selectedReadingFontNotifier.value = readingFontFromName(user.readingFont);

  selectedReadingColumnNotifier.value = readingColumnFromName(user.readingColumn);

  rsvpWordsPerMinuteNotifier.value = user.rsvpWordsPerMinute;

  nightShiftLevelNotifier.value = user.nightShiftLevel;

  selectedBirdNotifier.value = birdOptionFromName(user.birdName);

  justifiedReadingEnabledNotifier.value = user.justifiedReading;

  bionicEnabledNotifier.value = user.bionic;

  rsvpEnabledNotifier.value = user.rsvp;

  lastOpenedCourseIdNotifier.value = user.lastOpenedCourseId;
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

  selectedBirdNotifier.value = BIRD_OPTIONS.first;

  justifiedReadingEnabledNotifier.value = false;

  bionicEnabledNotifier.value = false;

  rsvpEnabledNotifier.value = false;

  lastOpenedCourseIdNotifier.value = null;
}
