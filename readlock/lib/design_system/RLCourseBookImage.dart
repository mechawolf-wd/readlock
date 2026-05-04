// Course book image — resolves a course color (hex, with or without '#') to
// the matching assets/books/{HEX}.png pixel-art cover. When the color isn't
// in the palette, renders the shared FALLBACK.png instead.
//
// Used on the roadmap hero (large) and every course list card (smaller).

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLCoursePalette.dart';

class RLSkillBookImage extends StatelessWidget {
  final String? courseColor;
  final double size;

  const RLSkillBookImage({super.key, required this.courseColor, required this.size});

  @override
  Widget build(BuildContext context) {
    final String normalized = (courseColor ?? '').replaceAll('#', '').trim().toUpperCase();
    final bool isKnownPaletteColor = KNOWN_COURSE_COLORS.contains(normalized);

    final String primaryAssetPath = isKnownPaletteColor
        ? '$COURSE_BOOKS_ASSET_PREFIX$normalized.png'
        : COURSE_FALLBACK_ASSET;

    return Image.asset(
      primaryAssetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: FallbackImageBuilder,
    );
  }

  Widget FallbackImageBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      COURSE_FALLBACK_ASSET,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => SizedBox(width: size, height: size),
    );
  }
}
