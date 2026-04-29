// Reader-controlled eye-strain overlay, modeled after Apple Night Shift.
//
// Overlay color is the sRGB white-point Apple shifts the display toward at
// max Night Shift warmth (approximately 2700K), reverse-engineered as
// roughly RGB(255, 169, 87). Lower steps lerp from transparent (off) up to
// that target so step 5 lands on Apple's "More Warm" endpoint.
//
// State is kept in nightShiftLevelNotifier and read globally by
// RLNightShiftOverlay (mounted via the MaterialApp builder), so the tint
// applies to every screen at once.

import 'package:flutter/material.dart';

const int NIGHT_SHIFT_OFF_LEVEL = 0;
const int NIGHT_SHIFT_MAX_LEVEL = 5;

// Deeper, more saturated amber than Apple's 2700K white point. Lower
// luminance + higher chroma so the tint reads as a real warm wash on the
// dark surfaces instead of a pale cream cast.
const Color NIGHT_SHIFT_WARM_COLOR = Color(0xFFCF6A1A);

// Per-step warm-tint alpha. Step 0 is fully transparent (overlay disabled);
// step 5 lands at 0.34 — the practitioner cap above which a saturated
// warm wash starts crushing contrast on muted greys (WCAG 4.5:1 body
// text holds, but icons get muddy beyond this point).
const List<double> NIGHT_SHIFT_STEP_ALPHA = [0.0, 0.08, 0.15, 0.22, 0.28, 0.34];

// Per-step app screen-brightness target (0.0 = blackest the panel can go,
// 1.0 = brightest). Applied via screen_brightness so the panel is actually
// dimmed below the OS slider rather than overlay-painted — that's the real
// lever for eye-strain relief in low-light rooms. Sentinel -1 means
// "don't override" so the device follows the user's own slider.
const double NIGHT_SHIFT_BRIGHTNESS_RESTORE = -1.0;
const List<double> NIGHT_SHIFT_BRIGHTNESS = [
  NIGHT_SHIFT_BRIGHTNESS_RESTORE,
  0.55,
  0.40,
  0.28,
  0.18,
  0.10,
];

final ValueNotifier<int> nightShiftLevelNotifier = ValueNotifier<int>(NIGHT_SHIFT_OFF_LEVEL);

double getNightShiftAlpha(int level) {
  final bool isInRange = level >= 0 && level < NIGHT_SHIFT_STEP_ALPHA.length;

  if (!isInRange) {
    return 0.0;
  }

  return NIGHT_SHIFT_STEP_ALPHA[level];
}

double getNightShiftBrightness(int level) {
  final bool isInRange = level >= 0 && level < NIGHT_SHIFT_BRIGHTNESS.length;

  if (!isInRange) {
    return NIGHT_SHIFT_BRIGHTNESS_RESTORE;
  }

  return NIGHT_SHIFT_BRIGHTNESS[level];
}
