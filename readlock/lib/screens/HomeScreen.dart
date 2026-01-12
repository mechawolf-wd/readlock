// Home screen with latest courses and user stats
// Features top bar with streak and experience counters

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/screens/ReaderPassScreen.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const String HOME_TITLE = 'Home';

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
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              const Offset begin = Offset(0.0, 1.0);
              const Offset end = Offset.zero;
              const Curve curve = Curves.easeInOut;

              final Animatable<Offset> tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              final Animation<Offset> offsetAnimation = animation.drive(
                tween,
              );

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
      ),
    );
  }

  void handleContinueReading() {
    navigateToCourse('design-everyday-things-comprehensive');
  }

  void handlePromoBannerTap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ReaderPassScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(0.0, 1.0);
          const Offset end = Offset.zero;
          const Curve curve = Curves.easeInOut;

          final Animatable<Offset> tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          final Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Div.column([
            // Promotional banner (no padding)
            SeasonPromoBanner(),

            // Main content (with padding)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Div.column([
                // Welcome header
                HomeWelcomeHeader(),

                const Spacing.height(24),

                // Continue reading section
                ContinueReadingSection(),

                const Spacing.height(24),

                // For your personality section
                ForYourPersonalitySection(),

                const Spacing.height(24),

                // Random lesson section
                RandomLessonSection(),

                const Spacing.height(24),
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
            ),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget SeasonPromoBanner() {
    return GestureDetector(
      onTap: handlePromoBannerTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: Colors.black,
        child: Div.row([
          RLTypography.bodyMedium(
            'Outperformers do not start tomorrow - Reader Pass -25%',
            color: Colors.white,
          ),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
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
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.primaryGreen.withValues(alpha: 0.3),
      ),
    );

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.primaryGreen,
      borderRadius: BorderRadius.circular(8),
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

      Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Div.column([
          Div.row([
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'covers/doet-cover.png',
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            const Spacing.width(16),

            Expanded(
              child: Div.column([
                RLTypography.text('The Design of Everyday Things'),

                const Spacing.height(4),

                RLTypography.text(
                  'Don Norman',
                  color: RLTheme.textSecondary,
                ),

                const Spacing.height(12),

                Div.row([
                  Expanded(
                    child: ProgressBar(
                      progress: bookProgress,
                      color: RLTheme.primaryGreen,
                    ),
                  ),

                  const Spacing.width(8),

                  RLTypography.text(
                    '$progressPercent%',
                    color: RLTheme.primaryGreen,
                  ),
                ]),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
          ]),

          const Spacing.height(12),

          GestureDetector(
            onTap: handleContinueReading,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: buttonDecoration,
              child: Div.row([
                RLTypography.text('Continue', color: Colors.white),
              ], mainAxisAlignment: MainAxisAlignment.center),
            ),
          ),
        ]),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ProgressBar({required double progress, required Color color}) {
    final BoxDecoration trackDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
    );

    final BoxDecoration fillDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    );

    return Container(
      height: 4,
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

        RLTypography.text(
          'Picked based on your unique choices',
          color: RLTheme.textSecondary,
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      Div.column(
        PersonalityBookCards(books),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> PersonalityBookCards(List<Map<String, String>> books) {
    final BoxDecoration bookCardDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.primaryBlue.withValues(alpha: 0.2),
      ),
    );

    final BoxDecoration bookCoverDecoration = BoxDecoration(
      color: RLTheme.primaryBlue.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(6),
    );

    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: bookCardDecoration,
        child: Div.row([
          Container(
            width: 40,
            height: 60,
            decoration: bookCoverDecoration,
          ),

          const Spacing.width(12),

          Expanded(
            child: Div.column([
              RLTypography.text(bookTitle),

              const Spacing.height(4),

              RLTypography.text(
                bookAuthor,
                color: RLTheme.textSecondary,
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          // Bookmark icon
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Icon(
              Icons.bookmark_border,
              color: RLTheme.primaryBlue,
              size: 24,
            ),
          ),
        ]),
      );
    }).toList();
  }

  Widget RandomLessonSection() {
    final BoxDecoration cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.primaryBlue.withValues(alpha: 0.3),
      ),
    );

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.primaryBlue,
      borderRadius: BorderRadius.circular(8),
    );

    return Div.column([
      Div.column([
        RLTypography.headingMedium('Any Lesson'),

        const Spacing.height(4),

        RLTypography.text(
          'Next bite that could change your perspective',
          color: RLTheme.textSecondary,
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Div.column([
          RLTypography.headingMedium('Affordances in Design'),

          const Spacing.height(8),

          RLTypography.text(
            'From: Emotional Design by Don Norman',
            color: RLTheme.textSecondary,
          ),

          const Spacing.height(12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: buttonDecoration,
            child: Div.row([
              RLTypography.text('Let\'s Go', color: Colors.white),
            ], mainAxisAlignment: MainAxisAlignment.center),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }
}
