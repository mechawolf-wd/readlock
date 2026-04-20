// Bottom sheet that lets the user pick their profile bird
// Renders the 5 birds as a vertical wheel (iOS picker style) backed by selectedBirdNotifier

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

import 'package:pixelarticons/pixel.dart';
// * Wheel geometry — item extent fits the bird sprite plus vertical breathing room
const double BIRD_WHEEL_HEIGHT = 432.0;
const double BIRD_WHEEL_ITEM_EXTENT = 144.0;
const double BIRD_WHEEL_DIAMETER_RATIO = 2.5;

class BirdPickerBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
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
  late FixedExtentScrollController wheelController;

  static final Widget HeaderIcon = const Icon(Pixel.human, color: RLDS.primary, size: 20);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 16, 24, 24);
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(24, 0, 24, 24);

  @override
  void initState() {
    super.initState();

    final int initialIndex = BIRD_OPTIONS.indexWhere(
      (bird) => bird.name == selectedBirdNotifier.value.name,
    );

    wheelController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    wheelController.dispose();
    super.dispose();
  }

  void handleWheelChanged(int index) {
    HapticFeedback.selectionClick();
    selectedBirdNotifier.value = BIRD_OPTIONS[index];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          HeaderSection(),

          // Wheel body
          BodySection(),
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

  Widget BodySection() {
    final Widget wheel = WheelLayer();
    final Widget lens = LensOverlay();

    return Padding(
      padding: bodyPadding,
      child: SizedBox(
        height: BIRD_WHEEL_HEIGHT,
        child: Stack(
          children: [
            wheel,

            lens,
          ],
        ),
      ),
    );
  }

  Widget WheelLayer() {
    final List<Widget> wheelItems = WheelItems();

    return ListWheelScrollView(
      controller: wheelController,
      itemExtent: BIRD_WHEEL_ITEM_EXTENT,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: BIRD_WHEEL_DIAMETER_RATIO,
      onSelectedItemChanged: handleWheelChanged,
      children: wheelItems,
    );
  }

  List<Widget> WheelItems() {
    return BIRD_OPTIONS.map(WheelItem).toList();
  }

  Widget WheelItem(BirdOption bird) {
    final Widget BirdSprite = BirdAnimationSprite(bird: bird);

    return Center(
      child: Div.row([
        BirdSprite,

        const Spacing.width(RLDS.spacing16),

        RLTypography.headingMedium(bird.name, color: RLDS.primary),
      ], mainAxisAlignment: MainAxisAlignment.center),
    );
  }

  Widget LensOverlay() {
    final BoxDecoration lensDecoration = BoxDecoration(
      border: Border(
        top: BorderSide(color: RLDS.primary.withValues(alpha: 0.4), width: 1.5),
        bottom: BorderSide(color: RLDS.primary.withValues(alpha: 0.4), width: 1.5),
      ),
    );

    return IgnorePointer(
      child: Center(
        child: SizedBox(
          height: BIRD_WHEEL_ITEM_EXTENT,
          child: Container(decoration: lensDecoration),
        ),
      ),
    );
  }
}
