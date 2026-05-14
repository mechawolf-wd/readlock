// Pixel-art plume sprite used as the feather currency glyph. Shared by
// the bookshelf balance pill and the Feathers sheet plan cards so a single
// source of truth covers every place the app shows the feather unit.
//
// FilterQuality.none preserves the crisp pixel edges when the 16x16 source
// is rendered at any size larger than native.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLFeatherIcon extends StatelessWidget {
  final double size;

  const RLFeatherIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      RLDS.featherIconAsset,
      width: size,
      height: size,
      // Without an explicit fit, Image.asset draws the 16x16 source at its
      // intrinsic pixel size centred inside the requested box, so passing
      // size: 320 produces a 320 box with a 16px plume floating in it.
      // BoxFit.contain scales the sprite up to fill the box while keeping
      // its aspect ratio crisp under FilterQuality.none.
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
    );
  }
}
