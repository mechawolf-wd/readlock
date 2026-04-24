// Reader-selectable column width for every CC widget in the course viewer.
// Three options covering the useful range:
//
//   - narrow       → 320 pt. Newspaper-column tight (45–55 char lines).
//   - comfortable  → 360 pt. Between narrow and wide; the default.
//   - wide         → unconstrained. Fills the full phone width, matching the
//                    pre-column-constraint behaviour.
//
// Held in selectedReadingColumnNotifier and consumed by CourseContentViewer
// via ValueListenableBuilder so every content swipe picks up a Settings
// change on the next rebuild.

import 'package:flutter/foundation.dart';

enum ReadingColumn { narrow, comfortable, wide }

class ReadingColumnOption {
  final ReadingColumn column;
  final String displayName;

  // Null = no constraint; content fills the full available width.
  final double? maxWidth;

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

  ReadingColumnOption(column: ReadingColumn.wide, displayName: 'Expanded', maxWidth: null),
];

const ReadingColumn DEFAULT_READING_COLUMN = ReadingColumn.comfortable;

final ValueNotifier<ReadingColumn> selectedReadingColumnNotifier = ValueNotifier<ReadingColumn>(
  DEFAULT_READING_COLUMN,
);

// Resolves the column enum to its max width. Returns null for unconstrained.
double? maxWidthFor(ReadingColumn column) {
  for (final ReadingColumnOption option in READING_COLUMN_OPTIONS) {
    if (option.column == column) {
      return option.maxWidth;
    }
  }

  return null;
}
