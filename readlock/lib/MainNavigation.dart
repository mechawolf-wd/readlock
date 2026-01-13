// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/screens/SandboxScreen.dart';

const String HOME_TAB_LABEL = 'Home';
const String SEARCH_TAB_LABEL = 'Search';
const String BOOKSHELF_TAB_LABEL = 'My Bookshelf';
const String SANDBOX_TAB_LABEL = 'Sandbox';

// Floating navigation bar constants
const double FLOATING_NAV_HEIGHT = 56.0;
const double FLOATING_NAV_MARGIN = 16.0;
const double FLOATING_NAV_BOTTOM_OFFSET =
    FLOATING_NAV_HEIGHT + FLOATING_NAV_MARGIN + 16.0;

class MainNavigation extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigation({super.key, this.initialTabIndex = 0});

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
      const MyBookshelfScreen(),
      const SandboxScreen(),
    ];
  }

  void handleNavigationTap(int navigationItemIndex) {
    setState(() {
      currentIndex = navigationItemIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: Stack(
        children: [
          // Main content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder:
                (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
            child: KeyedSubtree(
              key: ValueKey<int>(currentIndex),
              child: screens[currentIndex],
            ),
          ),

          // Floating bottom navigation
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: FloatingNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget FloatingNavigationBar() {
    final BoxDecoration navBarDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Container(
      decoration: navBarDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: handleNavigationTap,
            backgroundColor: Colors.white,
            selectedItemColor: RLTheme.primaryGreen,
            unselectedItemColor: const Color.fromARGB(255, 180, 180, 180),
            type: BottomNavigationBarType.fixed,
            items: NavigationItems(),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> NavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: HOME_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore_rounded),
        label: SEARCH_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.menu_book_outlined),
        activeIcon: Icon(Icons.menu_book_rounded),
        label: BOOKSHELF_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.science_outlined),
        activeIcon: Icon(Icons.science_rounded),
        label: SANDBOX_TAB_LABEL,
      ),
    ];
  }
}
