import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/widgets/bottom_navigation_widget.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => BooksScreenState();
}

class BooksScreenState extends State<BooksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  // @Widget: App bar
  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text(AppConstants.BOOKS_TITLE),
    );
  }

  // @Widget: Main body content
  Widget body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [welcomeText()],
      ),
    );
  }

  // @Widget: Welcome text
  Widget welcomeText() {
    return const Text(
      AppConstants.BOOKS_WELCOME_MESSAGE,
      style: TextStyle(fontSize: AppConstants.WELCOME_TEXT_SIZE),
    );
  }

  // @Widget: Bottom navigation
  Widget bottomNavigation() {
    return BottomNavigationWidget(
      currentIndex: AppConstants.BOOKS_INDEX,
      onTap: handleNavigationTap,
    );
  }

  void handleNavigationTap(int index) {
    final bool shouldNavigateToWorld =
        index == AppConstants.WORLD_INDEX;
    final bool shouldNavigateToProfile =
        index == AppConstants.PROFILE_INDEX;

    if (shouldNavigateToWorld) {
      Navigator.pushReplacementNamed(context, AppConstants.WORLD_ROUTE);
    } else if (shouldNavigateToProfile) {
      Navigator.pushReplacementNamed(
        context,
        AppConstants.PROFILE_ROUTE,
      );
    }
    // Already on Books screen if index == AppConstants.BOOKS_INDEX
  }
}
