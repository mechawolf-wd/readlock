// Centralized bottom sheet wrapper for the Readlock application
// Provides consistent styling, grabber, and layout for all bottom sheets

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLUtility.dart';

const double BOTTOM_SHEET_BACKDROP_BLUR_SIGMA = 10.0;

class RLBottomSheet {
  // * Standard show — wraps content with grabber, safe area, and rounded top corners.
  // Returns the sheet's dismissal future so callers can await it.
  static Future<void> show(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showGrabber = true,
    bool applyBackdropBlur = false,
    Color? backgroundColor,
  }) {
    final Color sheetColor = backgroundColor ?? RLDS.backgroundDark;

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
          child: child,
        );

        if (applyBackdropBlur) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: BOTTOM_SHEET_BACKDROP_BLUR_SIGMA,
              sigmaY: BOTTOM_SHEET_BACKDROP_BLUR_SIGMA,
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
    Color? backgroundColor,
  }) {
    final Color sheetColor = backgroundColor ?? RLDS.backgroundDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: RLDS.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (BuildContext sheetContext) {
        return FullHeightSheetContainer(backgroundColor: sheetColor, child: child);
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

  const SheetContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.showGrabber = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color sheetColor = backgroundColor ?? RLDS.backgroundDark;

    final BoxDecoration sheetDecoration = BoxDecoration(
      color: sheetColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    );

    return Container(
      color: RLDS.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: sheetDecoration,
          child: Column(mainAxisSize: MainAxisSize.min, children: GrabberAndContent()),
        ),
      ),
    );
  }

  List<Widget> GrabberAndContent() {
    if (!showGrabber) {
      return [
        // Top padding without the drag indicator — sheet owns its own chrome.
        const Spacing.height(12),

        child,
      ];
    }

    return [const Spacing.height(12), const BottomSheetGrabber(), child];
  }
}

// * Full-height sheet container (90% screen) with grabber and ClipRRect
class FullHeightSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FullHeightSheetContainer({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final Color sheetColor = backgroundColor ?? RLDS.backgroundDark;
    final double sheetHeight = MediaQuery.of(context).size.height * 0.9;

    final BorderRadius sheetBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(color: sheetColor, borderRadius: sheetBorderRadius),
      child: ClipRRect(
        borderRadius: sheetBorderRadius,
        child: Column(
          children: [
            // Grabber with top padding
            const Spacing.height(12),

            const BottomSheetGrabber(),

            // Sheet content fills remaining space
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
