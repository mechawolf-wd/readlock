// Reusable switch toggle component (iOS-style via CupertinoSwitch).
// Uses design system colors for active/inactive states. Plays the shared
// switch click sound on every commit so toggling any settings switch
// carries the same audible feedback.

import 'package:flutter/cupertino.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/services/feedback/SoundService.dart';

class RLSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const RLSwitch({super.key, required this.value, this.onChanged, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final Color resolvedActiveColor = activeColor ?? RLDS.primary;
    // null when no caller handler — keeps the switch disabled (Cupertino
    // gates interaction on a non-null onChanged) instead of letting it
    // look tappable but only emit a sound.
    final ValueChanged<bool>? wrappedOnChanged = buildSoundedOnChanged();

    return CupertinoSwitch(
      value: value,
      onChanged: wrappedOnChanged,
      activeTrackColor: resolvedActiveColor,
      inactiveTrackColor: RLDS.glass15(RLDS.textPrimary),
    );
  }

  // Wraps the caller's onChanged so every toggle plays the click sound
  // before delegating. Returns null when the caller didn't supply a
  // handler so the disabled-switch contract is preserved.
  ValueChanged<bool>? buildSoundedOnChanged() {
    final ValueChanged<bool>? caller = onChanged;
    final bool isDisabled = caller == null;

    if (isDisabled) {
      return null;
    }

    return (bool newValue) {
      SoundService.playSwitch();
      caller(newValue);
    };
  }
}
