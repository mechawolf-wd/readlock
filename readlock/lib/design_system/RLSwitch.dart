// Reusable switch toggle component
// Uses design system colors for active/inactive states

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const RLSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedActiveColor = activeColor ?? RLDS.primary;

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: resolvedActiveColor,
      activeTrackColor: resolvedActiveColor.withValues(alpha: 0.3),
      inactiveThumbColor: RLDS.textPrimary.withValues(alpha: 0.5),
      inactiveTrackColor: RLDS.textPrimary.withValues(alpha: 0.1),
    );
  }
}
