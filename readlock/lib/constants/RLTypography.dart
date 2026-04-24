// Readlock Typography System
// Three font families: display (8-bit), UI (clean), reading (reader-picked)
//
// Display — Press Start 2P: headings, author names, standout elements
// UI — JetBrains MONO: buttons, labels, menus, general interface text
// Reading — reader picks one of three (Lora / Lexend / JetBrains Mono) in
// Settings. See RLReadingFont for the selection plumbing — readingLargeStyle
// and readingMediumStyle are getters that consult selectedReadingFontNotifier
// at read time, so a Settings change flows into every rebuild of reading
// content.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingFont.dart';

class RLTypography {
  // * Display font — Press Start 2P (8-bit, for headings and standout elements)

  static final TextStyle headingLargeStyle = GoogleFonts.pressStart2p(
    fontSize: 20,
    fontWeight: RLDS.weightBold,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: -0.3,
  );

  static final TextStyle headingMediumStyle = GoogleFonts.pressStart2p(
    fontSize: 14,
    fontWeight: RLDS.weightSemibold,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: -0.2,
  );

  // Small pixel-font caption (e.g., roadmap tile titles).
  static final TextStyle pixelLabelStyle = GoogleFonts.pressStart2p(
    fontSize: 9,
    fontWeight: RLDS.weightSemibold,
    color: RLDS.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  // Large pixel-font number (e.g., level number inside a roadmap tile).
  static final TextStyle pixelNumberStyle = GoogleFonts.pressStart2p(
    fontSize: 20,
    fontWeight: RLDS.weightBold,
    color: RLDS.textPrimary,
    height: 1.0,
    letterSpacing: 0,
  );

  // * UI font — JetBrains MONO (clean, for buttons, labels, menus)

  static final TextStyle bodyLargeStyle = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: RLDS.weightMedium,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle bodyMediumStyle = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static final TextStyle bodySmallStyle = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textSecondary,
    height: 1.5,
    letterSpacing: 0.2,
  );

  // * Reading font — selectable (Lora / Lexend / JetBrains Mono).
  //
  // The size/weight/colour/height attributes are fixed on the app side; only
  // the font family switches with the reader's preference. `readingStyleFor`
  // applies the picked GoogleFonts family to this base style.

  // Reading weight is shared across readingLarge / readingMedium so every CC
  // reading surface (text content, reflect points, question answers, quote
  // body, feedback sheets) renders at the same density — only size differs.
  // Markup-highlighted spans (<c:g>…</c:g>) and the bionic-fixation prefix
  // are the two sanctioned bold exceptions; both are applied locally at
  // render time, not on the base style.
  static const TextStyle readingLargeBase = TextStyle(
    fontSize: 18,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textPrimary,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle readingMediumBase = TextStyle(
    fontSize: 16,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textPrimary,
    height: 1.6,
    letterSpacing: 0.15,
  );

  // Per-font builders — useful when a caller needs to preview a specific
  // font (e.g. the font-picker demo) without switching the global selection.
  static TextStyle readingLargeStyleFor(ReadingFont font) {
    return readingStyleFor(font, readingLargeBase);
  }

  static TextStyle readingMediumStyleFor(ReadingFont font) {
    return readingStyleFor(font, readingMediumBase);
  }

  // Getters read the current selection at access time. Any widget that
  // rebuilds after a font change will pick up the new family automatically;
  // screens that want live updates mid-view can wrap their reading surface
  // in a ValueListenableBuilder on selectedReadingFontNotifier.
  static TextStyle get readingLargeStyle {
    return readingLargeStyleFor(selectedReadingFontNotifier.value);
  }

  static TextStyle get readingMediumStyle {
    return readingMediumStyleFor(selectedReadingFontNotifier.value);
  }

  // * Display text widgets

  static Widget headingLarge(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? headingLargeStyle.copyWith(color: color)
        : headingLargeStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget headingMedium(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? headingMediumStyle.copyWith(color: color)
        : headingMediumStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget pixelLabel(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? pixelLabelStyle.copyWith(color: color)
        : pixelLabelStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget pixelNumber(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? pixelNumberStyle.copyWith(color: color)
        : pixelNumberStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  // * UI text widgets

  static Widget bodyLarge(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? bodyLargeStyle.copyWith(color: color)
        : bodyLargeStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget bodyMedium(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? bodyMediumStyle.copyWith(color: color)
        : bodyMediumStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget bodySmall(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? bodySmallStyle.copyWith(color: color)
        : bodySmallStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget text(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? bodyMediumStyle.copyWith(color: color)
        : bodyMediumStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  // * Reading text widgets

  static Widget readingLarge(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? readingLargeStyle.copyWith(color: color)
        : readingLargeStyle;

    return Text(content, style: style, textAlign: textAlign);
  }

  static Widget readingMedium(String content, {Color? color, TextAlign? textAlign}) {
    final TextStyle style = color != null
        ? readingMediumStyle.copyWith(color: color)
        : readingMediumStyle;

    return Text(content, style: style, textAlign: textAlign);
  }
}
