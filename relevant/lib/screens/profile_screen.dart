/// Screen that displays user profile information and settings
library;

import 'package:flutter/material.dart';
import 'package:relevant/constants/app_constants.dart';

/// @Class: Profile screen for user information and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: mainBody());
  }

  /// @Widget: Main content area for user profile and settings
  Widget mainBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [welcomeText()],
      ),
    );
  }

  /// @Widget: Personalized greeting message for the profile section
  Widget welcomeText() {
    return const Text(
      AppConstants.PROFILE_WELCOME_MESSAGE,
      style: TextStyle(fontSize: AppConstants.WELCOME_TEXT_SIZE),
    );
  }
}
