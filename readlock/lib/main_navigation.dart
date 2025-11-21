// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/screens/courses_screen.dart';
import 'package:relevant/screens/shelf_screen.dart';
import 'package:relevant/screens/profile_screen.dart';
import 'package:relevant/screens/sandbox_screen.dart';

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
    // Reset invalid index during hot reload
    if (currentIndex >= screens.length) {
      currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure index is safe without mutating state
    final int safeIndex = (currentIndex >= 0 && currentIndex < screens.length) 
        ? currentIndex 
        : 0;
        
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (navigationItemIndex) {
          if (navigationItemIndex >= 0 && navigationItemIndex < screens.length) {
            setState(() {
              currentIndex = navigationItemIndex;
            });
          }
        },
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
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
