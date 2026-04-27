// Reader-selectable column width for every CC widget in the course viewer.
// Two options:
//
//   - narrow       → 320 pt. Newspaper-column tight (45–55 char lines); the default.
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

  const ReadingColumnOption({
    required this.column,
    required this.displayName,
    required this.maxWidth,
  });
}

const List<ReadingColumnOption> READING_COLUMN_OPTIONS = [
  ReadingColumnOption(column: ReadingColumn.narrow, displayName: 'Newspaper', maxWidth: 320.0),

  ReadingColumnOption(
    column: ReadingColumn.comfortable,
    displayName: 'Classic',
    maxWidth: 360.0,
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
