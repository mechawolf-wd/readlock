// Widget that displays humorous good and bad design examples
// Provides entertaining conclusion to design courses with relatable examples

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/app_theme.dart';

class DesignExamplesShowcase extends StatefulWidget {
  const DesignExamplesShowcase({super.key});

  @override
  State<DesignExamplesShowcase> createState() =>
      DesignExamplesShowcaseState();
}

class DesignExamplesShowcaseState
    extends State<DesignExamplesShowcase> {
  int currentExampleIndex = 0;

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
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          PageIndicator(),

          const Spacing.height(16),

          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: examples.length,
              onPageChanged: (index) {
                setState(() {
                  currentExampleIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ExampleCard(examples[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget PageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        examples.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentExampleIndex
                ? AppTheme.textPrimary
                : AppTheme.textPrimary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget ExampleCard(DesignExample example) {
    final themeColor = example.isGoodDesign
        ? AppTheme.primaryGreen
        : AppTheme.errorColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    example.isGoodDesign
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: themeColor,
                    size: 24,
                  ),
                ),

                const Spacing.width(12),

                Expanded(
                  child: Text(
                    example.title,
                    style: Typography.bodyLargeStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

            const Spacing.height(20),

            ProgressiveText(
              textSegments: example.textSegments,
              textStyle: Typography.bodyLargeStyle,
              characterDelay: const Duration(milliseconds: 15),
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
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
