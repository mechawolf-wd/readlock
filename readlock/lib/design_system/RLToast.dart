// Centralised top-screen toast — four semantic variants (info, warning,
// error, success). Card-styled, tap to dismiss, quick opacity animation.
// Sits at the top of the overlay with the same outer margin as page content.

import 'package:flutter/material.dart' hide Typography;
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';

// * Tuning — fade timing pulled from RLDS so every opacity transition in
// the app (reveal, fade switcher, toast) shares one token.
const Duration TOAST_VISIBLE_DURATION = Duration(seconds: 3);
const double TOAST_ICON_SIZE = 20.0;

enum RLToastVariant { info, warning, error, success }

// * Controller — owns the active overlay entry so consecutive calls replace
// the previous toast instantly instead of stacking.
class RLToastController {
  OverlayEntry? overlayEntry;
  RLToastViewState? toastState;

  void show({
    required BuildContext context,
    required String message,
    required RLToastVariant variant,
  }) {
    dismissImmediately();

    final RLToastView toast = RLToastView(
      message: message,
      variant: variant,
      onDismiss: dismissImmediately,
      onStateCreated: (RLToastViewState state) {
        toastState = state;
      },
    );

    overlayEntry = OverlayEntry(builder: (BuildContext context) => toast);

    Overlay.of(context).insert(overlayEntry!);
  }

  void dismissImmediately() {
    overlayEntry?.remove();
    overlayEntry = null;
    toastState = null;
  }

  Future<void> dismissAnimated() async {
    final RLToastViewState? currentState = toastState;
    final bool hasNoState = currentState == null;

    if (hasNoState) {
      dismissImmediately();
      return;
    }

    await currentState.animateOut();
    dismissImmediately();
  }
}

final RLToastController rlToastController = RLToastController();

// * Public API
class RLToast {
  static void info(BuildContext context, String message) {
    rlToastController.show(
      context: context,
      message: message,
      variant: RLToastVariant.info,
    );
  }

  static void warning(BuildContext context, String message) {
    rlToastController.show(
      context: context,
      message: message,
      variant: RLToastVariant.warning,
    );
  }

  static void error(BuildContext context, String message) {
    rlToastController.show(
      context: context,
      message: message,
      variant: RLToastVariant.error,
    );
  }

  static void success(BuildContext context, String message) {
    rlToastController.show(
      context: context,
      message: message,
      variant: RLToastVariant.success,
    );
  }

  static void dismiss() {
    rlToastController.dismissAnimated();
  }
}

// * Variant → icon + colour mapping. Keeps the view lean and the mapping
// explicit so every semantic variant is defined in one spot.
class RLToastVariantStyle {
  final IconData icon;
  final Color color;

  const RLToastVariantStyle({required this.icon, required this.color});

  static RLToastVariantStyle forVariant(RLToastVariant variant) {
    switch (variant) {
      case RLToastVariant.info:
        {
          return const RLToastVariantStyle(icon: Pixel.infobox, color: RLDS.info);
        }
      case RLToastVariant.warning:
        {
          return const RLToastVariantStyle(icon: Pixel.alert, color: RLDS.warning);
        }
      case RLToastVariant.error:
        {
          return const RLToastVariantStyle(icon: Pixel.close, color: RLDS.error);
        }
      case RLToastVariant.success:
        {
          return const RLToastVariantStyle(icon: Pixel.check, color: RLDS.green);
        }
    }
  }
}

// * Overlay view — positions the card at the top of the screen with the same
// outer margin as the page content, fades in, auto-dismisses, fades out on tap.
class RLToastView extends StatefulWidget {
  final String message;
  final RLToastVariant variant;
  final VoidCallback onDismiss;
  final void Function(RLToastViewState) onStateCreated;

  const RLToastView({
    super.key,
    required this.message,
    required this.variant,
    required this.onDismiss,
    required this.onStateCreated,
  });

  @override
  State<RLToastView> createState() => RLToastViewState();
}

class RLToastViewState extends State<RLToastView> with SingleTickerProviderStateMixin {
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    widget.onStateCreated(this);

    fadeController = AnimationController(
      vsync: this,
      duration: RLDS.opacityFadeDurationFast,
    );

    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    fadeController.forward();

    scheduleAutoDismiss();
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }

  void scheduleAutoDismiss() {
    Future.delayed(TOAST_VISIBLE_DURATION, handleAutoDismissTick);
  }

  Future<void> handleAutoDismissTick() async {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    await animateOut();

    final bool isStillMounted = mounted;

    if (isStillMounted) {
      widget.onDismiss();
    }
  }

  Future<void> animateOut() async {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    await fadeController.reverse();
  }

  Future<void> handleTapToDismiss() async {
    await animateOut();

    final bool isStillMounted = mounted;

    if (isStillMounted) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final RLToastVariantStyle style = RLToastVariantStyle.forVariant(widget.variant);

    return Positioned(
      top: topSafeArea + RLDS.spacing24,
      left: RLDS.spacing24,
      right: RLDS.spacing24,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Material(
          color: RLDS.transparent,
          child: GestureDetector(
            onTap: handleTapToDismiss,
            child: ToastCard(style: style),
          ),
        ),
      ),
    );
  }

  Widget ToastCard({required RLToastVariantStyle style}) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLDS.surface,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: style.color, width: RLDS.borderWidth),
    );

    final Icon variantIcon = Icon(style.icon, color: style.color, size: TOAST_ICON_SIZE);

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing16,
        vertical: RLDS.spacing12,
      ),
      child: Row(
        children: [
          variantIcon,

          const SizedBox(width: RLDS.spacing12),

          Expanded(
            child: RLTypography.bodyMedium(widget.message, color: RLDS.textPrimary),
          ),
        ],
      ),
    );
  }
}
