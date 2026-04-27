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

  // Compact form shown when the tab is not selected — e.g. an acronym so
  // long titles collapse to two letters and only the active tab reveals
  // its full name. Optional; falls back to `label` for both states when
  // omitted, preserving the simple single-label call sites.
  final String? compactLabel;

  const RLSegmentTabOption({
    required this.value,
    required this.label,
    this.compactLabel,
  });
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
            compactLabel: option.compactLabel,
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
  final String? compactLabel;
  final bool isSelected;
  final Color selectedLabelColor;
  final VoidCallback onTap;

  const RLSegmentTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.selectedLabelColor,
    required this.onTap,
    this.compactLabel,
  });

  static const EdgeInsets tabPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing16,
    vertical: RLDS.spacing8,
  );

  String getDisplayLabel() {
    final String? compact = compactLabel;
    final bool shouldUseCompact = !isSelected && compact != null && compact.isNotEmpty;

    if (shouldUseCompact) {
      return compact;
    }

    return label;
  }

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected ? selectedLabelColor : RLDS.textSecondary;
    final Widget tabLabel = RLTypography.bodyMedium(
      getDisplayLabel(),
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
        behavior: HitTestBehavior.opaque,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          padding: tabPadding,
          child: tabLabel,
        ),
      );
    }

    // Wrap the unselected tab in an opaque GestureDetector so the entire
    // padded slot registers taps — clicking the empty space around the
    // label still flips the selection. Haptic is fired here directly
    // (the inner Div has no onTap, so there's no double-fire risk).
    return GestureDetector(
      onTap: handleTabTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: tabPadding,
        alignment: Alignment.center,
        child: tabLabel,
      ),
    );
  }
}
