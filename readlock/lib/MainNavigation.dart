// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/screens/SandboxScreen.dart';
import 'package:readlock/utility_widgets/LoginBottomSheet.dart';

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

    WidgetsBinding.instance.addPostFrameCallback(showLoginSheet);
  }

  void showLoginSheet(Duration timestamp) {
    LoginBottomSheet.show(context);
  }

  void handleNavigationTap(int navigationItemIndex) {
    final bool isSameTab = navigationItemIndex == currentIndex;

    if (isSameTab) {
      return;
    }

    HapticFeedback.lightImpact();

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
            duration: const Duration(milliseconds: 150),
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
    const BorderRadius navBarBorderRadius = BorderRadius.all(
      Radius.circular(28),
    );

    final BoxDecoration navBarDecoration = BoxDecoration(
      color: RLTheme.white,
      borderRadius: navBarBorderRadius,
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Container(
      decoration: navBarDecoration,
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: handleNavigationTap,
            backgroundColor: Colors.transparent,
            selectedItemColor: RLTheme.primaryGreen,
            unselectedItemColor: RLTheme.textSecondary,
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
