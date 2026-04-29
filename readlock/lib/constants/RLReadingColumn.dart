// Reader-selectable column width for every CC widget in the course viewer.
// Two options:
//
//   - narrow       → 320 pt. Newspaper-column tight (45-55 char lines); the default.
//   - comfortable  → 360 pt. Classic, slightly wider than newspaper.
//
// Held in selectedReadingColumnNotifier and consumed by CourseContentViewer
// via ValueListenableBuilder so every content swipe picks up a Settings
// change on the next rebuild.

import 'package:flutter/foundation.dart';

enum ReadingColumn { narrow, comfortable }

class ReadingColumnOption {
  final ReadingColumn column;
  final String displayName;
  final double maxWidth;
  // Used only by the Settings demo preview so the option picker stays
  // visibly different on small phones, where both absolute maxWidth values
  // would clamp to the same slot width and produce no perceptible change.
  final double previewWidthFraction;

  const ReadingColumnOption({
    required this.column,
    required this.displayName,
    required this.maxWidth,
    required this.previewWidthFraction,
  });
}

const List<ReadingColumnOption> READING_COLUMN_OPTIONS = [
  ReadingColumnOption(
    column: ReadingColumn.narrow,
    displayName: 'Newspaper',
    maxWidth: 320.0,
    previewWidthFraction: 0.7,
  ),

  ReadingColumnOption(
    column: ReadingColumn.comfortable,
    displayName: 'Classic',
    maxWidth: 360.0,
    previewWidthFraction: 0.92,
  ),
];

const ReadingColumn DEFAULT_READING_COLUMN = ReadingColumn.narrow;

final ValueNotifier<ReadingColumn> selectedReadingColumnNotifier = ValueNotifier<ReadingColumn>(
  DEFAULT_READING_COLUMN,
);

// Resolves the column enum to its max width. Both options are constrained
// (no unconstrained "wide" anymore), so callers can rely on a finite value.
double maxWidthFor(ReadingColumn column) {
  for (final ReadingColumnOption option in READING_COLUMN_OPTIONS) {
    if (option.column == column) {
      return option.maxWidth;
    }
  }

  return READING_COLUMN_OPTIONS.first.maxWidth;
}

// Parses a persisted column name back to a ReadingColumn. Falls back to
// the default when the name is unrecognised (e.g. an older build wrote a
// value this build doesn't know about, or the field is missing entirely).
ReadingColumn readingColumnFromName(String? name) {
  if (name == null) {
    return DEFAULT_READING_COLUMN;
  }

  for (final ReadingColumn column in ReadingColumn.values) {
    if (column.name == name) {
      return column;
    }
  }

  return DEFAULT_READING_COLUMN;
}

// Settings-demo only. Returns the fraction of the available slot width the
// preview should occupy for the given column option, so the picker remains
// visibly different on phones whose slot is already narrower than maxWidth.
double previewWidthFractionFor(ReadingColumn column) {
  for (final ReadingColumnOption option in READING_COLUMN_OPTIONS) {
    if (option.column == column) {
      return option.previewWidthFraction;
    }
  }

  return READING_COLUMN_OPTIONS.first.previewWidthFraction;
}
