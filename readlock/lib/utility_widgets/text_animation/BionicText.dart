// Bionic reading helper.
//
// Bionic reading bolds the first ~40% of each word so the reader's eye
// catches word shapes faster. Exposed as a settings toggle; the
// `bionicSpans` helper can be pointed at any TextStyle to produce a list of
// InlineSpans that render the text with the fixation emphasis applied.

import 'package:flutter/material.dart';

// Global toggle. ProfileScreen flips this when the user taps the Bionic
// switch; ProgressiveText listens and rebuilds so the fixation emphasis
// appears / disappears immediately across any live reading surface.
// Kept in-memory only — no Firestore round-trip yet (matches the existing
// ProfileScreen contract for bionic).
final ValueNotifier<bool> bionicEnabledNotifier = ValueNotifier<bool>(false);

// How many leading characters of a word to bold. Follows the canonical
// bionic-reading fixation ratio — shorter words get a single anchor letter,
// longer words scale up to roughly 40% of their length.
int bionicBoldCount(int wordLength) {
  if (wordLength <= 3) {
    return 1;
  }

  if (wordLength <= 5) {
    return 2;
  }

  if (wordLength <= 7) {
    return 3;
  }

  return (wordLength * 0.4).ceil();
}

// Returns a per-character mask for `text` where `true` marks positions that
// belong to the bionic-bold prefix of a word (non-word runs — punctuation,
// whitespace — are always `false`). Callers render bold where `mask[i]` is
// true. This is the character-level counterpart to `bionicSpans`; it's the
// shape ProgressiveText needs because its span builder already operates on
// per-character indices for the typewriter / fade-in pipeline.
List<bool> bionicBoldMask(String text) {
  final List<bool> mask = List<bool>.filled(text.length, false);
  final RegExp wordPattern = RegExp(r'\w+');
  final Iterable<RegExpMatch> matches = wordPattern.allMatches(text);

  for (final RegExpMatch match in matches) {
    final int wordLength = match.end - match.start;
    final int boldCount = bionicBoldCount(wordLength);

    for (int localIndex = 0; localIndex < boldCount; localIndex++) {
      mask[match.start + localIndex] = true;
    }
  }

  return mask;
}

// Splits `text` into word / non-word runs and returns InlineSpans where
// each word's first `bionicBoldCount` letters are bolded on top of the
// passed base style, and the remainder stays at the base weight. Preserves
// punctuation and whitespace verbatim.
List<InlineSpan> bionicSpans(String text, TextStyle baseStyle) {
  final List<InlineSpan> spans = [];
  final RegExp tokenPattern = RegExp(r'(\w+)|(\W+)');
  final Iterable<RegExpMatch> matches = tokenPattern.allMatches(text);

  for (final RegExpMatch match in matches) {
    final String? word = match.group(1);
    final String? nonWord = match.group(2);

    if (word != null) {
      final int boldCount = bionicBoldCount(word.length);
      final String boldPart = word.substring(0, boldCount);
      final String restPart = word.substring(boldCount);

      spans.add(
        TextSpan(
          text: boldPart,
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      );

      final bool hasRemainder = restPart.isNotEmpty;

      if (hasRemainder) {
        spans.add(TextSpan(text: restPart, style: baseStyle));
      }
    }

    if (nonWord != null) {
      spans.add(TextSpan(text: nonWord, style: baseStyle));
    }
  }

  return spans;
}
