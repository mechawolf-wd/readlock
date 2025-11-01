import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/screens/world_screen.dart';
import 'package:relevant/screens/books_screen.dart';
import 'package:relevant/screens/profile_screen.dart';

void main() {
  runApp(const RelevantApp());
}

class RelevantApp extends StatelessWidget {
  const RelevantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_TITLE,
      theme: appTheme(),
      initialRoute: AppConstants.WORLD_ROUTE,
      routes: appRoutes(),
    );
  }

  // @Widget: App theme
  ThemeData appTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }

  // @Widget: App routes
  Map<String, WidgetBuilder> appRoutes() {
    return {
      AppConstants.WORLD_ROUTE: (context) => const WorldScreen(),
      AppConstants.BOOKS_ROUTE: (context) => const BooksScreen(),
      AppConstants.PROFILE_ROUTE: (context) => const ProfileScreen(),
    };
  }
}
