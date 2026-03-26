// Geomates Design System
// Centralized design variables for consistent styling across the app
// Simple design: no glows, no gradients, no shadows, 1px borders
//
// Colors defined using HSL (Hue, Saturation, Lightness) for clarity.

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';

class RLDS {
  // * HSL helper

  static Color colorFromHSL(double h, double s, double l, [double a = 1.0]) {
    return HSLColor.fromAHSL(a, h, s, l).toColor();
  }

  // * Color palettes
  // * HSL values with individual hues per shade

  // * Harlequin — primary (Geomates brand)

  static final Color primary50 = colorFromHSL(94, 1.00, 0.95);
  static final Color primary100 = colorFromHSL(96, 1.00, 0.89);
  static final Color primary200 = colorFromHSL(97, 1.00, 0.80);
  static final Color primary300 = colorFromHSL(98, 0.95, 0.67);
  static final Color primary400 = colorFromHSL(99, 0.88, 0.55);
  static final Color primary500 = colorFromHSL(100, 0.90, 0.49);
  static final Color primary600 = colorFromHSL(101, 0.95, 0.35);
  static final Color primary700 = colorFromHSL(102, 0.88, 0.27);
  static final Color primary800 = colorFromHSL(102, 0.78, 0.23);
  static final Color primary900 = colorFromHSL(104, 0.69, 0.20);
  static final Color primary1000 = colorFromHSL(104, 0.69, 0.08);

  // * Cod gray

  static final Color grey50 = colorFromHSL(120, 0.09, 0.98);
  static final Color grey100 = colorFromHSL(120, 0.05, 0.96);
  static final Color grey200 = colorFromHSL(60, 0.02, 0.90);
  static final Color grey300 = colorFromHSL(60, 0.01, 0.83);
  static final Color grey400 = colorFromHSL(60, 0.01, 0.64);
  static final Color grey500 = colorFromHSL(75, 0.02, 0.45);
  static final Color grey600 = colorFromHSL(80, 0.02, 0.32);
  static final Color grey700 = colorFromHSL(60, 0.02, 0.25);
  static final Color grey800 = colorFromHSL(60, 0.01, 0.15);
  static final Color grey900 = colorFromHSL(60, 0.02, 0.10);
  static final Color grey1000 = colorFromHSL(60, 0.02, 0.05);

  // * Deep Cerulean — secondary

  static final Color blue50 = colorFromHSL(198, 0.87, 0.97);
  static final Color blue100 = colorFromHSL(201, 0.81, 0.94);
  static final Color blue200 = colorFromHSL(198, 0.83, 0.86);
  static final Color blue300 = colorFromHSL(198, 0.85, 0.74);
  static final Color blue400 = colorFromHSL(196, 0.83, 0.60);
  static final Color blue500 = colorFromHSL(196, 0.79, 0.48);
  static final Color blue600 = colorFromHSL(198, 0.87, 0.39);
  static final Color blue700 = colorFromHSL(199, 0.85, 0.32);
  static final Color blue800 = colorFromHSL(199, 0.80, 0.27);
  static final Color blue900 = colorFromHSL(200, 0.70, 0.24);
  static final Color blue1000 = colorFromHSL(200, 0.70, 0.08);

  // * Green

  static final Color green50 = colorFromHSL(120, 1.00, 0.95);
  static final Color green100 = colorFromHSL(123, 1.00, 0.89);
  static final Color green200 = colorFromHSL(124, 1.00, 0.80);
  static final Color green300 = colorFromHSL(126, 0.95, 0.67);
  static final Color green400 = colorFromHSL(126, 0.88, 0.55);
  static final Color green500 = colorFromHSL(127, 0.90, 0.49);
  static final Color green600 = colorFromHSL(128, 0.95, 0.35);
  static final Color green700 = colorFromHSL(129, 0.88, 0.27);
  static final Color green800 = colorFromHSL(129, 0.78, 0.23);
  static final Color green900 = colorFromHSL(131, 0.69, 0.20);
  static final Color green1000 = colorFromHSL(131, 0.69, 0.08);

  // * Trinidad

  static final Color vermilion50 = colorFromHSL(33, 1.00, 0.96);
  static final Color vermilion100 = colorFromHSL(34, 1.00, 0.92);
  static final Color vermilion200 = colorFromHSL(31, 0.98, 0.83);
  static final Color vermilion300 = colorFromHSL(30, 0.97, 0.72);
  static final Color vermilion400 = colorFromHSL(26, 0.96, 0.61);
  static final Color vermilion500 = colorFromHSL(24, 0.95, 0.53);
  static final Color vermilion600 = colorFromHSL(20, 0.90, 0.49);
  static final Color vermilion700 = colorFromHSL(17, 0.88, 0.40);
  static final Color vermilion800 = colorFromHSL(15, 0.79, 0.34);
  static final Color vermilion900 = colorFromHSL(15, 0.75, 0.28);
  static final Color vermilion1000 = colorFromHSL(15, 0.75, 0.08);

  // * Red

  static final Color red50 = colorFromHSL(8, 1.00, 0.97);
  static final Color red100 = colorFromHSL(7, 1.00, 0.94);
  static final Color red200 = colorFromHSL(7, 1.00, 0.88);
  static final Color red300 = colorFromHSL(7, 1.00, 0.80);
  static final Color red400 = colorFromHSL(7, 1.00, 0.69);
  static final Color red500 = colorFromHSL(7, 1.00, 0.59);
  static final Color red600 = colorFromHSL(7, 0.90, 0.49);
  static final Color red700 = colorFromHSL(7, 0.92, 0.42);
  static final Color red800 = colorFromHSL(7, 0.88, 0.35);
  static final Color red900 = colorFromHSL(7, 0.78, 0.31);
  static final Color red1000 = colorFromHSL(7, 0.78, 0.08);

  // * Magenta / fuchsia

  static final Color pink50 = colorFromHSL(305, 1.00, 0.97);
  static final Color pink100 = colorFromHSL(300, 1.00, 0.95);
  static final Color pink200 = colorFromHSL(301, 1.00, 0.89);
  static final Color pink300 = colorFromHSL(304, 1.00, 0.81);
  static final Color pink400 = colorFromHSL(304, 1.00, 0.70);
  static final Color pink500 = colorFromHSL(302, 1.00, 0.59);
  static final Color pink600 = colorFromHSL(301, 0.90, 0.49);
  static final Color pink700 = colorFromHSL(302, 0.94, 0.40);
  static final Color pink800 = colorFromHSL(303, 0.92, 0.33);
  static final Color pink900 = colorFromHSL(304, 0.83, 0.28);
  static final Color pink1000 = colorFromHSL(304, 0.83, 0.08);

  // * Turquoise blue

  static final Color teal50 = colorFromHSL(180, 1.00, 0.96);
  static final Color teal100 = colorFromHSL(181, 1.00, 0.90);
  static final Color teal200 = colorFromHSL(182, 0.98, 0.82);
  static final Color teal300 = colorFromHSL(183, 0.97, 0.69);
  static final Color teal400 = colorFromHSL(184, 0.90, 0.49);
  static final Color teal500 = colorFromHSL(185, 1.00, 0.43);
  static final Color teal600 = colorFromHSL(188, 0.97, 0.36);
  static final Color teal700 = colorFromHSL(189, 0.87, 0.31);
  static final Color teal800 = colorFromHSL(191, 0.74, 0.27);
  static final Color teal900 = colorFromHSL(193, 0.67, 0.24);
  static final Color teal1000 = colorFromHSL(193, 0.67, 0.08);

  // * Aquamarine

  static final Color cyan50 = colorFromHSL(161, 1.00, 0.96);
  static final Color cyan100 = colorFromHSL(158, 1.00, 0.89);
  static final Color cyan200 = colorFromHSL(160, 1.00, 0.80);
  static final Color cyan300 = colorFromHSL(163, 1.00, 0.67);
  static final Color cyan400 = colorFromHSL(165, 0.90, 0.49);
  static final Color cyan500 = colorFromHSL(165, 1.00, 0.43);
  static final Color cyan600 = colorFromHSL(166, 1.00, 0.35);
  static final Color cyan700 = colorFromHSL(168, 1.00, 0.28);
  static final Color cyan800 = colorFromHSL(168, 1.00, 0.22);
  static final Color cyan900 = colorFromHSL(170, 1.00, 0.18);
  static final Color cyan1000 = colorFromHSL(170, 1.00, 0.08);

  // * Electric primary

  static final Color indigo50 = colorFromHSL(284, 1.00, 0.98);
  static final Color indigo100 = colorFromHSL(282, 1.00, 0.95);
  static final Color indigo200 = colorFromHSL(281, 1.00, 0.91);
  static final Color indigo300 = colorFromHSL(282, 1.00, 0.83);
  static final Color indigo400 = colorFromHSL(282, 1.00, 0.73);
  static final Color indigo500 = colorFromHSL(282, 1.00, 0.63);
  static final Color indigo600 = colorFromHSL(281, 1.00, 0.55);
  static final Color indigo700 = colorFromHSL(281, 0.90, 0.49);
  static final Color indigo800 = colorFromHSL(282, 0.85, 0.39);
  static final Color indigo900 = colorFromHSL(283, 0.83, 0.32);
  static final Color indigo1000 = colorFromHSL(283, 0.83, 0.08);

  // * Neutral

  static final Color black = grey900;
  static final Color white = Colors.white;

  static const Color transparent = Color(0x00000000);

  // * Text

  static final Color textPrimary = primary1000;
  static final Color textSecondary = grey500;
  static final Color textMuted = grey400;

  // * Social & brand

  static final Color instagramIconColor = const Color(0xFFE1306C);
  static final Color whatsappIconColor = const Color(0xFF25D366);
  static final Color telegramIconColor = const Color(0xFF2AABEE);
  static final Color snapchatIconColor = const Color(0xFFD4A800);
  static final Color googleRed = colorFromHSL(5, 0.70, 0.54);
  static final Color otherContactIconColor = primary900;

  // * Spacing

  static const double spacing2 = 2.0;
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

  // * Border radius presets

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

  // * Primary colors

  static final Color primaryBlue = blue400;
  static final Color primaryGreen = green500;

  // * Background colors

  static final Color backgroundDark = white;
  static final Color backgroundLight = grey50;

  // * Status colors

  static final Color successColor = green400;
  static final Color errorColor = red500;
  static final Color warningColor = vermilion500;

  static final Color successDark = green600;
  static final Color errorDark = red600;
  static final Color warningDark = vermilion600;
  static final Color warningLight = vermilion400;

  // * Accent colors

  static final Color accentPurple = indigo600;
  static final Color accentTeal = teal500;
  static final Color accentIndigo = indigo700;
  static final Color accentPink = pink500;
  static final Color accentCyan = cyan400;
  static final Color accentAmber = colorFromHSL(45, 1.00, 0.50);
  static final Color accentBrown = colorFromHSL(16, 0.25, 0.38);
  static final Color accentYellow = colorFromHSL(54, 1.00, 0.50);
  static final Color accentLime = colorFromHSL(65, 0.70, 0.52);

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
