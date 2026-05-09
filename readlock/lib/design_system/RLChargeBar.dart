// Game-style charge bar with discrete colored tiles.
// 7 tiles run from red (critical) to green (fully charged), filling
// left-to-right based on a 0.0..1.0 fraction. The tile count and
// colors live in RLCoursePalette so the bar rescales automatically
// when the rental window changes.
//
// On first render each tile fades in sequentially using RLStaggerReveal,
// mirroring the tab-header typewriter so every progressive reveal in the
// app shares one timing token.
//
// When fully discharged (fraction <= 0) the tiles are replaced by a
// single blinking white strip that pulses opacity 0..1..0 to signal
// "needs recharge".

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLCoursePalette.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLStaggerReveal.dart';

// * Layout constants
const double CHARGE_BAR_TILE_HEIGHT = 8.0;
const double CHARGE_BAR_TILE_GAP = RLDS.spacing8;
const Duration CHARGE_BAR_BLINK_DURATION = Duration(milliseconds: 1400);

class RLChargeBar extends StatefulWidget {
  final double fraction;

  const RLChargeBar({super.key, required this.fraction});

  @override
  State<RLChargeBar> createState() => RLChargeBarState();
}

class RLChargeBarState extends State<RLChargeBar> with SingleTickerProviderStateMixin {
  late AnimationController blinkController;
  late Animation<double> blinkAnimation;

  @override
  void initState() {
    super.initState();

    blinkController = AnimationController(vsync: this, duration: CHARGE_BAR_BLINK_DURATION)
      ..repeat(reverse: true);

    blinkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: blinkController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double clampedFraction = widget.fraction.clamp(0.0, 1.0);
    final bool isDischarged = clampedFraction <= 0.0;

    if (isDischarged) {
      return DischargedBlinkBar();
    }

    final int filledTileCount = (clampedFraction * CHARGE_BAR_TILE_COUNT).ceil();

    return ChargeTilesRow(filledTileCount: filledTileCount);
  }

  // * Discharged state: a single full-width white strip that blinks.
  Widget DischargedBlinkBar() {
    return FadeTransition(
      opacity: blinkAnimation,
      child: Container(
        width: double.infinity,
        height: CHARGE_BAR_TILE_HEIGHT,
        color: RLDS.white,
      ),
    );
  }

  // Wraps tile layout in RLStaggerReveal so each tile fades in with the
  // same step + fade-window as the tab-header typewriter.
  Widget ChargeTilesRow({required int filledTileCount}) {
    return RLStaggerReveal(
      itemCount: CHARGE_BAR_TILE_COUNT,
      builder: (BuildContext context, List<double> opacities) {
        return Row(children: ChargeTiles(filledTileCount: filledTileCount, opacities: opacities));
      },
    );
  }

  List<Widget> ChargeTiles({required int filledTileCount, required List<double> opacities}) {
    final List<Widget> tiles = [];

    for (int tileIndex = 0; tileIndex < CHARGE_BAR_TILE_COUNT; tileIndex++) {
      final bool isNotFirstTile = tileIndex > 0;

      if (isNotFirstTile) {
        tiles.add(const SizedBox(width: CHARGE_BAR_TILE_GAP));
      }

      final bool isFilled = tileIndex < filledTileCount;
      final double opacity = opacities[tileIndex];

      final Color baseColor = isFilled ? CHARGE_BAR_TILE_COLORS[tileIndex] : RLDS.transparent;
      final Color tileColor = baseColor.withValues(alpha: isFilled ? opacity : 0.0);

      final BoxDecoration tileDecoration = BoxDecoration(color: tileColor);

      tiles.add(
        Expanded(
          child: Container(height: CHARGE_BAR_TILE_HEIGHT, decoration: tileDecoration),
        ),
      );
    }

    return tiles;
  }
}
