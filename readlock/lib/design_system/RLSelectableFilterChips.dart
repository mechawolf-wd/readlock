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
    this.chipSpacing = RLDS.spacing8,
    this.runSpacing = RLDS.spacing8,
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

// Multi-select sibling of SelectableFilterChips. Same chip widget, same
// styling — only the selection model differs: callers hold a Set of active
// labels and `onToggled` fires the tapped label so the parent can flip its
// membership in/out of that Set. Used by the search screen's genre row.
class SelectableFilterChipsMulti extends StatelessWidget {
  final List<String> options;
  final Set<String> selectedOptions;
  final ValueChanged<String> onToggled;
  final double chipSpacing;
  final double runSpacing;

  const SelectableFilterChipsMulti({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onToggled,
    this.chipSpacing = RLDS.spacing8,
    this.runSpacing = RLDS.spacing8,
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
      final bool isSelected = selectedOptions.contains(option);

      return SelectableFilterChip(
        label: option,
        isSelected: isSelected,
        onTap: () => onToggled(option),
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
        child: RLTypography.bodyMedium(label, color: chipTextColor),
      ),
    );
  }
}
