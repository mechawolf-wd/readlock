// Shared segmented-tab row used across the app — the CourseRoadmapScreen
// segment picker, the column-width picker in Settings, and any future place
// that wants the same visual language. Selected tab renders as a frosted
// RLLunarBlur pill matching RLCard's alpha; the rest render as flat labels.
// Tabs stretch equally to fill the available width (each tab takes 1/N of
// the row minus the inter-tab spacing), so the whole row reads as a single
// surface rather than a cluster of chips.

import 'package:flutter/material.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/feedback/SoundService.dart';

class RLSegmentTabOption<T> {
  final T value;
  final String label;

  // Glyph rendered in place of the label when the tab is not selected.
  // Lets unselected tabs collapse to a single icon (e.g. an eye) so only
  // the active tab carries text. Optional; falls back to the text label
  // for both states when omitted.
  final IconData? unselectedIcon;

  const RLSegmentTabOption({required this.value, required this.label, this.unselectedIcon});
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

  final bool showBorder;

  const RLSegmentTabs({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.selectedLabelColor = RLDS.primary,
    this.showBorder = true,
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
            unselectedIcon: option.unselectedIcon,
            isSelected: isSelected,
            selectedLabelColor: selectedLabelColor,
            showBorder: showBorder,
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
  final IconData? unselectedIcon;
  final bool isSelected;
  final Color selectedLabelColor;
  final VoidCallback onTap;

  final bool showBorder;

  const RLSegmentTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.selectedLabelColor,
    required this.onTap,
    this.unselectedIcon,
    this.showBorder = true,
  });

  static const EdgeInsets tabPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing16,
    vertical: RLDS.spacing8,
  );

  static const double tabIconSize = RLDS.iconXLarge;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected ? selectedLabelColor : RLDS.textSecondary;

    final Widget selectedContent = RLTypography.bodyMedium(
      label,
      color: labelColor,
      textAlign: TextAlign.center,
    );

    final IconData? icon = unselectedIcon;
    final bool shouldShowIcon = !isSelected && icon != null;

    final Widget unselectedContent = shouldShowIcon
        ? Icon(icon, color: labelColor, size: tabIconSize)
        : RLTypography.bodyMedium(label, color: labelColor, textAlign: TextAlign.center);

    void handleTabTap() {
      SoundService.playSwitch();
      HapticsService.lightImpact();
      onTap();
    }

    if (isSelected) {
      return GestureDetector(
        onTap: handleTabTap,
        behavior: HitTestBehavior.opaque,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          borderColor: showBorder ? labelColor : RLDS.transparent,
          borderWidth: showBorder ? 2.0 : 0.0,
          padding: tabPadding,
          child: selectedContent,
        ),
      );
    }

    // Wrap the unselected tab in an opaque GestureDetector so the entire
    // padded slot registers taps — clicking the empty space around the
    // glyph still flips the selection. Haptic is fired here directly
    // (the inner Container has no onTap, so there's no double-fire risk).
    return GestureDetector(
      onTap: handleTabTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: tabPadding,
        alignment: Alignment.center,
        child: unselectedContent,
      ),
    );
  }
}
