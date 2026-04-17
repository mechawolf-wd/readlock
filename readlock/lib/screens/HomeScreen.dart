// Home screen with latest courses and user stats

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/course_screens/CourseRoadmapScreen.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLBookListCard.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLProgressBar.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLCard.dart';

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

  void handleRandomBookTap() {
    HapticFeedback.lightImpact();

    final List<String> availableBookIds = [
      'book:design-everyday-things',
      'book:thinking-fast-slow',
      'book:hooked',
      'book:dont-make-me-think',
    ];

    final int randomIndex = Random().nextInt(availableBookIds.length);
    final String randomBookId = availableBookIds[randomIndex];

    navigateToCourse(randomBookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Div.column([
            // Main content (with padding)
            Div.column(
              [
                // Continue reading section
                ContinueReadingSection(),

                const Spacing.height(24),

                // Surprise me section
                RandomLessonSection(),

                const Spacing.height(24),

                // For your personality section
                ForYourPersonalitySection(),
              ],
              padding: const EdgeInsets.all(RLDS.spacing24),
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget ContinueReadingSection() {
    final double bookProgress = 0.45;
    final int progressPercent = (bookProgress * 100).toInt();

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
        padding: const EdgeInsets.all(RLDS.spacing0),
        borderColor: Colors.transparent,
        child: Column(
          children: [
            Div.row([
              ContinueReadingCover(),

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
                    Expanded(child: RLProgressBar(progress: bookProgress)),

                    const Spacing.width(8),

                    Text(
                      '$progressPercent%',
                      style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.success),
                    ),
                  ]),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ]),

            const Spacing.height(12),

            RLButton.primary(
              label: RLUIStrings.CONTINUE_BUTTON_LABEL,
              onTap: handleContinueReading,
              padding: const EdgeInsets.symmetric(
                horizontal: RLDS.spacing16,
                vertical: RLDS.spacing8,
              ),
            ),
          ],
        ),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget ContinueReadingCover() {
    return ClipRRect(
      borderRadius: RLDS.borderRadiusSmall,
      child: Image.asset(
        'assets/covers/doet-cover.png',
        width: 60.0,
        height: 80.0,
        fit: BoxFit.cover,
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
    return books.map((book) {
      final String bookTitle = book['title'] ?? '';
      final String bookAuthor = book['author'] ?? '';

      return BookListCard(title: bookTitle, author: bookAuthor);
    }).toList();
  }

  static final Widget ChevronRightIcon = const Icon(
    Icons.chevron_right,
    color: RLDS.textSecondary,
    size: 24.0,
  );

  static final Widget ShuffleIcon = const Icon(
    Icons.shuffle_rounded,
    color: RLDS.info,
    size: 24.0,
  );

  Widget RandomLessonSection() {
    return RLCard.subtle(
      padding: const EdgeInsets.all(RLDS.spacing16),
      onTap: handleRandomBookTap,
      child: Div.row([
        ShuffleIcon,

        const Spacing.width(12.0),

        Expanded(child: RLTypography.bodyLarge(RLUIStrings.SURPRISE_ME_LABEL)),

        ChevronRightIcon,
      ], crossAxisAlignment: CrossAxisAlignment.center),
    );
  }
}
