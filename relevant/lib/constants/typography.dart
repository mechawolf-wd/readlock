// Self-contained typography system with built-in text styles
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Typography {
  // Base color definitions
  static const Color TEXT_PRIMARY = Color(0xFFE0E0E0);
  static const Color TEXT_SECONDARY = Color(0xFFB0B0B0);
  static const Color TEXT_TERTIARY = Color(0xFF808080);

  // Typography styles
  static final TextStyle headingLarge = GoogleFonts.crimsonText(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: TEXT_PRIMARY,
    height: 1.2,
  );

  static final TextStyle headingMedium = GoogleFonts.crimsonText(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: TEXT_PRIMARY,
    height: 1.3,
  );

  static final TextStyle headingSmall = GoogleFonts.crimsonText(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: TEXT_PRIMARY,
    height: 1.4,
  );

  static final TextStyle bodyLarge = GoogleFonts.crimsonText(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: TEXT_PRIMARY,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.crimsonText(
    fontSize: 16,
    color: TEXT_PRIMARY,
    height: 1.4,
  );

  static final TextStyle bodySmall = GoogleFonts.crimsonText(
    fontSize: 14,
    color: TEXT_SECONDARY,
    height: 1.3,
  );

  static final TextStyle captionText = GoogleFonts.crimsonText(
    fontSize: 12,
    color: TEXT_TERTIARY,
    height: 1.2,
  );

  // Text widget methods
  static Text text(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: bodyMedium,
      textAlign: textAlign,
    );
  }

  static Text headingLarge(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: headingLarge,
      textAlign: textAlign,
    );
  }

  static Text headingMedium(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: headingMedium,
      textAlign: textAlign,
    );
  }

  static Text headingSmall(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: headingSmall,
      textAlign: textAlign,
    );
  }

  static Text bodyLarge(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: bodyLarge,
      textAlign: textAlign,
    );
  }

  static Text bodyMedium(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: bodyMedium,
      textAlign: textAlign,
    );
  }

  static Text bodySmall(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: bodySmall,
      textAlign: textAlign,
    );
  }

  static Text captionText(String content, {TextAlign? textAlign}) {
    return Text(
      content,
      style: captionText,
      textAlign: textAlign,
    );
  }
}