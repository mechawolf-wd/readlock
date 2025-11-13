// Main navigation wrapper with bottom navigation bar
// Provides navigation between course roadmap and profile screens

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/course_roadmap_screen.dart';
import 'package:relevant/screens/profile_screen.dart';

const String COURSES_TAB_LABEL = 'Courses';
const String PROFILE_TAB_LABEL = 'Profile';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const CourseRoadmapScreen(
      courseId: 'design_everyday_things',
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: NavigationItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> NavigationItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.school),
        label: COURSES_TAB_LABEL,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: PROFILE_TAB_LABEL,
      ),
    ];
  }
}