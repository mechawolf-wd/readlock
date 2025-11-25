// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/ProfileScreen.dart';
import 'package:readlock/screens/SandboxScreen.dart';

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
    const HomeScreen(),
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
      backgroundColor: RLTheme.backgroundDark,
      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (navigationItemIndex) {
          setState(() {
            currentIndex = navigationItemIndex;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: RLTheme.primaryBlue,
        unselectedItemColor: RLTheme.textSecondary,
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
