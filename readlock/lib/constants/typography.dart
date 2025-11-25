// Self-contained typography system with built-in text styles
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RLTypography {
  // Base color definitions for light theme
  static const Color TEXT_PRIMARY = Color(0xFF212121);
  static const Color TEXT_SECONDARY = Color(0xFF757575);

  // Typography styles
  static final TextStyle headingLargeStyle = GoogleFonts.merriweather(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: TEXT_PRIMARY,
    height: 1.4,
  );

  static final TextStyle headingMediumStyle = GoogleFonts.merriweather(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: TEXT_PRIMARY,
    height: 1.5,
  );

  static final TextStyle bodyLargeStyle = GoogleFonts.merriweather(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: TEXT_PRIMARY,
    height: 1.6,
  );

  static final TextStyle bodyMediumStyle = GoogleFonts.merriweather(
    fontSize: 16,
    color: TEXT_PRIMARY,
    height: 1.6,
  );

  // Text widget methods
  static Text text(
    String content, {
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      content,
      style: color != null
          ? bodyMediumStyle.copyWith(color: color)
          : bodyMediumStyle,
      textAlign: textAlign,
    );
  }

  static Text headingLarge(
    String content, {
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      content,
      style: color != null
          ? headingLargeStyle.copyWith(color: color)
          : headingLargeStyle,
      textAlign: textAlign,
    );
  }

  static Text headingMedium(
    String content, {
    TextAlign? textAlign,
    Color? color,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      content,
      style: color != null
          ? headingMediumStyle.copyWith(color: color)
          : headingMediumStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  static Text bodyLarge(
    String content, {
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      content,
      style: color != null
          ? bodyLargeStyle.copyWith(color: color)
          : bodyLargeStyle,
      textAlign: textAlign,
    );
  }

  static Text bodyMedium(
    String content, {
    TextAlign? textAlign,
    Color? color,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      content,
      style: color != null
          ? bodyMediumStyle.copyWith(color: color)
          : bodyMediumStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
