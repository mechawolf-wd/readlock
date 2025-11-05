/// Widget that provides the bottom navigation bar for main app sections
library;

import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';

/// @Class: Reusable bottom navigation widget with three main tabs
class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: navigationItems(),
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }

  /// @Method: Creates list of navigation items with icons and labels for each tab
  List<BottomNavigationBarItem> navigationItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.public),
        label: AppConstants.WORLD_LABEL,
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: AppConstants.BOOKS_LABEL,
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: AppConstants.PROFILE_LABEL,
      ),
    ];
  }
}
