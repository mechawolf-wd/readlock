// Centralised opacity reveal — single source of truth for every "fade in /
// fade out based on a bool" surface in the app (continue button, true/false
// blur, password field, etc.). Keep all opacity reveals routed through this
// so the timing never drifts.
//
// `RLReveal` wraps AnimatedOpacity + IgnorePointer so invisible children
// never intercept taps. Pair it with AnimatedSize when the reveal also
// needs to change layout size.

import 'package:flutter/material.dart';

const Duration RL_REVEAL_DURATION = Duration(milliseconds: 200);
const Curve RL_REVEAL_CURVE = Curves.easeOut;

class RLReveal extends StatelessWidget {
  final bool visible;
  final Widget child;

  const RLReveal({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    final double targetOpacity = visible ? 1.0 : 0.0;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: RL_REVEAL_DURATION,
        curve: RL_REVEAL_CURVE,
        opacity: targetOpacity,
        child: child,
      ),
    );
  }
}
