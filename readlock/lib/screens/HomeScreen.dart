// Home screen with latest courses and user stats
// Features top bar with streak and experience counters

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/StatisticsTopBar.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const String HOME_TITLE = 'Welcome Back';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Div.column([
            // Top stats bar
            const StatisticsTopBar(),

            const Spacing.height(32),

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
      ),
    );
  }

  Widget HomeWelcomeHeader() {
    return Div.column([
      // Main welcome title
      RLTypography.headingLarge(HOME_TITLE),

      const Spacing.height(8),

      // Subtitle text
      RLTypography.text('Continue your learning journey'),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  Widget ContinueReadingSection() {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.primaryGreen.withValues(alpha: 0.3),
      ),
    );

    final BoxDecoration bookCoverDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          RLTheme.primaryGreen,
          RLTheme.primaryGreen.withValues(alpha: 0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(8),
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
          'Pick up where you left',
          color: RLTheme.textSecondary,
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),

      const Spacing.height(16),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Div.column([
          Div.row([
            Container(
              width: 60,
              height: 80,
              decoration: bookCoverDecoration,
            ),

            const Spacing.width(16),

            Expanded(
              child: Div.column([
                RLTypography.text('The Design of Everyday Things'),

                const Spacing.height(4),

                RLTypography.text(
                  'Chapter 3 - 45% complete',
                  color: RLTheme.textSecondary,
                ),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
          ]),

          const Spacing.height(12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: buttonDecoration,
            child: Div.row([
              RLTypography.text('Continue', color: Colors.white),
            ], mainAxisAlignment: MainAxisAlignment.center),
          ),
        ]),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
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
          'Curated based on your interests',
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
        ]),
      );
    }).toList();
  }

  Widget RandomLessonSection() {
    final BoxDecoration cardDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          RLTheme.primaryBlue.withValues(alpha: 0.1),
          RLTheme.primaryGreen.withValues(alpha: 0.1),
        ],
      ),
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
        RLTypography.headingMedium('Random Lesson'),

        const Spacing.height(4),

        RLTypography.text(
          'Discover something new today',
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
              RLTypography.text('Start Lesson', color: Colors.white),
            ], mainAxisAlignment: MainAxisAlignment.center),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }
}
