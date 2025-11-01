import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/widgets/bottom_navigation_widget.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => WorldScreenState();
}

class WorldScreenState extends State<WorldScreen> {
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
      title: const Text(AppConstants.WORLD_TITLE),
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
      AppConstants.WORLD_WELCOME_MESSAGE,
      style: TextStyle(fontSize: AppConstants.WELCOME_TEXT_SIZE),
    );
  }

  // @Widget: Bottom navigation
  Widget bottomNavigation() {
    return BottomNavigationWidget(
      currentIndex: AppConstants.WORLD_INDEX,
      onTap: handleNavigationTap,
    );
  }

  void handleNavigationTap(int index) {
    final bool shouldNavigateToBooks =
        index == AppConstants.BOOKS_INDEX;
    final bool shouldNavigateToProfile =
        index == AppConstants.PROFILE_INDEX;

    if (shouldNavigateToBooks) {
      Navigator.pushReplacementNamed(context, AppConstants.BOOKS_ROUTE);
    } else if (shouldNavigateToProfile) {
      Navigator.pushReplacementNamed(
        context,
        AppConstants.PROFILE_ROUTE,
      );
    }
    // Already on World screen if index == AppConstants.WORLD_INDEX
  }
}
