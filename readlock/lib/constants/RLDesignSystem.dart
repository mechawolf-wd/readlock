// Readlock Design System
// Centralized design variables for consistent styling across the app
// Simple design: no glows, no gradients, no shadows, 1px borders

import 'package:flutter/material.dart';

class RLDS {
  // * Brand colors

  static const Color primary = Color(0xFFE63946); // warm vivid red
  static const Color info = Color(0xFF1E88E5); // bright blue
  static const Color success = Color(0xFF2EAE6E); // fresh green
  static const Color warning = Color(0xFFF5A509); // amber
  static const Color error = Color(0xFFE63946); // shares the primary red

  // * Neutrals

  static const Color surface = Color(0xFF1C1C1E);
  static const Color onSurface = Color(0xFFE5E5E5);
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);
  static const Color transparent = Color(0x00000000);

  // * Backgrounds

  static const Color backgroundDark = surface;
  static const Color backgroundLight = Color(0xFF2C2C2E);

  // * Text

  static const Color textPrimary = onSurface;
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF5A5A5A);

  // * Spacing — all multiples of 4

  static const double spacing0 = 0.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // * Border radius

  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusCircle = 100.0;

  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderRadiusCircle = BorderRadius.circular(radiusCircle);

  static const BorderRadius borderRadiusTopLarge = BorderRadius.only(
    topLeft: Radius.circular(radiusLarge),
    topRight: Radius.circular(radiusLarge),
  );

  // * Font weights

  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // * Strokes

  static const double borderWidth = 2;
  static const double separatorWidth = 48.0;

  // * Icon sizes

  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;
  static const double iconXXLarge = 48.0;

  // * Sheet standardized spacing

  static const double sheetTopPadding = spacing12;
  static const double sheetGrabberToHeadingSpacing = spacing24;
  static const double sheetHeadingToSubheadingSpacing = spacing4;
  static const double sheetSubheadingToContentSpacing = spacing16;

  // * Content padding

  static const EdgeInsets contentPaddingInsets = EdgeInsets.all(spacing24);
  static const EdgeInsets contentPaddingMediumInsets = EdgeInsets.all(spacing12);

  // * Navigation transitions

  static const Curve transitionCurve = Curves.easeInOut;

  static PageRouteBuilder<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: transitionCurve));

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder<T> slowFadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: transitionCurve));

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder<T> slideUpTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<Offset> slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: transitionCurve));

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }
}
