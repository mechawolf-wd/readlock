// Geomates Typography System
// Centralized text styles for consistent typography across the app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLTypography {
  // * Text styles — ordered by size descending

  // * Headings

  static final TextStyle headingLarge = GoogleFonts.bricolageGrotesque(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: RLDS.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static final TextStyle headingMedium = GoogleFonts.bricolageGrotesque(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: RLDS.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  // * Body

  static final TextStyle bodyLarge = GoogleFonts.bricolageGrotesque(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle bodyMedium = GoogleFonts.bricolageGrotesque(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: RLDS.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static final TextStyle bodySmall = GoogleFonts.bricolageGrotesque(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: RLDS.textSecondary,
    height: 1.5,
    letterSpacing: 0.2,
  );
}
