import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/screens/world_screen.dart';
import 'package:relevant/screens/books_screen.dart';
import 'package:relevant/screens/profile_screen.dart';

void main() {
  runApp(const RelevantApp());
}

/// @Class: Main application widget that sets up theme and navigation
class RelevantApp extends StatelessWidget {
  const RelevantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_TITLE,
      theme: appTheme(),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  /// @Method: Creates and returns the application theme configuration
  ThemeData appTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryBrown,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppTheme.backgroundDark,
      useMaterial3: true,
      textTheme: GoogleFonts.crimsonTextTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppTheme.textPrimary,
        displayColor: AppTheme.textPrimary,
      ),
    );
  }
}

/// @Class: Main navigation screen that handles page switching between different sections
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = AppConstants.WORLD_INDEX;
  late PageController pageController;

  /// @Method: Initializes the page controller with the default page index
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
  }

  /// @Method: Disposes of the page controller to prevent memory leaks
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: handlePageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          WorldScreen(),
          BooksScreen(),
          ProfileScreen()
        ],
      ),
      bottomNavigationBar: navigationBar(),
    );
  }

  /// @Method: Handles navigation tab selection with smooth animation
  void handleNavigationTap(int navigationIndex) {
    pageController.animateToPage(
      navigationIndex,
      duration: const Duration(
        milliseconds: AppConstants.ANIMATION_DURATION_MS,
      ),
      curve: Curves.easeInOut,
    );
  }

  /// @Method: Updates current index when page changes
  void handlePageChanged(int pageIndex) {
    setState(() {
      currentIndex = pageIndex;
    });
  }

  /// @Widget: Creates the bottom navigation bar with three main sections
  Widget navigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: handleNavigationTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: AppConstants.WORLD_LABEL,
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: AppConstants.BOOKS_LABEL,
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppConstants.PROFILE_LABEL,
        ),
      ],
    );
  }
}
