// Readlock Design System
// Centralized design variables for consistent styling across the app
// Simple design: no glows, no gradients, no shadows, 1px borders

import 'package:flutter/material.dart';

class RLDS {
  // * Brand colors

  static const Color primary = Color.fromARGB(255, 238, 70, 84); // warm vivid red
  static const Color info = Color.fromARGB(255, 41, 177, 244); // bright blue
  static const Color green = Color.fromARGB(255, 34, 181, 98); // fresh green
  static const Color success = green; // success uses the fresh green, not the primary red
  static const Color warning = Color.fromARGB(255, 249, 180, 44); // amber
  static const Color error = Color.fromARGB(255, 246, 85, 98); // shares the primary red

  // * Text-markup accents
  //
  // Used by <c:g>…</c:g> and <c:r>…</c:r> spans inside course text (text swipes,
  // question bodies, explanations). Distinct from the brand semantic palette
  // above (success/error/primary all share the same warm red and would blur
  // into the background when used for mid-sentence highlights). Values tuned
  // for readability on the dark surface: bright enough to stand out, soft
  // enough to avoid shouting at the reader.

  static const Color markupGreen = Color(0xFF4ADE80); // bright green accent
  static const Color markupRed = Color(0xFFF87171); // warm red accent

  static Color getMarkupColor(String code) {
    switch (code) {
      case 'g':
        {
          return markupGreen;
        }
      case 'r':
        {
          return markupRed;
        }
      default:
        {
          return markupGreen;
        }
    }
  }

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

  static const double radiusXSmall = 8.0;
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusCircle = 100.0;

  static final BorderRadius borderRadiusXSmall = BorderRadius.circular(radiusXSmall);
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

  // * Glass helpers — five buckets cover every translucent paint in the
  // app. Use the helper at the call site so changing the curve is a
  // single edit here. Naming is value-based so the alpha reads at a
  // glance: glass10 = 10% opacity, glass70 = 70% opacity.

  static Color glass10(Color color) {
    return color.withValues(alpha: 0.10);
  }

  static Color glass15(Color color) {
    return color.withValues(alpha: 0.15);
  }

  static Color glass40(Color color) {
    return color.withValues(alpha: 0.40);
  }

  static Color glass50(Color color) {
    return color.withValues(alpha: 0.50);
  }

  static Color glass70(Color color) {
    return color.withValues(alpha: 0.70);
  }

  // * Icon sizes

  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;
  static const double iconXXLarge = 48.0;

  // * Feather currency icon — native 16x16 pixel sprite. Used wherever the
  // app counts feathers (bookshelf balance pill, Feathers sheet plan cards)
  // so the unit reads visually instead of relying on the word.
  static const String featherIconAsset = 'assets/Plume 16x16.png';

  // * Backdrop blur — applied behind every modal surface (bottom sheets,
  // dialogs) so they all read as one family.
  static const double backdropBlurSigma = 10.0;

  // * Opacity animation durations — single source of truth for every fade
  // / reveal in the app. Callers should pick the closest bucket rather than
  // author their own Duration literals.
  //   fast:     quick on/off reveals (RLReveal, RLFadeSwitcher, RLToast)
  //   standard: feedback toasts, sheet content swaps
  //   intro:    hero intros (roadmap progress ring, onboarding)
  static const Duration opacityFadeDurationFast = Duration(milliseconds: 200);
  static const Duration opacityFadeDurationStandard = Duration(milliseconds: 300);
  static const Duration opacityFadeDurationIntro = Duration(milliseconds: 1200);

  // * Lyrics-style completed-text blur (Apple Music cadence).
  //
  // Apple Music's upcoming lyrics keep moderate opacity (~0.5) paired with a
  // soft Gaussian blur (~3 sigma) — the de-emphasis comes from the blur, not
  // from fading. Single source of truth for every "completed / covered /
  // not-yet-revealed reading text" surface in the app: ProgressiveText's
  // completed sentences, CCQuestion option cards, CCTrueFalseQuestion
  // buttons, and the Settings blur demo. Edit these two numbers and every
  // one of those surfaces stays in lock-step.
  static const double lyricsBlurSigma = 3.0;
  static const double lyricsBlurOpacity = 0.5;

  // * Sheet standardized spacing

  static const double sheetTopPadding = spacing12;
  static const double sheetGrabberToHeadingSpacing = spacing24;
  static const double sheetHeadingToSubheadingSpacing = spacing4;
  static const double sheetSubheadingToContentSpacing = spacing16;

  // * Content padding

  static const EdgeInsets contentPaddingInsets = EdgeInsets.all(spacing24);
  static const EdgeInsets contentPaddingMediumInsets = EdgeInsets.all(spacing12);

  // * Dialog padding — shared across every dialog surface (alert dialogs,
  // confirmation dialogs, quit dialog, etc.) so they all sit at the same
  // screen margin and frame their content with the same inset. Change
  // these in one place and every dialog in the app follows.
  //
  //   dialogOuterHorizontalInset — side gap between the screen edge and
  //       the dialog card (applied by DialogContainer).
  //   dialogContentInsets        — padding between the dialog card edge
  //       and its inner content (title / message / action row).

  static const double dialogOuterHorizontalInset = spacing24;
  static const EdgeInsets dialogContentInsets = EdgeInsets.all(spacing24);

  // * Scrim painted behind any modal dialog. Single source of truth so
  // every dialog (alert, confirmation, future ones) dims the page by the
  // same amount instead of each call site picking its own alpha.
  static final Color dialogBarrierColor = glass50(black);

  // * Hex color parsing

  static Color? parseHexColor(String? hex) {
    final bool hasNoHex = hex == null || hex.isEmpty;

    if (hasNoHex) {
      return null;
    }

    final String cleaned = hex.replaceAll('#', '').trim();
    final bool isRgb = cleaned.length == 6;
    final bool isArgb = cleaned.length == 8;

    if (!isRgb && !isArgb) {
      return null;
    }

    final String normalized = isRgb ? 'FF$cleaned' : cleaned;
    final int? value = int.tryParse(normalized, radix: 16);
    final bool hasInvalidValue = value == null;

    if (hasInvalidValue) {
      return null;
    }

    return Color(value);
  }

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

// Replaces the default platform page transition (classic right-to-left swipe
// on Android, iOS horizontal push) with a slide from the top.
// Wired into MaterialApp via pageTransitionsTheme so every MaterialPageRoute
// uses it automatically without touching individual Navigator.push calls.
class TopSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const TopSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: RLDS.transitionCurve));

    return SlideTransition(position: slideAnimation, child: child);
  }
}
