// Home screen with latest courses and user stats
// Features top bar with streak and experience counters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/screens/ReaderPassScreen.dart';
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/RLCard.dart';

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
      backgroundColor: RLDS.backgroundDark,
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
                const Spacing.height(MainNavigation.bottomOffset),
              ],
              padding: EdgeInsets.all(24.0),
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget SeasonPromoBanner() {
    final EdgeInsets bannerPadding = const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 16.0,
    );

    return Div.row(
      [
        Flexible(
          child: RLTypography.bodyMedium(
            RLUIStrings.PROMO_BANNER_TEXT,
            color: RLDS.white,
            textAlign: TextAlign.center,
          ),
        ),
      ],
      width: 'full',
      padding: bannerPadding,
      color: RLDS.black,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: handlePromoBannerTap,
    );
  }

  Widget HomeWelcomeHeader() {
    return Div.column([
      // Main welcome title
      RLTypography.headingLarge(RLUIStrings.HOME_TITLE),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ContinueReadingSection() {
    final double bookProgress = 0.45;
    final int progressPercent = (bookProgress * 100).toInt();

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.primaryGreen,
      borderRadius: BorderRadius.circular(8.0),
    );

    final EdgeInsets buttonPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );

    return Div.column([
      Div.column([
        RLTypography.headingMedium(RLUIStrings.CONTINUE_READING_TITLE),

        const Spacing.height(4),

        Text(
          RLUIStrings.CONTINUE_READING_SUBTITLE,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      RLCard.elevated(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Div.row([
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/covers/doet-cover.png',
                  width: 60.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                ),
              ),

              const Spacing.width(16),

              Expanded(
                child: Div.column([
                  Text('The Design of Everyday Things', style: RLTypography.bodyMediumStyle),

                  const Spacing.height(4),

                  Text(
                    'Don Norman',
                    style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
                  ),

                  const Spacing.height(12),

                  Div.row([
                    Expanded(
                      child: ProgressBar(progress: bookProgress, color: RLDS.primaryGreen),
                    ),

                    const Spacing.width(8),

                    Text(
                      '$progressPercent%',
                      style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.primaryGreen),
                    ),
                  ]),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ]),

            const Spacing.height(12),

            Div.row(
              [
                Text(
                  RLUIStrings.CONTINUE_BUTTON_LABEL,
                  style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.white),
                ),
              ],
              padding: buttonPadding,
              decoration: buttonDecoration,
              mainAxisAlignment: MainAxisAlignment.center,
              onTap: handleContinueReading,
            ),
          ],
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ProgressBar({required double progress, required Color color}) {
    final BoxDecoration trackDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4.0),
    );

    final BoxDecoration fillDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4.0),
    );

    return Container(
      height: 4.0,
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
        RLTypography.headingMedium(RLUIStrings.FOR_YOUR_PERSONALITY_TITLE),

        const Spacing.height(4),

        Text(
          RLUIStrings.FOR_YOUR_PERSONALITY_SUBTITLE,
          style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      Div.column(PersonalityBookCards(books), crossAxisAlignment: CrossAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> PersonalityBookCards(List<Map<String, String>> books) {
    final BoxDecoration bookCardDecoration = BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: RLDS.primaryBlue.withValues(alpha: 0.2)),
    );

    final BoxDecoration bookCoverDecoration = BoxDecoration(
      color: RLDS.primaryBlue.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(6.0),
    );

    final EdgeInsets cardMargin = const EdgeInsets.only(bottom: 12.0);

    final EdgeInsets iconMargin = const EdgeInsets.only(top: 8.0);

    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';

      return Div.row(
        [
          Div.emptyColumn(
            width: 40.0,
            height: 60.0,
            decoration: bookCoverDecoration,
          ),

          const Spacing.width(12),

          Expanded(
            child: Div.column([
              Text(bookTitle, style: RLTypography.bodyMediumStyle),

              const Spacing.height(4),

              Text(
                bookAuthor,
                style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          // Bookmark icon
          Div.column([BookmarkIcon], margin: iconMargin),
        ],
        margin: cardMargin,
        padding: EdgeInsets.all(12.0),
        decoration: bookCardDecoration,
      );
    }).toList();
  }

  static final Widget BookmarkIcon = Icon(
    Icons.bookmark_border,
    color: RLDS.primaryBlue,
    size: 24.0,
  );

  static final Widget ChevronRightIcon = Icon(
    Icons.chevron_right,
    color: RLDS.textSecondary,
    size: 24.0,
  );

  static final Widget ShuffleIcon = Icon(
    Icons.shuffle_rounded,
    color: RLDS.primaryBlue,
    size: 24.0,
  );

  Widget RandomLessonSection() {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(12.0),
    );

    return Div.row(
      [
        ShuffleIcon,

        const Spacing.width(12.0),

        Expanded(child: RLTypography.bodyLarge(RLUIStrings.SURPRISE_ME_LABEL)),

        ChevronRightIcon,
      ],
      padding: EdgeInsets.all(16.0),
      decoration: cardDecoration,
      crossAxisAlignment: CrossAxisAlignment.center,
      onTap: () {},
    );
  }
}
