// Centralized dimension constants for consistent spacing and sizing
// All values follow the 4-pixel grid system

import 'package:flutter/material.dart';

class RLDimensions {
  // ==========================================================================
  // SPACING - Consistent gaps between elements
  // ==========================================================================

  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ==========================================================================
  // PADDING - Internal element spacing
  // ==========================================================================

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double paddingXXXL = 32.0;

  // Common EdgeInsets
  static const EdgeInsets paddingAllS = EdgeInsets.all(paddingS);
  static const EdgeInsets paddingAllM = EdgeInsets.all(paddingM);
  static const EdgeInsets paddingAllL = EdgeInsets.all(paddingL);
  static const EdgeInsets paddingAllXL = EdgeInsets.all(paddingXL);
  static const EdgeInsets paddingAllXXL = EdgeInsets.all(paddingXXL);

  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(
    horizontal: paddingL,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: paddingXL,
  );

  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(
    vertical: paddingM,
  );
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(
    vertical: paddingL,
  );

  // Screen padding (consistent across app)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: paddingXL,
    vertical: paddingL,
  );

  // ==========================================================================
  // BORDER RADIUS - Rounded corners
  // ==========================================================================

  static const double radiusXS = 4.0;
  static const double radiusS = 6.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusXXXL = 24.0;
  static const double radiusRound = 30.0;
  static const double radiusCircle = 36.0;

  // Common BorderRadius
  static final BorderRadius borderRadiusXS = BorderRadius.circular(
    radiusXS,
  );
  static final BorderRadius borderRadiusS = BorderRadius.circular(
    radiusS,
  );
  static final BorderRadius borderRadiusM = BorderRadius.circular(
    radiusM,
  );
  static final BorderRadius borderRadiusL = BorderRadius.circular(
    radiusL,
  );
  static final BorderRadius borderRadiusXL = BorderRadius.circular(
    radiusXL,
  );
  static final BorderRadius borderRadiusXXL = BorderRadius.circular(
    radiusXXL,
  );
  static final BorderRadius borderRadiusRound = BorderRadius.circular(
    radiusRound,
  );
  static final BorderRadius borderRadiusCircle = BorderRadius.circular(
    radiusCircle,
  );

  // ==========================================================================
  // ICON SIZES
  // ==========================================================================

  static const double iconXS = 14.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 28.0;
  static const double iconXXL = 32.0;
  static const double iconXXXL = 36.0;
  static const double iconHuge = 48.0;

  // ==========================================================================
  // COMPONENT SIZES - Common UI element dimensions
  // ==========================================================================

  // Buttons
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 52.0;

  // Avatars / Profile images
  static const double avatarS = 36.0;
  static const double avatarM = 48.0;
  static const double avatarL = 60.0;
  static const double avatarXL = 80.0;

  // Book covers / Thumbnails
  static const double thumbnailWidthS = 40.0;
  static const double thumbnailWidthM = 60.0;
  static const double thumbnailWidthL = 80.0;
  static const double thumbnailWidthXL = 100.0;

  static const double thumbnailHeightS = 56.0;
  static const double thumbnailHeightM = 80.0;
  static const double thumbnailHeightL = 112.0;
  static const double thumbnailHeightXL = 140.0;

  // Progress indicators
  static const double progressBarHeight = 4.0;
  static const double progressBarHeightThick = 6.0;

  // Dots / Indicators
  static const double dotS = 6.0;
  static const double dotM = 8.0;
  static const double dotL = 10.0;

  // Dividers
  static const double dividerThin = 0.5;
  static const double dividerNormal = 1.0;
  static const double dividerThick = 1.5;
  static const double dividerBold = 2.0;

  // ==========================================================================
  // ANIMATION DURATIONS
  // ==========================================================================

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 450);
  static const Duration durationVerySlow = Duration(milliseconds: 500);

  // ==========================================================================
  // OPACITY / ALPHA VALUES
  // ==========================================================================

  static const double opacityDisabled = 0.4;
  static const double opacityMuted = 0.5;
  static const double opacitySubtle = 0.6;
  static const double opacityLight = 0.7;
  static const double opacitySoft = 0.8;

  // For overlays and backgrounds
  static const double alphaVeryLight = 0.05;
  static const double alphaLight = 0.1;
  static const double alphaMediumLight = 0.15;
  static const double alphaMedium = 0.2;
  static const double alphaMediumDark = 0.25;
  static const double alphaDark = 0.3;
  static const double alphaVeryDark = 0.4;

  // ==========================================================================
  // BADGE COLORS - Achievement medals
  // ==========================================================================

  static const Color goldColor = Color(0xFFFFD700);
  static const Color silverColor = Color(0xFFC0C0C0);
  static const Color bronzeColor = Color(0xFFCD7F32);
}
