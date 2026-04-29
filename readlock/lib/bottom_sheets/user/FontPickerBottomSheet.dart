// Bottom sheet that lets the reader pick the font used for course swipes.
// Three options shown in a horizontal swipe slider, mirroring the plan
// slider in FeathersBottomSheet: each card renders its description in the
// option's typeface so the reader sees a true sample. Swiping the slider
// updates selectedReadingFontNotifier; every reading surface picks up the
// change on its next rebuild.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/UserService.dart';

import 'package:pixelarticons/pixel.dart';

// Matches AccountBottomSheet / Support sheet outer padding for the title
// block. The slider itself sits flush to the screen edges so peeking
// neighbour cards read past the page padding.
const EdgeInsets FONT_PICKER_TITLE_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing0,
);

const EdgeInsets FONT_PICKER_BOTTOM_PADDING = EdgeInsets.only(bottom: RLDS.spacing24);

// * Slider tuning — same horizontal PageView pattern as FeathersBottomSheet.
const double FONT_SLIDER_HEIGHT = 200.0;
const double FONT_CARD_VIEWPORT_FRACTION = 0.78;

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
  late PageController fontController;

  @override
  void initState() {
    super.initState();

    selectedFont = selectedReadingFontNotifier.value;

    final int initialIndex = getInitialFontIndex();

    fontController = PageController(
      initialPage: initialIndex,
      viewportFraction: FONT_CARD_VIEWPORT_FRACTION,
    );
  }

  @override
  void dispose() {
    fontController.dispose();
    super.dispose();
  }

  int getInitialFontIndex() {
    for (int optionIndex = 0; optionIndex < READING_FONT_OPTIONS.length; optionIndex++) {
      final bool isCurrent = READING_FONT_OPTIONS[optionIndex].font == selectedFont;

      if (isCurrent) {
        return optionIndex;
      }
    }

    return 0;
  }

  // Page change is the selection. Tick haptic per page change matches the
  // plan slider so swiping between typefaces feels detented.
  void handlePageChanged(int index) {
    HapticFeedback.selectionClick();

    final ReadingFont nextFont = READING_FONT_OPTIONS[index].font;

    selectedReadingFontNotifier.value = nextFont;

    setState(() {
      selectedFont = nextFont;
    });

    // Optimistic persistence — the notifier update above already drove the UI,
    // and the Firestore write is fire-and-forget so swiping between fonts
    // never stalls on a network round-trip. UserService logs failures.
    UserService.updateReadingFont(nextFont.name);
  }

  // Tapping an off-centre card animates the slider to that page; tapping
  // the centred card is a no-op (it's already selected).
  void handleCardTap(int index) {
    final bool isAlreadySelected = READING_FONT_OPTIONS[index].font == selectedFont;

    if (isAlreadySelected) {
      return;
    }

    fontController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FONT_PICKER_BOTTOM_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: FONT_PICKER_TITLE_PADDING, child: HeaderRow()),

          const Spacing.height(RLDS.spacing24),

          FontSlider(),
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

  Widget FontSlider() {
    return SizedBox(
      height: FONT_SLIDER_HEIGHT,
      child: PageView.builder(
        controller: fontController,
        itemCount: READING_FONT_OPTIONS.length,
        onPageChanged: handlePageChanged,
        itemBuilder: FontCardForIndex,
      ),
    );
  }

  Widget FontCardForIndex(BuildContext context, int optionIndex) {
    final ReadingFontOption option = READING_FONT_OPTIONS[optionIndex];
    final bool isSelected = option.font == selectedFont;

    void onCardTap() => handleCardTap(optionIndex);

    return FontCard(option: option, isSelected: isSelected, onTap: onCardTap);
  }
}

// Single typeface card — frosted LunarBlur pane that fills its slot. The
// selected (centred) card paints at full opacity; off-centre cards fade
// to the secondary alpha so the eye lands on the active typeface without
// hiding the others. Mirrors PlanCard's geometry from FeathersBottomSheet.
class FontCard extends StatelessWidget {
  final ReadingFontOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const FontCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  static const EdgeInsets cardPadding = EdgeInsets.all(RLDS.spacing20);
  static const EdgeInsets cardOuterPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing8,
    vertical: RLDS.spacing4,
  );

  @override
  Widget build(BuildContext context) {
    final double cardOpacity = isSelected ? 1.0 : 0.45;

    return Padding(
      padding: cardOuterPadding,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: cardOpacity,
          child: RLLunarBlur(
            borderRadius: RLDS.borderRadiusMedium,
            padding: cardPadding,
            child: FontCardBody(option: option),
          ),
        ),
      ),
    );
  }
}

// Card body — sample text rendered in the option's typeface, centred in
// the card so the card itself reads as a calm preview pane.
class FontCardBody extends StatelessWidget {
  final ReadingFontOption option;

  const FontCardBody({super.key, required this.option});

  // Sample-line style mirrors what CCTextContent renders: readingMedium
  // promoted to fontSize 18 / height 1.6, white text.
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

    return Align(
      alignment: Alignment.topLeft,
      child: Text(option.description, style: sampleStyle),
    );
  }
}
