// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/screens/courses_screen.dart';
import 'package:readlock/screens/shelf_screen.dart';
import 'package:readlock/screens/profile_screen.dart';
import 'package:readlock/screens/sandbox_screen.dart';

const String HOME_TAB_LABEL = 'Home';
const String COURSES_TAB_LABEL = 'Courses';
const String YOU_TAB_LABEL = 'You';
const String SANDBOX_TAB_LABEL = 'Sandbox';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const ShelfScreen(),
    const CoursesScreen(),
    const ProfileScreen(),
    const SandboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (navigationItemIndex) {
          setState(() {
            currentIndex = navigationItemIndex;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: NavigationItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> NavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.house),
        label: HOME_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book_sharp),
        label: COURSES_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: YOU_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.science),
        label: SANDBOX_TAB_LABEL,
      ),
    ];
  }
}
