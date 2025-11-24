// Sandbox screen with experimental and engaging interactive widgets
// Playground for testing new course content patterns and interactions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/typography.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/app_theme.dart';

const String SANDBOX_TITLE = 'Widget Sandbox';

class SandboxScreen extends StatelessWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: const SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Div.column([
            const SandboxHeader(),

            const Spacing.height(32),

            const ThoughtPrompWidget(),

            const Spacing.height(24),

            const BookmarkHighlightWidget(),

            const Spacing.height(24),

            const SwipeToRevealWidget(),

            const Spacing.height(24),

            const ConceptConnectionWidget(),

            const Spacing.height(24),

            const MicroQuizWidget(),

            const Spacing.height(24),

            const ProgressCelebrationWidget(),

            const Spacing.height(24),

            const SliderRevealWidget(),

            const Spacing.height(24),

            const MemoryCardMatchWidget(),

            const Spacing.height(24),

            const PriorityRankingWidget(),

            const Spacing.height(24),

            const BeforeAfterComparisonWidget(),

            const Spacing.height(24),

            const ReactionPickerWidget(),

            const Spacing.height(24),

            const KnowledgeBuilderWidget(),

            const Spacing.height(24),

            const TimelineBuilderWidget(),

            const Spacing.height(24),

            const WordAssociationWidget(),

            const Spacing.height(24),

            const DialAdjustmentWidget(),

            const Spacing.height(24),

            const StoryBranchingWidget(),

            const Spacing.height(24),

            const PatternRecognitionWidget(),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }
}

class SandboxHeader extends StatelessWidget {
  const SandboxHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Div.row([
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.science,
            color: Colors.white,
            size: 24,
          ),
        ),

        const Spacing.width(16),

        Expanded(
          child: Text(
            SANDBOX_TITLE,
            style: Typography.headingLargeStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            'EXPERIMENTAL',
            style: Typography.bodyMediumStyle.copyWith(
              color: Colors.purple,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.center),

      const Spacing.height(8),

      Typography.bodyMedium(
        'Essential widgets for engaging course content',
        color: AppTheme.textPrimary.withValues(alpha: 0.7),
      ),
    ]);
  }
}

class ThoughtPrompWidget extends StatefulWidget {
  const ThoughtPrompWidget({super.key});

  @override
  State<ThoughtPrompWidget> createState() => ThoughtPrompWidgetState();
}

class ThoughtPrompWidgetState extends State<ThoughtPrompWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Div.column([
        Div.row([
          const Icon(
            Icons.psychology,
            color: AppTheme.primaryBlue,
            size: 24,
          ),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Thought Prompt',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Icon(
            isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ], onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        }),

        RenderIf.condition(
          isExpanded,
          Div.column([
            const Spacing.height(16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Think about a time when you encountered bad design. What made it frustrating? How could it have been improved using the principles from this chapter?',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const Spacing.height(12),

            Text(
              'Take a moment to reflect on this before continuing...',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                color: AppTheme.textPrimary.withValues(alpha: 0.6),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class BookmarkHighlightWidget extends StatefulWidget {
  const BookmarkHighlightWidget({super.key});

  @override
  State<BookmarkHighlightWidget> createState() =>
      BookmarkHighlightWidgetState();
}

class BookmarkHighlightWidgetState
    extends State<BookmarkHighlightWidget> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(
            Icons.format_quote,
            color: Colors.orange,
            size: 24,
          ),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Notable Quote',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Div.row(
            [Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.orange,
              size: 24,
            )],
            onTap: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
          ),
        ]),

        const Spacing.height(16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Text(
            '"Good design is obvious. Great design is transparent."',
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 16,
              height: 1.4,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Spacing.height(12),

        Div.row([
          Text(
            '— Joe Sparano',
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textPrimary.withValues(alpha: 0.7),
            ),
          ),

          const Spacer(),

          RenderIf.condition(
            isBookmarked,
            Text(
              'Bookmarked ✓',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class SwipeToRevealWidget extends StatefulWidget {
  const SwipeToRevealWidget({super.key});

  @override
  State<SwipeToRevealWidget> createState() =>
      SwipeToRevealWidgetState();
}

class SwipeToRevealWidgetState extends State<SwipeToRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController revealController;
  late Animation<double> revealAnimation;
  bool isRevealed = false;

  @override
  void initState() {
    super.initState();
    revealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    revealAnimation = CurvedAnimation(
      parent: revealController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.visibility, color: Colors.purple, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Swipe to Reveal Insight',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(16),

        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.2),
            ),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Center(
                  child: Text(
                    'The most powerful design principle is...',
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 14,
                      color: AppTheme.textPrimary.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              AnimatedBuilder(
                animation: revealAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: revealAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'SIMPLICITY - removing the unnecessary',
                            style: Typography.bodyLargeStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              Positioned.fill(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (!isRevealed && details.delta.dx > 2) {
                      setState(() {
                        isRevealed = true;
                      });
                      revealController.forward();
                    }
                  },
                  onTap: () {
                    if (!isRevealed) {
                      setState(() {
                        isRevealed = true;
                      });
                      revealController.forward();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: RenderIf.condition(
                        !isRevealed,
                        Div.row([
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.purple,
                            size: 16,
                          ),
                          const Spacing.width(8),
                          Text(
                            'Swipe right → or tap',
                            style: Typography.bodyMediumStyle.copyWith(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ], mainAxisAlignment: MainAxisAlignment.center),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacing.height(12),

        RenderIf.condition(
          isRevealed,
          Text(
            'Insight revealed! +5 Understanding points',
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}

class ConceptConnectionWidget extends StatefulWidget {
  const ConceptConnectionWidget({super.key});

  @override
  State<ConceptConnectionWidget> createState() =>
      ConceptConnectionWidgetState();
}

class ConceptConnectionWidgetState
    extends State<ConceptConnectionWidget> {
  int? selectedConcept;
  int? selectedApplication;
  bool hasMatched = false;

  final List<String> concepts = [
    'Affordances',
    'Feedback',
    'Constraints',
  ];

  final List<String> applications = [
    'Door handles that show how to open',
    'Button click sounds and animations',
    'Form fields that only accept valid input',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.account_tree, color: Colors.teal, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Connect Concepts',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Match design principles to real-world examples',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        Div.row([
          Expanded(
            child: Div.column([
              Text(
                'Concepts',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
              const Spacing.height(8),
              ...concepts.asMap().entries.map((entry) {
                final int index = entry.key;
                final String concept = entry.value;
                final bool isSelected = selectedConcept == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedConcept = selectedConcept == index
                            ? null
                            : index;
                        if (selectedApplication != null &&
                            selectedConcept != null) {
                          checkMatch();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.teal.withValues(alpha: 0.1)
                            : AppTheme.backgroundDark.withValues(
                                alpha: 0.5,
                              ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.teal
                              : AppTheme.textPrimary.withValues(
                                  alpha: 0.2,
                                ),
                        ),
                      ),
                      child: Text(
                        concept,
                        style: Typography.bodyMediumStyle.copyWith(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.teal
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ]),
          ),

          const Spacing.width(16),

          Expanded(
            child: Div.column([
              Text(
                'Examples',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
              const Spacing.height(8),
              ...applications.asMap().entries.map((entry) {
                final int index = entry.key;
                final String application = entry.value;
                final bool isSelected = selectedApplication == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedApplication =
                            selectedApplication == index ? null : index;
                        if (selectedConcept != null &&
                            selectedApplication != null) {
                          checkMatch();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.teal.withValues(alpha: 0.1)
                            : AppTheme.backgroundDark.withValues(
                                alpha: 0.5,
                              ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.teal
                              : AppTheme.textPrimary.withValues(
                                  alpha: 0.2,
                                ),
                        ),
                      ),
                      child: Text(
                        application,
                        style: Typography.bodyMediumStyle.copyWith(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.teal
                              : AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ]),
          ),
        ]),

        RenderIf.condition(
          hasMatched,
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryGreen),
            ),
            child: Div.row([
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const Spacing.width(8),
              Text(
                'Perfect match! +10 Connection points',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void checkMatch() {
    if (selectedConcept == selectedApplication) {
      setState(() {
        hasMatched = true;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            selectedConcept = null;
            selectedApplication = null;
            hasMatched = false;
          });
        }
      });
    }
  }
}

class MicroQuizWidget extends StatefulWidget {
  const MicroQuizWidget({super.key});

  @override
  State<MicroQuizWidget> createState() => MicroQuizWidgetState();
}

class MicroQuizWidgetState extends State<MicroQuizWidget>
    with SingleTickerProviderStateMixin {
  int? selectedAnswer;
  bool hasAnswered = false;
  late AnimationController bounceController;
  late Animation<double> bounceAnimation;

  final String question = 'What makes a design "invisible"?';
  final List<String> options = [
    'Using transparency effects',
    'When users don\'t notice the interface',
    'Making everything minimal',
    'Hiding all the buttons',
  ];
  final int correctAnswer = 1;

  @override
  void initState() {
    super.initState();
    bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: bounceController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.quiz, color: Colors.indigo, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Quick Quiz',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(16),

        Text(
          question,
          style: Typography.bodyLargeStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),

        const Spacing.height(16),

        ...options.asMap().entries.map((entry) {
          final int index = entry.key;
          final String option = entry.value;
          final bool isSelected = selectedAnswer == index;
          final bool isCorrect = hasAnswered && index == correctAnswer;
          final bool isWrong =
              hasAnswered && isSelected && index != correctAnswer;

          Color backgroundColor;
          Color borderColor;
          Color textColor;

          if (isCorrect) {
            backgroundColor = AppTheme.primaryGreen.withValues(
              alpha: 0.1,
            );
            borderColor = AppTheme.primaryGreen;
            textColor = AppTheme.primaryGreen;
          } else if (isWrong) {
            backgroundColor = Colors.red.withValues(alpha: 0.1);
            borderColor = Colors.red;
            textColor = Colors.red;
          } else if (isSelected) {
            backgroundColor = Colors.indigo.withValues(alpha: 0.1);
            borderColor = Colors.indigo;
            textColor = Colors.indigo;
          } else {
            backgroundColor = AppTheme.backgroundDark.withValues(
              alpha: 0.5,
            );
            borderColor = AppTheme.textPrimary.withValues(alpha: 0.2);
            textColor = AppTheme.textPrimary;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnimatedBuilder(
              animation: bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: (isCorrect && hasAnswered)
                      ? bounceAnimation.value
                      : 1.0,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: hasAnswered ? null : () => selectAnswer(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Div.row([
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect || isWrong || isSelected
                            ? (isCorrect
                                  ? AppTheme.primaryGreen
                                  : isWrong
                                  ? Colors.red
                                  : Colors.indigo)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCorrect
                              ? AppTheme.primaryGreen
                              : isWrong
                              ? Colors.red
                              : isSelected
                              ? Colors.indigo
                              : AppTheme.textPrimary.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : isWrong
                          ? const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            )
                          : isSelected
                          ? const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8,
                            )
                          : null,
                    ),

                    const Spacing.width(12),

                    Expanded(
                      child: Text(
                        option,
                        style: Typography.bodyMediumStyle.copyWith(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: (isCorrect || isSelected)
                              ? FontWeight.w500
                              : FontWeight.normal,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        }).toList(),

        RenderIf.condition(
          hasAnswered,
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Great design becomes invisible because users can focus on their goals, not fighting the interface.',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 13,
                color: AppTheme.textPrimary.withValues(alpha: 0.8),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      hasAnswered = true;
    });

    if (index == correctAnswer) {
      bounceController.forward().then((_) {
        bounceController.reverse();
      });
    }
  }
}

class ProgressCelebrationWidget extends StatefulWidget {
  const ProgressCelebrationWidget({super.key});

  @override
  State<ProgressCelebrationWidget> createState() =>
      ProgressCelebrationWidgetState();
}

class ProgressCelebrationWidgetState
    extends State<ProgressCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController progressController;
  late AnimationController celebrationController;
  late Animation<double> progressAnimation;
  late Animation<double> celebrationAnimation;
  bool hasCompleted = false;

  @override
  void initState() {
    super.initState();
    progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    progressAnimation = CurvedAnimation(
      parent: progressController,
      curve: Curves.easeInOut,
    );
    celebrationAnimation = CurvedAnimation(
      parent: celebrationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    progressController.dispose();
    celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          AnimatedBuilder(
            animation: celebrationAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: hasCompleted
                    ? 1.0 + (celebrationAnimation.value * 0.3)
                    : 1.0,
                child: Icon(
                  hasCompleted ? Icons.emoji_events : Icons.trending_up,
                  color: hasCompleted
                      ? Colors.amber
                      : Colors.amber.shade700,
                  size: 24,
                ),
              );
            },
          ),

          const Spacing.width(12),

          Expanded(
            child: Text(
              hasCompleted ? 'Chapter Complete!' : 'Learning Progress',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(16),

        Div.column([
          Div.row([
            Text(
              'Design Principles Mastery',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: progressAnimation,
              builder: (context, child) {
                final double progress = progressAnimation.value;
                return Text(
                  '${(progress * 100).toInt()}%',
                  style: Typography.bodyMediumStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                );
              },
            ),
          ]),

          const Spacing.height(8),

          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.amber.shade600,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),

        const Spacing.height(16),

        RenderIf.condition(
          !hasCompleted,
          GestureDetector(
            onTap: startProgress,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Complete Chapter',
                  style: Typography.bodyLargeStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),

        RenderIf.condition(
          hasCompleted,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Div.column([
              Div.row([
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const Spacing.width(8),
                Text(
                  'Excellent work! +50 XP earned',
                  style: Typography.bodyLargeStyle.copyWith(
                    fontSize: 14,
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]),
              const Spacing.height(4),
              Text(
                'You\'ve mastered the fundamentals of good design.',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.textPrimary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void startProgress() {
    progressController.forward().then((_) {
      setState(() {
        hasCompleted = true;
      });
      celebrationController.forward().then((_) {
        celebrationController.reverse();
      });
    });
  }
}

class SliderRevealWidget extends StatefulWidget {
  const SliderRevealWidget({super.key});

  @override
  State<SliderRevealWidget> createState() => SliderRevealWidgetState();
}

class SliderRevealWidgetState extends State<SliderRevealWidget> {
  double sliderValue = 0.0;
  bool hasRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.tune, color: Colors.cyan, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Slider to Reveal',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Adjust the design principle importance',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Div.column([
            Text(
              'Simplicity in Design',
              style: Typography.bodyLargeStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.cyan.shade700,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacing.height(12),

            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.cyan,
                inactiveTrackColor: AppTheme.textPrimary.withValues(
                  alpha: 0.1,
                ),
                thumbColor: Colors.cyan,
                overlayColor: Colors.cyan.withValues(alpha: 0.1),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12,
                ),
                trackHeight: 6,
              ),
              child: Slider(
                value: sliderValue,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                    hasRevealed = value > 80;
                  });
                },
              ),
            ),

            const Spacing.height(8),

            Div.row([
              Text(
                'Low',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.textPrimary.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              Text(
                'Critical',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ]),
          ]),
        ),

        const Spacing.height(16),

        AnimatedOpacity(
          opacity: hasRevealed ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyan),
            ),
            child: Div.row([
              const Icon(Icons.lightbulb, color: Colors.cyan, size: 16),
              const Spacing.width(8),
              Expanded(
                child: Text(
                  'Exactly! Simplicity eliminates cognitive load and lets users focus on their goals.',
                  style: Typography.bodyMediumStyle.copyWith(
                    fontSize: 12,
                    color: Colors.cyan.shade700,
                    height: 1.3,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class MemoryCardMatchWidget extends StatefulWidget {
  const MemoryCardMatchWidget({super.key});

  @override
  State<MemoryCardMatchWidget> createState() =>
      MemoryCardMatchWidgetState();
}

class MemoryCardMatchWidgetState extends State<MemoryCardMatchWidget>
    with TickerProviderStateMixin {
  List<bool> flippedCards = List.filled(6, false);
  List<int?> selectedCards = [];
  List<bool> matchedCards = List.filled(6, false);
  int matches = 0;

  final List<String> cardPairs = [
    'Affordance',
    'Visual cue for action',
    'Feedback',
    'System response',
    'Constraint',
    'Limits user actions',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.memory, color: Colors.deepPurple, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Memory Match',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Text(
            'Matches: $matches/3',
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Match design principles with their descriptions',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => flipCard(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: matchedCards[index]
                      ? Colors.deepPurple.withValues(alpha: 0.1)
                      : flippedCards[index]
                      ? Colors.deepPurple.withValues(alpha: 0.05)
                      : AppTheme.backgroundDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: matchedCards[index]
                        ? Colors.deepPurple
                        : flippedCards[index]
                        ? Colors.deepPurple.withValues(alpha: 0.5)
                        : AppTheme.textPrimary.withValues(alpha: 0.2),
                    width: matchedCards[index] ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      flippedCards[index] || matchedCards[index]
                          ? cardPairs[index]
                          : '?',
                      style: Typography.bodyMediumStyle.copyWith(
                        fontSize:
                            flippedCards[index] || matchedCards[index]
                            ? 11
                            : 18,
                        fontWeight: matchedCards[index]
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: matchedCards[index]
                            ? Colors.deepPurple
                            : flippedCards[index]
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimary.withValues(
                                alpha: 0.4,
                              ),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        RenderIf.condition(
          matches == 3,
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryGreen),
            ),
            child: Div.row([
              const Icon(
                Icons.celebration,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const Spacing.width(8),
              Text(
                'Perfect! All design principles matched! +15 Memory points',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void flipCard(int index) {
    if (flippedCards[index] ||
        matchedCards[index] ||
        selectedCards.length >= 2) {
      return;
    }

    setState(() {
      flippedCards[index] = true;
      selectedCards.add(index);
    });

    if (selectedCards.length == 2) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        checkMatch();
      });
    }
  }

  void checkMatch() {
    final int first = selectedCards[0]!;
    final int second = selectedCards[1]!;

    // Check if cards are a matching pair
    final bool isMatch =
        (first < 3 && second >= 3 && first == second - 3) ||
        (second < 3 && first >= 3 && second == first - 3);

    if (isMatch) {
      setState(() {
        matchedCards[first] = true;
        matchedCards[second] = true;
        matches++;
      });
    } else {
      setState(() {
        flippedCards[first] = false;
        flippedCards[second] = false;
      });
    }

    setState(() {
      selectedCards.clear();
    });
  }
}

class PriorityRankingWidget extends StatefulWidget {
  const PriorityRankingWidget({super.key});

  @override
  State<PriorityRankingWidget> createState() =>
      PriorityRankingWidgetState();
}

class PriorityRankingWidgetState extends State<PriorityRankingWidget> {
  List<String> principles = [
    'Usability',
    'Aesthetics',
    'Accessibility',
    'Performance',
  ];

  List<String> correctOrder = [
    'Usability',
    'Accessibility',
    'Performance',
    'Aesthetics',
  ];

  bool hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.sort, color: Colors.orange, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Priority Ranking',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Drag to rank design priorities from most to least important',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: principles.length,
          onReorder: hasSubmitted
              ? (oldIndex, newIndex) {}
              : (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final String item = principles.removeAt(oldIndex);
                    principles.insert(newIndex, item);
                  });
                },
          itemBuilder: (context, index) {
            final String principle = principles[index];
            final bool isCorrect =
                hasSubmitted &&
                principles[index] == correctOrder[index];

            return Container(
              key: ValueKey(principle),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: hasSubmitted
                    ? (isCorrect
                          ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1))
                    : AppTheme.backgroundDark.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasSubmitted
                      ? (isCorrect
                            ? AppTheme.primaryGreen
                            : Colors.orange)
                      : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Div.row([
                Text(
                  '${index + 1}.',
                  style: Typography.bodyMediumStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasSubmitted
                        ? (isCorrect
                              ? AppTheme.primaryGreen
                              : Colors.orange)
                        : Colors.orange,
                  ),
                ),

                const Spacing.width(12),

                Expanded(
                  child: Text(
                    principle,
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 14,
                      fontWeight: isCorrect
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: hasSubmitted
                          ? (isCorrect
                                ? AppTheme.primaryGreen
                                : Colors.orange.shade700)
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),

                RenderIf.condition(
                  !hasSubmitted,
                  const Icon(
                    Icons.drag_handle,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),

                RenderIf.condition(
                  hasSubmitted,
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.info,
                    color: isCorrect
                        ? AppTheme.primaryGreen
                        : Colors.orange,
                    size: 20,
                  ),
                ),
              ]),
            );
          },
        ),

        const Spacing.height(16),

        RenderIf.condition(
          !hasSubmitted,
          GestureDetector(
            onTap: checkRanking,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Submit Ranking',
                  style: Typography.bodyLargeStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),

        RenderIf.condition(
          hasSubmitted,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Great thinking! Usability and accessibility should indeed come first - they ensure everyone can use the product effectively.',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 13,
                color: AppTheme.textPrimary.withValues(alpha: 0.8),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void checkRanking() {
    setState(() {
      hasSubmitted = true;
    });
  }
}

class BeforeAfterComparisonWidget extends StatefulWidget {
  const BeforeAfterComparisonWidget({super.key});

  @override
  State<BeforeAfterComparisonWidget> createState() =>
      BeforeAfterComparisonWidgetState();
}

class BeforeAfterComparisonWidgetState
    extends State<BeforeAfterComparisonWidget> {
  bool showAfter = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.compare, color: Colors.pink, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Before/After Comparison',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                showAfter = !showAfter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.pink.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                showAfter ? 'AFTER' : 'BEFORE',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Tap to compare good vs bad button design',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Container(
            key: ValueKey(showAfter),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: showAfter
                  ? AppTheme.primaryGreen.withValues(alpha: 0.05)
                  : Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showAfter
                    ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Div.column([
              Text(
                showAfter ? 'Good Design ✓' : 'Bad Design ✗',
                style: Typography.bodyLargeStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: showAfter
                      ? AppTheme.primaryGreen
                      : Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacing.height(16),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: showAfter ? 24 : 8,
                    vertical: showAfter ? 12 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: showAfter
                        ? AppTheme.primaryBlue
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(
                      showAfter ? 8 : 0,
                    ),
                    boxShadow: showAfter
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    showAfter ? 'Download Now' : 'click here',
                    style: Typography.bodyLargeStyle.copyWith(
                      fontSize: showAfter ? 14 : 12,
                      fontWeight: showAfter
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: showAfter ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),

              const Spacing.height(16),

              Text(
                showAfter
                    ? '• Clear action • Proper sizing • Good contrast • Visual hierarchy'
                    : '• Vague text • Poor sizing • Low contrast • No visual cues',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: showAfter
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),

        const Spacing.height(16),

        Text(
          'Tap the badge above to toggle between examples',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 11,
            color: AppTheme.textPrimary.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class ReactionPickerWidget extends StatefulWidget {
  const ReactionPickerWidget({super.key});

  @override
  State<ReactionPickerWidget> createState() =>
      ReactionPickerWidgetState();
}

class ReactionPickerWidgetState extends State<ReactionPickerWidget> {
  String? selectedReaction;
  bool hasSubmitted = false;

  final Map<String, String> reactions = {
    '😍': 'Love it!',
    '👍': 'Makes sense',
    '🤔': 'Need to think',
    '😕': 'Disagree',
    '🤯': 'Mind blown!',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(
            Icons.sentiment_satisfied_alt,
            color: Colors.green,
            size: 24,
          ),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Quick Reaction',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'How do you feel about this design principle?',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '"The best interface is no interface at all"',
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacing.height(16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: reactions.entries.map((entry) {
            final String emoji = entry.key;
            final String label = entry.value;
            final bool isSelected = selectedReaction == emoji;

            return GestureDetector(
              onTap: hasSubmitted ? null : () => selectReaction(emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppTheme.backgroundDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.green
                        : AppTheme.textPrimary.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Div.row([
                  Text(emoji, style: const TextStyle(fontSize: 20)),

                  const Spacing.width(8),

                  Text(
                    label,
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.green
                          : AppTheme.textPrimary,
                    ),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),

        RenderIf.condition(
          hasSubmitted && selectedReaction != null,
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Div.column([
              Div.row([
                Text(
                  selectedReaction ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacing.width(8),
                Text(
                  'Thanks for sharing! +3 Engagement points',
                  style: Typography.bodyMediumStyle.copyWith(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
              const Spacing.height(4),
              Text(
                'Your reaction helps us understand what resonates with learners.',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 11,
                  color: AppTheme.textPrimary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void selectReaction(String emoji) {
    setState(() {
      selectedReaction = emoji;
      hasSubmitted = true;
    });
  }
}

class KnowledgeBuilderWidget extends StatefulWidget {
  const KnowledgeBuilderWidget({super.key});

  @override
  State<KnowledgeBuilderWidget> createState() =>
      KnowledgeBuilderWidgetState();
}

class KnowledgeBuilderWidgetState extends State<KnowledgeBuilderWidget>
    with TickerProviderStateMixin {
  List<bool> unlockedLevels = [true, false, false, false];
  int currentLevel = 0;
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  final List<Map<String, String>> levels = [
    {
      'title': 'Basic Principles',
      'description': 'Understanding core design fundamentals',
    },
    {
      'title': 'User Psychology',
      'description': 'How users think and behave',
    },
    {
      'title': 'Advanced Patterns',
      'description': 'Complex interaction patterns',
    },
    {
      'title': 'Design Systems',
      'description': 'Creating scalable design frameworks',
    },
  ];

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.school, color: Colors.indigo, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Knowledge Builder',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Text(
            'Level ${currentLevel + 1}/4',
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Unlock design mastery step by step',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        ...levels.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, String> level = entry.value;
          final bool isUnlocked = unlockedLevels[index];
          final bool isCurrent = currentLevel == index;
          final bool isCompleted = currentLevel > index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: isUnlocked ? () => selectLevel(index) : null,
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: (isCurrent && isUnlocked)
                        ? pulseAnimation.value
                        : 1.0,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : isCurrent
                        ? Colors.indigo.withValues(alpha: 0.1)
                        : isUnlocked
                        ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                        : AppTheme.textPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.primaryGreen
                          : isCurrent
                          ? Colors.indigo
                          : isUnlocked
                          ? Colors.indigo.withValues(alpha: 0.3)
                          : AppTheme.textPrimary.withValues(alpha: 0.1),
                      width: (isCurrent || isCompleted) ? 2 : 1,
                    ),
                  ),
                  child: Div.row([
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.primaryGreen
                            : isCurrent
                            ? Colors.indigo
                            : isUnlocked
                            ? Colors.indigo.withValues(alpha: 0.3)
                            : AppTheme.textPrimary.withValues(
                                alpha: 0.2,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : isUnlocked
                            ? Text(
                                '${index + 1}',
                                style: Typography.bodyLargeStyle
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.indigo,
                                    ),
                              )
                            : const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),

                    const Spacing.width(12),

                    Expanded(
                      child: Div.column([
                        Text(
                          level['title']!,
                          style: Typography.bodyLargeStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppTheme.primaryGreen
                                : isCurrent
                                ? Colors.indigo
                                : isUnlocked
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimary.withValues(
                                    alpha: 0.4,
                                  ),
                          ),
                        ),

                        const Spacing.height(2),

                        Text(
                          level['description']!,
                          style: Typography.bodyMediumStyle.copyWith(
                            fontSize: 12,
                            color: isUnlocked
                                ? AppTheme.textPrimary.withValues(
                                    alpha: 0.7,
                                  )
                                : AppTheme.textPrimary.withValues(
                                    alpha: 0.3,
                                  ),
                            height: 1.3,
                          ),
                        ),
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                    ),

                    RenderIf.condition(
                      isCurrent && isUnlocked,
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.indigo,
                        size: 20,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        }).toList(),

        const Spacing.height(8),

        LinearProgressIndicator(
          value: (currentLevel + 1) / levels.length,
          backgroundColor: AppTheme.textPrimary.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(
            Colors.indigo,
          ),
          minHeight: 6,
        ),

        const Spacing.height(8),

        Text(
          'Progress: ${((currentLevel + 1) / levels.length * 100).toInt()}% complete',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 11,
            color: Colors.indigo,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  void selectLevel(int index) {
    if (index <= currentLevel + 1 && index < levels.length) {
      setState(() {
        currentLevel = index;
        if (index < levels.length - 1) {
          unlockedLevels[index + 1] = true;
        }
      });
    }
  }
}

class TimelineBuilderWidget extends StatefulWidget {
  const TimelineBuilderWidget({super.key});

  @override
  State<TimelineBuilderWidget> createState() =>
      TimelineBuilderWidgetState();
}

class TimelineBuilderWidgetState extends State<TimelineBuilderWidget> {
  List<String> timelineEvents = [];
  List<String> availableEvents = [
    'Research user needs',
    'Create wireframes',
    'Design prototypes',
    'User testing',
    'Final implementation',
  ];
  bool isComplete = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.timeline, color: Colors.brown, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Timeline Builder',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Drag to arrange the design process in correct order',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        // Timeline area
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.brown.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.brown.withValues(alpha: 0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: timelineEvents.isEmpty
              ? Center(
                  child: Text(
                    'Drop events here to build timeline',
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 12,
                      color: AppTheme.textPrimary.withValues(
                        alpha: 0.4,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: timelineEvents.asMap().entries.map((
                      entry,
                    ) {
                      final int index = entry.key;
                      final String event = entry.value;

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: index == timelineEvents.length - 1
                                ? 0
                                : 4,
                          ),
                          child: GestureDetector(
                            onTap: () => removeFromTimeline(index),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.brown.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.brown.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                event,
                                style: Typography.bodyMediumStyle
                                    .copyWith(
                                      fontSize: 10,
                                      color: Colors.brown.shade700,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),

        const Spacing.height(16),

        Text(
          'Available Events:',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.brown,
          ),
        ),

        const Spacing.height(8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableEvents.map((event) {
            final bool isUsed = timelineEvents.contains(event);

            return GestureDetector(
              onTap: isUsed ? null : () => addToTimeline(event),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isUsed ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isUsed
                        ? Colors.grey.withValues(alpha: 0.1)
                        : AppTheme.backgroundDark.withValues(
                            alpha: 0.5,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUsed
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.brown.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    event,
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 12,
                      color: isUsed
                          ? AppTheme.textPrimary.withValues(alpha: 0.4)
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        RenderIf.condition(
          isComplete,
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryGreen),
            ),
            child: Div.row([
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const Spacing.width(8),
              Text(
                'Perfect timeline! You understand the design process. +12 Process points',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void addToTimeline(String event) {
    if (timelineEvents.length < 5) {
      setState(() {
        timelineEvents.add(event);
        if (timelineEvents.length == 5) {
          checkTimeline();
        }
      });
    }
  }

  void removeFromTimeline(int index) {
    setState(() {
      timelineEvents.removeAt(index);
      isComplete = false;
    });
  }

  void checkTimeline() {
    final List<String> correctOrder = [
      'Research user needs',
      'Create wireframes',
      'Design prototypes',
      'User testing',
      'Final implementation',
    ];

    bool isCorrect = true;
    for (int i = 0; i < timelineEvents.length; i++) {
      if (timelineEvents[i] != correctOrder[i]) {
        isCorrect = false;
        break;
      }
    }

    setState(() {
      isComplete = isCorrect;
    });
  }
}

class WordAssociationWidget extends StatefulWidget {
  const WordAssociationWidget({super.key});

  @override
  State<WordAssociationWidget> createState() =>
      WordAssociationWidgetState();
}

class WordAssociationWidgetState extends State<WordAssociationWidget> {
  String centralWord = 'Usability';
  List<String> associatedWords = [];
  List<String> availableWords = [
    'Intuitive',
    'Accessible',
    'Efficient',
    'Clear',
    'Simple',
    'Colorful',
    'Trendy',
    'Flashy',
    'Complex',
  ];
  Set<String> correctWords = {
    'Intuitive',
    'Accessible',
    'Efficient',
    'Clear',
    'Simple',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.hub, color: Colors.blue, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Word Association',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Connect words that relate to the central concept',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        // Central word
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Text(
              centralWord,
              style: Typography.bodyLargeStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ),

        const Spacing.height(16),

        // Associated words area
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
          child: associatedWords.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to add associations',
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 12,
                      color: AppTheme.textPrimary.withValues(
                        alpha: 0.4,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: associatedWords.map((word) {
                    final bool isCorrect = correctWords.contains(word);

                    return GestureDetector(
                      onTap: () => removeAssociation(word),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppTheme.primaryGreen.withValues(
                                  alpha: 0.1,
                                )
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect
                                ? AppTheme.primaryGreen
                                : Colors.red,
                          ),
                        ),
                        child: Div.row([
                          Text(
                            word,
                            style: Typography.bodyMediumStyle.copyWith(
                              fontSize: 12,
                              color: isCorrect
                                  ? AppTheme.primaryGreen
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacing.width(4),
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            size: 14,
                            color: isCorrect
                                ? AppTheme.primaryGreen
                                : Colors.red,
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
        ),

        const Spacing.height(16),

        Text(
          'Available Words:',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),

        const Spacing.height(8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableWords.map((word) {
            final bool isUsed = associatedWords.contains(word);

            return GestureDetector(
              onTap: isUsed ? null : () => addAssociation(word),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isUsed ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isUsed
                        ? Colors.grey.withValues(alpha: 0.1)
                        : AppTheme.backgroundDark.withValues(
                            alpha: 0.5,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUsed
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    word,
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 12,
                      color: isUsed
                          ? AppTheme.textPrimary.withValues(alpha: 0.4)
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        RenderIf.condition(
          associatedWords.length == 5 &&
              associatedWords.every(
                (word) => correctWords.contains(word),
              ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryGreen),
            ),
            child: Div.row([
              const Icon(
                Icons.psychology,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const Spacing.width(8),
              Text(
                'Excellent associations! You understand usability principles. +8 Concept points',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void addAssociation(String word) {
    if (associatedWords.length < 5) {
      setState(() {
        associatedWords.add(word);
      });
    }
  }

  void removeAssociation(String word) {
    setState(() {
      associatedWords.remove(word);
    });
  }
}

class DialAdjustmentWidget extends StatefulWidget {
  const DialAdjustmentWidget({super.key});

  @override
  State<DialAdjustmentWidget> createState() =>
      DialAdjustmentWidgetState();
}

class DialAdjustmentWidgetState extends State<DialAdjustmentWidget> {
  double complexityLevel = 50.0;
  double usabilityLevel = 50.0;
  bool showOptimal = false;

  @override
  Widget build(BuildContext context) {
    final bool isOptimal =
        (complexityLevel < 30 && usabilityLevel > 70);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.tune, color: Colors.purple, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Design Balance Dial',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Adjust both dials to find the optimal design balance',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        // Complexity dial
        Div.column([
          Div.row([
            Text(
              'Complexity',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.purple,
              ),
            ),
            const Spacer(),
            Text(
              '${complexityLevel.round()}%',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ]),

          const Spacing.height(8),

          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.purple,
              inactiveTrackColor: AppTheme.textPrimary.withValues(
                alpha: 0.1,
              ),
              thumbColor: Colors.purple,
              overlayColor: Colors.purple.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
              ),
              trackHeight: 6,
            ),
            child: Slider(
              value: complexityLevel,
              max: 100,
              onChanged: (value) {
                setState(() {
                  complexityLevel = value;
                  checkOptimal();
                });
              },
            ),
          ),

          Div.row([
            Text(
              'Simple',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 11,
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            Text(
              'Complex',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 11,
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ]),
        ]),

        const Spacing.height(16),

        // Usability dial
        Div.column([
          Div.row([
            Text(
              'Usability',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.purple,
              ),
            ),
            const Spacer(),
            Text(
              '${usabilityLevel.round()}%',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ]),

          const Spacing.height(8),

          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.purple,
              inactiveTrackColor: AppTheme.textPrimary.withValues(
                alpha: 0.1,
              ),
              thumbColor: Colors.purple,
              overlayColor: Colors.purple.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
              ),
              trackHeight: 6,
            ),
            child: Slider(
              value: usabilityLevel,
              max: 100,
              onChanged: (value) {
                setState(() {
                  usabilityLevel = value;
                  checkOptimal();
                });
              },
            ),
          ),

          Div.row([
            Text(
              'Difficult',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 11,
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            Text(
              'Easy',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 11,
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ]),
        ]),

        const Spacing.height(16),

        // Balance indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOptimal
                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOptimal ? AppTheme.primaryGreen : Colors.orange,
            ),
          ),
          child: Div.row([
            Icon(
              isOptimal ? Icons.balance : Icons.warning,
              color: isOptimal ? AppTheme.primaryGreen : Colors.orange,
              size: 16,
            ),
            const Spacing.width(8),
            Expanded(
              child: Text(
                isOptimal
                    ? 'Perfect balance! Low complexity + high usability = great design'
                    : 'Try adjusting: aim for simple and easy to use',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: isOptimal
                      ? AppTheme.primaryGreen
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ]),
        ),

        RenderIf.condition(
          showOptimal,
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Excellent! You found the sweet spot where designs are both simple and usable. +10 Balance points',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void checkOptimal() {
    if (complexityLevel < 30 && usabilityLevel > 70 && !showOptimal) {
      setState(() {
        showOptimal = true;
      });
    }
  }
}

class StoryBranchingWidget extends StatefulWidget {
  const StoryBranchingWidget({super.key});

  @override
  State<StoryBranchingWidget> createState() =>
      StoryBranchingWidgetState();
}

class StoryBranchingWidgetState extends State<StoryBranchingWidget> {
  int currentStory = 0;
  List<int> storyPath = [];
  bool storyComplete = false;

  final List<Map<String, dynamic>> storyNodes = [
    {
      'text':
          'Kenji, a product designer in Tokyo, faces a deadline. His team needs to choose a design direction for a mobile app.',
      'choices': [
        {'text': 'Research users first', 'next': 1, 'points': 5},
        {'text': 'Start with visual design', 'next': 2, 'points': 2},
      ],
    },
    {
      'text':
          'Kenji conducts user interviews at a local café. He discovers users struggle with small buttons on mobile devices.',
      'choices': [
        {'text': 'Increase button sizes', 'next': 3, 'points': 5},
        {'text': 'Add colorful animations', 'next': 4, 'points': 1},
      ],
    },
    {
      'text':
          'Kenji creates beautiful mockups with trendy gradients, but ignores user needs during the design process.',
      'choices': [
        {'text': 'Test with users anyway', 'next': 5, 'points': 3},
        {'text': 'Ship the pretty design', 'next': 6, 'points': 0},
      ],
    },
    {
      'text':
          'The app launches with accessible, easy-to-tap buttons. Users love the intuitive interface and adoption soars.',
      'choices': [],
      'ending': 'success',
    },
    {
      'text':
          'Despite beautiful animations, users struggle with tiny buttons. Adoption remains low.',
      'choices': [],
      'ending': 'partial',
    },
    {
      'text':
          'Late-stage testing reveals usability issues, but there\'s time to fix critical problems.',
      'choices': [],
      'ending': 'partial',
    },
    {
      'text':
          'The beautiful app launches but users can\'t navigate it effectively. Bad reviews flood the app store.',
      'choices': [],
      'ending': 'failure',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> currentNode = storyNodes[currentStory];
    final List<dynamic> choices =
        currentNode['choices'] as List<dynamic>;
    final bool isEnding = choices.isEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.auto_stories, color: Colors.teal, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Design Story Path',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Text(
            'Chapter ${storyPath.length + 1}',
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: Colors.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Choose how the design story unfolds',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        // Story text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            currentNode['text'],
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),

        const Spacing.height(16),

        // Choices or ending
        if (isEnding) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getEndingColor(
                currentNode['ending'],
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getEndingColor(currentNode['ending']),
              ),
            ),
            child: Div.column([
              Div.row([
                Icon(
                  getEndingIcon(currentNode['ending']),
                  color: getEndingColor(currentNode['ending']),
                  size: 20,
                ),
                const Spacing.width(8),
                Text(
                  getEndingTitle(currentNode['ending']),
                  style: Typography.bodyLargeStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getEndingColor(currentNode['ending']),
                  ),
                ),
              ]),

              const Spacing.height(8),

              Text(
                getEndingMessage(currentNode['ending']),
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 12,
                  color: AppTheme.textPrimary.withValues(alpha: 0.8),
                  height: 1.3,
                ),
              ),
            ]),
          ),

          const Spacing.height(12),

          GestureDetector(
            onTap: resetStory,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Try Different Choices',
                  style: Typography.bodyLargeStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ] else ...[
          ...choices.map<Widget>((choice) {
            final Map<String, dynamic> choiceMap =
                choice as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => makeChoice(choiceMap),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Div.row([
                    Expanded(
                      child: Text(
                        choiceMap['text'] as String,
                        style: Typography.bodyMediumStyle.copyWith(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.teal,
                    ),
                  ]),
                ),
              ),
            );
          }),
        ],
      ]),
    );
  }

  Color getEndingColor(String ending) {
    switch (ending) {
      case 'success':
        return AppTheme.primaryGreen;
      case 'partial':
        return Colors.orange;
      case 'failure':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  IconData getEndingIcon(String ending) {
    switch (ending) {
      case 'success':
        return Icons.celebration;
      case 'partial':
        return Icons.warning;
      case 'failure':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String getEndingTitle(String ending) {
    switch (ending) {
      case 'success':
        return 'Excellent Design Process!';
      case 'partial':
        return 'Mixed Results';
      case 'failure':
        return 'Design Failed';
      default:
        return 'Story Complete';
    }
  }

  String getEndingMessage(String ending) {
    switch (ending) {
      case 'success':
        return 'Kenji followed user-centered design principles and created a successful product. +15 Story points';
      case 'partial':
        return 'Some good choices, but could be improved. +8 Story points';
      case 'failure':
        return 'Design without user focus leads to poor outcomes. +3 Story points for learning';
      default:
        return 'Story completed.';
    }
  }

  void makeChoice(Map<String, dynamic> choice) {
    setState(() {
      currentStory = choice['next'];
      storyPath.add(currentStory);
    });
  }

  void resetStory() {
    setState(() {
      currentStory = 0;
      storyPath.clear();
      storyComplete = false;
    });
  }
}

class PatternRecognitionWidget extends StatefulWidget {
  const PatternRecognitionWidget({super.key});

  @override
  State<PatternRecognitionWidget> createState() =>
      PatternRecognitionWidgetState();
}

class PatternRecognitionWidgetState
    extends State<PatternRecognitionWidget> {
  List<String> designPatterns = [
    'Card Layout',
    'Navigation Bar',
    'Search Box',
    'Button Grid',
    'Card Layout',
  ];

  List<bool> selectedIndices = List.filled(5, false);
  bool hasSubmitted = false;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Div.column([
        Div.row([
          const Icon(Icons.pattern, color: Colors.red, size: 24),

          const Spacing.width(12),

          Expanded(
            child: Text(
              'Pattern Recognition',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ]),

        const Spacing.height(8),

        Text(
          'Identify repeated design patterns in the sequence',
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(16),

        // Pattern sequence
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Div.column([
            Text(
              'Design Pattern Sequence:',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),

            const Spacing.height(12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: designPatterns.asMap().entries.map((entry) {
                final int index = entry.key;
                final String pattern = entry.value;
                final bool isSelected = selectedIndices[index];
                final bool isRepeated = pattern == 'Card Layout';

                return GestureDetector(
                  onTap: hasSubmitted
                      ? null
                      : () => toggleSelection(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: hasSubmitted
                          ? (isRepeated
                                ? AppTheme.primaryGreen.withValues(
                                    alpha: 0.1,
                                  )
                                : (isSelected
                                      ? Colors.red.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppTheme.backgroundDark
                                            .withValues(alpha: 0.5)))
                          : (isSelected
                                ? Colors.red.withValues(alpha: 0.1)
                                : AppTheme.backgroundDark.withValues(
                                    alpha: 0.5,
                                  )),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasSubmitted
                            ? (isRepeated
                                  ? AppTheme.primaryGreen
                                  : (isSelected
                                        ? Colors.red
                                        : AppTheme.textPrimary
                                              .withValues(alpha: 0.2)))
                            : (isSelected
                                  ? Colors.red
                                  : AppTheme.textPrimary.withValues(
                                      alpha: 0.2,
                                    )),
                        width: hasSubmitted && isRepeated ? 2 : 1,
                      ),
                    ),
                    child: Div.row([
                      Text(
                        '${index + 1}. $pattern',
                        style: Typography.bodyMediumStyle.copyWith(
                          fontSize: 12,
                          color: hasSubmitted
                              ? (isRepeated
                                    ? AppTheme.primaryGreen
                                    : (isSelected
                                          ? Colors.red.shade700
                                          : AppTheme.textPrimary))
                              : (isSelected
                                    ? Colors.red
                                    : AppTheme.textPrimary),
                          fontWeight: hasSubmitted && isRepeated
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),

                      RenderIf.condition(
                        hasSubmitted,
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            isRepeated
                                ? Icons.check_circle
                                : isSelected
                                ? Icons.cancel
                                : Icons.circle_outlined,
                            size: 16,
                            color: isRepeated
                                ? AppTheme.primaryGreen
                                : isSelected
                                ? Colors.red
                                : AppTheme.textPrimary.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ]),
        ),

        const Spacing.height(16),

        RenderIf.condition(
          !hasSubmitted,
          GestureDetector(
            onTap: checkPattern,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Check Pattern Recognition',
                  style: Typography.bodyLargeStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),

        RenderIf.condition(
          hasSubmitted,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: score >= 2
                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: score >= 2
                    ? AppTheme.primaryGreen
                    : Colors.orange,
              ),
            ),
            child: Div.column([
              Div.row([
                Icon(
                  score >= 2 ? Icons.visibility : Icons.psychology,
                  color: score >= 2
                      ? AppTheme.primaryGreen
                      : Colors.orange,
                  size: 16,
                ),
                const Spacing.width(8),
                Text(
                  score >= 2
                      ? 'Great pattern recognition!'
                      : 'Pattern recognition needs practice',
                  style: Typography.bodyMediumStyle.copyWith(
                    fontSize: 12,
                    color: score >= 2
                        ? AppTheme.primaryGreen
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]),

              const Spacing.height(4),

              Text(
                'You identified $score/2 repeated patterns. ${score >= 2 ? "+12 Recognition points" : "+6 Recognition points for trying"}',
                style: Typography.bodyMediumStyle.copyWith(
                  fontSize: 11,
                  color: AppTheme.textPrimary.withValues(alpha: 0.7),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void toggleSelection(int index) {
    setState(() {
      selectedIndices[index] = !selectedIndices[index];
    });
  }

  void checkPattern() {
    // Count correct selections (Card Layout appears at indices 0 and 4)
    int correctSelections = 0;
    if (selectedIndices[0]) {
      correctSelections++; // First Card Layout
    }
    if (selectedIndices[4]) {
      correctSelections++; // Second Card Layout
    }

    // Subtract incorrect selections
    for (int i = 1; i < 4; i++) {
      if (selectedIndices[i]) {
        correctSelections--;
      }
    }

    setState(() {
      hasSubmitted = true;
      score = correctSelections.clamp(0, 2);
    });
  }
}
