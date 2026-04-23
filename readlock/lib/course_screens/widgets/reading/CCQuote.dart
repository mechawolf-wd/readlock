// Widget for displaying notable quotes with bookmark functionality
// Clean design highlighting important insights from authors

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';
class CCQuote extends StatefulWidget {
  final QuoteSwipe content;

  const CCQuote({super.key, required this.content});

  @override
  State<CCQuote> createState() => CCQuoteState();
}

class CCQuoteState extends State<CCQuote> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration quoteContainerDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusMedium,
      border: Border.all(color: RLDS.warning.withValues(alpha: 0.2)),
    );

    return Padding(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(RLDS.spacing20),
          decoration: quoteContainerDecoration,
          child: Div.column([
            QuoteHeader(),

            const Spacing.height(RLDS.spacing16),

            QuoteText(),

            const Spacing.height(RLDS.spacing12),

            QuoteFooter(),
          ]),
        ),
      ),
    );
  }

  Widget QuoteHeader() {
    final Widget QuoteIcon = const Icon(Pixel.message, color: RLDS.warning, size: 24);

    IconData bookmarkIconData = Pixel.bookmark;

    if (isBookmarked) {
      bookmarkIconData = Pixel.bookmark;
    }

    final Widget BookmarkToggleIcon = Icon(
      bookmarkIconData,
      color: RLDS.warning,
      size: RLDS.iconLarge,
    );

    return Div.row([
      QuoteIcon,

      const Spacing.width(RLDS.spacing12),

      Expanded(child: RLTypography.bodyLarge(RLUIStrings.NOTABLE_QUOTE_TITLE)),

      Div.row([BookmarkToggleIcon], onTap: handleBookmarkToggle),
    ]);
  }

  void handleBookmarkToggle() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  Widget QuoteText() {
    final BoxDecoration quoteTextDecoration = BoxDecoration(
      color: RLDS.warning.withValues(alpha: 0.05),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.warning.withValues(alpha: 0.2), width: 2),
    );

    return Container(
      padding: const EdgeInsets.all(RLDS.spacing16),
      decoration: quoteTextDecoration,
      child: RLTypography.readingLarge('"${widget.content.quote}"'),
    );
  }

  Widget QuoteFooter() {
    return Div.row([
      RLTypography.bodyMedium(
        '— ${widget.content.author}',
        color: RLDS.textPrimary.withValues(alpha: 0.7),
      ),

      const Spacer(),

      RenderIf.condition(
        isBookmarked,
        RLTypography.bodyMedium(RLUIStrings.QUOTE_BOOKMARKED_LABEL, color: RLDS.warning),
      ),
    ]);
  }
}
