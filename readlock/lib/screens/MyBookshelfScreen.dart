// My Bookshelf screen showing user's saved and in-progress books
// Simple bookshelf layout with settings access

import 'package:flutter/material.dart';
import 'package:readlock/screens/profile/LearningStatsCard.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/bottom_sheets/user/SettingsBottomSheet.dart';
import 'package:readlock/bottom_sheets/bookshelf/AllTitlesBottomSheet.dart';

class MyBookshelfScreen extends StatefulWidget {
  const MyBookshelfScreen({super.key});

  @override
  State<MyBookshelfScreen> createState() => MyBookshelfScreenState();
}

class MyBookshelfScreenState extends State<MyBookshelfScreen> {
  void showAllTitlesBottomSheet() {
    AllTitlesBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Div.column([
            // Top stats bar
            const StatisticsTopBar(),

            const Spacing.height(24),

            // Bookshelf title with settings
            BookshelfHeaderWithSettings(),

            const Spacing.height(24),

            // Currently reading grid
            CurrentlyReadingGrid(),

            const Spacing.height(24),

            // Learning statistics
            const LearningStatsCard(),

            // Bottom spacing for floating navigation
            const Spacing.height(FLOATING_NAV_BOTTOM_OFFSET),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  static const Widget ArrowForwardIcon = Icon(
    Icons.arrow_forward_ios,
    color: RLTheme.primaryBlue,
    size: 12,
  );

  static const Widget SettingsIcon = Icon(
    Icons.settings,
    color: RLTheme.textSecondary,
    size: 24,
  );

  Widget BookshelfHeaderWithSettings() {
    final BoxDecoration settingsIconDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    );

    return Div.row([
      Expanded(
        child: Div.column([
          RLTypography.headingLarge(BOOKSHELF_TITLE),

          const Spacing.height(4),

          RLTypography.text('12 titles', color: RLTheme.textSecondary),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),

      GestureDetector(
        onTap: () => SettingsBottomSheet.show(context),
        child: Container(
          padding: const EdgeInsets.only(top: 8, right: 12),
          decoration: settingsIconDecoration,
          child: SettingsIcon,
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget CurrentlyReadingGrid() {
    final List<Map<String, dynamic>> currentBooks = [
      {
        'title': 'Design of Everyday Things',
        'author': 'Don Norman',
        'progress': 0.45,
        'coverImage': 'assets/covers/doet-cover.png',
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'progress': 0.22,
        'coverImage': null,
      },
      {'title': 'Hooked', 'author': 'Nir Eyal', 'progress': 0.67, 'coverImage': null},
    ];

    return Div.column([
      Div.row([
        Expanded(child: RLTypography.headingMedium('Reading')),

        ViewAllBooksButton(),
      ], crossAxisAlignment: CrossAxisAlignment.center),

      const Spacing.height(16),

      Div.column(ReadingBookCards(currentBooks), crossAxisAlignment: CrossAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> ReadingBookCards(List<Map<String, dynamic>> books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final double bookProgress = book['progress'] ?? 0.0;
      final String? coverImagePath = book['coverImage'];
      final int progressPercent = (bookProgress * 100).toInt();

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RLTheme.grey300.withValues(alpha: 0.3)),
      );

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RLTheme.primaryBlue.withValues(alpha: 0.2)),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration,
        child: Div.row([
          // Book cover
          BookCover(
            coverImagePath: coverImagePath,
            coverPlaceholderDecoration: coverPlaceholderDecoration,
          ),

          const Spacing.width(12),

          // Book info
          Expanded(
            child: Div.column([
              RLTypography.bodyLarge(bookTitle),

              const Spacing.height(4),

              RLTypography.text(bookAuthor, color: RLTheme.textSecondary),

              const Spacing.height(12),

              Div.column([
                Div.row([
                  Expanded(
                    child: ProgressBar(progress: bookProgress, color: RLTheme.primaryGreen),
                  ),

                  const Spacing.width(8),

                  RLTypography.text('$progressPercent%', color: RLTheme.primaryGreen),
                ]),
              ]),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),
        ]),
      );
    }).toList();
  }

  Widget BookCover({
    required String? coverImagePath,
    required BoxDecoration coverPlaceholderDecoration,
  }) {
    final bool hasCover = coverImagePath != null;

    const Widget BookIcon = Icon(Icons.book, color: RLTheme.primaryBlue, size: 24);

    if (hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(coverImagePath, width: 60, height: 80, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 60,
      height: 80,
      decoration: coverPlaceholderDecoration,
      child: BookIcon,
    );
  }

  Widget ProgressBar({required double progress, required Color color}) {
    final BoxDecoration trackDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
    );

    final BoxDecoration fillDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    );

    return Container(
      height: 4,
      decoration: trackDecoration,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(decoration: fillDecoration),
      ),
    );
  }

  Widget ViewAllBooksButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
    );

    return GestureDetector(
      onTap: showAllTitlesBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: buttonDecoration,
        child: Div.row([
          RLTypography.text('Titles and history', color: RLTheme.primaryBlue),

          const Spacing.width(4),

          ArrowForwardIcon,
        ]),
      ),
    );
  }
}
