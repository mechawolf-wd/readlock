import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/widgets/bottom_navigation_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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
      title: const Text(AppConstants.PROFILE_TITLE),
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
      AppConstants.PROFILE_WELCOME_MESSAGE,
      style: TextStyle(fontSize: AppConstants.WELCOME_TEXT_SIZE),
    );
  }

  // @Widget: Bottom navigation
  Widget bottomNavigation() {
    return BottomNavigationWidget(
      currentIndex: AppConstants.PROFILE_INDEX,
      onTap: handleNavigationTap,
    );
  }

  void handleNavigationTap(int index) {
    final bool shouldNavigateToWorld =
        index == AppConstants.WORLD_INDEX;
    final bool shouldNavigateToBooks =
        index == AppConstants.BOOKS_INDEX;

    if (shouldNavigateToWorld) {
      Navigator.pushReplacementNamed(context, AppConstants.WORLD_ROUTE);
    } else if (shouldNavigateToBooks) {
      Navigator.pushReplacementNamed(context, AppConstants.BOOKS_ROUTE);
    }
    // Already on Profile screen if index == AppConstants.PROFILE_INDEX
  }
}
