// Pushes the loaded user's persisted preferences into the global notifiers
// every reading surface listens to. Called once after the profile resolves
// (MainNavigation hydrates on auth, ProfileContent re-applies on sheet open)
// so a fresh launch picks up the same font/column/wpm/night-shift/bird the
// reader last set on any device.
//
// The booleans (typingSound, sounds, haptics, reveal, blur, coloredText,
// bionic, rsvp) are read directly by ProfileContent into local state plus
// rsvpEnabledNotifier and bionicEnabledNotifier — those handlers stay in
// ProfileScreen so the toggles can update both in one place.

import 'package:readlock/constants/RLNightShift.dart';
import 'package:readlock/constants/RLReadingColumn.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';

void hydrateUserPreferenceNotifiersFromUser(UserModel user) {
  selectedReadingFontNotifier.value = readingFontFromName(user.readingFont);

  selectedReadingColumnNotifier.value = readingColumnFromName(user.readingColumn);

  rsvpWordsPerMinuteNotifier.value = user.rsvpWordsPerMinute;

  nightShiftLevelNotifier.value = user.nightShiftLevel;

  selectedBirdNotifier.value = birdOptionFromName(user.birdName);
}
