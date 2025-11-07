import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark theme colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryGreen = Color(0xFF7ED321);
  static const Color primaryBrown = Color(0xFFB8860B); // Brownish gold
  static const Color primaryAmber = Color(0xFFDAA520); // Golden rod
  static const Color primaryDeepPurple = Color(
    0xFFCD853F,
  ); // Peru brown

  static const Color backgroundDark = Color(0xFF1E1E1E);
  static const Color backgroundLight = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFFF5F5DC); // Beige text
  static const Color textSecondary = Color(0xFFD2B48C); // Tan text

  // Additional color constants
  static const Color shadowColor = Colors.black;
  static const Color greyBackground = Color(0xFF3D3D3D);
  static const Color white = Color(0xFF2D2D2D); // Dark card color

  // Extended color palette
  static final Color grey300 =
      Colors.grey[300] ?? const Color(0xFFE0E0E0);
  static final Color grey400 =
      Colors.grey[400] ?? const Color(0xFFBDBDBD);
  static final Color grey600 =
      Colors.grey[600] ?? const Color(0xFF757575);
  static final Color grey700 =
      Colors.grey[700] ?? const Color(0xFF616161);

  static final Color blue600 =
      Colors.blue[600] ?? const Color(0xFF1E88E5);
  static final Color green600 =
      Colors.green[600] ?? const Color(0xFF43A047);
  static final Color green800 =
      Colors.green[800] ?? const Color(0xFF2E7D32);
  static final Color red800 =
      Colors.red[800] ?? const Color(0xFFC62828);
  static final Color orange600 =
      Colors.orange[600] ?? const Color(0xFFFB8C00);
  static final Color purple600 =
      Colors.purple[600] ?? const Color(0xFF8E24AA);

  static final Color brown50 = const Color(0xFFFDF5E6);
  static final Color brown200 = const Color(0xFFDEB887);
  static final Color brown400 = const Color(0xFFCD853F);
  static final Color brown600 = const Color(0xFFB8860B);

  static final Color amber50 =
      Colors.amber[50] ?? const Color(0xFFFFF8E1);
  static final Color amber200 =
      Colors.amber[200] ?? const Color(0xFFFFE082);
  static final Color amber700 =
      Colors.amber[700] ?? const Color(0xFFFFA000);

  // Extended color variants
  static final Color grey50 =
      Colors.grey[50] ?? const Color(0xFFFAFAFA);
  static final Color grey100 =
      Colors.grey[100] ?? const Color(0xFFF5F5F5);
  static final Color blue50 =
      Colors.blue[50] ?? const Color(0xFFE3F2FD);
  static final Color blue100 =
      Colors.blue[100] ?? const Color(0xFFBBDEFB);
  static final Color blue200 =
      Colors.blue[200] ?? const Color(0xFF90CAF9);
  static final Color blue800 =
      Colors.blue[800] ?? const Color(0xFF1565C0);
  static final Color green100 =
      Colors.green[100] ?? const Color(0xFFC8E6C9);
  static final Color red100 =
      Colors.red[100] ?? const Color(0xFFFFCDD2);

  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

  // Typography with serif fonts
  static final TextStyle headingLarge = GoogleFonts.crimsonText(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static final TextStyle headingMedium = GoogleFonts.crimsonText(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static final TextStyle headingSmall = GoogleFonts.crimsonText(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static final TextStyle bodyLarge = GoogleFonts.crimsonText(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.crimsonText(
    fontSize: 16,
    color: textPrimary,
    height: 1.4,
  );

  static final TextStyle bodySmall = GoogleFonts.crimsonText(
    fontSize: 14,
    color: textPrimary,
  );

  static final TextStyle captionText = GoogleFonts.crimsonText(
    fontSize: 12,
    color: textPrimary,
    fontWeight: FontWeight.bold,
  );

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

  // Elevations
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 10.0;

  // Alpha transparency constants
  static const double alphaVeryLight = 0.05;
  static const double alphaLight = 0.1;
  static const double alphaMedium = 0.2;
  static const double alphaHeavy = 0.3;
  static const double alphaDark = 0.8;
  static const double alphaOpaque = 0.9;

  // Color variants with alpha transparency
  static Color get primaryBlueLight =>
      primaryBlue.withValues(alpha: alphaLight);
  static Color get primaryGreenLight =>
      primaryGreen.withValues(alpha: alphaLight);
  static Color get primaryGreenVeryLight =>
      primaryGreen.withValues(alpha: alphaVeryLight);
  static Color get primaryGreenMedium =>
      primaryGreen.withValues(alpha: alphaMedium);
  static Color get primaryGreenHeavy =>
      primaryGreen.withValues(alpha: alphaHeavy);
  static Color get primaryAmberLight =>
      primaryAmber.withValues(alpha: alphaLight);
  static Color get primaryAmberVeryLight =>
      primaryAmber.withValues(alpha: alphaVeryLight);
  static Color get primaryAmberMedium =>
      primaryAmber.withValues(alpha: alphaMedium);
  static Color get primaryDeepPurpleVeryLight =>
      primaryDeepPurple.withValues(alpha: alphaVeryLight);
  static Color get primaryDeepPurpleLight =>
      primaryDeepPurple.withValues(alpha: alphaLight);
  static Color get primaryBrownVeryLight =>
      primaryBrown.withValues(alpha: alphaVeryLight);
  static Color get grey600Medium =>
      grey600.withValues(alpha: alphaMedium);
  static Color get whiteHeavy =>
      Colors.white.withValues(alpha: alphaHeavy);
  static Color get whiteOpaque =>
      Colors.white.withValues(alpha: alphaOpaque);
  static Color get whiteDark =>
      Colors.white.withValues(alpha: alphaDark);
  static Color get primaryBrownHeavy =>
      primaryBrown.withValues(alpha: alphaHeavy);
  static Color get primaryDeepPurpleHeavy =>
      primaryDeepPurple.withValues(alpha: alphaHeavy);
  static Color get backgroundDarkDark =>
      backgroundDark.withValues(alpha: alphaDark);
  static Color get backgroundLightHeavy =>
      backgroundLight.withValues(alpha: alphaHeavy);
  static Color get primaryBrownLight =>
      primaryBrown.withValues(alpha: alphaLight);
  static Color get primaryBrownMedium =>
      primaryBrown.withValues(alpha: alphaMedium);
  static Color get primaryDeepPurpleMedium =>
      primaryDeepPurple.withValues(alpha: alphaMedium);
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
  static Color get amber200Heavy =>
      amber200.withValues(alpha: alphaHeavy);
  static Color get grey300Heavy =>
      grey300.withValues(alpha: alphaHeavy);

  // Shadow opacity constants
  static const double shadowLight = 0.08;
  static const double shadowMedium = 0.1;
  static const double shadowHeavy = 0.12;
  static const double shadowDark = 0.15;
  static const double shadowVeryDark = 0.2;

  // BoxShadow presets
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadowMedium),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadowDark),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadowVeryDark),
      blurRadius: 10,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadowLight),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadowHeavy),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static ColorScheme getCourseColorScheme(CourseThemeColor color) {
    switch (color) {
      case CourseThemeColor.blue: {
        return ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.dark,
        );
      }
      case CourseThemeColor.green: {
        return ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.dark,
        );
      }
      case CourseThemeColor.purple: {
        return ColorScheme.fromSeed(
          seedColor: primaryBrown,
          brightness: Brightness.dark,
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
          backgroundColor: Color(0xFF2E7D32),
          textColor: Color(0xFFC8E6C9),
        );
      } else {
        return const QuestionOptionColors(
          backgroundColor: Color(0xFFC62828),
          textColor: Color(0xFFFFCDD2),
        );
      }
    } else if (isSelected) {
      return const QuestionOptionColors(
        backgroundColor: AppTheme.primaryBrown,
        textColor: Color(0xFFFDF5E6),
      );
    } else {
      return const QuestionOptionColors(
        backgroundColor: Color(0xFF424242),
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

  static BoxDecoration getCardShadowDecoration({
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppTheme.shadowColor.withValues(alpha: shadowMedium),
          blurRadius: elevationHigh,
          offset: const Offset(0, 4),
        ),
      ],
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
