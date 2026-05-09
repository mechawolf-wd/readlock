// Global reading-preference notifiers for progressive reveal, focus blur,
// and accent-coloured markup. Hydrated from the user's Firestore profile
// on launch (UserPreferencesHydrator) and updated live when Settings toggles
// flip. ProgressiveText listens to all three so every CC reading surface
// reflects the saved preferences without per-widget wiring.

import 'package:flutter/foundation.dart';

// When true, text skips the typewriter animation and appears all at once.
// User-facing label: "Progressive" (inverted: switch ON = revealAll false).
final ValueNotifier<bool> revealAllEnabledNotifier = ValueNotifier<bool>(false);

// When true, completed sentences blur (Apple Music lyrics style).
// User-facing label: "Focus".
final ValueNotifier<bool> blurEnabledNotifier = ValueNotifier<bool>(true);

// When true, <c:g> and <c:r> markup renders with accent colour / bold-italic.
// When false, markup text renders as plain body text.
// User-facing label: "Accent".
final ValueNotifier<bool> coloredTextEnabledNotifier = ValueNotifier<bool>(true);
