// Full-screen loading widget displayed while course content is being prepared.
// Shows the reader's picked bird as an animated sprite so the loading state
// reads as part of the reader's profile — same bird sprite used on Pause slides,
// the natural source of truth.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

// Larger than the default preview sizes so the loader reads as the hero
// element on an otherwise empty screen. Integer multiple of the 32×32
// source frame keeps the pixel art crisp.
const double COURSE_LOADING_BIRD_SIZE = 192.0;

class CourseLoadingScreen extends StatelessWidget {
  const CourseLoadingScreen({super.key});

  Widget BirdLoader() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: BirdLoaderBuilder,
    );
  }

  Widget BirdLoaderBuilder(BuildContext context, BirdOption bird, Widget? _) {
    return BirdAnimationSprite(bird: bird, previewSize: COURSE_LOADING_BIRD_SIZE);
  }

  Widget LoadingContent() {
    return Div.column(
      [BirdLoader()],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Matches CCTextContent's background: drifting starfield with a
    // full-bleed LunarBlur pane frosting it, so the transition from
    // loading → reading reads as one continuous surface.
    return Scaffold(
      backgroundColor: STARFIELD_BACKGROUND_COLOR,
      body: Stack(
        children: [
          const Positioned.fill(child: RLStarfieldBackground()),

          const Positioned.fill(
            child: RLLunarBlur(
              borderRadius: BorderRadius.zero,
              child: SizedBox.expand(),
            ),
          ),

          LoadingContent(),
        ],
      ),
    );
  }
}
