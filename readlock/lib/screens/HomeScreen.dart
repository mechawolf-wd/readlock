// Home screen with latest courses and user stats
// Features top bar with streak and experience counters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/screens/ReaderPassScreen.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void navigateToCourse(String courseId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CourseRoadmapScreen(courseId: courseId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(0.0, 1.0);
          const Offset end = Offset.zero;
          const Curve curve = Curves.easeInOut;

          final Animatable<Offset> tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          final Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void handleContinueReading() {
    HapticFeedback.lightImpact();
    navigateToCourse('book:design-everyday-things');
  }

  void handlePromoBannerTap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ReaderPassScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(0.0, 1.0);
          const Offset end = Offset.zero;
          const Curve curve = Curves.easeInOut;

          final Animatable<Offset> tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          final Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Div.column([
            // Promotional banner (no padding)
            SeasonPromoBanner(),

            // Main content (with padding)
            Div.column(
              [
                // Top stats bar
                const StatisticsTopBar(),

                const Spacing.height(24),

                // Welcome header
                HomeWelcomeHeader(),

                const Spacing.height(24),

                // Continue reading section
                ContinueReadingSection(),

                const Spacing.height(24),

                // Surprise me section
                RandomLessonSection(),

                const Spacing.height(24),

                // For your personality section
                ForYourPersonalitySection(),

                // Bottom spacing for floating navigation
                const Spacing.height(FLOATING_NAV_BOTTOM_OFFSET),
              ],
              padding: RLDimensions.paddingAllXXL,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget SeasonPromoBanner() {
    final EdgeInsets bannerPadding = const EdgeInsets.symmetric(
      vertical: RLDimensions.paddingM,
      horizontal: RLDimensions.paddingL,
    );

    return Div.row(
      [
        Flexible(
          child: RLTypography.bodyMedium(
            'Outperformers do not start tomorrow - Reader Pass -25%',
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
      ],
      width: 'full',
      padding: bannerPadding,
      color: Colors.black,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: handlePromoBannerTap,
    );
  }

  Widget HomeWelcomeHeader() {
    return Div.column([
      // Main welcome title
      RLTypography.headingLarge(HOME_TITLE),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ContinueReadingSection() {
    final double bookProgress = 0.45;
    final int progressPercent = (bookProgress * 100).toInt();

    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLTheme.white,
      borderRadius: RLDimensions.borderRadiusL,
      border: Border.all(color: SOLID_SHADOW_COLOR, width: 1.5),
      boxShadow: const [SOLID_SHADOW],
    );

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.primaryGreen,
      borderRadius: RLDimensions.borderRadiusM,
    );

    final EdgeInsets buttonPadding = const EdgeInsets.symmetric(
      horizontal: RLDimensions.paddingL,
      vertical: RLDimensions.paddingS,
    );

    return Div.column([
      Div.column([
        RLTypography.headingMedium('Continue Reading'),

        const Spacing.height(4),

        RLTypography.text(
          'Continue the title you\'ve been reading',
          color: RLTheme.textSecondary,
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      Div.column(
        [
          Div.row([
            ClipRRect(
              borderRadius: RLDimensions.borderRadiusM,
              child: Image.asset(
                'assets/covers/doet-cover.png',
                width: RLDimensions.thumbnailWidthM,
                height: RLDimensions.thumbnailHeightM,
                fit: BoxFit.cover,
              ),
            ),

            const Spacing.width(16),

            Expanded(
              child: Div.column([
                RLTypography.text('The Design of Everyday Things'),

                const Spacing.height(4),

                RLTypography.text('Don Norman', color: RLTheme.textSecondary),

                const Spacing.height(12),

                Div.row([
                  Expanded(
                    child: ProgressBar(progress: bookProgress, color: RLTheme.primaryGreen),
                  ),

                  const Spacing.width(8),

                  RLTypography.text('$progressPercent%', color: RLTheme.primaryGreen),
                ]),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
          ]),

          const Spacing.height(12),

          Div.row(
            [RLTypography.text('Continue', color: Colors.white)],
            padding: buttonPadding,
            decoration: buttonDecoration,
            mainAxisAlignment: MainAxisAlignment.center,
            onTap: handleContinueReading,
          ),
        ],
        padding: RLDimensions.paddingAllL,
        decoration: cardDecoration,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ProgressBar({required double progress, required Color color}) {
    final BoxDecoration trackDecoration = BoxDecoration(
      color: color.withValues(alpha: RLDimensions.alphaMedium),
      borderRadius: RLDimensions.borderRadiusXS,
    );

    final BoxDecoration fillDecoration = BoxDecoration(
      color: color,
      borderRadius: RLDimensions.borderRadiusXS,
    );

    return Container(
      height: RLDimensions.progressBarHeight,
      decoration: trackDecoration,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(decoration: fillDecoration),
      ),
    );
  }

  Widget ForYourPersonalitySection() {
    final List<Map<String, String>> books = [
      {'title': 'Thinking, Fast and Slow', 'author': 'Daniel Kahneman'},
      {'title': 'Hooked', 'author': 'Nir Eyal'},
      {'title': 'Don\'t Make Me Think', 'author': 'Steve Krug'},
    ];

    return Div.column([
      Div.column([
        RLTypography.headingMedium('For Your Personality'),

        const Spacing.height(4),

        RLTypography.text('Picked based on your unique choices', color: RLTheme.textSecondary),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      Div.column(PersonalityBookCards(books), crossAxisAlignment: CrossAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> PersonalityBookCards(List<Map<String, String>> books) {
    final BoxDecoration bookCardDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: RLDimensions.alphaLight),
      borderRadius: RLDimensions.borderRadiusL,
      border: Border.all(
        color: RLTheme.primaryBlue.withValues(alpha: RLDimensions.alphaMedium),
      ),
    );

    final BoxDecoration bookCoverDecoration = BoxDecoration(
      color: RLTheme.primaryBlue.withValues(alpha: RLDimensions.alphaDark),
      borderRadius: RLDimensions.borderRadiusS,
    );

    final EdgeInsets cardMargin = const EdgeInsets.only(bottom: RLDimensions.spacing12);

    final EdgeInsets iconMargin = const EdgeInsets.only(top: RLDimensions.spacing8);

    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';

      return Div.row(
        [
          Div.emptyColumn(
            width: RLDimensions.thumbnailWidthS,
            height: RLDimensions.thumbnailWidthM,
            decoration: bookCoverDecoration,
          ),

          const Spacing.width(12),

          Expanded(
            child: Div.column([
              RLTypography.text(bookTitle),

              const Spacing.height(4),

              RLTypography.text(bookAuthor, color: RLTheme.textSecondary),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          // Bookmark icon
          Div.column(const [BookmarkIcon], margin: iconMargin),
        ],
        margin: cardMargin,
        padding: RLDimensions.paddingAllM,
        decoration: bookCardDecoration,
      );
    }).toList();
  }

  static const Widget BookmarkIcon = Icon(
    Icons.bookmark_border,
    color: RLTheme.primaryBlue,
    size: RLDimensions.iconL,
  );

  static const Widget ChevronRightIcon = Icon(
    Icons.chevron_right,
    color: RLTheme.textSecondary,
    size: RLDimensions.iconL,
  );

  static const Widget ShuffleIcon = Icon(
    Icons.shuffle_rounded,
    color: RLTheme.primaryBlue,
    size: RLDimensions.iconL,
  );

  Widget RandomLessonSection() {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: RLDimensions.borderRadiusL,
    );

    return Div.row(
      [
        ShuffleIcon,

        const Spacing.width(RLDimensions.spacing12),

        Expanded(child: RLTypography.bodyLarge('Surprise Me')),

        ChevronRightIcon,
      ],
      padding: RLDimensions.paddingAllL,
      decoration: cardDecoration,
      crossAxisAlignment: CrossAxisAlignment.center,
      onTap: () {},
    );
  }
}
