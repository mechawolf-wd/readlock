import 'package:flutter/material.dart';

class RLTheme {
  // Light theme colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryGreen = Color(0xFF388E3C);
  static const Color primaryBrown = Color(0xFF8D6E63); // Brown
  static const Color primaryDeepPurple = Color(
    0xFF7B1FA2,
  ); // Deep Purple

  static const Color backgroundDark = Color(
    0xFFFFFFFF,
  ); // White background
  static const Color backgroundLight = Color(
    0xFFF5F5F5,
  ); // Light grey background
  static const Color textPrimary = Color(0xFF212121); // Dark text
  static const Color textSecondary = Color(0xFF757575); // Grey text

  // Additional color constants
  static const Color greyBackground = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF); // White color

  // Status colors
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color warningColorGentle = Color(0xFFFF9800);

  // Essential extended colors for content widgets
  static final Color grey300 =
      Colors.grey[300] ?? const Color(0xFFE0E0E0);
  static final Color grey400 =
      Colors.grey[400] ?? const Color(0xFFBDBDBD);
  static final Color grey600 =
      Colors.grey[600] ?? const Color(0xFF757575);
  static final Color blue50 =
      Colors.blue[50] ?? const Color(0xFFE3F2FD);
  static final Color blue100 =
      Colors.blue[100] ?? const Color(0xFFBBDEFB);
  static final Color blue200 =
      Colors.blue[200] ?? const Color(0xFF90CAF9);
  static final Color blue600 =
      Colors.blue[600] ?? const Color(0xFF1E88E5);
  static final Color green600 =
      Colors.green[600] ?? const Color(0xFF43A047);
  static final Color green800 =
      Colors.green[800] ?? const Color(0xFF2E7D32);
  static final Color brown50 = const Color(0xFFFDF5E6);
  static final Color brown200 = const Color(0xFFDEB887);
  static final Color amber50 =
      Colors.amber[50] ?? const Color(0xFFFFF8E1);
  static final Color amber200 =
      Colors.amber[200] ?? const Color(0xFFFFE082);
  static final Color amber700 =
      Colors.amber[700] ?? const Color(0xFFFFA000);
  static final Color grey50 =
      Colors.grey[50] ?? const Color(0xFFFAFAFA);

  // Border Radius
  static const double radiusMedium = 12.0;

  // Card specific properties
  static const double cardBorderRadius = 8.0;
  static const double cardPadding = 16.0;
  static const double cardMarginBottom = 12.0;
  static final Color cardBackgroundColor =
      Colors.grey[50] ?? const Color(0xFFFAFAFA);
  static final Color cardBorderColor =
      Colors.grey[300] ?? const Color(0xFFE0E0E0);
  static const double cardBorderWidth = 1.0;

  // Content padding
  static const double contentPadding = 24.0;
  static const double contentPaddingSmall = 20.0;
  static const double contentPaddingMedium = 12.0;
  static const double contentPaddingTiny = 4.0;
  static const double contentPaddingSmaller = 8.0;

  // Alpha transparency constants
  static const double alphaVeryLight = 0.05;
  static const double alphaLight = 0.1;
  static const double alphaMedium = 0.2;
  static const double alphaHeavy = 0.3;
  static const double alphaDark = 0.8;
  static const double alphaOpaque = 0.9;

  // Navigation transitions
  static const Duration transitionDuration = Duration(
    milliseconds: 300,
  );
  static const Curve transitionCurve = Curves.easeInOut;

  static PageRouteBuilder<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: transitionDuration,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
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

  static BoxDecoration getContainerDecoration({
    required Color backgroundColor,
    required Color borderColor,
    double borderRadius = radiusMedium,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
    );
  }

  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      border: Border.all(color: cardBorderColor),
    );
  }

  static EdgeInsets get cardPaddingInsets =>
      const EdgeInsets.all(cardPadding);

  static EdgeInsets get cardMarginInsets =>
      const EdgeInsets.only(bottom: cardMarginBottom);

  static EdgeInsets get screenPaddingInsets =>
      const EdgeInsets.all(cardPadding);

  static EdgeInsets get contentPaddingInsets =>
      const EdgeInsets.all(contentPadding);

  static EdgeInsets get contentPaddingSmallInsets =>
      const EdgeInsets.all(contentPaddingSmall);

  static EdgeInsets get contentPaddingMediumInsets =>
      const EdgeInsets.all(contentPaddingMedium);

  static EdgeInsets get contentPaddingTinyInsets =>
      const EdgeInsets.all(contentPaddingTiny);

  static EdgeInsets get contentPaddingSmallerInsets =>
      const EdgeInsets.all(contentPaddingSmaller);

  static EdgeInsets get contentPaddingVerticalInsets =>
      const EdgeInsets.symmetric(vertical: contentPadding);

  static EdgeInsets get contentPaddingHorizontalInsets =>
      const EdgeInsets.symmetric(horizontal: contentPadding);
}
