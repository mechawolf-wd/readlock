// Shared "filter a list of courses" pane, frosted LunarBlur surface
// hosting a horizontally-scrollable genre chip ribbon stacked above a
// title search field. The visual was originally inlined in CoursesScreen
// (Search) and is now lifted here so MyBookshelf can mount the same UI
// when the reader taps its filter affordance.
//
// Stateless on purpose. The host owns the chip selection set, the search
// controller, and the change handlers; this widget is only the layout
// and styling so a future restyle is a single edit.

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLSelectableFilterChips.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/design_system/RLUtility.dart';

class RLCourseFilterPanel extends StatelessWidget {
  final List<String> availableGenres;
  final Set<String> selectedGenres;
  final ValueChanged<String> onGenreToggled;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchPlaceholder;

  const RLCourseFilterPanel({
    super.key,
    required this.availableGenres,
    required this.selectedGenres,
    required this.onGenreToggled,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasGenres = availableGenres.isNotEmpty;

    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusMedium,
      padding: const EdgeInsets.all(RLDS.spacing12),
      child: Div.column([
        RenderIf.condition(hasGenres, GenreChipsRow()),

        RenderIf.condition(hasGenres, const Spacing.height(RLDS.spacing12)),

        SearchBar(),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Single horizontally-scrollable row for the closed genre list. Reads as
  // one long ribbon the user pans through, instead of stacking onto a
  // second line.
  Widget GenreChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: ChipRowChildren()),
    );
  }

  List<Widget> ChipRowChildren() {
    final List<Widget> children = [];

    for (int chipIndex = 0; chipIndex < availableGenres.length; chipIndex++) {
      final bool isFirstChip = chipIndex == 0;

      if (!isFirstChip) {
        children.add(const Spacing.width(RLDS.spacing8));
      }

      final String genre = availableGenres[chipIndex];
      final bool isSelected = selectedGenres.contains(genre);

      void onChipTap() => onGenreToggled(genre);

      children.add(
        SelectableFilterChip(
          label: genre,
          isSelected: isSelected,
          onTap: onChipTap,
        ),
      );
    }

    return children;
  }

  Widget SearchBar() {
    return RLTextField(
      controller: searchController,
      hintText: searchPlaceholder,
      leadingIcon: Pixel.search,
      onChanged: onSearchChanged,
    );
  }
}
