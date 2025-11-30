// Widget that displays humorous good and bad design examples
// Provides entertaining conclusion to design courses with relatable examples

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

class CCDesignExamplesShowcase extends StatefulWidget {
  const CCDesignExamplesShowcase({super.key});

  @override
  State<CCDesignExamplesShowcase> createState() =>
      CCDesignExamplesShowcaseState();
}

class CCDesignExamplesShowcaseState
    extends State<CCDesignExamplesShowcase> {
  Set<int> revealedCards = {};

  final List<DesignExample> examples = const [
    DesignExample(
      title: 'Good Affordances: The Door Handle',
      isGoodDesign: true,
      textSegments: [
        'A well-designed door handle is like a silent conversation: "Hi there, I\'m a handle. Please grab me and pull."',
        'The shape, size, and placement all scream "USE ME THIS WAY" without saying a word.',
        'You\'ve never stood confused in front of a good door handle, wondering if it\'s decorative.',
        'That\'s because it passed Affordances 101 with flying colors.',
      ],
    ),
    DesignExample(
      title: 'Bad Signifiers: The Norman Door',
      isGoodDesign: false,
      textSegments: [
        'Meet the "Norman Door" - named after Don Norman, who got tired of pushing doors that needed pulling.',
        'It has a handle that says "pull me" but a sign that says "push."',
        'You end up doing the walk of shame: pull, read sign, push, feel silly.',
        'If a door needs instructions, it\'s basically admitting design defeat.',
      ],
    ),
    DesignExample(
      title: 'Natural Mapping: Car Mirrors',
      isGoodDesign: true,
      textSegments: [
        'Car mirror controls that match the mirror layout are pure genius.',
        'Want to adjust the left mirror? Press the left button. Revolutionary!',
        'Your brain doesn\'t have to translate "left button controls right mirror" nonsense.',
        'It\'s like the designers actually used their own product. Imagine that!',
      ],
    ),
    DesignExample(
      title: 'Feedback Failures: The Silent Elevator',
      isGoodDesign: false,
      textSegments: [
        'You press an elevator button. Nothing happens. Did it register? Is it broken? Are you trapped forever?',
        'Welcome to the anxiety-inducing world of zero feedback design.',
        'You end up pressing the button seventeen more times, just to be sure.',
        'A simple light or beep would\'ve saved everyone from your button-mashing panic.',
      ],
    ),
    DesignExample(
      title: 'Smart Constraints: The Gas Cap',
      isGoodDesign: true,
      textSegments: [
        'Modern gas caps that can only go on one way are constraint heroes.',
        'They prevent the 3 AM gas station struggle of "which way does this thing screw on?"',
        'Good constraints are like helpful friends who stop you from doing dumb things.',
        'They make the right way the only way, eliminating user error through clever design.',
      ],
    ),
    DesignExample(
      title: 'Hidden Mysteries: Gesture Interfaces',
      isGoodDesign: false,
      textSegments: [
        'Gesture-only interfaces: "We\'ve hidden all our functions! Good luck finding them!"',
        'It\'s like a treasure hunt, but instead of gold, you find basic functionality.',
        'Users spend more time discovering features than actually using them.',
        'Discoverability is not a bonus feature - it\'s a basic requirement.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: RLTheme.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RLTypography.headingMedium(
            'Design Examples',
            color: RLTheme.textPrimary,
          ),

          const Spacing.height(8),

          RLTypography.bodyMedium(
            'Tap cards to reveal examples of good and bad design',
            color: RLTheme.textPrimary.withValues(alpha: 0.7),
          ),

          const Spacing.height(20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: examples.length,
            itemBuilder: (context, index) {
              return ExampleCard(
                example: examples[index],
                index: index,
                isRevealed: revealedCards.contains(index),
                onTap: () {
                  setState(() {
                    if (revealedCards.contains(index)) {
                      revealedCards.remove(index);
                    } else {
                      revealedCards.add(index);
                    }
                  });
                },
              );
            },
          ),

          const Spacing.height(20),

          RevealProgressIndicator(),
        ],
      ),
    );
  }

  Widget RevealProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RLTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: RLTheme.primaryGreen,
            size: 20,
          ),

          const Spacing.width(12),

          Expanded(
            child: RLTypography.bodyMedium(
              '${revealedCards.length}/${examples.length} examples discovered',
              color: RLTheme.textPrimary,
            ),
          ),

          if (revealedCards.length == examples.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RLTheme.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RLTypography.bodyMedium(
                'Complete!',
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget ExampleCard({
    required DesignExample example,
    required int index,
    required bool isRevealed,
    required VoidCallback onTap,
  }) {
    final themeColor = example.isGoodDesign
        ? RLTheme.primaryGreen
        : RLTheme.errorColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRevealed 
              ? themeColor.withValues(alpha: 0.1)
              : RLTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRevealed 
                ? themeColor.withValues(alpha: 0.3)
                : RLTheme.textPrimary.withValues(alpha: 0.1),
            width: isRevealed ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRevealed
                        ? themeColor.withValues(alpha: 0.2)
                        : RLTheme.textPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isRevealed
                        ? (example.isGoodDesign
                            ? Icons.check_circle
                            : Icons.cancel)
                        : Icons.help_outline,
                    color: isRevealed 
                        ? themeColor 
                        : RLTheme.textPrimary.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
                
                const Spacer(),
                
                if (!isRevealed)
                  Icon(
                    Icons.touch_app,
                    color: RLTheme.textPrimary.withValues(alpha: 0.3),
                    size: 16,
                  ),
              ],
            ),

            const Spacing.height(12),

            Text(
              isRevealed 
                  ? example.title 
                  : 'Design Example ${index + 1}',
              style: RLTypography.bodyMediumStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: isRevealed 
                    ? RLTheme.textPrimary 
                    : RLTheme.textPrimary.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (isRevealed) ...[
              const Spacing.height(8),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: example.textSegments.map((segment) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          segment,
                          style: RLTypography.bodyMediumStyle.copyWith(
                            color: RLTheme.textPrimary.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ] else ...[
              const Spacing.height(8),
              
              Expanded(
                child: Center(
                  child: Text(
                    'Tap to reveal',
                    style: RLTypography.bodyMediumStyle.copyWith(
                      color: RLTheme.textPrimary.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DesignExample {
  final String title;
  final bool isGoodDesign;
  final List<String> textSegments;

  const DesignExample({
    required this.title,
    required this.isGoodDesign,
    required this.textSegments,
  });
}
