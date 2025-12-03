// Full-screen loading widget displayed while course content is being prepared
// Features bird icon and indexing message for smooth user experience

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

const String LOADING_MESSAGE = 'Birds are indexing the course';
const double PIGEON_IMAGE_SIZE = 240.0;
const double SPACING_HEIGHT = 24.0;

class CourseLoadingScreen extends StatelessWidget {
  const CourseLoadingScreen({super.key});

  Widget PigeonImage() {
    return Image.asset(
      'assets/pigeon.png',
      width: PIGEON_IMAGE_SIZE,
      height: PIGEON_IMAGE_SIZE,
      fit: BoxFit.contain,
    );
  }

  Widget LoadingContent() {
    return Div.column(
      [PigeonImage()],
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
