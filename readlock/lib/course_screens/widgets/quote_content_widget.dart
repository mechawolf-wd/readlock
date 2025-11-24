// Widget for displaying notable quotes with bookmark functionality
// Clean design highlighting important insights from authors

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';

class QuoteContentWidget extends StatefulWidget {
  final QuoteContent content;

  const QuoteContentWidget({super.key, required this.content});

  @override
  State<QuoteContentWidget> createState() => QuoteContentWidgetState();
}

class QuoteContentWidgetState extends State<QuoteContentWidget> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration quoteContainerDecoration = BoxDecoration(
      color: AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
    );

    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
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
      Icon(Icons.format_quote, color: Colors.orange, size: 24),

      const Spacing.width(12),

      Expanded(child: Typography.bodyLarge('Notable Quote')),

      Div.row(
        [Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.orange,
          size: 24,
        )],
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
      color: Colors.orange.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.orange.withValues(alpha: 0.2),
        width: 2,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: quoteTextDecoration,
      child: Typography.bodyLarge('"${widget.content.quote}"'),
    );
  }

  Widget QuoteFooter() {
    return Div.row([
      Typography.bodyMedium(
        '— ${widget.content.author}',
        color: AppTheme.textPrimary.withValues(alpha: 0.7),
      ),

      const Spacer(),

      RenderIf.condition(
        isBookmarked,
        Typography.bodyMedium('Bookmarked ✓', color: Colors.orange),
      ),
    ]);
  }
}
