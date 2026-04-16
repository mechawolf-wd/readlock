// All titles bottom sheet
// Shows complete book library

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/BookListCard.dart';
import 'package:readlock/constants/DartAliases.dart';

class AllTitlesBottomSheet extends StatelessWidget {
  const AllTitlesBottomSheet({super.key});

  static void show(BuildContext context) {
    RLBottomSheet.showFullHeight(context, child: const AllTitlesBottomSheet());
  }

  @override
  Widget build(BuildContext context) {
    final JSONList allBooks = [
      {
        'title': 'Design of Everyday Things',
        'author': 'Don Norman',
        'coverImage': 'assets/covers/doet-cover.png',
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'coverImage': null,
      },
      {'title': 'Hooked', 'author': 'Nir Eyal', 'coverImage': null},
      {
        'title': 'The Lean Startup',
        'author': 'Eric Ries',
        'coverImage': null,
      },
      {
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'coverImage': null,
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'coverImage': null,
      },
      {
        'title': 'Deep Work',
        'author': 'Cal Newport',
        'coverImage': null,
      },
    ];

    return Div.column([
      const Spacing.height(16),

      // Books list
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Div.column(
            BookCards(allBooks),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  List<Widget> BookCards(JSONList books) {
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';
      final String? coverImagePath = book['coverImage'];

      return BookListCard(
        title: bookTitle,
        author: bookAuthor,
        coverImagePath: coverImagePath,
      );
    }).toList();
  }
}
