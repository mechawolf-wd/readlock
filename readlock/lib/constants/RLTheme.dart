import 'package:flutter/material.dart';

class RLTheme {
  // Base colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Primary colors
  static const Color primaryBlue = Color.fromARGB(255, 59, 154, 233);
  static const Color primaryGreen = Color.fromARGB(255, 70, 183, 76);

  // Background colors
  static const Color backgroundDark = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Status colors
  static const Color successColor = Color.fromARGB(255, 81, 230, 86);
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  // Status shades for UI feedback
  static final Color successDark = Colors.green.shade600;
  static final Color errorDark = Colors.red.shade600;
  static final Color warningDark = Colors.orange.shade600;
  static final Color warningLight = Colors.orange.shade400;

  // Accent colors
  static const Color accentPurple = Colors.purple;
  static const Color accentTeal = Colors.teal;
  static const Color accentIndigo = Colors.indigo;
  static const Color accentPink = Colors.pink;
  static const Color accentCyan = Colors.cyan;
  static const Color accentAmber = Colors.amber;
  static const Color accentBrown = Colors.brown;
  static const Color accentYellow = Colors.yellow;
  static const Color accentLime = Colors.lime;

  // Grey shades
  static final Color grey300 = Colors.grey[300] ?? const Color(0xFFE0E0E0);
  static final Color grey400 = Colors.grey[400] ?? const Color(0xFFBDBDBD);
  static final Color grey600 = Colors.grey[600] ?? const Color(0xFF757575);

  // Border radius
  static const double radiusMedium = 12.0;

  // Card properties
  static const double cardBorderRadius = 8.0;
  static const double cardPadding = 16.0;
  static const double cardMarginBottom = 12.0;
  static final Color cardBackgroundColor =
      Colors.grey[50] ?? const Color(0xFFFAFAFA);
  static final Color cardBorderColor =
      Colors.grey[300] ?? const Color(0xFFE0E0E0);
  static const double cardBorderWidth = 1.0;

  // Content padding values
  static const double contentPadding = 24.0;
  static const double contentPaddingSmall = 20.0;
  static const double contentPaddingMedium = 12.0;
  static const double contentPaddingTiny = 4.0;
  static const double contentPaddingSmaller = 8.0;

  // Navigation transitions
  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Curve transitionCurve = Curves.easeInOut;

  static PageRouteBuilder<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: transitionCurve,
            ),
          ),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> slideUpTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: transitionCurve,
            ),
          ),
          child: child,
        );
      },
    );
  }

  // EdgeInsets getters
  static EdgeInsets get contentPaddingInsets =>
      const EdgeInsets.all(contentPadding);

  static EdgeInsets get contentPaddingMediumInsets =>
      const EdgeInsets.all(contentPaddingMedium);
}
