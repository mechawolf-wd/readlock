// Hyphenation utilities for justified text.
//
// Inserts Unicode soft hyphens (\u00AD) at syllable boundaries so Flutter's
// text layout engine can break long words when text is justified. The visible
// dash only appears when a soft hyphen actually causes a line break.
//
// resolveVisibleHyphens uses a two-pass TextPainter + caret comparison to
// find which soft hyphens triggered a break and replaces only those with a
// real dash. This is intended to be called once and cached (not on every
// rebuild).

import 'package:flutter/material.dart';
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';

const String softHyphen = '\u00AD';

final Hyphenator hyphenator = Hyphenator(Language_en_us());

// Inserts soft hyphens into every word of `text` at syllable boundaries.
// Non-word characters (spaces, punctuation) pass through unchanged.
String hyphenateText(String text) {
  return hyphenator.hyphenateText(text);
}

// Routes a sentence to the correct hyphenation strategy: markup-aware
// for sentences containing highlight tags, plain for everything else.
String hyphenateSentence(String text) {
  final bool hasMarkup = text.contains('<c:');

  if (hasMarkup) {
    return hyphenateAroundMarkup(text);
  }

  return hyphenateText(text);
}

// Hyphenates only the prose portions of a markup sentence, leaving
// `<c:g>`, `</c:g>`, `<c:r>`, `</c:r>` tags untouched.
String hyphenateAroundMarkup(String text) {
  final RegExp markupTag = RegExp(r'</?c:[gr]>');
  final StringBuffer result = StringBuffer();
  int lastEnd = 0;

  for (final RegExpMatch match in markupTag.allMatches(text)) {
    final bool hasProseBeforeTag = match.start > lastEnd;

    if (hasProseBeforeTag) {
      result.write(hyphenateText(text.substring(lastEnd, match.start)));
    }

    result.write(match.group(0));
    lastEnd = match.end;
  }

  final bool hasTrailingProse = lastEnd < text.length;

  if (hasTrailingProse) {
    result.write(hyphenateText(text.substring(lastEnd)));
  }

  return result.toString();
}

// Resolves which soft hyphens in `text` are actually visible (caused a line
// break at the given width) and replaces those with a real hyphen-minus.
// All other soft hyphens are stripped so the final string is ready to render
// without further processing.
//
// Uses a two-pass approach: first detects breaks on the soft-hyphen text,
// then verifies against the resolved text. This is needed because replacing
// a zero-width soft hyphen with a visible '-' changes text metrics, which
// can cause reflow (a break detected in pass 1 may no longer exist after
// the '-' character shifts the layout).
//
// This is expensive (two TextPainter layouts) so callers should cache the
// result and only recompute when the available width changes.
String resolveVisibleHyphens(
  String text,
  TextStyle style,
  double maxWidth,
  TextAlign textAlign,
) {
  final bool hasNoSoftHyphens = !text.contains(softHyphen);

  if (hasNoSoftHyphens) {
    return text;
  }

  // * Pass 1: detect which soft hyphens caused line breaks.

  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: textAlign,
  )..layout(maxWidth: maxWidth);

  final Set<int> breakPositions = {};

  for (int charIndex = 0; charIndex < text.length; charIndex++) {
    final bool isSoftHyphen = text[charIndex] == softHyphen;

    if (!isSoftHyphen) {
      continue;
    }

    final Offset caretBefore = painter.getOffsetForCaret(
      TextPosition(offset: charIndex),
      Rect.zero,
    );

    final Offset caretAfter = painter.getOffsetForCaret(
      TextPosition(offset: charIndex + 1),
      Rect.zero,
    );

    final bool isOnDifferentLine = (caretAfter.dy - caretBefore.dy).abs() > 1.0;

    if (isOnDifferentLine) {
      breakPositions.add(charIndex);
    }
  }

  painter.dispose();

  // Build the resolved string and track where we inserted dashes.
  final StringBuffer resolved = StringBuffer();
  final List<int> insertedDashPositions = [];
  int resolvedIndex = 0;

  for (int charIndex = 0; charIndex < text.length; charIndex++) {
    final bool isSoftHyphenChar = text[charIndex] == softHyphen;

    if (!isSoftHyphenChar) {
      resolved.write(text[charIndex]);
      resolvedIndex++;
      continue;
    }

    final bool isVisibleBreak = breakPositions.contains(charIndex);

    if (isVisibleBreak) {
      resolved.write('-');
      insertedDashPositions.add(resolvedIndex);
      resolvedIndex++;
    }
  }

  final String resolvedText = resolved.toString();

  final bool hasNoDashes = insertedDashPositions.isEmpty;

  if (hasNoDashes) {
    return resolvedText;
  }

  // * Pass 2: verify each inserted '-' is still at a line break after reflow.
  // Replacing zero-width \u00AD with a visible '-' changes text metrics, so
  // a break detected in pass 1 might no longer exist in the resolved layout.

  final TextPainter verifier = TextPainter(
    text: TextSpan(text: resolvedText, style: style),
    textDirection: TextDirection.ltr,
    textAlign: textAlign,
  )..layout(maxWidth: maxWidth);

  final Set<int> falsePositives = {};

  for (final int dashPos in insertedDashPositions) {
    final Offset dashCaret = verifier.getOffsetForCaret(
      TextPosition(offset: dashPos),
      Rect.zero,
    );

    final Offset afterDashCaret = verifier.getOffsetForCaret(
      TextPosition(offset: dashPos + 1),
      Rect.zero,
    );

    final bool isStillAtLineBreak =
        (afterDashCaret.dy - dashCaret.dy).abs() > 1.0;

    if (!isStillAtLineBreak) {
      falsePositives.add(dashPos);
    }
  }

  verifier.dispose();

  final bool allDashesValid = falsePositives.isEmpty;

  if (allDashesValid) {
    return resolvedText;
  }

  // Strip false-positive dashes that ended up mid-line after reflow.
  final StringBuffer cleaned = StringBuffer();

  for (int i = 0; i < resolvedText.length; i++) {
    final bool isFalsePositiveDash = falsePositives.contains(i);

    if (!isFalsePositiveDash) {
      cleaned.write(resolvedText[i]);
    }
  }

  return cleaned.toString();
}

// Resolves visible hyphens for markup-containing sentences. Strips the markup
// tags, resolves hyphens on the clean (rendered) text, then maps the same
// break/strip decisions back onto the original markup string so tags remain
// intact.
String resolveVisibleHyphensForMarkup(
  String markupText,
  TextStyle style,
  double maxWidth,
  TextAlign textAlign,
) {
  final bool hasNoSoftHyphens = !markupText.contains(softHyphen);

  if (hasNoSoftHyphens) {
    return markupText;
  }

  // Strip tags to get the text as Flutter will actually render it.
  final String cleanText = markupText.replaceAll(RegExp(r'</?c:[gr]>'), '');
  final String resolvedClean = resolveVisibleHyphens(cleanText, style, maxWidth, textAlign);

  // Determine which soft hyphens (by sequential order in clean text) became
  // visible dashes vs were stripped. Walk both strings in parallel: non-hyphen
  // characters advance both pointers, soft hyphens either map to a '-' in the
  // resolved output (breaking) or are absent (non-breaking).
  final Set<int> breakingHyphenOrdinals = {};
  int softHyphenOrdinal = 0;
  int resolvedPos = 0;

  for (int i = 0; i < cleanText.length; i++) {
    final bool isSoftHyphenChar = cleanText[i] == softHyphen;

    if (isSoftHyphenChar) {
      final bool becameDash =
          resolvedPos < resolvedClean.length && resolvedClean[resolvedPos] == '-';

      if (becameDash) {
        breakingHyphenOrdinals.add(softHyphenOrdinal);
        resolvedPos++;
      }

      softHyphenOrdinal++;
    } else {
      resolvedPos++;
    }
  }

  // Apply the same transformations to the markup string, preserving tags.
  final RegExp tagPattern = RegExp(r'</?c:[gr]>');
  final StringBuffer result = StringBuffer();
  int hyphenOrdinal = 0;
  int lastEnd = 0;

  for (final RegExpMatch match in tagPattern.allMatches(markupText)) {
    // Process prose characters before this tag.
    for (int i = lastEnd; i < match.start; i++) {
      final bool isSoftHyphenChar = markupText[i] == softHyphen;

      if (isSoftHyphenChar) {
        final bool isBreaking = breakingHyphenOrdinals.contains(hyphenOrdinal);

        if (isBreaking) {
          result.write('-');
        }

        hyphenOrdinal++;
      } else {
        result.write(markupText[i]);
      }
    }

    // Write the tag verbatim.
    result.write(match.group(0));
    lastEnd = match.end;
  }

  // Process trailing prose after the last tag.
  for (int i = lastEnd; i < markupText.length; i++) {
    final bool isSoftHyphenChar = markupText[i] == softHyphen;

    if (isSoftHyphenChar) {
      final bool isBreaking = breakingHyphenOrdinals.contains(hyphenOrdinal);

      if (isBreaking) {
        result.write('-');
      }

      hyphenOrdinal++;
    } else {
      result.write(markupText[i]);
    }
  }

  return result.toString();
}
