// Bottom sheet that lets the reader pick the font used for course swipes.
// Each option is a row in a vertical list rendered in its own typeface so
// the reader sees a true sample. Tapping a row updates
// selectedReadingFontNotifier; every reading surface picks up the change
// on its next rebuild.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/UserService.dart';

import 'package:pixelarticons/pixel.dart';

const EdgeInsets FONT_PICKER_CONTENT_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing24,
);

const EdgeInsets FONT_OPTION_ROW_PADDING = EdgeInsets.symmetric(
  vertical: RLDS.spacing16,
);

const double FONT_OPTION_UNSELECTED_OPACITY = 0.40;
const Duration FONT_OPTION_OPACITY_FADE = Duration(milliseconds: 200);

class FontPickerBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(context, child: const FontPickerSheet());
  }
}

class FontPickerSheet extends StatefulWidget {
  const FontPickerSheet({super.key});

  @override
  State<FontPickerSheet> createState() => FontPickerSheetState();
}

class FontPickerSheetState extends State<FontPickerSheet> {
  static const Icon HeaderIcon = Icon(
    Pixel.edit,
    color: RLDS.info,
    size: RLDS.iconMedium,
  );

  late ReadingFont selectedFont;

  @override
  void initState() {
    super.initState();

    selectedFont = selectedReadingFontNotifier.value;
  }

  // Tapping a row selects that font. No-op when the row is already the
  // active selection so the sheet doesn't re-fire haptics or re-write to
  // Firestore on a redundant tap.
  void handleOptionTap(ReadingFont nextFont) {
    final bool isAlreadySelected = nextFont == selectedFont;

    if (isAlreadySelected) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      selectedFont = nextFont;
    });

    selectedReadingFontNotifier.value = nextFont;

    // Optimistic persistence — the notifier update above already drove the UI,
    // and the Firestore write is fire-and-forget so the sheet never stalls
    // on a network round-trip. UserService logs failures.
    UserService.updateReadingFont(nextFont.name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FONT_PICKER_CONTENT_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          HeaderRow(),

          const Spacing.height(RLDS.spacing16),

          // Vertical list of font options
          FontOptionList(),
        ],
      ),
    );
  }

  Widget HeaderRow() {
    return Div.row([
      HeaderIcon,

      const Spacing.width(RLDS.spacing12),

      RLTypography.headingMedium(RLUIStrings.FONT_PICKER_TITLE),
    ], mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget FontOptionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: FontOptionRows(),
    );
  }

  List<Widget> FontOptionRows() {
    final List<Widget> rows = [];

    for (int optionIndex = 0; optionIndex < READING_FONT_OPTIONS.length; optionIndex++) {
      final ReadingFontOption option = READING_FONT_OPTIONS[optionIndex];
      final bool isSelected = option.font == selectedFont;

      void onRowTap() => handleOptionTap(option.font);

      rows.add(FontOptionRow(option: option, isSelected: isSelected, onTap: onRowTap));
    }

    return rows;
  }
}

// Single row in the font picker list. Renders the option's description in
// the option's own typeface so the reader sees a true sample. Selected row
// paints at full opacity; unselected rows fade so the eye lands on the
// active typeface without hiding the alternatives.
class FontOptionRow extends StatelessWidget {
  final ReadingFontOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const FontOptionRow({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  TextStyle getSampleStyle() {
    return RLTypography.readingMediumStyleFor(option.font).copyWith(
      fontSize: 18,
      height: 1.6,
      color: RLDS.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle sampleStyle = getSampleStyle();
    final double rowOpacity = isSelected ? 1.0 : FONT_OPTION_UNSELECTED_OPACITY;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: FONT_OPTION_OPACITY_FADE,
        opacity: rowOpacity,
        child: Padding(
          padding: FONT_OPTION_ROW_PADDING,
          child: Text(option.description, style: sampleStyle),
        ),
      ),
    );
  }
}
