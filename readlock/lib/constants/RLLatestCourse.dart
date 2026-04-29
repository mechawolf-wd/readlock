import 'package:flutter/foundation.dart';

// Global notifier holding the user's most recently opened course id.
// Updated whenever the reader taps a roadmap node and hydrated from the
// user's Firestore profile on auth. Null until the reader opens their
// first course; the home screen reads this to render the "Reading now…"
// card and hides the section when it's null.
final ValueNotifier<String?> lastOpenedCourseIdNotifier = ValueNotifier<String?>(null);
