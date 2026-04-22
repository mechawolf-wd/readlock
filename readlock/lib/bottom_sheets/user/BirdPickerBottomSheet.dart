// Bottom sheet that lets the user pick their profile bird.
// Horizontal snap-slider: one bird per page, name shown once below the slider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

import 'package:pixelarticons/pixel.dart';

// * Slider geometry
const double BIRD_SLIDER_HEIGHT = 200.0;
const double BIRD_SLIDER_VIEWPORT_FRACTION = 0.45;

class BirdPickerBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      useLunarBlurSurface: true,
      child: const BirdPickerSheet(),
    );
  }
}

class BirdPickerSheet extends StatefulWidget {
  const BirdPickerSheet({super.key});

  @override
  State<BirdPickerSheet> createState() => BirdPickerSheetState();
}

class BirdPickerSheetState extends State<BirdPickerSheet> {
  late PageController pageController;
  late int selectedIndex;

  static final Widget HeaderIcon = const Icon(Pixel.human, color: RLDS.primary, size: 20);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 16, 24, 0);
  static const EdgeInsets bodyPadding = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();

    selectedIndex = BIRD_OPTIONS.indexWhere(
      (bird) => bird.name == selectedBirdNotifier.value.name,
    );

    final bool hasNoMatch = selectedIndex < 0;

    if (hasNoMatch) {
      selectedIndex = 0;
    }

    pageController = PageController(
      initialPage: selectedIndex,
      viewportFraction: BIRD_SLIDER_VIEWPORT_FRACTION,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void handlePageChanged(int index) {
    HapticFeedback.selectionClick();

    setState(() {
      selectedIndex = index;
    });

    selectedBirdNotifier.value = BIRD_OPTIONS[index];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderSection(),

          SliderBody(),

          const Spacing.height(RLDS.spacing16),

          SelectedBirdName(),
        ],
      ),
    );
  }

  Widget HeaderSection() {
    return Div.row([
      HeaderIcon,

      const Spacing.width(12),

      RLTypography.headingMedium(RLUIStrings.BIRD_PICKER_TITLE),
    ], padding: headerPadding);
  }

  Widget SelectedBirdName() {
    final BirdOption selectedBird = BIRD_OPTIONS[selectedIndex];

    return RLTypography.headingLarge(selectedBird.name, color: RLDS.primary);
  }

  Widget SliderBody() {
    return Padding(
      padding: bodyPadding,
      child: SizedBox(
        height: BIRD_SLIDER_HEIGHT,
        child: PageView.builder(
          controller: pageController,
          physics: const PageScrollPhysics(),
          onPageChanged: handlePageChanged,
          itemCount: BIRD_OPTIONS.length,
          itemBuilder: SliderItemBuilder,
        ),
      ),
    );
  }

  Widget SliderItemBuilder(BuildContext context, int index) {
    final BirdOption bird = BIRD_OPTIONS[index];
    final bool isSelected = index == selectedIndex;
    final double itemScale = isSelected ? 1.0 : 0.7;
    final double itemOpacity = isSelected ? 1.0 : 0.5;

    return Center(
      child: Opacity(
        opacity: itemOpacity,
        child: Transform.scale(
          scale: itemScale,
          child: BirdAnimationSprite(bird: bird),
        ),
      ),
    );
  }
}
