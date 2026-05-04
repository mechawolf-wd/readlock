// Reader-controlled colour-temperature shift, modelled on Apple's Night
// Shift. Five stops (Off + four warmth levels) running from D65 (6500K) at
// step 0 down to a warm 3400K at step 4. Each stop carries the per-channel
// multipliers RLNightShift uses to drive a ColorFiltered matrix at the
// MaterialApp root, plus a brightness target the
// NightShiftBrightnessService uses to actually dim the panel.
//
// State lives in nightShiftLevelNotifier and is read app-wide so the tint
// and the panel dim stay in sync without per-screen wiring.

import 'package:flutter/material.dart';

class NightShiftLevel {
  final String label;
  final int kelvin;
  final double rMultiplier;
  final double gMultiplier;
  final double bMultiplier;

  const NightShiftLevel({
    required this.label,
    required this.kelvin,
    required this.rMultiplier,
    required this.gMultiplier,
    required this.bMultiplier,
  });
}

const int NIGHT_SHIFT_OFF_LEVEL = 0;
const int NIGHT_SHIFT_MAX_LEVEL = 4;

// Step 0 = neutral D65 (no shift). Steps 1–4 walk down to 3400K with the
// same RGB targets Apple's Night Shift uses at each stop.
const List<NightShiftLevel> NIGHT_SHIFT_LEVELS = [
  NightShiftLevel(
    label: 'Off',
    kelvin: 6500,
    rMultiplier: 1.00,
    gMultiplier: 1.00,
    bMultiplier: 1.00,
  ),
  NightShiftLevel(
    label: 'Subtle',
    kelvin: 5500,
    rMultiplier: 1.00,
    gMultiplier: 0.95,
    bMultiplier: 0.86,
  ),
  NightShiftLevel(
    label: 'Less Warm',
    kelvin: 4500,
    rMultiplier: 1.00,
    gMultiplier: 0.85,
    bMultiplier: 0.73,
  ),
  NightShiftLevel(
    label: 'Warm',
    kelvin: 3700,
    rMultiplier: 1.00,
    gMultiplier: 0.78,
    bMultiplier: 0.60,
  ),
  NightShiftLevel(
    label: 'More Warm',
    kelvin: 3400,
    rMultiplier: 1.00,
    gMultiplier: 0.74,
    bMultiplier: 0.53,
  ),
];

// Per-step app screen-brightness target (0.0 = blackest the panel can go,
// 1.0 = brightest). Applied via screen_brightness so the panel is actually
// dimmed below the OS slider rather than overlay-painted — that's the real
// lever for eye-strain relief in low-light rooms. Sentinel -1 means
// "don't override" so the device follows the user's own slider. List is
// indexed by the same level int as NIGHT_SHIFT_LEVELS so a single slider
// drives both axes (warmth + dim) coherently.
const double NIGHT_SHIFT_BRIGHTNESS_RESTORE = -1.0;
const List<double> NIGHT_SHIFT_BRIGHTNESS = [
  NIGHT_SHIFT_BRIGHTNESS_RESTORE,
  0.55,
  0.40,
  0.25,
  0.15,
];

final ValueNotifier<int> nightShiftLevelNotifier = ValueNotifier<int>(NIGHT_SHIFT_OFF_LEVEL);

// Returns the level entry for a given index, clamped into range so a
// stale persisted value (eg. 5 from the previous 6-step build) resolves
// to the closest valid stop instead of throwing.
NightShiftLevel getNightShiftLevel(int level) {
  final int lastIndex = NIGHT_SHIFT_LEVELS.length - 1;
  final int clamped = level.clamp(0, lastIndex);

  return NIGHT_SHIFT_LEVELS[clamped];
}

double getNightShiftBrightness(int level) {
  final int lastIndex = NIGHT_SHIFT_BRIGHTNESS.length - 1;
  final bool isInRange = level >= 0 && level <= lastIndex;

  if (!isInRange) {
    return NIGHT_SHIFT_BRIGHTNESS_RESTORE;
  }

  return NIGHT_SHIFT_BRIGHTNESS[level];
}
