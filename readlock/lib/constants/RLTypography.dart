// Readlock Typography System
// Centralized text styles and text widgets for consistent typography across the app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLTypography {
  // * Text styles — use for .copyWith() and direct style references

  static final TextStyle headingLargeStyle = GoogleFonts.bricolageGrotesque(
    fontSize: 28,
    fontWeight: RLDS.weightBold,
    color: RLDS.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static final TextStyle headingMediumStyle = GoogleFonts.bricolageGrotesque(
    fontSize: 22,
    fontWeight: RLDS.weightSemibold,
    color: RLDS.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static final TextStyle bodyLargeStyle = GoogleFonts.bricolageGrotesque(
    fontSize: 16,
    fontWeight: RLDS.weightMedium,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle bodyMediumStyle = GoogleFonts.bricolageGrotesque(
    fontSize: 14,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static final TextStyle bodySmallStyle = GoogleFonts.bricolageGrotesque(
    fontSize: 12,
    fontWeight: RLDS.weightRegular,
    color: RLDS.textSecondary,
    height: 1.5,
    letterSpacing: 0.2,
  );

  // * Text widgets — use in widget tree instead of raw Text()

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
}
