// App-wide colour-temperature shift. Mounted once at the root via
// MaterialApp's builder so the warm cast lands on every screen, including
// modals and bottom sheets. Replaces the previous orange-overlay approach
// with a per-channel ColorFiltered matrix — the same technique Apple's
// Night Shift uses, so whites become genuinely warm instead of being
// masked under a tinted scrim.
//
// Listens to nightShiftLevelNotifier so the slider in NightShiftBottomSheet
// flows through here without per-screen wiring. The TweenAnimationBuilder
// lerps the multipliers smoothly between stops; flipping levels feels like
// a sunset rather than a step change.
//
// Panel-brightness dimming is a separate axis driven by
// NightShiftBrightnessService — temperature shift and brightness both come
// off the same notifier but are applied independently.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLNightShift.dart';

const Duration RL_NIGHT_SHIFT_TRANSITION_DURATION = Duration(milliseconds: 600);

class RLNightShift extends StatelessWidget {
  final Widget child;

  const RLNightShift({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: nightShiftLevelNotifier,
      builder: NightShiftBuilder,
      child: child,
    );
  }

  Widget NightShiftBuilder(BuildContext context, int level, Widget? cachedChild) {
    final NightShiftLevel target = getNightShiftLevel(level);
    final NightShiftMultiplier targetMultiplier = NightShiftMultiplier(
      target.rMultiplier,
      target.gMultiplier,
      target.bMultiplier,
    );
    final Widget content = cachedChild ?? const SizedBox.shrink();

    return TweenAnimationBuilder<NightShiftMultiplier>(
      tween: NightShiftMultiplierTween(end: targetMultiplier),
      duration: RL_NIGHT_SHIFT_TRANSITION_DURATION,
      curve: Curves.easeInOut,
      builder: NightShiftFilterBuilder,
      child: content,
    );
  }

  Widget NightShiftFilterBuilder(
    BuildContext context,
    NightShiftMultiplier current,
    Widget? cachedChild,
  ) {
    final ColorFilter channelMultiplyFilter = ColorFilter.matrix(<double>[
      current.r, 0, 0, 0, 0,
      0, current.g, 0, 0, 0,
      0, 0, current.b, 0, 0,
      0, 0, 0, 1, 0,
    ]);
    final Widget content = cachedChild ?? const SizedBox.shrink();

    return ColorFiltered(colorFilter: channelMultiplyFilter, child: content);
  }
}

// Per-channel R/G/B multiplier triplet for the ColorFilter matrix. Held as
// a value type so TweenAnimationBuilder can interpolate cleanly between
// stops without allocating intermediate matrices outside the build call.
class NightShiftMultiplier {
  final double r;
  final double g;
  final double b;

  const NightShiftMultiplier(this.r, this.g, this.b);

  static const NightShiftMultiplier identity = NightShiftMultiplier(1.0, 1.0, 1.0);
}

// Linearly interpolates between two multiplier triplets. Begin defaults to
// identity (no shift) so a fresh mount tweens in from neutral instead of
// snapping to the target on the first frame.
class NightShiftMultiplierTween extends Tween<NightShiftMultiplier> {
  NightShiftMultiplierTween({
    NightShiftMultiplier? begin,
    required NightShiftMultiplier end,
  }) : super(begin: begin ?? NightShiftMultiplier.identity, end: end);

  @override
  NightShiftMultiplier lerp(double t) {
    final NightShiftMultiplier from = begin ?? NightShiftMultiplier.identity;
    final NightShiftMultiplier to = end ?? NightShiftMultiplier.identity;

    return NightShiftMultiplier(
      from.r + (to.r - from.r) * t,
      from.g + (to.g - from.g) * t,
      from.b + (to.b - from.b) * t,
    );
  }
}
