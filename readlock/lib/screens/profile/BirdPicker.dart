// Bird picker shared state, data, and sprite widget
// The selected bird is held in a top-level ValueNotifier so any screen
// (menu, bookshelf header, etc.) can observe and react via ValueListenableBuilder.

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/UserService.dart';

// * Common-bird sheets pack art into 64x64 cells with 32x32 content centered.
// * Exotic-bird sheets are tightly packed (each cell is its own bird-bounding
// * box with zero padding). Per-bird metrics on BirdOption let one widget
// * render both layouts without sheet-level branching.
const double BIRD_FRAME_SIZE = 64.0;
const double BIRD_CONTENT_SIZE = 32.0;
const double BIRD_COMMON_CONTENT_OFFSET = (BIRD_FRAME_SIZE - BIRD_CONTENT_SIZE) / 2;
const double BIRD_ANIMATION_STEP_TIME = 0.20;
const double BIRD_PREVIEW_SIZE_LARGE = 128.0;
const double BIRD_PREVIEW_SIZE_SMALL = 96.0;
const String BIRD_ASSET_PREFIX = 'assets/birds/';

class BirdOption {
  final String name;
  final String assetFile;
  final int firstFrame;
  final int frameCount;
  final double frameWidth;
  final double frameHeight;
  final double contentOffsetX;
  final double contentOffsetY;
  final double contentWidth;
  final double contentHeight;

  const BirdOption({
    required this.name,
    required this.assetFile,
    required this.firstFrame,
    required this.frameCount,
    this.frameWidth = BIRD_FRAME_SIZE,
    this.frameHeight = BIRD_FRAME_SIZE,
    this.contentOffsetX = BIRD_COMMON_CONTENT_OFFSET,
    this.contentOffsetY = BIRD_COMMON_CONTENT_OFFSET,
    this.contentWidth = BIRD_CONTENT_SIZE,
    this.contentHeight = BIRD_CONTENT_SIZE,
  });
}

// * Common birds — Sparrow's Idle tag begins at frame 0, the rest at frame 1.
// * Exotic birds — dedicated Idle PNGs starting at frame 0; frame size matches
// * the bird's true bounding box (per Aseprite JSON metadata).
const List<BirdOption> BIRD_OPTIONS = [
  BirdOption(
    name: RLUIStrings.BIRD_SPARROW,
    assetFile: 'Sparrow.png',
    firstFrame: 0,
    frameCount: 4,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_PIGEON,
    assetFile: 'Pigeon.png',
    firstFrame: 1,
    frameCount: 4,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_COLLARED_DOVE,
    assetFile: 'CollaredDove.png',
    firstFrame: 1,
    frameCount: 4,
  ),

  BirdOption(name: RLUIStrings.BIRD_CROW, assetFile: 'Crow.png', firstFrame: 1, frameCount: 4),

  BirdOption(
    name: RLUIStrings.BIRD_BLUE_MACAW,
    assetFile: 'BlueMacaw.png',
    firstFrame: 0,
    frameCount: 5,
    frameWidth: 26,
    frameHeight: 17,
    contentOffsetX: 0,
    contentOffsetY: 0,
    contentWidth: 26,
    contentHeight: 17,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_FLAMINGO,
    assetFile: 'Flamingo.png',
    firstFrame: 0,
    frameCount: 4,
    frameWidth: 35,
    frameHeight: 33,
    contentOffsetX: 0,
    contentOffsetY: 0,
    contentWidth: 35,
    contentHeight: 33,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_KIWI,
    assetFile: 'Kiwi.png',
    firstFrame: 0,
    frameCount: 4,
    frameWidth: 27,
    frameHeight: 17,
    contentOffsetX: 0,
    contentOffsetY: 0,
    contentWidth: 27,
    contentHeight: 17,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_SHOEBILL,
    assetFile: 'Shoebill.png',
    firstFrame: 0,
    frameCount: 4,
    frameWidth: 30,
    frameHeight: 36,
    contentOffsetX: 0,
    contentOffsetY: 0,
    contentWidth: 30,
    contentHeight: 36,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_TOUCAN,
    assetFile: 'Toucan.png',
    firstFrame: 0,
    frameCount: 5,
    frameWidth: 32,
    frameHeight: 18,
    contentOffsetX: 0,
    contentOffsetY: 0,
    contentHeight: 18,
  ),
];

// Shared Images cache so Flame.images doesn't need reconfiguring globally
final Images birdImageCache = Images(prefix: BIRD_ASSET_PREFIX);

// * Shared selection — the source of truth read by the bottom sheet and any
// * surface that wants to display the user's chosen bird (eg. bookshelf title).
final ValueNotifier<BirdOption> selectedBirdNotifier = ValueNotifier(BIRD_OPTIONS.first);

// Resolves a stored bird name back to its option. Falls back to the first
// option when the name is unrecognised (eg. a future build wrote a name
// this build doesn't know about, or the field is missing entirely).
BirdOption birdOptionFromName(String? birdName) {
  if (birdName == null) {
    return BIRD_OPTIONS.first;
  }

  for (final BirdOption option in BIRD_OPTIONS) {
    if (option.name == birdName) {
      return option;
    }
  }

  return BIRD_OPTIONS.first;
}

class BirdAnimationSprite extends StatelessWidget {
  final BirdOption bird;
  final double previewSize;
  final double zoom;

  const BirdAnimationSprite({
    super.key,
    required this.bird,
    this.previewSize = BIRD_PREVIEW_SIZE_LARGE,
    this.zoom = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final List<SpriteAnimationFrameData> frames = List.generate(bird.frameCount, (frameIndex) {
      final double cellOriginX = (bird.firstFrame + frameIndex) * bird.frameWidth;

      return SpriteAnimationFrameData(
        srcPosition: Vector2(cellOriginX + bird.contentOffsetX, bird.contentOffsetY),
        srcSize: Vector2(bird.contentWidth, bird.contentHeight),
        stepTime: BIRD_ANIMATION_STEP_TIME,
      );
    });

    final SpriteAnimationData animationData = SpriteAnimationData(frames);

    final double boxSize = previewSize * zoom;

    final Widget animationWidget = SpriteAnimationWidget.asset(
      path: bird.assetFile,
      images: birdImageCache,
      data: animationData,
    );

    // Render at native pixel dimensions then scale-to-fit the square preview
    // so non-square exotics (eg Flamingo 35x33) keep their aspect ratio.
    final Widget nativeSizedSprite = SizedBox(
      width: bird.contentWidth,
      height: bird.contentHeight,
      child: animationWidget,
    );

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: FittedBox(child: nativeSizedSprite),
    );
  }
}

// * Bird-carousel geometry — values shared by every surface that uses the
// horizontal snap-slider (the dedicated picker sheet and the onboarding
// step). Tuning lives here so a future change to the slider feel ripples
// through both call sites without divergence.
const double BIRD_CAROUSEL_HEIGHT = 200.0;
const double BIRD_CAROUSEL_VIEWPORT_FRACTION = 0.45;
const double BIRD_CAROUSEL_UNSELECTED_SCALE = 0.7;
const double BIRD_CAROUSEL_UNSELECTED_OPACITY = 0.5;
const double BIRD_CAROUSEL_SELECTED_SCALE = 1.0;
const double BIRD_CAROUSEL_SELECTED_OPACITY = 1.0;

// Reusable bird snap-slider — owns its own PageController and selection
// state, syncs with selectedBirdNotifier on every page change. Renders the
// slider stacked above the selected bird's name so callers don't have to
// stitch the label themselves. Ships with the BirdPickerBottomSheet (the
// dedicated picker sheet) and the OnboardingBottomSheet (the bird step).
class BirdCarousel extends StatefulWidget {
  final double height;

  const BirdCarousel({super.key, this.height = BIRD_CAROUSEL_HEIGHT});

  @override
  State<BirdCarousel> createState() => BirdCarouselState();
}

class BirdCarouselState extends State<BirdCarousel> {
  late PageController pageController;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    final int initialIndex = BIRD_OPTIONS.indexWhere(
      (BirdOption bird) => bird.name == selectedBirdNotifier.value.name,
    );
    final bool hasNoMatch = initialIndex < 0;

    selectedIndex = hasNoMatch ? 0 : initialIndex;

    pageController = PageController(
      initialPage: selectedIndex,
      viewportFraction: BIRD_CAROUSEL_VIEWPORT_FRACTION,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void handlePageChanged(int newIndex) {
    HapticFeedback.selectionClick();

    setState(() {
      selectedIndex = newIndex;
    });

    final BirdOption nextBird = BIRD_OPTIONS[newIndex];

    selectedBirdNotifier.value = nextBird;

    UserService.updateBirdName(nextBird.name);
  }

  @override
  Widget build(BuildContext context) {
    final BirdOption selectedBird = BIRD_OPTIONS[selectedIndex];

    final Widget slider = PageView.builder(
      controller: pageController,
      physics: const PageScrollPhysics(),
      onPageChanged: handlePageChanged,
      itemCount: BIRD_OPTIONS.length,
      itemBuilder: SliderItemBuilder,
    );

    return Div.column([
      Div.column(
        [Expanded(child: slider)],
        height: widget.height,
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),

      const Spacing.height(RLDS.spacing16),

      RLTypography.headingLarge(selectedBird.name, color: RLDS.primary),
    ]);
  }

  Widget SliderItemBuilder(BuildContext context, int birdIndex) {
    final BirdOption bird = BIRD_OPTIONS[birdIndex];
    final bool isSelected = birdIndex == selectedIndex;
    final double itemScale = isSelected
        ? BIRD_CAROUSEL_SELECTED_SCALE
        : BIRD_CAROUSEL_UNSELECTED_SCALE;
    final double itemOpacity = isSelected
        ? BIRD_CAROUSEL_SELECTED_OPACITY
        : BIRD_CAROUSEL_UNSELECTED_OPACITY;

    return Center(
      child: Opacity(
        opacity: itemOpacity,
        child: Transform.scale(
          scale: itemScale,
          child: BirdAnimationSprite(bird: bird),
        ),
      ),
    );
  }
}
