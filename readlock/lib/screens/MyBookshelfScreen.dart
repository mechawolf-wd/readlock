// My Bookshelf screen showing user's saved and in-progress books
// Simple bookshelf layout with settings access

import 'package:flutter/material.dart';
import 'package:readlock/screens/profile/LearningStatsCard.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/BookListCard.dart';
import 'package:readlock/utility_widgets/RLProgressBar.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/bottom_sheets/user/SettingsBottomSheet.dart';
import 'package:readlock/bottom_sheets/bookshelf/AllTitlesBottomSheet.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/utility_widgets/RLCard.dart';

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
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RLDS.spacing24),
          child: Div.column([
            // Bookshelf title with settings
            BookshelfHeaderWithSettings(),

            const Spacing.height(24),

            // Currently reading grid
            CurrentlyReadingGrid(),

            const Spacing.height(24),

            // Learning statistics
            const LearningStatsCard(),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  static final Widget ArrowForwardIcon = const Icon(
    Icons.arrow_forward_ios,
    color: RLDS.info,
    size: 12,
  );

  static final Widget SettingsIcon = const Icon(Icons.settings, color: RLDS.textSecondary, size: 24);

  Widget BookshelfHeaderWithSettings() {
    return Div.row([
      Expanded(
        child: Div.column([
          RLTypography.headingLarge(RLUIStrings.BOOKSHELF_TITLE),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),

      GestureDetector(
        onTap: () => SettingsBottomSheet.show(context),
        child: SettingsIcon,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget CurrentlyReadingGrid() {
    final JSONList currentBooks = [
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
        Expanded(child: RLTypography.headingMedium(RLUIStrings.READING_SECTION_TITLE)),

        ViewAllBooksButton(),
      ], crossAxisAlignment: CrossAxisAlignment.center),

      const Spacing.height(16),

      Div.column(ReadingBookCards(currentBooks), crossAxisAlignment: CrossAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> ReadingBookCards(JSONList books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final double bookProgress = book['progress'] ?? 0.0;
      final String? coverImagePath = book['coverImage'];
      final int progressPercent = (bookProgress * 100).toInt();

      return RLCard.subtle(
        padding: const EdgeInsets.all(RLDS.spacing12),
        margin: const EdgeInsets.only(bottom: RLDS.spacing12),
        child: Div.row([
          // Book cover
          BookCoverThumbnail(
            coverImagePath: coverImagePath,
            width: 60,
            height: 80,
          ),

          const Spacing.width(12),

          // Book info
          Expanded(
            child: Div.column([
              RLTypography.bodyLarge(bookTitle),

              const Spacing.height(4),

              Text(
                bookAuthor,
                style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
              ),

              const Spacing.height(12),

              Div.row([
                Expanded(child: RLProgressBar(progress: bookProgress)),

                const Spacing.width(8),

                Text(
                  '$progressPercent%',
                  style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.success),
                ),
              ]),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),
        ]),
      );
    }).toList();
  }

  Widget ViewAllBooksButton() {
    return RLCard.subtle(
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing12,
        vertical: RLDS.spacing8,
      ),
      onTap: showAllTitlesBottomSheet,
      child: Div.row([
        Text(
          RLUIStrings.TITLES_AND_HISTORY_LABEL,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.info),
        ),

        const Spacing.width(4),

        ArrowForwardIcon,
      ]),
    );
  }
}
