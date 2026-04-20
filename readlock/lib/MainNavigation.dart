// Main navigation wrapper with bottom navigation bar
// Provides navigation between home, courses and bookshelf screens

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';

import 'package:pixelarticons/pixel.dart';
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

    screens = [const HomeScreen(), const CoursesScreen(), const MyBookshelfScreen()];

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

  // Icon definitions for navigation items
  static const Icon HomeIcon = Icon(Pixel.home);
  static const Icon HomeActiveIcon = Icon(Pixel.home);
  static const Icon ExploreIcon = Icon(Pixel.map);
  static const Icon ExploreActiveIcon = Icon(Pixel.map);
  static const Icon BookshelfIcon = Icon(Pixel.bookopen);
  static const Icon BookshelfActiveIcon = Icon(Pixel.bookopen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: handleNavigationTap,
        selectedItemColor: RLDS.success,
        unselectedItemColor: RLDS.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: NavigationItems(),
      ),
    );
  }

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
    ];
  }
}
