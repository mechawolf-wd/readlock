// Centralised book list card used across home, search, trending, and library
// Renders a subtle card with small book cover, title, and author

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLUtility.dart';

import 'package:pixelarticons/pixel.dart';
class BookListCard extends StatelessWidget {
  final String title;
  final String author;
  final String? coverImagePath;
  final VoidCallback? onTap;
  final EdgeInsets margin;

  const BookListCard({
    super.key,
    required this.title,
    required this.author,
    this.coverImagePath,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: margin,
      onTap: onTap,
      child: Div.row([
        BookCoverThumbnail(coverImagePath: coverImagePath),

        const Spacing.width(RLDS.spacing12),

        Expanded(
          child: Div.column([
            RLTypography.bodyLarge(title),

            const Spacing.height(RLDS.spacing4),

            Text(
              author,
              style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
            ),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ),
      ]),
    );
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
        borderRadius: BorderRadius.circular(6),
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
        borderRadius: BorderRadius.circular(6),
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
      borderRadius: BorderRadius.circular(6),
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
