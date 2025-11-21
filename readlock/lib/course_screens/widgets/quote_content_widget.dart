// Widget for displaying notable quotes with bookmark functionality
// Clean design highlighting important insights from authors

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';

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
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.2),
            ),
          ),
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
      Icon(
        Icons.format_quote,
        color: Colors.orange,
        size: 24,
      ),

      const Spacing.width(12),

      Expanded(
        child: Text(
          'Notable Quote',
          style: Typography.bodyLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      GestureDetector(
        onTap: () {
          setState(() {
            isBookmarked = !isBookmarked;
          });
        },
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.orange,
          size: 24,
        ),
      ),
    ]);
  }

  Widget QuoteText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Text(
        '"${widget.content.quote}"',
        style: Typography.bodyLargeStyle.copyWith(
          fontSize: 16,
          height: 1.4,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget QuoteFooter() {
    return Div.row([
      Text(
        '— ${widget.content.author}',
        style: Typography.bodyMediumStyle.copyWith(
          fontSize: 12,
          color: AppTheme.textPrimary.withValues(alpha: 0.7),
        ),
      ),

      const Spacer(),

      RenderIf.condition(
        isBookmarked,
        Text(
          'Bookmarked ✓',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ]);
  }
}