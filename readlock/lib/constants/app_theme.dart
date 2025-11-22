import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryGreen = Color(0xFF388E3C);
  static const Color primaryBrown = Color(0xFF8D6E63); // Brown
  static const Color primaryAmber = Color(0xFFF57C00); // Amber
  static const Color primaryDeepPurple = Color(
    0xFF7B1FA2,
  ); // Deep Purple

  static const Color backgroundDark = Color(0xFFFFFFFF); // White background
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light grey background
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
  static const Color infoColor = Colors.blue;

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

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

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
  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Curve transitionCurve = Curves.easeInOut;

  static PageRouteBuilder<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: transitionDuration,
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

  // Essential color variants with alpha transparency (used in widgets)
  static Color get primaryDeepPurpleLight =>
      primaryDeepPurple.withValues(alpha: alphaLight);
  static Color get primaryBrownVeryLight =>
      primaryBrown.withValues(alpha: alphaVeryLight);
  static Color get backgroundDarkDark =>
      backgroundDark.withValues(alpha: alphaDark);
  static Color get backgroundLightHeavy =>
      backgroundLight.withValues(alpha: alphaHeavy);
  static Color get primaryBrownMedium =>
      primaryBrown.withValues(alpha: alphaMedium);
  static Color get primaryDeepPurpleMedium =>
      primaryDeepPurple.withValues(alpha: alphaMedium);
  static Color get primaryDeepPurpleHeavy =>
      primaryDeepPurple.withValues(alpha: alphaHeavy);
  static Color get primaryBrownLight =>
      primaryBrown.withValues(alpha: alphaLight);
  static Color get primaryDeepPurpleVeryLight =>
      primaryDeepPurple.withValues(alpha: alphaVeryLight);
  static Color get primaryBrownHeavy =>
      primaryBrown.withValues(alpha: alphaHeavy);
  static Color get blue600Medium =>
      blue600.withValues(alpha: alphaMedium);
  static Color get green600Heavy =>
      green600.withValues(alpha: alphaHeavy);
  static Color get amber700Heavy =>
      amber700.withValues(alpha: alphaHeavy);
  static Color get brown200Heavy =>
      brown200.withValues(alpha: alphaHeavy);
  static Color get blue200Heavy =>
      blue200.withValues(alpha: alphaHeavy);
  static Color get grey300Heavy =>
      grey300.withValues(alpha: alphaHeavy);

  // Typography styles (import from typography.dart)
  static TextStyle get headingLarge => GoogleFonts.merriweather(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get headingSmall => GoogleFonts.merriweather(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.merriweather(
    fontSize: 16,
    color: textPrimary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.merriweather(
    fontSize: 14,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get captionText => GoogleFonts.merriweather(
    fontSize: 12,
    color: textSecondary,
    height: 1.4,
  );


  static ColorScheme getCourseColorScheme(CourseThemeColor color) {
    switch (color) {
      case CourseThemeColor.blue:
        {
          return ColorScheme.fromSeed(
            seedColor: primaryBlue,
            brightness: Brightness.light,
          );
        }
      case CourseThemeColor.green:
        {
          return ColorScheme.fromSeed(
            seedColor: primaryGreen,
            brightness: Brightness.light,
          );
        }
      case CourseThemeColor.purple:
        {
          return ColorScheme.fromSeed(
            seedColor: primaryBrown,
            brightness: Brightness.light,
          );
        }
    }
  }

  static QuestionOptionColors getQuestionOptionColors({
    required bool isSelected,
    required bool shouldShowFeedback,
    required bool isCorrect,
  }) {
    if (shouldShowFeedback) {
      if (isCorrect) {
        return const QuestionOptionColors(
          backgroundColor: Color(0xFFE8F5E8),
          textColor: Color(0xFF2E7D32),
        );
      } else {
        return const QuestionOptionColors(
          backgroundColor: Color(0xFFFFEBEE),
          textColor: Color(0xFFC62828),
        );
      }
    } else if (isSelected) {
      return const QuestionOptionColors(
        backgroundColor: Color(0xFFEFEBE9),
        textColor: AppTheme.primaryBrown,
      );
    } else {
      return const QuestionOptionColors(
        backgroundColor: Color(0xFFFFFFFF),
        textColor: AppTheme.textPrimary,
      );
    }
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


  static ButtonStyle getElevatedButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    double borderRadius = radiusMedium,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.all(spacingL),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
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

class QuestionOptionColors {
  final Color backgroundColor;
  final Color textColor;

  const QuestionOptionColors({
    required this.backgroundColor,
    required this.textColor,
  });
}

enum CourseThemeColor { blue, green, purple }

class ContentBackgroundStyles {
  // Question container
  static BoxDecoration get questionContainer =>
      AppTheme.getContainerDecoration(
        backgroundColor: AppTheme.blue50,
        borderColor: AppTheme.blue200,
      );

  // Reflection container
  static BoxDecoration get reflectionContainer =>
      AppTheme.getContainerDecoration(
        backgroundColor: AppTheme.brown50,
        borderColor: AppTheme.brown200,
      );

  // Explanation container
  static BoxDecoration get explanationContainer =>
      AppTheme.getContainerDecoration(
        backgroundColor: AppTheme.grey50,
        borderColor: AppTheme.grey300,
      );

  // Insight container
  static BoxDecoration get insightContainer =>
      AppTheme.getContainerDecoration(
        backgroundColor: AppTheme.amber50,
        borderColor: AppTheme.amber200,
      );

  // Scenario container
  static BoxDecoration get scenarioContainer =>
      AppTheme.getContainerDecoration(
        backgroundColor: AppTheme.grey50,
        borderColor: AppTheme.grey300,
      );

  // Follow-up container
  static BoxDecoration get followUpContainer =>
      AppTheme.getContainerDecoration(
        backgroundColor: AppTheme.blue50,
        borderColor: AppTheme.blue200,
      );
}

class AppIcons {
  static const IconData psychology = Icons.psychology;
  static const IconData lightbulbOutline = Icons.lightbulb_outline;
  static const IconData lightbulb = Icons.lightbulb;
  static const IconData checkCircle = Icons.check_circle;
  static const IconData cancel = Icons.cancel;
  static const IconData emojiObjects = Icons.emoji_objects;
  static const IconData theater = Icons.theater_comedy;
  static const IconData questionMarkCircle = Icons.help_outline;

  static Widget GetColoredIcon(
    IconData icon,
    Color color, {
    double size = 24,
  }) {
    return Icon(icon, color: color, size: size);
  }
}
