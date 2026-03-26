// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/screens/SandboxScreen.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';

class MainNavigation extends StatefulWidget {
  static const double navHeight = 56.0;
  static const double navMargin = 16.0;
  static const double bottomOffset = navHeight + navMargin + 16.0;

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

  Widget fadeTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: Stack(
        children: [
          // Main content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: fadeTransitionBuilder,
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
      color: RLDS.white,
      borderRadius: navBarBorderRadius,
      border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
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
            selectedItemColor: RLDS.primaryGreen,
            unselectedItemColor: RLDS.textSecondary,
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

  // Icon definitions for navigation items
  static const Icon HomeIcon = Icon(Icons.home_outlined);
  static const Icon HomeActiveIcon = Icon(Icons.home_rounded);
  static const Icon ExploreIcon = Icon(Icons.explore_outlined);
  static const Icon ExploreActiveIcon = Icon(Icons.explore_rounded);
  static const Icon BookshelfIcon = Icon(Icons.menu_book_outlined);
  static const Icon BookshelfActiveIcon = Icon(Icons.menu_book_rounded);
  static const Icon SandboxIcon = Icon(Icons.science_outlined);
  static const Icon SandboxActiveIcon = Icon(Icons.science_rounded);

  List<BottomNavigationBarItem> NavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: HomeIcon,
        activeIcon: HomeActiveIcon,
        label: RLUIStrings.HOME_TAB_LABEL,
      ),

      const BottomNavigationBarItem(
        icon: ExploreIcon,
        activeIcon: ExploreActiveIcon,
        label: RLUIStrings.SEARCH_TAB_LABEL,
      ),

      const BottomNavigationBarItem(
        icon: BookshelfIcon,
        activeIcon: BookshelfActiveIcon,
        label: RLUIStrings.BOOKSHELF_TAB_LABEL,
      ),

      const BottomNavigationBarItem(
        icon: SandboxIcon,
        activeIcon: SandboxActiveIcon,
        label: RLUIStrings.SANDBOX_TAB_LABEL,
      ),
    ];
  }
}
