import 'package:flutter/material.dart';

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

  List<BottomNavigationBarItem> navigationItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.public),
        label: 'World',
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Books',
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}
