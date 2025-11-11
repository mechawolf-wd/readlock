// Self-contained typography system with built-in text styles
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Typography {
  // Base color definitions
  static const Color TEXT_PRIMARY = Color(0xFFE0E0E0);
  static const Color TEXT_SECONDARY = Color(0xFFB0B0B0);
  static const Color TEXT_TERTIARY = Color(0xFF808080);

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
  static Text text(String content, {TextAlign? textAlign}) {
    return Text(content, style: bodyMediumStyle, textAlign: textAlign);
  }

  static Text headingLarge(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: headingLargeStyle,
      textAlign: textAlign,
    );
  }

  static Text headingMedium(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: headingMediumStyle,
      textAlign: textAlign,
    );
  }

  static Text bodyLarge(String content, {TextAlign? textAlign}) {
    return Text(content, style: bodyLargeStyle, textAlign: textAlign);
  }

  static Text bodyMedium(String content, {TextAlign? textAlign}) {
    return Text(content, style: bodyMediumStyle, textAlign: textAlign);
  }
}
