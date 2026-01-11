// Widget for displaying notable quotes with bookmark functionality
// Clean design highlighting important insights from authors

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

class CCQuote extends StatefulWidget {
  final QuoteContent content;

  const CCQuote({super.key, required this.content});

  @override
  State<CCQuote> createState() => CCQuoteState();
}

class CCQuoteState extends State<CCQuote> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration quoteContainerDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLTheme.warningColor.withValues(alpha: 0.2)),
    );

    return Container(
      color: RLTheme.backgroundDark,
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
    return Div.row([
      Icon(Icons.format_quote, color: RLTheme.warningColor, size: 24),

      const Spacing.width(12),

      Expanded(child: RLTypography.bodyLarge('Notable Quote')),

      Div.row(
        [
          Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: RLTheme.warningColor,
            size: 24,
          ),
        ],
        onTap: () {
          setState(() {
            isBookmarked = !isBookmarked;
          });
        },
      ),
    ]);
  }

  Widget QuoteText() {
    final BoxDecoration quoteTextDecoration = BoxDecoration(
      color: RLTheme.warningColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.warningColor.withValues(alpha: 0.2),
        width: 2,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: quoteTextDecoration,
      child: RLTypography.bodyLarge('"${widget.content.quote}"'),
    );
  }

  Widget QuoteFooter() {
    return Div.row([
      RLTypography.bodyMedium(
        '— ${widget.content.author}',
        color: RLTheme.textPrimary.withValues(alpha: 0.7),
      ),

      const Spacer(),

      RenderIf.condition(
        isBookmarked,
        RLTypography.bodyMedium('Bookmarked ✓', color: RLTheme.warningColor),
      ),
    ]);
  }
}
