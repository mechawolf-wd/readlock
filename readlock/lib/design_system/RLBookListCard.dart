// Centralised book list card used across home, search, trending, and library
// Renders a subtle card with the course's palette book, title, and author.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/feedback/HapticsService.dart';

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
  // Optional trailing buy affordance — renders a cart icon at the right
  // edge of the card with its own tap target. Inner GestureDetector
  // absorbs the tap so the outer card's onTap (typically navigate-to-
  // roadmap) doesn't fire when the user hits the icon.
  final VoidCallback? onBuyTap;
  final EdgeInsets margin;

  const BookListCard({
    super.key,
    required this.title,
    required this.author,
    this.courseColor,
    this.coverImagePath,
    this.onTap,
    this.onBuyTap,
    this.margin = const EdgeInsets.only(bottom: RLDS.spacing12),
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> rowChildren = [
      ListCardBook(),

      const Spacing.width(RLDS.spacing12),

      Expanded(
        child: Div.column([
          RLTypography.bodyLarge(title, maxLines: 1, overflow: TextOverflow.ellipsis),

          const Spacing.height(RLDS.spacing4),

          RLTypography.bodyMedium(author, color: RLDS.textSecondary),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    ];

    final VoidCallback? buyHandler = onBuyTap;
    final bool hasBuyHandler = buyHandler != null;

    if (hasBuyHandler) {
      rowChildren.add(const Spacing.width(RLDS.spacing12));
      rowChildren.add(BuyIconButton(onTap: buyHandler));
    }

    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing12),
      margin: margin,
      onTap: onTap,
      child: Div.row(rowChildren),
    );
  }

  // Trailing cart icon — sits at the right edge of the card with a
  // small padding so the tap target stays comfortable without growing
  // the card's row height. Muted glyph color so the icon reads as a
  // secondary affordance, not a primary CTA.
  Widget BuyIconButton({required VoidCallback onTap}) {
    final Widget CartIcon = const Icon(
      Pixel.cart,
      color: RLDS.markupGreen,
      size: RLDS.iconLarge,
    );

    void handleCartTap() {
      HapticsService.lightImpact();
      onTap();
    }

    return GestureDetector(
      onTap: handleCartTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: const EdgeInsets.all(RLDS.spacing4), child: CartIcon),
    );
  }

  // Prefer the palette book (matching hex PNG) when a course color is given.
  // Fall back to the legacy cover-image path / placeholder for unknown data.
  Widget ListCardBook() {
    final bool hasCourseColor = courseColor != null && courseColor!.isNotEmpty;

    if (hasCourseColor) {
      return RLSkillBookImage(courseColor: courseColor, size: LIST_CARD_BOOK_SIZE);
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
      color: RLDS.glass10(RLDS.info),
      borderRadius: RLDS.borderRadiusXSmall,
      border: Border.all(color: RLDS.glass15(RLDS.info)),
    );

    final Widget BookIcon = const Icon(Pixel.book, color: RLDS.info, size: RLDS.iconMedium);

    return Container(
      width: width,
      height: height,
      decoration: placeholderDecoration,
      child: BookIcon,
    );
  }
}
