// Shared segmented-tab row used across the app — the CourseRoadmapScreen
// segment picker, the column-width picker in Settings, and any future place
// that wants the same visual language. Selected tab renders as a frosted
// RLLunarBlur pill matching RLCard's alpha; the rest render as flat labels.
// Tabs stretch equally to fill the available width (each tab takes 1/N of
// the row minus the inter-tab spacing), so the whole row reads as a single
// surface rather than a cluster of chips.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';

class RLSegmentTabOption<T> {
  final T value;
  final String label;

  const RLSegmentTabOption({required this.value, required this.label});
}

class RLSegmentTabs<T> extends StatelessWidget {
  final List<RLSegmentTabOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  // Colour of the selected tab's label. Defaults to RLDS.primary — the
  // same warm red used on active switches in Settings — so segmented
  // pickers read as part of the app's active-state family. Callers that
  // need a different accent (e.g. the roadmap uses the current course's
  // palette) can override.
  final Color selectedLabelColor;

  const RLSegmentTabs({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.selectedLabelColor = RLDS.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: TabWidgets());
  }

  List<Widget> TabWidgets() {
    final List<Widget> widgets = [];

    for (int optionIndex = 0; optionIndex < options.length; optionIndex++) {
      final bool isFirstTab = optionIndex == 0;

      if (!isFirstTab) {
        widgets.add(const Spacing.width(RLDS.spacing8));
      }

      final RLSegmentTabOption<T> option = options[optionIndex];
      final bool isSelected = option.value == selectedValue;

      void onTabTap() => onChanged(option.value);

      widgets.add(
        Expanded(
          child: RLSegmentTab(
            label: option.label,
            isSelected: isSelected,
            selectedLabelColor: selectedLabelColor,
            onTap: onTabTap,
          ),
        ),
      );
    }

    return widgets;
  }
}

class RLSegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedLabelColor;
  final VoidCallback onTap;

  const RLSegmentTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.selectedLabelColor,
    required this.onTap,
  });

  static const EdgeInsets tabPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing16,
    vertical: RLDS.spacing8,
  );

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected ? selectedLabelColor : RLDS.textSecondary;
    final Widget tabLabel = RLTypography.bodyMedium(
      label,
      color: labelColor,
      textAlign: TextAlign.center,
    );

    void handleTabTap() {
      HapticFeedback.lightImpact();
      onTap();
    }

    if (isSelected) {
      return GestureDetector(
        onTap: handleTabTap,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          padding: tabPadding,
          child: tabLabel,
        ),
      );
    }

    // Div already fires its own haptic when its onTap is called, so the
    // unselected branch routes through the raw onTap to avoid a double-fire.
    return Div.row(
      [tabLabel],
      padding: tabPadding,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: onTap,
    );
  }
}
