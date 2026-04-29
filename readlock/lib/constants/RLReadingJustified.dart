import 'package:flutter/foundation.dart';

// Global reading-preference toggle for justified text alignment in long-form
// reading content. Hydrated from the user's Firestore profile when Settings
// loads, and updated whenever the toggle flips. Default false = regular
// (left-aligned) reading, matching the historical default.
final ValueNotifier<bool> justifiedReadingEnabledNotifier = ValueNotifier<bool>(false);
