// Centralized bottom sheet wrapper for the Readlock application
// Provides consistent styling, grabber, and layout for all bottom sheets

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/Utility.dart';

class RLBottomSheet {
  // * Standard show — wraps content with grabber, safe area, and rounded top corners
  static void show(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    final Color sheetColor = backgroundColor ?? RLDS.backgroundDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (BuildContext sheetContext) {
        return SheetContainer(
          backgroundColor: sheetColor,
          child: child,
        );
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (BuildContext sheetContext) {
        return FullHeightSheetContainer(
          backgroundColor: sheetColor,
          child: child,
        );
      },
    );
  }
}

// * Standard sheet container with grabber, safe area, and top border radius
class SheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const SheetContainer({
    super.key,
    required this.child,
    this.backgroundColor,
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
      color: RLDS.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: sheetDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber with top padding
              const Spacing.height(12),

              const BottomSheetGrabber(),

              // Sheet content
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// * Full-height sheet container (90% screen) with grabber and ClipRRect
class FullHeightSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FullHeightSheetContainer({
    super.key,
    required this.child,
    this.backgroundColor,
  });

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
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: sheetBorderRadius,
      ),
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
