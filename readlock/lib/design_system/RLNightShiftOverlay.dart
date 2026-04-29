// App-wide warm tint. Mounted once at the root via MaterialApp's builder
// so the overlay paints on top of every screen, including modals and
// bottom sheets. Actual screen dimming is driven by
// NightShiftBrightnessService (panel brightness override), so this layer
// is purely the colour cast. IgnorePointer keeps it cosmetic.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLNightShift.dart';

class RLNightShiftOverlay extends StatelessWidget {
  final Widget child;

  const RLNightShiftOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        Positioned.fill(
          child: IgnorePointer(
            child: ValueListenableBuilder<int>(
              valueListenable: nightShiftLevelNotifier,
              builder: TintLayer,
            ),
          ),
        ),
      ],
    );
  }

  Widget TintLayer(BuildContext context, int level, Widget? _) {
    final double alpha = getNightShiftAlpha(level);
    final bool isOff = alpha <= 0.0;

    if (isOff) {
      return const SizedBox.shrink();
    }

    final Color tintColor = NIGHT_SHIFT_WARM_COLOR.withValues(alpha: alpha);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: tintColor,
    );
  }
}
