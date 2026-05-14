// Main navigation wrapper with bottom navigation bar
// Provides navigation between home, courses and bookshelf screens

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/screens/CoursesScreen.dart';
import 'package:readlock/screens/HomeScreen.dart';
import 'package:readlock/screens/MyBookshelfScreen.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/auth/UserPreferencesHydrator.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/AppConfigService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';

import 'package:pixelarticons/pixel.dart';

// Bottom-nav tab indices, kept here so screen-level subscribers
// (HomeScreen / CoursesScreen / MyBookshelfScreen) reference one source
// of truth instead of scattering magic numbers.
const int TAB_INDEX_HOME = 0;
const int TAB_INDEX_SEARCH = 1;
const int TAB_INDEX_BOOKSHELF = 2;

// Live index of the currently-active bottom-nav tab. Each tab screen
// subscribes so it can re-trigger its heading typewriter every time its
// tab becomes active again, tabs are kept mounted, so without this signal
// the header would only animate once per app launch.
final ValueNotifier<int> activeTabIndexNotifier = ValueNotifier<int>(TAB_INDEX_HOME);

class MainNavigation extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigation({super.key, this.initialTabIndex = 0});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> with WidgetsBindingObserver {
  late int currentIndex;
  late List<Widget> screens;

  StreamSubscription<User?>? authStateSubscription;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialTabIndex;
    activeTabIndexNotifier.value = currentIndex;

    WidgetsBinding.instance.addObserver(this);

    screens = [const HomeScreen(), const CoursesScreen(), const BookshelfScreen()];

    authStateSubscription = AuthService.authStateChanges.listen(handleAuthStateChange);

    // Listen so external callers (e.g. the logout flow that wants the Search
    // tab visible behind the login sheet) can switch tabs by writing to
    // activeTabIndexNotifier without a state reference. The tap path also
    // writes to the notifier and is short-circuited via the same-index guard.
    activeTabIndexNotifier.addListener(handleActiveTabIndexNotifierChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    authStateSubscription?.cancel();
    activeTabIndexNotifier.removeListener(handleActiveTabIndexNotifierChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool isResumed = state == AppLifecycleState.resumed;

    if (isResumed) {
      AppConfigService.fetchConfigIfStale();
    }
  }

  void handleActiveTabIndexNotifierChange() {
    final int requestedIndex = activeTabIndexNotifier.value;
    final bool isBookshelfTab = requestedIndex == TAB_INDEX_BOOKSHELF;

    if (isBookshelfTab) {
      bookshelfHasUnseenPurchaseNotifier.value = false;
    }

    final bool isSameTab = requestedIndex == currentIndex;

    if (isSameTab) {
      return;
    }

    setState(() {
      currentIndex = requestedIndex;
    });
  }

  // Auth-state gate. On the user channel:
  //   - User present: hydrate purchases + preferences so every screen reads
  //     correct wallet / reading-preference state without refetching.
  //   - User absent: wipe local user state and auto-present the login sheet
  //     so the app is never browsable while signed out. Covers both first
  //     launch (the auth stream emits the initial null) and any mid-session
  //     sign-out / token expiry / server-side disable.
  //
  // The dev-skip button on the login sheet flips isDevBypassed to true so
  // local testing can dismiss the sheet without authenticating; we honour
  // that flag here so subsequent rebuilds don't immediately re-present.
  void handleAuthStateChange(User? user) {
    final bool hasUser = user != null;

    if (hasUser) {
      hydratePurchaseStateForCurrentUser();
      return;
    }

    // Signed-out path. AuthService.signOut and deleteAccount already wipe
    // local state before this listener runs, but we re-run the wipe here
    // (and clear the dev bypass flag) as a safety net for sessions that
    // end without going through our explicit teardown: token expiry,
    // server-side disable, account-deleted-elsewhere, etc.
    wipeLocalUserSessionState();

    LoginBottomSheet.isDevBypassed = false;

    presentLoginSheetWhenSignedOut();
  }

  // Schedules the login sheet for the next frame so the show call lands
  // after the build that's currently in flight (and so the Navigator is
  // guaranteed to be mounted on first launch when the auth stream emits
  // its initial null synchronously). The dedup guard inside
  // LoginBottomSheet.show keeps overlapping callers idempotent.
  void presentLoginSheetWhenSignedOut() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      final bool isBypassed = LoginBottomSheet.isDevBypassed;

      if (isBypassed) {
        return;
      }

      LoginBottomSheet.show(context);
    });
  }

  Future<void> hydratePurchaseStateForCurrentUser() async {
    // Fetch remote config now that we have an authenticated session.
    // Stored globally in AppConfigService.cachedConfig for all screens.
    await AppConfigService.fetchConfig();

    final UserModel? user = await UserService.getCurrentUserProfile();

    if (user == null) {
      return;
    }

    hydratePurchaseStateFromUser(user);

    // Same one-shot hydration for the reading-preference notifiers (font,
    // column, RSVP wpm, night-shift, bird) so a fresh launch picks up the
    // values the reader last set on any device, without each surface
    // having to refetch the user profile.
    hydrateUserPreferenceNotifiersFromUser(user);
  }

  void handleNavigationTap(int navigationItemIndex) {
    final bool isSameTab = navigationItemIndex == currentIndex;

    if (isSameTab) {
      return;
    }

    HapticsService.lightImpact();
    SoundService.playUiClick();

    setState(() {
      currentIndex = navigationItemIndex;
    });

    activeTabIndexNotifier.value = navigationItemIndex;
  }

  // * Nav chrome sizing
  static const double navIconSize = RLDS.iconXLarge;
  static const double navLabelFontSize = 10;
  static final TextStyle navLabelStyle = GoogleFonts.pressStart2p(
    fontSize: navLabelFontSize,
    fontWeight: FontWeight.w100,
  );

  // Icon definitions for navigation items
  static const Icon HomeIcon = Icon(Pixel.home, size: navIconSize);
  static const Icon HomeActiveIcon = Icon(Pixel.home, size: navIconSize);
  static const Icon ExploreIcon = Icon(Pixel.map, size: navIconSize);
  static const Icon ExploreActiveIcon = Icon(Pixel.map, size: navIconSize);
  static const Icon BookshelfIcon = Icon(Pixel.book, size: navIconSize);
  static const Icon BookshelfActiveIcon = Icon(Pixel.book, size: navIconSize);

  // Red unread-purchase dot painted on top of the bookshelf nav icon.
  // Sized so it reads as a notification mark, not a status pip.
  static const double bookshelfBadgeSize = 8.0;
  static final BoxDecoration bookshelfBadgeDecoration = const BoxDecoration(
    color: RLDS.error,
    shape: BoxShape.circle,
  );

  // Bookshelf nav icon with the unread-purchase dot overlaid. The dot is
  // driven by bookshelfHasUnseenPurchaseNotifier, which PurchaseService
  // flips on a successful purchase and MainNavigation clears the moment
  // the bookshelf tab activates. clipBehavior: none lets the dot sit
  // slightly outside the icon bounds so it reads as a badge.
  Widget BookshelfTabIcon(Icon innerIcon) {
    final Widget badgeDot = Container(
      width: bookshelfBadgeSize,
      height: bookshelfBadgeSize,
      decoration: bookshelfBadgeDecoration,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: bookshelfHasUnseenPurchaseNotifier,
      builder: (BuildContext context, bool hasUnseenPurchase, Widget? _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            innerIcon,

            Positioned(
              top: 0,
              right: 0,
              child: RenderIf.condition(hasUnseenPurchase, badgeDot),
            ),
          ],
        );
      },
    );
  }

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

    return Scaffold(
      // extendBody lets the starfield paint under the nav, so the frosted
      // surface has actual stars to blur instead of flat Scaffold colour.
      extendBody: true,
      backgroundColor: RLDS.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: RLStarfieldBackground()),

          ...TabLayers(),
        ],
      ),
      bottomNavigationBar: RLLunarBlur(
        borderRadius: RLDS.borderRadiusModalTop,
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
            unselectedItemColor: RLDS.textMuted,
            type: BottomNavigationBarType.fixed,
            iconSize: navIconSize,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: NavigationItems(),
          ),
        ),
      ),
    );
  }

  // Each tab is kept mounted in its own layer so switching back doesn't
  // re-trigger its loader. The active tab fades to opacity 1, the others
  // fade out to 0, gives the small fade swap without the loading flash
  // that AnimatedSwitcher's mount/unmount cycle used to cause.
  List<Widget> TabLayers() {
    final List<Widget> layers = [];

    for (int tabIndex = 0; tabIndex < screens.length; tabIndex++) {
      final bool isActive = tabIndex == currentIndex;

      layers.add(
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isActive,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeIn,
              opacity: isActive ? 1.0 : 0.0,
              child: screens[tabIndex],
            ),
          ),
        ),
      );
    }

    return layers;
  }

  List<BottomNavigationBarItem> NavigationItems() {
    return [
      BottomNavigationBarItem(
        icon: HomeIcon,
        activeIcon: HomeActiveIcon,
        label: RLUIStrings.HOME_TAB_LABEL,
      ),

      BottomNavigationBarItem(
        icon: ExploreIcon,
        activeIcon: ExploreActiveIcon,
        label: RLUIStrings.SEARCH_TAB_LABEL,
      ),

      BottomNavigationBarItem(
        icon: BookshelfTabIcon(BookshelfIcon),
        activeIcon: BookshelfTabIcon(BookshelfActiveIcon),
        label: RLUIStrings.BOOKSHELF_TAB_LABEL,
      ),
    ];
  }
}
