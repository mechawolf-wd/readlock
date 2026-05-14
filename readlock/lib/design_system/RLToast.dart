// Centralised top-screen toast — four semantic variants (info, warning,
// error, success). Card-styled, tap to dismiss, quick opacity animation.
// Sits at the top of the overlay with the same outer margin as page content.

import 'dart:ui';

import 'package:flutter/material.dart' hide Typography;
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/services/feedback/SoundService.dart';

// * Tuning — fade timing pulled from RLDS so every opacity transition in
// the app (reveal, fade switcher, toast) shares one token.
const Duration TOAST_VISIBLE_DURATION = Duration(seconds: 3);
const double TOAST_ICON_SIZE = RLDS.iconMedium;

// 2px variant-coloured border on a neutral surface — the variant identity
// rides on the icon and the edge, the body stays the standard surface so
// the toast reads consistently regardless of severity.
const double RL_TOAST_BORDER_WIDTH = 2.0;

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
    SoundService.playRandomTextClick();
    rlToastController.show(context: context, message: message, variant: RLToastVariant.info);
  }

  static void warning(BuildContext context, String message) {
    SoundService.playNegative();
    rlToastController.show(context: context, message: message, variant: RLToastVariant.warning);
  }

  static void error(BuildContext context, String message) {
    SoundService.playNegative();
    rlToastController.show(context: context, message: message, variant: RLToastVariant.error);
  }

  // playSound defaults true so the existing callers (password reset,
  // verify email, support email copied, feather top-up) keep their
  // success chime. Purchase flows pass false because they already play
  // SoundService.playPurchase, and we don't want both sounds layered.
  static void success(BuildContext context, String message, {bool playSound = true}) {
    if (playSound) {
      SoundService.playSuccess();
    }

    rlToastController.show(context: context, message: message, variant: RLToastVariant.success);
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
          return const RLToastVariantStyle(icon: Pixel.check, color: RLDS.success);
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

    fadeController = AnimationController(vsync: this, duration: RLDS.opacityFadeDurationFast);

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
      child: Material(
        color: RLDS.transparent,
        child: GestureDetector(
          onTap: handleTapToDismiss,
          child: ToastCard(style: style),
        ),
      ),
    );
  }

  // Frosted variant-bordered surface. Built inline rather than via
  // RLLunarBlur because the toast animates its blur sigma alongside its
  // tint and content opacity — wrapping a BackdropFilter in a FadeTransition
  // (the obvious approach) produces a "blur snaps in at the end" pop, since
  // Opacity around BackdropFilter doesn't blend the blur kernel smoothly.
  // Growing sigma from 0 to full instead lets the frosted effect bloom in.
  Widget ToastCard({required RLToastVariantStyle style}) {
    final Icon VariantIcon = Icon(style.icon, color: style.color, size: TOAST_ICON_SIZE);

    final Widget cardContent = Row(
      children: [
        VariantIcon,

        const SizedBox(width: RLDS.spacing12),

        Expanded(child: RLTypography.bodyMedium(widget.message, color: RLDS.textPrimary)),
      ],
    );

    final BorderRadius radius = RLDS.borderRadiusSmall;
    const EdgeInsets cardPadding = EdgeInsets.symmetric(
      horizontal: RLDS.spacing16,
      vertical: RLDS.spacing12,
    );

    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (BuildContext _, Widget? __) {
        final double progress = fadeAnimation.value;
        final double blurSigma = RL_LUNAR_BLUR_DEFAULT_SIGMA * progress;
        final double surfaceAlpha = RL_LUNAR_BLUR_DEFAULT_SURFACE_ALPHA * progress;
        final Color tintedSurface = RLDS.surface.withValues(alpha: surfaceAlpha);
        final Color animatedBorder = style.color.withValues(alpha: progress);

        final BoxDecoration tintDecoration = BoxDecoration(
          color: tintedSurface,
          border: Border.all(color: animatedBorder, width: RL_TOAST_BORDER_WIDTH),
          borderRadius: radius,
        );

        return ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: tintDecoration,
              padding: cardPadding,
              child: Opacity(opacity: progress, child: cardContent),
            ),
          ),
        );
      },
    );
  }
}
