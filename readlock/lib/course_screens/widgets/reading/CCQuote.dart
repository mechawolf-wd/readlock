// Widget for displaying notable quotes with bookmark functionality
// Clean design highlighting important insights from authors

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

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
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.warning.withValues(alpha: 0.2)),
    );

    return Container(
      color: RLDS.backgroundDark,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: quoteContainerDecoration,
          child: Div.column([
            QuoteHeader(),

            const Spacing.height(16),

            QuoteText(),

            const Spacing.height(12),

            QuoteFooter(),
          ]),
        ),
      ),
    );
  }

  Widget QuoteHeader() {
    final Widget QuoteIcon = const Icon(Icons.format_quote, color: RLDS.warning, size: 24);

    IconData bookmarkIconData = Icons.bookmark_border;

    if (isBookmarked) {
      bookmarkIconData = Icons.bookmark;
    }

    final Widget BookmarkToggleIcon = Icon(
      bookmarkIconData,
      color: RLDS.warning,
      size: 24,
    );

    return Div.row([
      QuoteIcon,

      const Spacing.width(12),

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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLDS.warning.withValues(alpha: 0.2), width: 2),
    );

    return Container(
      padding: const EdgeInsets.all(16),
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
