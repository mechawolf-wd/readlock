import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'Relevant',
      theme: appTheme(),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData appTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      useMaterial3: true,
      textTheme: GoogleFonts.crimsonTextTextTheme(ThemeData.dark().textTheme),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
  }

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
        children: const [WorldScreen(), BooksScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(),
    );
  }

  void handleNavigationTap(int navigationIndex) {
    pageController.animateToPage(
      navigationIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handlePageChanged(int pageIndex) {
    setState(() {
      currentIndex = pageIndex;
    });
  }

  Widget NavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: handleNavigationTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: 'World',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Books',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
