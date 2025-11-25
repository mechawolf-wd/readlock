// Full-screen loading widget displayed while course content is being prepared
// Features bird icon and indexing message for smooth user experience

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/appTheme.dart';

const String LOADING_MESSAGE = 'Birds are indexing the course';
const double BIRD_ICON_SIZE = 60.0;
const double SPACING_HEIGHT = 24.0;

class CourseLoadingScreen extends StatelessWidget {
  const CourseLoadingScreen({super.key});

  // Icon and color definitions
  static const Icon BirdIcon = Icon(
    Icons.flight_takeoff_outlined,
    color: birdIconColor,
    size: BIRD_ICON_SIZE,
  );

  static const Color birdIconColor = RLTheme.primaryGreen;

  Widget LoadingContent() {
    return const Div.column(
      [BirdIcon],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: LoadingContent(),
    );
  }
}
