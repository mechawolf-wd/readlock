// Full-screen loading widget displayed while course content is being prepared
// Features bird icon and indexing message for smooth user experience

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class CourseLoadingScreen extends StatelessWidget {
  const CourseLoadingScreen({super.key});

  Widget PigeonImage() {
    return Image.asset(
      'assets/pigeon.png',
      width: 240.0,
      height: 240.0,
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
      backgroundColor: RLDS.backgroundDark,
      body: LoadingContent(),
    );
  }
}
