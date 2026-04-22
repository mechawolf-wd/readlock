// Main navigation wrapper with bottom navigation bar
// Provides navigation between home, courses and bookshelf screens

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLFadeSwitcher.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';
import 'package:readlock/services/auth/AuthService.dart';

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

  StreamSubscription<User?>? authStateSubscription;
  bool isLoginSheetVisible = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialTabIndex;

    screens = [const HomeScreen(), const CoursesScreen(), const MyBookshelfScreen()];

    authStateSubscription = AuthService.authStateChanges.listen(handleAuthStateChange);
  }

  @override
  void dispose() {
    authStateSubscription?.cancel();
    super.dispose();
  }

  // Show the login sheet whenever the user is signed out. This also covers the
  // first-launch case (currentUser is null before auth completes) and the
  // post-logout case from Settings → Log out.
  //
  // Honours the dev bypass flag so testers can skip auth and drive the rest
  // of the app without signing in.
  void handleAuthStateChange(User? user) {
    final bool hasNoUser = user == null;
    final bool isBypassed = LoginBottomSheet.isDevBypassed;
    final bool shouldShowLoginSheet =
        hasNoUser && !isBypassed && !isLoginSheetVisible && mounted;

    if (!shouldShowLoginSheet) {
      return;
    }

    isLoginSheetVisible = true;

    WidgetsBinding.instance.addPostFrameCallback(presentLoginSheet);
  }

  void presentLoginSheet(Duration timestamp) {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    LoginBottomSheet.show(context).then(handleLoginSheetClosed);
  }

  void handleLoginSheetClosed(dynamic result) {
    isLoginSheetVisible = false;
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

  // * Nav chrome sizing
  static const double navIconSize = 32.0;
  static const double navLabelFontSize = 12.0;

  // Icon definitions for navigation items
  static const Icon HomeIcon = Icon(Pixel.home, size: navIconSize);
  static const Icon HomeActiveIcon = Icon(Pixel.home, size: navIconSize);
  static const Icon ExploreIcon = Icon(Pixel.map, size: navIconSize);
  static const Icon ExploreActiveIcon = Icon(Pixel.map, size: navIconSize);
  static const Icon BookshelfIcon = Icon(Pixel.book, size: navIconSize);
  static const Icon BookshelfActiveIcon = Icon(Pixel.book, size: navIconSize);

  @override
  Widget build(BuildContext context) {
    // Kill every tap/hover/focus visual on the nav bar. BottomNavigationBar
    // still paints a circular hover/focus halo behind its icons when the
    // inherited theme leaves those colours set, so we override all four here.
    final ThemeData noRippleTheme = Theme.of(context).copyWith(
      splashColor: RLDS.transparent,
      highlightColor: RLDS.transparent,
      hoverColor: RLDS.transparent,
      focusColor: RLDS.transparent,
      splashFactory: NoSplash.splashFactory,
    );

    final TextStyle pixelNavLabelStyle = RLTypography.pixelLabelStyle.copyWith(
      fontSize: navLabelFontSize,
    );

    return Scaffold(
      // extendBody lets the starfield paint under the nav, so the frosted
      // surface has actual stars to blur instead of flat Scaffold colour.
      extendBody: true,
      backgroundColor: RLDS.backgroundDark,
      body: Stack(
        children: [
          const Positioned.fill(child: RLStarfieldBackground()),

          RLFadeSwitcher(
            child: KeyedSubtree(key: ValueKey<int>(currentIndex), child: screens[currentIndex]),
          ),
        ],
      ),
      bottomNavigationBar: RLLunarBlur(
        borderRadius: RLDS.borderRadiusTopLarge,
        borderColor: RLDS.transparent,
        padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
        child: Theme(
          data: noRippleTheme,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: handleNavigationTap,
            backgroundColor: RLDS.transparent,
            elevation: 0,
            selectedItemColor: RLDS.primary,
            unselectedItemColor: RLDS.textSecondary,
            type: BottomNavigationBarType.fixed,
            iconSize: navIconSize,
            // Labels hidden for now — icons-only nav. Keeping the style props
            // commented so re-enabling is a single uncomment.
            showSelectedLabels: false,
            showUnselectedLabels: false,
            // selectedLabelStyle: pixelNavLabelStyle,
            // unselectedLabelStyle: pixelNavLabelStyle,
            // selectedFontSize: navLabelFontSize,
            // unselectedFontSize: navLabelFontSize,
            items: NavigationItems(),
          ),
        ),
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
