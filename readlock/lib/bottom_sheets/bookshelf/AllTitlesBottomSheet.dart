// All titles bottom sheet with category filtering
// Shows complete book library with filter chips

import 'package:flutter/material.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

class AllTitlesBottomSheet extends StatefulWidget {
  const AllTitlesBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllTitlesBottomSheet(),
    );
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
    const BorderRadius sheetBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    const BoxDecoration sheetDecoration = BoxDecoration(
      color: RLTheme.backgroundDark,
      borderRadius: sheetBorderRadius,
    );

    final List<Map<String, dynamic>> allBooks = [
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

    final List<Map<String, dynamic>> filteredBooks = hasSelectedCategory
        ? allBooks.where((book) => book['category'] == selectedCategory).toList()
        : allBooks;

    final double sheetHeight = MediaQuery.of(context).size.height * 0.9;

    return ClipRRect(
      borderRadius: sheetBorderRadius,
      child: Container(
        height: sheetHeight,
        decoration: sheetDecoration,
        child: Div.column([
          // Drag handle
          const Spacing.height(12),

          const BottomSheetGrabber(),

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
                BookCards(filteredBooks),
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

      final Color chipColor = isSelected
          ? RLTheme.primaryBlue
          : RLTheme.backgroundLight.withValues(alpha: 0.08);

      final BoxDecoration chipDecoration = BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RLTheme.primaryBlue.withValues(alpha: 0.3)),
      );

      final Color chipTextColor = isSelected ? Colors.white : RLTheme.primaryBlue;

      return GestureDetector(
        onTap: () => onCategorySelected(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: chipDecoration,
          child: RLTypography.text(category, color: chipTextColor),
        ),
      );
    }).toList();
  }

  List<Widget> BookCards(List<Map<String, dynamic>> books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RLTheme.grey300.withValues(alpha: 0.3)),
      );

      final BoxDecoration coverPlaceholderDecoration = BoxDecoration(
        color: RLTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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

    const Widget BookIcon = Icon(Icons.book, color: RLTheme.primaryBlue, size: 20);

    return Container(
      width: 40,
      height: 60,
      decoration: coverPlaceholderDecoration,
      child: BookIcon,
    );
  }
}
