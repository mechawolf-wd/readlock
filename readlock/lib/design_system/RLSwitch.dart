// Reusable switch toggle component (iOS-style via CupertinoSwitch).
// Uses design system colors for active/inactive states.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const RLSwitch({super.key, required this.value, this.onChanged, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final Color resolvedActiveColor = activeColor ?? RLDS.primary;

    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: resolvedActiveColor,
      inactiveTrackColor: RLDS.textPrimary.withValues(alpha: 0.15),
    );
  }
}
