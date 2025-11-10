// Self-contained typography system with built-in text styles
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Typography {
  // Base color definitions
  static const Color TEXT_PRIMARY = Color(0xFFE0E0E0);
  static const Color TEXT_SECONDARY = Color(0xFFB0B0B0);
  static const Color TEXT_TERTIARY = Color(0xFF808080);

  // Typography styles
  static final TextStyle headingLargeStyle = GoogleFonts.crimsonText(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: TEXT_PRIMARY,
    height: 1.2,
  );

  static final TextStyle headingMediumStyle = GoogleFonts.crimsonText(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: TEXT_PRIMARY,
    height: 1.3,
  );

  static final TextStyle headingSmallStyle = GoogleFonts.crimsonText(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: TEXT_PRIMARY,
    height: 1.4,
  );

  static final TextStyle bodyLargeStyle = GoogleFonts.crimsonText(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: TEXT_PRIMARY,
    height: 1.5,
  );

  static final TextStyle bodyMediumStyle = GoogleFonts.crimsonText(
    fontSize: 16,
    color: TEXT_PRIMARY,
    height: 1.4,
  );

  static final TextStyle bodySmallStyle = GoogleFonts.crimsonText(
    fontSize: 14,
    color: TEXT_SECONDARY,
    height: 1.3,
  );

  static final TextStyle captionTextStyle = GoogleFonts.crimsonText(
    fontSize: 12,
    color: TEXT_TERTIARY,
    height: 1.2,
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

  static Text headingSmall(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: headingSmallStyle,
      textAlign: textAlign,
    );
  }

  static Text bodyLarge(String content, {TextAlign? textAlign}) {
    return Text(content, style: bodyLargeStyle, textAlign: textAlign);
  }

  static Text bodyMedium(String content, {TextAlign? textAlign}) {
    return Text(content, style: bodyMediumStyle, textAlign: textAlign);
  }

  static Text bodySmall(String content, {TextAlign? textAlign}) {
    return Text(content, style: bodySmallStyle, textAlign: textAlign);
  }

  static Text captionText(String content, {TextAlign? textAlign}) {
    return Text(content, style: captionTextStyle, textAlign: textAlign);
  }
}
