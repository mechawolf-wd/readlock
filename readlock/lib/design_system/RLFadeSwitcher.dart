// Centralised quick fade swap — same timing/curve as RLToast. Use wherever
// a screen or section swaps its child (tab changes, loader → content, etc.)
// so transitions read as opacity fades instead of hard flashes.
//
// The child MUST carry a stable `Key` whenever its identity changes (e.g. a
// different `ValueKey('loading')` vs `ValueKey('content')`), otherwise
// AnimatedSwitcher won't detect the swap.

import 'package:flutter/material.dart';

const Duration RL_FADE_SWITCHER_DURATION = Duration(milliseconds: 200);

class RLFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const RLFadeSwitcher({
    super.key,
    required this.child,
    this.duration = RL_FADE_SWITCHER_DURATION,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
