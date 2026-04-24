// Centralised book list card used across home, search, trending, and library
// Renders a subtle card with the course's palette book, title, and author.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/design_system/RLUtility.dart';

import 'package:pixelarticons/pixel.dart';

// List-card book thumbnail size. 48 = 0.75x of the 64-px source — a
// nearest-neighbour downscale that keeps the pixel art readable.
const double LIST_CARD_BOOK_SIZE = 48.0;

class BookListCard extends StatelessWidget {
  final String title;
  final String author;
  final String? courseColor;
  final String? coverImagePath;
  final VoidCallback? onTap;
  final EdgeInsets margin;

  const BookListCard({
    super.key,
    required this.title,
    required this.author,
    this.courseColor,
    this.coverImagePath,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: RLDS.spacing12),
  });

  @override
  Widget build(BuildContext context) {
    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: margin,
      onTap: onTap,
      child: Div.row([
        ListCardBook(),

        const Spacing.width(RLDS.spacing12),

        Expanded(
          child: Div.column([
            RLTypography.bodyLarge(title),

            const Spacing.height(RLDS.spacing4),

            RLTypography.bodyMedium(author, color: RLDS.textSecondary),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ),
      ]),
    );
  }

  // Prefer the palette book (matching hex PNG) when a course color is given.
  // Fall back to the legacy cover-image path / placeholder for unknown data.
  Widget ListCardBook() {
    final bool hasCourseColor = courseColor != null && courseColor!.isNotEmpty;

    if (hasCourseColor) {
      return RLCourseBookImage(
        courseColor: courseColor,
        size: LIST_CARD_BOOK_SIZE,
      );
    }

    return BookCoverThumbnail(coverImagePath: coverImagePath);
  }
}

class BookCoverThumbnail extends StatelessWidget {
  final String? coverImagePath;
  final double width;
  final double height;

  const BookCoverThumbnail({
    super.key,
    required this.coverImagePath,
    this.width = 40,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final String? resolvedPath = coverImagePath;
    final bool hasCover = resolvedPath != null && resolvedPath.isNotEmpty;
    final bool isNetworkCover = hasCover && resolvedPath.startsWith('http');
    final bool isAssetCover = hasCover && resolvedPath.startsWith('assets/');

    if (isNetworkCover) {
      return ClipRRect(
        borderRadius: RLDS.borderRadiusXSmall,
        child: Image.network(
          resolvedPath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: CoverErrorFallback,
        ),
      );
    }

    if (isAssetCover) {
      return ClipRRect(
        borderRadius: RLDS.borderRadiusXSmall,
        child: Image.asset(resolvedPath, width: width, height: height, fit: BoxFit.cover),
      );
    }

    return CoverPlaceholder();
  }

  Widget CoverErrorFallback(BuildContext context, Object error, StackTrace? stackTrace) {
    return CoverPlaceholder();
  }

  Widget CoverPlaceholder() {
    final BoxDecoration placeholderDecoration = BoxDecoration(
      color: RLDS.info.withValues(alpha: 0.1),
      borderRadius: RLDS.borderRadiusXSmall,
      border: Border.all(color: RLDS.info.withValues(alpha: 0.2)),
    );

    final Widget BookIcon = const Icon(Pixel.book, color: RLDS.info, size: 20);

    return Container(
      width: width,
      height: height,
      decoration: placeholderDecoration,
      child: BookIcon,
    );
  }
}
