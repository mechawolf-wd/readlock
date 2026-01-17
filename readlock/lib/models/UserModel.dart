enum SoundType { typewriter, switches, oiia }

enum TextSpeed { careful, classic, speed }

class User {
  final String id;
  final String displayName;
  final String email;
  final DateTime registrationDate;
  final UserPreferences preferences;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.registrationDate,
    required this.preferences,
  });
}

class UserPreferences {
  // Sound settings
  final bool soundsEnabled;
  final SoundType selectedSoundType;

  // Feedback settings
  final bool hapticsEnabled;
  final bool notificationsEnabled;

  // Reading experience settings
  final bool revealEnabled;
  final bool blurEnabled;
  final bool coloredTextEnabled;
  final TextSpeed textSpeed;

  const UserPreferences({
    this.soundsEnabled = true,
    this.selectedSoundType = SoundType.typewriter,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.revealEnabled = false,
    this.blurEnabled = true,
    this.coloredTextEnabled = true,
    this.textSpeed = TextSpeed.classic,
  });
}
