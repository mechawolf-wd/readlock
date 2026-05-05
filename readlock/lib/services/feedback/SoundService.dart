// Centralised UI sound effects. One AudioPlayer per discrete sound so two
// near-simultaneous events (e.g. text reveal + correct answer) don't
// trample each other. Two pooled players cover the multi-clip families:
// textClickPlayer rotates through the three text_click_* clips at random,
// and clickNotePlayer maps a 0-based tab index to its click_note_* clip.

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

const String wrongAudioPath = 'audio/ui_sounds/wrong.wav';
const String correctAudioPath = 'audio/ui_sounds/correct.wav';
const String correctTrueAudioPath = 'audio/ui_sounds/correct_true.wav';
const String enterAudioPath = 'audio/ui_sounds/enter.wav';
const String logoutAudioPath = 'audio/ui_sounds/logout.wav';
const String negativeAudioPath = 'audio/ui_sounds/negative.wav';
const String successAudioPath = 'audio/ui_sounds/success.wav';
const String purchaseAudioPath = 'audio/ui_sounds/purchase.wav';
const String switchAudioPath = 'audio/ui_sounds/switch.wav';
const String uiClickAudioPath = 'audio/ui_sounds/ui_click.wav';

const List<String> textClickAudioPaths = [
  'audio/ui_sounds/text_click_1.wav',
  'audio/ui_sounds/text_click_2.wav',
  'audio/ui_sounds/text_click_3.wav',
];

class SoundService {
  static final AudioPlayer wrongPlayer = AudioPlayer();
  static final AudioPlayer correctPlayer = AudioPlayer();
  static final AudioPlayer correctTruePlayer = AudioPlayer();
  static final AudioPlayer enterPlayer = AudioPlayer();
  static final AudioPlayer logoutPlayer = AudioPlayer();
  static final AudioPlayer negativePlayer = AudioPlayer();
  static final AudioPlayer successPlayer = AudioPlayer();
  static final AudioPlayer purchasePlayer = AudioPlayer();
  static final AudioPlayer switchPlayer = AudioPlayer();
  static final AudioPlayer textClickPlayer = AudioPlayer();
  static final AudioPlayer uiClickPlayer = AudioPlayer();

  static final Random random = Random();

  // Latched off once a play call throws — avoids hammering the log on
  // a system without working audio (eg. simulator misconfig).
  static bool isAudioEnabled = true;

  // * User-facing master switches.
  //
  // soundsEnabledNotifier gates every UI sound the service plays, so flipping
  // the Sounds toggle in Settings silences click feedback, success/negative
  // chimes, switch ticks, etc. — there is no other path to the audio players.
  //
  // typingSoundEnabledNotifier is a narrower switch dedicated to the
  // progressive-text reveal tick. It only affects playProgressiveTextTick, so
  // the reader can mute the typewriter cadence while keeping the rest of the
  // UI sounds intact.
  static final ValueNotifier<bool> soundsEnabledNotifier = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> typingSoundEnabledNotifier = ValueNotifier<bool>(true);

  static Future<void> playOneShot(AudioPlayer player, String assetPath, String label) async {
    final bool userMutedSounds = !soundsEnabledNotifier.value;

    if (userMutedSounds) {
      return;
    }

    final bool canPlayAudio = isAudioEnabled;

    if (!canPlayAudio) {
      return;
    }

    try {
      await player.stop();
      await player.play(AssetSource(assetPath));
    } on Object catch (error) {
      // Catch Object, not Exception: on web, audioplayers raises a JS
      // AbortError ("play() interrupted by a call to pause()") which surfaces
      // as a Dart Error and would otherwise rethrow. That race is benign and
      // happens whenever two sound triggers land in the same frame, so log
      // and move on without latching audio off.
      final bool isPlayInterrupted = error.toString().contains('AbortError');

      if (isPlayInterrupted) {
        return;
      }

      developer.log('Failed to play $label sound: $error');
      isAudioEnabled = false;
    }
  }

  static Future<void> playWrong() {
    return playOneShot(wrongPlayer, wrongAudioPath, 'wrong');
  }

  static Future<void> playCorrect() {
    return playOneShot(correctPlayer, correctAudioPath, 'correct');
  }

  // Distinct correct beat for True/False questions so binary choices feel
  // different from the multi-option correct chime.
  static Future<void> playCorrectTrue() {
    return playOneShot(correctTruePlayer, correctTrueAudioPath, 'correct true');
  }

  static Future<void> playEnter() {
    return playOneShot(enterPlayer, enterAudioPath, 'enter');
  }

  static Future<void> playLogout() {
    return playOneShot(logoutPlayer, logoutAudioPath, 'logout');
  }

  static Future<void> playNegative() {
    return playOneShot(negativePlayer, negativeAudioPath, 'negative');
  }

  static Future<void> playSuccess() {
    return playOneShot(successPlayer, successAudioPath, 'success');
  }

  static Future<void> playPurchase() {
    return playOneShot(purchasePlayer, purchaseAudioPath, 'purchase');
  }

  static Future<void> playSwitch() {
    return playOneShot(switchPlayer, switchAudioPath, 'switch');
  }

  // Picks one of the three text_click clips at random so successive
  // reveals don't all sound identical. Called when a new text segment
  // begins revealing (CCText) and when an answer / option is unblurred
  // (CCQuestion, CCTrueFalse, CCReflect).
  static Future<void> playRandomTextClick() {
    final int variantIndex = random.nextInt(textClickAudioPaths.length);
    final String selectedPath = textClickAudioPaths[variantIndex];

    return playOneShot(textClickPlayer, selectedPath, 'text click $variantIndex');
  }

  // Generic UI click. Used by main-navigation tab taps so every tab swap
  // shares the same audible beat instead of varying per-tab.
  static Future<void> playUiClick() {
    return playOneShot(uiClickPlayer, uiClickAudioPath, 'ui click');
  }

  // Per-sentence reveal tick fired by ProgressiveText every time a new
  // sentence starts typing in. Gated by the dedicated typing-sound switch
  // so the reader can mute the typewriter cadence without silencing the
  // rest of the UI (button clicks, switch flips, success chimes).
  static Future<void> playProgressiveTextTick() {
    final bool typingMuted = !typingSoundEnabledNotifier.value;

    if (typingMuted) {
      return Future<void>.value();
    }

    return playRandomTextClick();
  }

  static Future<void> dispose() async {
    try {
      await wrongPlayer.dispose();
      await correctPlayer.dispose();
      await correctTruePlayer.dispose();
      await enterPlayer.dispose();
      await logoutPlayer.dispose();
      await negativePlayer.dispose();
      await successPlayer.dispose();
      await switchPlayer.dispose();
      await textClickPlayer.dispose();
      await uiClickPlayer.dispose();
    } on Exception catch (error) {
      developer.log('Failed to dispose audio players: $error');
    }
  }
}
