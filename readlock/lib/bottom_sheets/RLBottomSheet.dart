// Centralized bottom sheet wrapper for the Readlock application
// Provides consistent styling, grabber, and layout for all bottom sheets

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';

// * Standardised outer margin for footer RLButtons at the bottom of every
// bottom sheet. Any sheet that ends with a primary CTA should apply this
// margin (or match its bottom value) so the gap between the button and the
// sheet's bottom edge reads the same across Feedback, Login, Support, etc.
const EdgeInsets RL_BOTTOM_SHEET_FOOTER_BUTTON_MARGIN = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  0,
  RLDS.spacing24,
  RLDS.spacing24,
);

// * Fraction of the screen used by every "tall" bottom sheet that needs to
// dominate the view but still leave a peek of the page behind it. Used by
// FullHeightSheetContainer (the existing 90% sheet) and by the onboarding
// sheet container — change here once and every "tall sheet" in the app
// follows.
const double RL_FULL_HEIGHT_SHEET_FRACTION = 0.9;

// * Standardised content padding for bottom sheets that render without a
// grabber (Account, Font picker, Support, etc.). These sheets own their
// own top chrome, so this constant is the single source of truth for
// "how much breathing room the content keeps from every edge of the sheet".
// Change it here and every no-grabber sheet lines up.
const EdgeInsets RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing16,
  RLDS.spacing24,
  RLDS.spacing24,
);

class RLBottomSheet {
  // * Standard show — wraps content with grabber, safe area, and rounded top corners.
  // Returns the sheet's dismissal future so callers can await it.
  static Future<void> show(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showGrabber = true,
    bool applyBackdropBlur = true,
    bool useLunarBlurSurface = true,
    Color? backgroundColor,
  }) {
    final Color sheetColor = backgroundColor ?? RLDS.surface;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: RLDS.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (BuildContext sheetContext) {
        final Widget container = SheetContainer(
          backgroundColor: sheetColor,
          showGrabber: showGrabber,
          useLunarBlurSurface: useLunarBlurSurface,
          child: child,
        );

        if (applyBackdropBlur) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: RLDS.backdropBlurSigma,
              sigmaY: RLDS.backdropBlurSigma,
            ),
            child: container,
          );
        }

        return container;
      },
    );
  }

  // * Full-height show — takes 90% of screen, uses ClipRRect for crisp corners
  static void showFullHeight(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool applyBackdropBlur = true,
    Color? backgroundColor,
  }) {
    final Color sheetColor = backgroundColor ?? RLDS.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: RLDS.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (BuildContext sheetContext) {
        final Widget container = FullHeightSheetContainer(
          backgroundColor: sheetColor,
          child: child,
        );

        if (applyBackdropBlur) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: RLDS.backdropBlurSigma,
              sigmaY: RLDS.backdropBlurSigma,
            ),
            child: container,
          );
        }

        return container;
      },
    );
  }
}

// * Standard sheet container with grabber, safe area, and top border radius.
// Set showGrabber to false when the sheet owns its own header treatment
// (e.g. the login sheet uses a blurred full-bleed look with no drag affordance).
class SheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool showGrabber;
  final bool useLunarBlurSurface;

  const SheetContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.showGrabber = true,
    this.useLunarBlurSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color sheetColor = backgroundColor ?? RLDS.surface;

    // SafeArea lives inside the sheet surface so the surface (LunarBlur or
    // solid tint) paints to the bottom edge of the screen — the home-
    // indicator inset reads the same colour as the sheet itself instead of
    // a bare strip underneath it.
    final Widget sheetContent = SafeArea(
      top: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: GrabberAndContent()),
    );

    if (useLunarBlurSurface) {
      return RLLunarBlur(
        borderRadius: RLDS.borderRadiusTopLarge,
        surfaceColor: sheetColor,
        borderColor: RLDS.transparent,
        child: sheetContent,
      );
    }

    final BoxDecoration solidDecoration = BoxDecoration(
      color: sheetColor,
      borderRadius: RLDS.borderRadiusTopLarge,
    );

    return Container(decoration: solidDecoration, child: sheetContent);
  }

  // Grabber owns its own RLDS.spacing16 above and below — so the child
  // content below NEVER needs to add its own top padding for the grabber.
  // Single source of truth: change this block and every sheet lines up.
  // (!showGrabber sheets own their top chrome, so we still add a spacing24
  // lead-in but don't require content to re-add a top inset either.)
  List<Widget> GrabberAndContent() {
    if (!showGrabber) {
      return [const Spacing.height(RLDS.spacing12), child];
    }

    return [
      const Spacing.height(RLDS.spacing16),

      const BottomSheetGrabber(),

      const Spacing.height(RLDS.spacing24),

      child,
    ];
  }
}

// * Full-height sheet container (90% screen) with grabber. Uses
// RLLunarBlur so the sheet reads as frosted glass over whatever is
// painted behind the modal (starfield + app content).
class FullHeightSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FullHeightSheetContainer({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final double sheetHeight =
        MediaQuery.of(context).size.height * RL_FULL_HEIGHT_SHEET_FRACTION;

    return SizedBox(
      height: sheetHeight,
      child: RLLunarBlur(
        borderRadius: RLDS.borderRadiusTopLarge,
        surfaceColor: backgroundColor,
        borderColor: RLDS.transparent,
        child: Column(
          children: [
            // Grabber with top padding
            const Spacing.height(RLDS.spacing16),

            const BottomSheetGrabber(),

            const Spacing.height(RLDS.spacing16),

            // Sheet content fills remaining space
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
