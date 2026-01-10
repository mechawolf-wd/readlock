// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/ProfileScreen.dart';
import 'package:readlock/screens/SandboxScreen.dart';

const String HOME_TAB_LABEL = 'Home';
const String SEARCH_TAB_LABEL = 'Search';
const String YOU_TAB_LABEL = 'You';
const String SANDBOX_TAB_LABEL = 'Sandbox';

class MainNavigation extends StatefulWidget {
  final int initialTabIndex;
  final bool showReadingLeagueExpanded;

  const MainNavigation({
    super.key,
    this.initialTabIndex = 0,
    this.showReadingLeagueExpanded = false,
  });

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late int currentIndex;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialTabIndex;

    screens = [
      const HomeScreen(),
      const CoursesScreen(),
      ProfileScreen(
        showReadingLeagueExpanded: widget.showReadingLeagueExpanded,
      ),
      const SandboxScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (navigationItemIndex) {
            setState(() {
              currentIndex = navigationItemIndex;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: RLTheme.primaryGreen,
          unselectedItemColor: const Color.fromARGB(255, 201, 201, 201),
          type: BottomNavigationBarType.fixed,
          items: NavigationItems(),
          selectedFontSize: 12,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> NavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.house_rounded),
        label: HOME_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: SEARCH_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_rounded),
        label: YOU_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.science_rounded),
        label: SANDBOX_TAB_LABEL,
      ),
    ];
  }
}
