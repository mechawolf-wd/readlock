import 'package:flutter/foundation.dart';

// Global reading-preference toggle for justified text alignment in long-form
// reading content. Hydrated from the user's Firestore profile when Settings
// loads, and updated whenever the toggle flips. Default true so first-time
// readers see the typeset, book-like layout from the very first lesson.
final ValueNotifier<bool> justifiedReadingEnabledNotifier = ValueNotifier<bool>(true);
