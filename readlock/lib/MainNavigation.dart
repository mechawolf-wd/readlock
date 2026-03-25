// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/screens/SandboxScreen.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';

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
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: KeyedSubtree(key: ValueKey<int>(currentIndex), child: screens[currentIndex]),
          ),

          // Floating bottom navigation with SafeArea
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FloatingNavigationBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget FloatingNavigationBar() {
    const BorderRadius navBarBorderRadius = BorderRadius.all(Radius.circular(28));

    final BoxDecoration navBarDecoration = BoxDecoration(
      color: RLTheme.white,
      borderRadius: navBarBorderRadius,
      border: Border.all(color: SOLID_SHADOW_COLOR, width: 1.5),
      boxShadow: const [SOLID_SHADOW],
    );

    return Container(
      decoration: navBarDecoration,
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Theme(
          data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
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
