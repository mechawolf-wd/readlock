// Centralised selectable filter chip row used across screens
// Renders a wrapping row of toggleable chips with consistent styling

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';

class SelectableFilterChips extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onChanged;
  final double chipSpacing;
  final double runSpacing;

  const SelectableFilterChips({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.chipSpacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: chipSpacing,
      runSpacing: runSpacing,
      children: ChipItems(),
    );
  }

  List<Widget> ChipItems() {
    return options.map((option) {
      final bool isSelected = selectedOption == option;

      return SelectableFilterChip(
        label: option,
        isSelected: isSelected,
        onTap: () => onChanged(option),
      );
    }).toList();
  }
}

class SelectableFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor = RLDS.backgroundLight.withValues(alpha: 0.08);
    Color chipTextColor = RLDS.info;

    if (isSelected) {
      chipColor = RLDS.info;
      chipTextColor = RLDS.white;
    }

    final BoxDecoration chipDecoration = BoxDecoration(
      color: chipColor,
      borderRadius: BorderRadius.circular(RLDS.radiusLarge),
      border: Border.all(color: RLDS.info.withValues(alpha: 0.3)),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RLDS.spacing16,
          vertical: RLDS.spacing8,
        ),
        decoration: chipDecoration,
        child: Text(
          label,
          style: RLTypography.bodyMediumStyle.copyWith(color: chipTextColor),
        ),
      ),
    );
  }
}
