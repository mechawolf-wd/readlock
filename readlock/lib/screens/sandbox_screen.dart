// Sandbox screen with experimental and engaging interactive widgets
// Playground for testing new course content patterns and interactions

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/app_theme.dart';

const String SANDBOX_TITLE = 'Widget Sandbox';

class SandboxScreen extends StatelessWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: const SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Div.column([
            SandboxHeader(),
            
            const Spacing.height(32),
            
            ThoughtPrompWidget(),
            
            const Spacing.height(24),
            
            BookmarkHighlightWidget(),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }
}

class SandboxHeader extends StatelessWidget {
  const SandboxHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Div.row([
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.science,
            color: Colors.white,
            size: 24,
          ),
        ),

        const Spacing.width(16),

        Expanded(
          child: Text(
            SANDBOX_TITLE,
            style: Typography.headingLargeStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            'EXPERIMENTAL',
            style: Typography.bodyMediumStyle.copyWith(
              color: Colors.purple,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.center),

      const Spacing.height(8),

      Text(
        'Essential widgets for engaging course content',
        style: Typography.bodyMediumStyle.copyWith(
          color: AppTheme.textPrimary.withValues(alpha: 0.7),
        ),
      ),
    ]);
  }
}


class ThoughtPrompWidget extends StatefulWidget {
  const ThoughtPrompWidget({super.key});

  @override
  State<ThoughtPrompWidget> createState() => ThoughtPrompWidgetState();
}

class ThoughtPrompWidgetState extends State<ThoughtPrompWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Div.column([
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Div.row([
            Icon(
              Icons.psychology,
              color: AppTheme.primaryBlue,
              size: 24,
            ),

            const Spacing.width(12),

            Expanded(
              child: Text(
                'Thought Prompt',
                style: Typography.bodyLargeStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ]),
        ),

        RenderIf.condition(
          isExpanded,
          Div.column([
            const Spacing.height(16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Think about a time when you encountered bad design. What made it frustrating? How could it have been improved using the principles from this chapter?',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const Spacing.height(12),

            Text(
              'Take a moment to reflect on this before continuing...',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                color: AppTheme.textPrimary.withValues(alpha: 0.6),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}


class BookmarkHighlightWidget extends StatefulWidget {
  const BookmarkHighlightWidget({super.key});

  @override
  State<BookmarkHighlightWidget> createState() => BookmarkHighlightWidgetState();
}

class BookmarkHighlightWidgetState extends State<BookmarkHighlightWidget> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Div.column([
        Div.row([
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
        ]),

        const Spacing.height(16),

        Container(
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
            '"Good design is obvious. Great design is transparent."',
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 16,
              height: 1.4,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Spacing.height(12),

        Div.row([
          Text(
            '— Joe Sparano',
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
        ]),
      ]),
    );
  }
}

