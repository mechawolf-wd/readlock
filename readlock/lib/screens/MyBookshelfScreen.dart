// My Bookshelf screen showing user's saved and in-progress books
// Simple bookshelf layout with settings access

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/screens/ProfileScreen.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const String BOOKSHELF_TITLE = 'My Bookshelf';

class MyBookshelfScreen extends StatefulWidget {
  const MyBookshelfScreen({super.key});

  @override
  State<MyBookshelfScreen> createState() => MyBookshelfScreenState();
}

class MyBookshelfScreenState extends State<MyBookshelfScreen> {
  void showAllTitlesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllTitlesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
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

            // Bookshelf collections
            BookshelfCollections(),

            const Spacing.height(24),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget BookshelfHeaderWithSettings() {
    final BoxDecoration settingsIconDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLTheme.grey300.withValues(alpha: 0.3)),
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
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SettingsBottomSheet(),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: settingsIconDecoration,
          child: const Icon(
            Icons.settings,
            color: RLTheme.textSecondary,
            size: 20,
          ),
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
        'coverImage': 'covers/doet-cover.png',
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'progress': 0.22,
        'coverImage': null,
      },
      {
        'title': 'Hooked',
        'author': 'Nir Eyal',
        'progress': 0.67,
        'coverImage': null,
      },
    ];

    return Div.column([
      Div.row([
        Expanded(child: RLTypography.headingMedium('Reading')),

        ViewAllBooksButton(),
      ], crossAxisAlignment: CrossAxisAlignment.center),

      const Spacing.height(16),

      Div.column(
        ReadingBookCards(currentBooks),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> ReadingBookCards(List<Map<String, dynamic>> books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final double bookProgress = book['progress'] ?? 0.0;
      final String? coverImagePath = book['coverImage'];
      final int progressPercent = (bookProgress * 100).toInt();
      final bool hasCoverImage = coverImagePath != null;

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RLTheme.grey300.withValues(alpha: 0.3),
        ),
      );

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: RLTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration,
        child: Div.row([
          // Book cover
          BookCoverWidget(
            coverImagePath: coverImagePath,
            coverPlaceholderDecoration: coverPlaceholderDecoration,
          ),

          const Spacing.width(12),

          // Book info
          Expanded(
            child: Div.column([
              RLTypography.bodyLarge(bookTitle),

              const Spacing.height(4),

              RLTypography.text(
                bookAuthor,
                color: RLTheme.textSecondary,
              ),

              const Spacing.height(12),

              Div.column([
                Div.row([
                  Expanded(
                    child: ProgressBar(
                      progress: bookProgress,
                      color: RLTheme.primaryGreen,
                    ),
                  ),

                  const Spacing.width(8),

                  RLTypography.text(
                    '$progressPercent%',
                    color: RLTheme.primaryGreen,
                  ),
                ]),
              ]),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),
        ]),
      );
    }).toList();
  }

  Widget BookCoverWidget({
    required String? coverImagePath,
    required BoxDecoration coverPlaceholderDecoration,
  }) {
    final bool hasCover = coverImagePath != null;

    if (hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          coverImagePath,
          width: 60,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 60,
      height: 80,
      decoration: coverPlaceholderDecoration,
      child: const Icon(
        Icons.book,
        color: RLTheme.primaryBlue,
        size: 24,
      ),
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
      border: Border.all(
        color: RLTheme.primaryBlue.withValues(alpha: 0.3),
      ),
    );

    return GestureDetector(
      onTap: showAllTitlesBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: buttonDecoration,
        child: Div.row([
          RLTypography.text(
            'Titles and history',
            color: RLTheme.primaryBlue,
          ),

          const Spacing.width(4),

          const Icon(
            Icons.arrow_forward_ios,
            color: RLTheme.primaryBlue,
            size: 12,
          ),
        ]),
      ),
    );
  }

  Widget BookshelfCollections() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Business', 'count': 8},
      {'name': 'Self-Help', 'count': 15},
      {'name': 'Design', 'count': 12},
      {'name': 'Psychology', 'count': 6},
      {'name': 'Technology', 'count': 10},
      {'name': 'Fiction', 'count': 4},
    ];

    return Div.column([
      Div.row([
        RLTypography.headingMedium('Categories'),
      ], mainAxisAlignment: MainAxisAlignment.start),

      const Spacing.height(16),

      Div.column(
        CategoryCards(categories),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> CategoryCards(List<Map<String, dynamic>> categories) {
    final List<Color> colors = [
      RLTheme.primaryBlue,
      RLTheme.errorColor,
      RLTheme.primaryGreen,
      RLTheme.accentPurple,
      RLTheme.warningColor,
      RLTheme.accentTeal,
    ];

    return categories.asMap().entries.map((entry) {
      final int categoryIndex = entry.key;
      final String categoryName = entry.value['name'] ?? '';
      final int categoryCount = entry.value['count'] ?? 0;
      final Color categoryColor = colors[categoryIndex % colors.length];

      final BoxDecoration categoryCardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: categoryCardDecoration,
        child: Div.row([
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
            ),
          ),

          const Spacing.width(12),

          Expanded(child: RLTypography.text(categoryName)),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RLTypography.text(
              '$categoryCount',
              color: categoryColor,
            ),
          ),

          const Spacing.width(8),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: RLTheme.textSecondary,
          ),
        ]),
      );
    }).toList();
  }

  Widget SettingsBottomSheet() {
    const BorderRadius sheetBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    final BoxDecoration sheetDecoration = BoxDecoration(
      color: RLTheme.backgroundDark,
      borderRadius: sheetBorderRadius,
    );

    final BoxDecoration handleDecoration = BoxDecoration(
      color: RLTheme.textSecondary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(4),
    );

    return ClipRRect(
      borderRadius: sheetBorderRadius,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: sheetDecoration,
        child: Div.column([
          // Drag handle
          const Spacing.height(12),

          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: handleDecoration,
            ),
          ),

          const Spacing.height(16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Div.row([
              RLTypography.headingMedium('Settings'),
            ], mainAxisAlignment: MainAxisAlignment.start),
          ),

          const Spacing.height(20),

          // Settings content
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ProfileContent(),
            ),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.stretch),
      ),
    );
  }
}

class AllTitlesBottomSheet extends StatefulWidget {
  const AllTitlesBottomSheet({super.key});

  @override
  State<AllTitlesBottomSheet> createState() =>
      AllTitlesBottomSheetState();
}

class AllTitlesBottomSheetState extends State<AllTitlesBottomSheet> {
  String? selectedCategory;

  void selectCategory(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = null;
      } else {
        selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius sheetBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    final BoxDecoration sheetDecoration = BoxDecoration(
      color: RLTheme.backgroundDark,
      borderRadius: sheetBorderRadius,
    );

    final BoxDecoration handleDecoration = BoxDecoration(
      color: RLTheme.textSecondary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(4),
    );

    final List<Map<String, dynamic>> allBooks = [
      {
        'title': 'Design of Everyday Things',
        'author': 'Don Norman',
        'category': 'Design',
        'coverImage': 'covers/doet-cover.png',
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'category': 'Psychology',
        'coverImage': null,
      },
      {
        'title': 'Hooked',
        'author': 'Nir Eyal',
        'category': 'Design',
        'coverImage': null,
      },
      {
        'title': 'The Lean Startup',
        'author': 'Eric Ries',
        'category': 'Business',
        'coverImage': null,
      },
      {
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'category': 'Technology',
        'coverImage': null,
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'category': 'Self-Help',
        'coverImage': null,
      },
      {
        'title': 'Deep Work',
        'author': 'Cal Newport',
        'category': 'Psychology',
        'coverImage': null,
      },
    ];

    final bool hasSelectedCategory = selectedCategory != null;

    final List<Map<String, dynamic>> filteredBooks = hasSelectedCategory
        ? allBooks
              .where((book) => book['category'] == selectedCategory)
              .toList()
        : allBooks;

    return ClipRRect(
      borderRadius: sheetBorderRadius,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: sheetDecoration,
        child: Div.column([
          // Drag handle
          const Spacing.height(12),

          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: handleDecoration,
            ),
          ),

          const Spacing.height(16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Div.row([
              RLTypography.headingMedium('My Titles'),
            ], mainAxisAlignment: MainAxisAlignment.start),
          ),

          const Spacing.height(16),

          // Category filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CategoryFilters(
              selectedCategory: selectedCategory,
              onCategorySelected: selectCategory,
            ),
          ),

          const Spacing.height(20),

          // Books list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Div.column(
                AllTitlesBookCards(filteredBooks),
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.stretch),
      ),
    );
  }

  Widget CategoryFilters({
    required String? selectedCategory,
    required Function(String) onCategorySelected,
  }) {
    final List<String> categories = [
      'Design',
      'Psychology',
      'Business',
      'Technology',
      'Self-Help',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final bool isSelected = selectedCategory == category;

        final BoxDecoration chipDecoration = BoxDecoration(
          color: isSelected
              ? RLTheme.primaryBlue
              : RLTheme.backgroundLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: RLTheme.primaryBlue.withValues(alpha: 0.3),
          ),
        );

        final Color chipTextColor = isSelected
            ? Colors.white
            : RLTheme.primaryBlue;

        return GestureDetector(
          onTap: () => onCategorySelected(category),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: chipDecoration,
            child: RLTypography.text(category, color: chipTextColor),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> AllTitlesBookCards(List<Map<String, dynamic>> books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RLTheme.grey300.withValues(alpha: 0.3),
        ),
      );

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: RLTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration,
        child: Div.row([
          // Book cover
          AllTitlesBookCover(
            coverImagePath: coverImagePath,
            coverPlaceholderDecoration: coverPlaceholderDecoration,
          ),

          const Spacing.width(12),

          // Book info
          Expanded(
            child: Div.column([
              RLTypography.bodyLarge(bookTitle),

              const Spacing.height(4),

              RLTypography.text(
                bookAuthor,
                color: RLTheme.textSecondary,
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),
        ]),
      );
    }).toList();
  }

  Widget AllTitlesBookCover({
    required String? coverImagePath,
    required BoxDecoration coverPlaceholderDecoration,
  }) {
    final bool hasCover = coverImagePath != null;

    if (hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          coverImagePath,
          width: 40,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 40,
      height: 60,
      decoration: coverPlaceholderDecoration,
      child: const Icon(
        Icons.book,
        color: RLTheme.primaryBlue,
        size: 20,
      ),
    );
  }
}
