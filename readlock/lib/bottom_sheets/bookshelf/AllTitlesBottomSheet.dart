// All titles bottom sheet with category filtering
// Shows complete book library with filter chips

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/RLCard.dart';

class AllTitlesBottomSheet extends StatefulWidget {
  const AllTitlesBottomSheet({super.key});

  static void show(BuildContext context) {
    RLBottomSheet.showFullHeight(context, child: const AllTitlesBottomSheet());
  }

  @override
  State<AllTitlesBottomSheet> createState() => AllTitlesBottomSheetState();
}

class AllTitlesBottomSheetState extends State<AllTitlesBottomSheet> {
  String? selectedCategory;

  void selectCategory(String category) {
    final bool isSameCategory = selectedCategory == category;

    setState(() {
      if (isSameCategory) {
        selectedCategory = null;
      } else {
        selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final JSONList allBooks = [
      {
        'title': 'Design of Everyday Things',
        'author': 'Don Norman',
        'category': 'Design',
        'coverImage': 'assets/covers/doet-cover.png',
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'category': 'Psychology',
        'coverImage': null,
      },
      {'title': 'Hooked', 'author': 'Nir Eyal', 'category': 'Design', 'coverImage': null},
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

    JSONList filteredBooks = allBooks;

    if (hasSelectedCategory) {
      filteredBooks = allBooks.where((book) => book['category'] == selectedCategory).toList();
    }

    return Div.column([
      const Spacing.height(16),

      // Title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Div.row([
          RLTypography.headingMedium(RLUIStrings.ALL_TITLES_TITLE),
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
            BookCards(filteredBooks),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
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

    final List<Widget> chipWidgets = CategoryChipItems(
      categories,
      selectedCategory,
      onCategorySelected,
    );

    return Wrap(spacing: 8, runSpacing: 8, children: chipWidgets);
  }

  List<Widget> CategoryChipItems(
    List<String> categories,
    String? selectedCategory,
    Function(String) onCategorySelected,
  ) {
    return categories.map((category) {
      final bool isSelected = selectedCategory == category;

      Color chipColor = RLDS.backgroundLight.withValues(alpha: 0.08);
      Color chipTextColor = RLDS.primaryBlue;

      if (isSelected) {
        chipColor = RLDS.primaryBlue;
        chipTextColor = RLDS.white;
      }

      final BoxDecoration chipDecoration = BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RLDS.primaryBlue.withValues(alpha: 0.3)),
      );

      return GestureDetector(
        onTap: () => onCategorySelected(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: chipDecoration,
          child: Text(
            category,
            style: RLTypography.bodyMediumStyle.copyWith(color: chipTextColor),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> BookCards(JSONList books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLDS.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RLDS.primaryBlue.withValues(alpha: 0.2)),
      );

      return RLCard.subtle(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
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

              Text(
                bookAuthor,
                style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
              ),
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

    if (hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(coverImagePath, width: 40, height: 60, fit: BoxFit.cover),
      );
    }

    final Widget BookIcon = Icon(Icons.book, color: RLDS.primaryBlue, size: 20);

    return Container(
      width: 40,
      height: 60,
      decoration: coverPlaceholderDecoration,
      child: BookIcon,
    );
  }
}
