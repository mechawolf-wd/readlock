// Reader-selectable font for long-form course content.
// Three options, each picked for a specific reading profile:
//
//   - serif     → Lora. Screen-optimised reading serif. Replaces Playfair
//                  Display (which is a display face and tiring for long text).
//   - dyslexic  → OpenDyslexic. Bundled locally (SIL OFL) under
//                  assets/fonts/ because the face isn't on Google Fonts.
//                  Weighted bottoms anchor each letter, and mirror-pair
//                  shapes (b/d, p/q, n/u) are individually tuned so they
//                  don't flip on readers with dyslexia.
//   - monospace → JetBrains Mono. Already in use across the UI; reusing it
//                  here keeps the "just mono everything" path trivial.
//
// The reader picks one in Settings; it is held in selectedReadingFontNotifier
// and read by RLTypography.readingLargeStyle / readingMediumStyle so every
// reading surface (CCTextContent, CCQuestion, CCPause, settings demo, …)
// picks up the change on next rebuild.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ReadingFont { serif, dyslexic, monospace }

class ReadingFontOption {
  final ReadingFont font;
  final String displayName;
  final String description;

  const ReadingFontOption({
    required this.font,
    required this.displayName,
    required this.description,
  });
}

const List<ReadingFontOption> READING_FONT_OPTIONS = [
  ReadingFontOption(
    font: ReadingFont.serif,
    displayName: 'Serif',
    description: 'Calm, classic shapes that feel like a printed novel in your hands.',
  ),

  ReadingFontOption(
    font: ReadingFont.dyslexic,
    displayName: 'Dyslexic Friendly',
    description: 'Weighted letters and tuned shapes so b, d, p never blur together.',
  ),

  ReadingFontOption(
    font: ReadingFont.monospace,
    displayName: 'Monospace',
    description: 'Sharp, even-width letters with a focused, almost analytical feel.',
  ),
];

const ReadingFont DEFAULT_READING_FONT = ReadingFont.serif;

// Shared selection — read by RLTypography when it computes reading styles,
// and watched by the settings demo via ValueListenableBuilder.
final ValueNotifier<ReadingFont> selectedReadingFontNotifier = ValueNotifier<ReadingFont>(
  DEFAULT_READING_FONT,
);

// Returns a GoogleFonts-backed TextStyle for the requested reading font with
// the shared reading-text attributes (size/weight/height/colour) applied by
// the caller via `base`. Every reading style in RLTypography routes through
// this so adding a new font option means editing only this file.
TextStyle readingStyleFor(ReadingFont font, TextStyle base) {
  switch (font) {
    case ReadingFont.serif:
      {
        return GoogleFonts.lora(textStyle: base);
      }

    case ReadingFont.dyslexic:
      {
        return base.copyWith(fontFamily: 'OpenDyslexic', letterSpacing: -3);
      }

    case ReadingFont.monospace:
      {
        return GoogleFonts.jetBrainsMono(textStyle: base);
      }
  }
}

// Parses a persisted string back to a ReadingFont. Falls back to the default
// when the string is unrecognised (e.g. a future build wrote an enum value
// this build doesn't know about).
ReadingFont readingFontFromName(String? name) {
  if (name == null) {
    return DEFAULT_READING_FONT;
  }

  for (final ReadingFont font in ReadingFont.values) {
    if (font.name == name) {
      return font;
    }
  }

  return DEFAULT_READING_FONT;
}
