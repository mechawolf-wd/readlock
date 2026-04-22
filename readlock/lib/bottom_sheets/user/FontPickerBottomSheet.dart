// Bottom sheet that lets the reader pick the font used for course swipes.
// Three rows — Serif / Dyslexic Friendly / Monospace — each showing a sample
// line in the font it applies, rendered at the exact size & line-height the
// reader will see in CCTextContent (fontSize 18, height 1.6 — what
// ProgressiveText.getConsistentTextStyle forces on every reading surface).
// Tapping a row updates selectedReadingFontNotifier; every reading surface
// picks up the change on its next rebuild.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';

import 'package:pixelarticons/pixel.dart';

// Matches AccountBottomSheet / Support sheet outer padding so the font
// picker reads as the same family of sheet.
const EdgeInsets FONT_PICKER_SHEET_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing24,
);

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
  static final Widget HeaderIcon = const Icon(
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

  void handleFontSelected(ReadingFont font) {
    HapticFeedback.selectionClick();

    selectedReadingFontNotifier.value = font;

    setState(() {
      selectedFont = font;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FONT_PICKER_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderRow(),

          const Spacing.height(RLDS.spacing16),

          OptionRowsList(),
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

  Widget OptionRowsList() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: OptionRowWidgets());
  }

  List<Widget> OptionRowWidgets() {
    final List<Widget> rows = [];

    for (int optionIndex = 0; optionIndex < READING_FONT_OPTIONS.length; optionIndex++) {
      final ReadingFontOption option = READING_FONT_OPTIONS[optionIndex];

      rows.add(FontOptionRow(option: option));

      final bool isLastOption = optionIndex == READING_FONT_OPTIONS.length - 1;

      if (!isLastOption) {
        rows.add(const Spacing.height(RLDS.spacing16));
      }
    }

    return rows;
  }

  // Card geometry matches the Settings demos (BlurDemo / RevealDemo /
  // ReadingFontDemo / ColoredTextDemo) so the picker reads as the same
  // family of card: 12px padding all-round, 8px border radius.
  static const EdgeInsets optionCardPadding = EdgeInsets.all(RLDS.spacing12);
  static final BorderRadius optionCardRadius = BorderRadius.circular(RLDS.spacing8);

  // Sample-line style mirrors exactly what CCTextContent renders via
  // ProgressiveText.getConsistentTextStyle: readingMedium promoted to
  // fontSize 18 / height 1.6, weightRegular (inherited from
  // readingMediumBase), letterSpacing 0.15 (inherited), colour textPrimary
  // (white). Only the font family switches per option.
  TextStyle getSampleStyle(ReadingFont font) {
    return RLTypography.readingMediumStyleFor(font).copyWith(
      fontSize: 18,
      height: 1.6,
      color: RLDS.textPrimary,
    );
  }

  // Each card shows only the option's description, rendered in the option's
  // font. The description doubles as name + sample + why-you-would-use-it,
  // so the reader gets all three pieces of information from a single block
  // of text set in the actual typeface they're evaluating.
  //
  // No border on either state — a border-only-when-selected treatment
  // shifts the card 1px on every selection change ("weird offset"). The
  // tinted background alone carries the selection state so the card's
  // outer box never moves. Text stays white in both states — matches
  // CCTextContent's reading colour.
  Widget FontOptionRow({required ReadingFontOption option}) {
    final bool isSelected = selectedFont == option.font;
    final BoxDecoration rowDecoration = getRowDecoration(isSelected);
    final TextStyle sampleStyle = getSampleStyle(option.font);
    final VoidCallback onRowTap = () => handleFontSelected(option.font);

    return Div.column(
      [Text(option.description, style: sampleStyle)],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: optionCardPadding,
      decoration: rowDecoration,
      onTap: onRowTap,
    );
  }

  BoxDecoration getRowDecoration(bool isSelected) {
    final Color rowColor = isSelected
        ? RLDS.info.withValues(alpha: 0.1)
        : RLDS.backgroundLight;

    return BoxDecoration(color: rowColor, borderRadius: optionCardRadius);
  }
}
