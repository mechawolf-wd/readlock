/// Screen that displays the books library and reading materials section
library;

import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';

/// @Class: Books screen for library and reading materials
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => BooksScreenState();
}

class BooksScreenState extends State<BooksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: mainBody());
  }

  /// @Widget: Main content area for book library and reading materials
  Widget mainBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [welcomeText()],
      ),
    );
  }

  /// @Widget: Welcoming message introducing the books section
  Widget welcomeText() {
    return const Text(
      AppConstants.BOOKS_WELCOME_MESSAGE,
      style: TextStyle(fontSize: AppConstants.WELCOME_TEXT_SIZE),
    );
  }
}
