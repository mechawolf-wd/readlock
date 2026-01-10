import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

const String CONTINUE_CLICK_AUDIO_PATH = 'audio/continue_click.mp3';
const String CORRECT_ANSWER_AUDIO_PATH = 'audio/correct_answer.wav';
const String TYPEWRITER_AUDIO_PATH = 'audio/typewriter.mp3';
const String SLOW_DOWN_CLOCK_AUDIO_PATH = 'audio/slow_down_clock.mp3';

class SoundService {
  static final AudioPlayer continueClickAudioPlayer = AudioPlayer();
  static final AudioPlayer correctAnswerAudioPlayer = AudioPlayer();
  static final AudioPlayer typewriterAudioPlayer = AudioPlayer();
  static final AudioPlayer slowDownClockAudioPlayer = AudioPlayer();
  static bool isAudioEnabled = true;

  static Future<void> playContinueClick() async {
    final bool canPlayAudio = isAudioEnabled;

    if (!canPlayAudio) {
      return;
    }

    try {
      await continueClickAudioPlayer.stop();
      await continueClickAudioPlayer.play(
        AssetSource(CONTINUE_CLICK_AUDIO_PATH),
      );
    } on Exception catch (error) {
      developer.log('Failed to play continue click sound: $error');
      isAudioEnabled = false;
    }
  }

  static Future<void> playCorrectAnswer() async {
    final bool canPlayAudio = isAudioEnabled;

    if (!canPlayAudio) {
      return;
    }

    try {
      await correctAnswerAudioPlayer.stop();
      await correctAnswerAudioPlayer.play(
        AssetSource(CORRECT_ANSWER_AUDIO_PATH),
      );
    } on Exception catch (error) {
      developer.log('Failed to play correct answer sound: $error');
      isAudioEnabled = false;
    }
  }

  static Future<void> playTypewriter() async {
    final bool canPlayAudio = isAudioEnabled;

    if (!canPlayAudio) {
      return;
    }

    final Duration randomPosition = getRandomStartPosition();

    try {
      await typewriterAudioPlayer.stop();
      await typewriterAudioPlayer.setReleaseMode(ReleaseMode.loop);

      await typewriterAudioPlayer.play(
        AssetSource(TYPEWRITER_AUDIO_PATH),
        mode: PlayerMode.lowLatency,
        position: randomPosition,
      );
    } on Exception catch (error) {
      developer.log('Failed to play typewriter sound: $error');
      isAudioEnabled = false;
    }
  }

  static Duration getRandomStartPosition() {
    final int currentTimeMilliseconds =
        DateTime.now().millisecondsSinceEpoch;
    final int randomMilliseconds = currentTimeMilliseconds % 5000;

    return Duration(milliseconds: randomMilliseconds);
  }

  static Future<void> stopTypewriter() async {
    try {
      await typewriterAudioPlayer.stop();
    } on Exception catch (error) {
      developer.log('Failed to stop typewriter sound: $error');
    }
  }

  static Future<void> playSlowDownClock() async {
    final bool canPlayAudio = isAudioEnabled;

    if (!canPlayAudio) {
      return;
    }

    try {
      await slowDownClockAudioPlayer.stop();
      await slowDownClockAudioPlayer.play(
        AssetSource(SLOW_DOWN_CLOCK_AUDIO_PATH),
      );
    } on Exception catch (error) {
      developer.log('Failed to play slow down clock sound: $error');
      isAudioEnabled = false;
    }
  }

  static Future<void> stopSlowDownClock() async {
    try {
      await slowDownClockAudioPlayer.stop();
    } on Exception catch (error) {
      developer.log('Failed to stop slow down clock sound: $error');
    }
  }

  static Future<void> dispose() async {
    try {
      await continueClickAudioPlayer.dispose();
      await correctAnswerAudioPlayer.dispose();
      await typewriterAudioPlayer.dispose();
      await slowDownClockAudioPlayer.dispose();
    } on Exception catch (error) {
      developer.log('Failed to dispose audio players: $error');
    }
  }
}
