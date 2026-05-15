// Bird picker shared state, data, and sprite widget
// The selected bird is held in a top-level ValueNotifier so any screen
// (menu, bookshelf header, etc.) can observe and react via ValueListenableBuilder.

import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';

import 'package:pixelarticons/pixel.dart';

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

// * Bird unlock economy.
//
// Each bird carries its unlock threshold directly as seconds of cumulative
// reading time. Skillbook-tier birds use N * BIRD_SKILLBOOK_UNIT_SECONDS so
// the 30-minute multiplier is preserved as a legible constant at the
// definition site; Collared Dove is a short introductory gate (7 minutes)
// that sits between the free starters and the first full skillbook tier.
// Sparrow and Pigeon are freely available from onboarding (unlockSeconds = 0).
const int BIRD_SKILLBOOK_UNIT_SECONDS = 45 * 60;

int getBirdUnlockSeconds(BirdOption bird) {
  return bird.unlockSeconds;
}

bool isBirdUnlockedAt(BirdOption bird, int totalReadingSeconds) {
  return totalReadingSeconds >= getBirdUnlockSeconds(bird);
}

// Mirrors BookshelfScreen.formatStopwatchReadout so the lock caption under
// each bird speaks the same digital-stopwatch vocabulary the bookshelf
// reading-time tile uses. Kept as a pure helper here so the picker doesn't
// have to import the bookshelf.
String formatBirdUnlockReadout(int totalSeconds) {
  final int safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
  final int hours = safeSeconds ~/ 3600;
  final int minutes = (safeSeconds % 3600) ~/ 60;
  final int seconds = safeSeconds % 60;

  final String hoursLabel = hours.toString().padLeft(2, '0');
  final String minutesLabel = minutes.toString().padLeft(2, '0');
  final String secondsLabel = seconds.toString().padLeft(2, '0');

  return '$hoursLabel:$minutesLabel:$secondsLabel';
}

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
  // Seconds of cumulative reading time required before this bird unlocks.
  // 0 means freely available from onboarding.
  final int unlockSeconds;

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
    this.unlockSeconds = 0,
  });
}

// * Common birds, Sparrow's Idle tag begins at frame 0, the rest at frame 1.
// * Exotic birds, dedicated Idle PNGs starting at frame 0; frame size matches
// * the bird's true bounding box (per Aseprite JSON metadata).
// * Sorted cheapest to most expensive (unlockSeconds ascending).
final List<BirdOption> BIRD_OPTIONS = [
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

  // 7-minute introductory gate, sits between free starters and first skillbook.
  BirdOption(
    name: RLUIStrings.BIRD_COLLARED_DOVE,
    assetFile: 'CollaredDove.png',
    firstFrame: 1,
    frameCount: 4,
    unlockSeconds: 7 * 60,
  ),

  // Skillbook tiers escalate with the bird's perceived rarity:
  //   Crow      = 1 skillbook (everyday city bird, easy first reward)
  //   Kiwi      = 2 skillbooks (cute novelty)
  //   Flamingo  = 3 skillbooks (distinctive but accessible)
  //   Blue Macaw = 4 skillbooks (vibrant exotic)
  //   Shoebill  = 6 skillbooks (rare, oddly serious bird)
  //   Toucan    = 10 skillbooks (premium, longest grind)
  BirdOption(
    name: RLUIStrings.BIRD_CROW,
    assetFile: 'Crow.png',
    firstFrame: 1,
    frameCount: 4,
    unlockSeconds: 1 * BIRD_SKILLBOOK_UNIT_SECONDS,
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
    unlockSeconds: 2 * BIRD_SKILLBOOK_UNIT_SECONDS,
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
    unlockSeconds: 3 * BIRD_SKILLBOOK_UNIT_SECONDS,
  ),

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
    unlockSeconds: 4 * BIRD_SKILLBOOK_UNIT_SECONDS,
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
    unlockSeconds: 6 * BIRD_SKILLBOOK_UNIT_SECONDS,
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
    unlockSeconds: 10 * BIRD_SKILLBOOK_UNIT_SECONDS,
  ),
];

// Onboarding only offers the unlocked starter birds (sparrow, pigeon,
// collared dove). Derived from BIRD_OPTIONS so the moment a bird's
// unlockSkillbooks flips to 0 in the master list it surfaces in
// onboarding too, no second list to keep in lock-step. Locked birds
// stay out of onboarding entirely so a brand-new reader isn't asked
// to choose between three free birds and a row of greyed-out previews.
final List<BirdOption> ONBOARDING_BIRD_OPTIONS = BIRD_OPTIONS
    .where((BirdOption bird) => bird.unlockSeconds == 0)
    .toList(growable: false);

// * Display-name map, purely a UI-layer concern. The canonical
// `BirdOption.name` (Sparrow, Pigeon, ...) is what's persisted to
// Firestore as the user's chosen bird, never replaced by these labels.
// Each bird's display name reaches for the language native to where
// that species is from or culturally anchored, so the picker reads as
// a small atlas instead of a flat English list:
//   Sparrow       → Passero        (Italian, ties to genus Passer)
//   Pigeon        → Piccione       (Italian, Mediterranean rock dove)
//   Collared Dove → Kumru          (Turkish, spread through Europe from
//                                   Turkey/Balkans)
//   Crow          → Karasu         (Japanese, strong cultural anchor)
//   Blue Macaw    → Arara-azul     (Brazilian Portuguese, endemic to Brazil)
//   Flamingo      → Flamenco       (Spanish, origin of the word)
//   Kiwi          → Kiwi           (Maori, already native)
//   Shoebill      → Abu Markub     (Arabic, "father of the shoe", its
//                                   Sudan/Uganda nickname)
//   Toucan        → Tucano         (Brazilian Portuguese, closest to the
//                                   original Tupi "tukana")
const Map<String, String> BIRD_DISPLAY_NAMES_BY_CANONICAL = {
  'Sparrow': 'Passero',
  'Pigeon': 'Piccione',
  'Collared Dove': 'Kumru',
  'Crow': 'Karasu',
  'Blue Macaw': 'Arara-azul',
  'Flamingo': 'Flamenco',
  'Kiwi': 'Kiwi',
  'Shoebill': 'Abu Markub',
  'Toucan': 'Tucano',
};

// Resolves the localised display name for a bird, falling back to the
// canonical English name when no override is registered (so a future
// bird that hasn't been mapped yet still renders something sensible).
String getBirdDisplayName(BirdOption bird) {
  final String? mappedName = BIRD_DISPLAY_NAMES_BY_CANONICAL[bird.name];

  if (mappedName == null) {
    return bird.name;
  }

  return mappedName;
}

// Shared Images cache so Flame.images doesn't need reconfiguring globally
final Images birdImageCache = Images(prefix: BIRD_ASSET_PREFIX);

// * Shared selection, the source of truth read by the bottom sheet and any
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

// * Bird-carousel geometry, values shared by every surface that uses the
// horizontal snap-slider (the dedicated picker sheet and the onboarding
// step). Tuning lives here so a future change to the slider feel ripples
// through both call sites without divergence.
const double BIRD_CAROUSEL_HEIGHT = 200.0;
const double BIRD_CAROUSEL_VIEWPORT_FRACTION = 0.45;
const double BIRD_CAROUSEL_UNSELECTED_SCALE = 0.7;
const double BIRD_CAROUSEL_UNSELECTED_OPACITY = 0.5;
const double BIRD_CAROUSEL_SELECTED_SCALE = 1.0;
const double BIRD_CAROUSEL_SELECTED_OPACITY = 1.0;
// Padding between the locked badge and the bottom edge of the carousel cell.
const double BIRD_CAROUSEL_LOCK_BADGE_BOTTOM_INSET = 8.0;
// Locked sprite + caption blur. Aliases the centralised
// RLDS.lockedTextBlurSigma token so the picker, the roadmap's locked
// lesson titles, and any future locked-content surface frost to the
// exact same degree.
const double BIRD_CAROUSEL_LOCKED_BLUR_SIGMA = RLDS.lockedTextBlurSigma;

// Reusable bird snap-slider, owns its own PageController and selection
// state, syncs with selectedBirdNotifier on every page change. Renders the
// slider stacked above the selected bird's name so callers don't have to
// stitch the label themselves. Ships with the BirdPickerBottomSheet (the
// dedicated picker sheet) and the OnboardingBottomSheet (the bird step).
class BirdCarousel extends StatefulWidget {
  final double height;
  // Birds to show in this carousel. Defaults to the full master list so
  // existing call sites (the picker bottom sheet) keep their behaviour;
  // onboarding passes ONBOARDING_BIRD_OPTIONS so a brand-new reader
  // sees only the three free starters.
  final List<BirdOption> birds;
  // When true (the default), landing on an unlocked bird commits it as
  // the reader's profile bird (selectedBirdNotifier + Firestore write).
  // Locked birds can always be browsed but are never committed.
  // When false the carousel runs as a browser only: nothing is
  // persisted regardless of lock state.
  final bool persistSelection;

  BirdCarousel({
    super.key,
    this.height = BIRD_CAROUSEL_HEIGHT,
    List<BirdOption>? birds,
    this.persistSelection = true,
  }) : birds = birds ?? BIRD_OPTIONS;

  @override
  State<BirdCarousel> createState() => BirdCarouselState();
}

class BirdCarouselState extends State<BirdCarousel> {
  late PageController pageController;
  late int selectedIndex;
  // The bird whose name renders under the carousel. Tracks the centered
  // page (including locked previews) so a locked bird the user is hovering
  // on shows its own name rather than the previously-selected one.
  late int displayedIndex;

  @override
  void initState() {
    super.initState();

    final int initialIndex = widget.birds.indexWhere(
      (BirdOption bird) => bird.name == selectedBirdNotifier.value.name,
    );
    final bool hasNoMatch = initialIndex < 0;

    selectedIndex = hasNoMatch ? 0 : initialIndex;
    displayedIndex = selectedIndex;

    pageController = PageController(
      initialPage: selectedIndex,
      viewportFraction: BIRD_CAROUSEL_VIEWPORT_FRACTION,
    );

    // Re-render so the lock badges drop the moment a session commit pushes
    // the cumulative reading total over a bird's threshold.
    timeSpentReadingNotifier.addListener(handleReadingTimeChanged);
  }

  @override
  void dispose() {
    timeSpentReadingNotifier.removeListener(handleReadingTimeChanged);
    pageController.dispose();
    super.dispose();
  }

  void handleReadingTimeChanged() {
    final bool stillMounted = mounted;

    if (!stillMounted) {
      return;
    }

    setState(() {});
  }

  void handlePageChanged(int newIndex) {
    final BirdOption nextBird = widget.birds[newIndex];
    final int totalReadingSeconds = timeSpentReadingNotifier.value;
    final bool isLocked = !isBirdUnlockedAt(nextBird, totalReadingSeconds);

    // displayedIndex tracks the currently centered bird (locked or not)
    // so the name caption updates immediately on landing.
    setState(() {
      displayedIndex = newIndex;
    });

    // Locked birds can be browsed freely but never committed as the
    // profile bird. No snap-back, no persistence, no feedback sound.
    if (isLocked) {
      return;
    }

    HapticsService.selectionClick();
    SoundService.playRandomTextClick();

    if (!widget.persistSelection) {
      return;
    }

    setState(() {
      selectedIndex = newIndex;
    });

    selectedBirdNotifier.value = nextBird;

    UserService.updateBirdName(nextBird.name);
  }

  @override
  Widget build(BuildContext context) {
    final BirdOption displayedBird = widget.birds[displayedIndex];
    final int totalReadingSeconds = timeSpentReadingNotifier.value;
    final bool displayedBirdLocked = !isBirdUnlockedAt(displayedBird, totalReadingSeconds);

    final Widget slider = PageView.builder(
      controller: pageController,
      physics: const PageScrollPhysics(),
      onPageChanged: handlePageChanged,
      itemCount: widget.birds.length,
      itemBuilder: SliderItemBuilder,
    );

    final Widget displayedNameLabel = BirdNameLabel(
      bird: displayedBird,
      isLocked: displayedBirdLocked,
    );

    return Div.column([
      Div.column(
        [Expanded(child: slider)],
        height: widget.height,
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),

      const Spacing.height(RLDS.spacing16),

      displayedNameLabel,
    ]);
  }

  Widget SliderItemBuilder(BuildContext context, int birdIndex) {
    final BirdOption bird = widget.birds[birdIndex];
    // Scale / opacity follow the currently centred page rather than the
    // user's committed selection, so a locked bird the reader is hovering
    // on still grows to full hero size like any other centred bird.
    // selectedIndex is reserved for the persisted choice (snap-back, save).
    final bool isCentered = birdIndex == displayedIndex;
    final int totalReadingSeconds = timeSpentReadingNotifier.value;
    final bool isLocked = !isBirdUnlockedAt(bird, totalReadingSeconds);

    final double itemScale = isCentered
        ? BIRD_CAROUSEL_SELECTED_SCALE
        : BIRD_CAROUSEL_UNSELECTED_SCALE;
    final double itemOpacity = isCentered
        ? BIRD_CAROUSEL_SELECTED_OPACITY
        : BIRD_CAROUSEL_UNSELECTED_OPACITY;

    final Widget scaledBird = Transform.scale(
      scale: itemScale,
      child: BirdAnimationSprite(bird: bird),
    );

    // Locked birds wear the exact same frosted treatment as the bird-
    // name label below them, single shared blur sigma, no extra opacity
    // dim, so the silhouette and the caption read as one preview.
    final ui.ImageFilter lockedBlurFilter = ui.ImageFilter.blur(
      sigmaX: BIRD_CAROUSEL_LOCKED_BLUR_SIGMA,
      sigmaY: BIRD_CAROUSEL_LOCKED_BLUR_SIGMA,
    );

    final Widget framedBird = isLocked
        ? ImageFiltered(imageFilter: lockedBlurFilter, child: scaledBird)
        : scaledBird;

    final Widget birdLayer = Opacity(opacity: itemOpacity, child: framedBird);

    final Widget lockBadge = LockedBirdBadge(unlockSeconds: getBirdUnlockSeconds(bird));

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(child: birdLayer),

        Positioned(
          left: 0,
          right: 0,
          bottom: BIRD_CAROUSEL_LOCK_BADGE_BOTTOM_INSET,
          child: RenderIf.condition(isLocked, lockBadge),
        ),
      ],
    );
  }
}

// Bird-name caption rendered below the carousel. Mirrors the centered
// bird (selected or hovered) so the label always matches the page on
// screen; when that bird is still locked the label is wrapped in
// ImageFiltered so only the letterforms blur, keeping the colour and
// position of the unlocked variant for a continuous read.
class BirdNameLabel extends StatelessWidget {
  final BirdOption bird;
  final bool isLocked;

  const BirdNameLabel({super.key, required this.bird, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final String displayName = getBirdDisplayName(bird);
    final Widget nameText = RLTypography.headingLarge(displayName, color: RLDS.primary);

    if (!isLocked) {
      return nameText;
    }

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: BIRD_CAROUSEL_LOCKED_BLUR_SIGMA,
        sigmaY: BIRD_CAROUSEL_LOCKED_BLUR_SIGMA,
      ),
      child: nameText,
    );
  }
}

// Lock + stopwatch caption painted under each locked bird in the carousel.
// Uses the same JetBrains Mono / textSecondary vocabulary the bookshelf
// reading-time tile speaks so the unlock target reads as "this is how much
// reading is required" without any explanatory copy.
class LockedBirdBadge extends StatelessWidget {
  final int unlockSeconds;

  const LockedBirdBadge({super.key, required this.unlockSeconds});

  static const Widget LockIcon = Icon(Pixel.lock, size: RLDS.iconSmall, color: RLDS.success);

  @override
  Widget build(BuildContext context) {
    final String unlockReadout = formatBirdUnlockReadout(unlockSeconds);

    return Div.row([
      LockIcon,

      const Spacing.width(RLDS.spacing4),

      RLTypography.bodyMedium(unlockReadout, color: RLDS.textSecondary),
    ], mainAxisAlignment: MainAxisAlignment.center);
  }
}
