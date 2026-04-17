// Readlock Typography System
// Three font families: display (8-bit), UI (clean), reading (serif)
//
// Display — Press Start 2P: headings, author names, standout elements
// UI — Poppins: buttons, labels, menus, general interface text
// Reading — Playfair Display: course swipe content, long-form text

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

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

  // * UI font — Poppins (clean, for buttons, labels, menus)

  static final TextStyle bodyLargeStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: RLDS.weightMedium,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle bodyMediumStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static final TextStyle bodySmallStyle = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textSecondary,
    height: 1.5,
    letterSpacing: 0.2,
  );

  // * Reading font — Playfair Display (for course swipe content)

  static final TextStyle readingLargeStyle = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: RLDS.weightMedium,
    color: RLDS.textPrimary,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static final TextStyle readingMediumStyle = GoogleFonts.playfairDisplay(
    fontSize: 16,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textPrimary,
    height: 1.6,
    letterSpacing: 0.15,
  );

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
