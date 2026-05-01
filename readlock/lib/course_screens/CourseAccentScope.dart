// Inherited scope that hands the active course's accent colour down to any
// descendant that wants to tint inline text markup (<c:g>…</c:g>,
// <c:r>…</c:r>) with the course's own colour instead of a fixed palette.
// CourseContentViewer wraps its body in this once per course; ProgressiveText
// reads it via CourseAccentScope.of(context) when it builds highlighted spans.

import 'package:flutter/material.dart';

class CourseAccentScope extends InheritedWidget {
  final Color accentColor;

  const CourseAccentScope({
    super.key,
    required this.accentColor,
    required super.child,
  });

  // Walks up the tree for the nearest scope. Returns the fallback when no
  // scope exists (eg. ProgressiveText used outside a course, like the
  // settings preview) so callers never deal with a null colour.
  static Color of(BuildContext context, {required Color fallback}) {
    final CourseAccentScope? scope = context
        .dependOnInheritedWidgetOfExactType<CourseAccentScope>();

    return scope?.accentColor ?? fallback;
  }

  @override
  bool updateShouldNotify(CourseAccentScope oldWidget) {
    return oldWidget.accentColor != accentColor;
  }
}
