// Widget that displays humorous good and bad design examples
// Provides entertaining conclusion to design courses with relatable examples

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

class DesignExamplesShowcase extends StatefulWidget {
  const DesignExamplesShowcase({super.key});

  @override
  State<DesignExamplesShowcase> createState() => DesignExamplesShowcaseState();
}

class DesignExamplesShowcaseState extends State<DesignExamplesShowcase> {
  int currentExampleIndex = 0;
  
  final List<DesignExample> examples = const [
    DesignExample(
      title: 'Good Design: The Humble Teapot',
      isGoodDesign: true,
      textSegments: [
        'Meet the perfect teapot: round body that says "I hold liquid," curved spout that whispers "pour here," and a handle positioned exactly where your hand expects it.',
        'You\'ve never been confused by a teapot, have you?',
        'That\'s because teapots figured out good design centuries ago.',
        'They\'re basically the design world\'s overachievers.',
      ],
    ),
    DesignExample(
      title: 'Bad Design: The Bathroom Door Lock',
      isGoodDesign: false,
      textSegments: [
        'You know the one: that tiny, mysterious lever that could mean "locked" or "unlocked" depending on its position.',
        'Is it horizontal? Vertical? Does up mean locked or does down?',
        'You end up doing the "jiggle test" from inside the stall.',
        'Because nothing says "modern civilization" like being trapped in a bathroom by a design riddle.',
      ],
    ),
    DesignExample(
      title: 'Good Design: The Zipper',
      isGoodDesign: true,
      textSegments: [
        'Two rows of teeth that somehow understand each other perfectly.',
        'Pull up, they connect. Pull down, they separate.',
        'No instruction manual needed.',
        'It just works, every time, in a way that feels almost magical.',
        'Zippers are the reliable friend of the design world.',
      ],
    ),
    DesignExample(
      title: 'Bad Design: The USB Cable',
      isGoodDesign: false,
      textSegments: [
        'It looks like it should fit. You try to plug it in. It doesn\'t fit.',
        'You flip it over. Still doesn\'t fit.',
        'You flip it back to the original position. Now it fits.',
        'Congratulations, you\'ve just experienced the USB Superposition Principle.',
        'Scientists are still baffled by this phenomenon.',
      ],
    ),
    DesignExample(
      title: 'Good Design: The Sticky Note',
      isGoodDesign: true,
      textSegments: [
        'A piece of paper with just enough stickiness to stay put but not enough to destroy what it\'s stuck to.',
        'Removable, repositionable, and somehow always the perfect size.',
        'It communicates "temporary information here" without saying a word.',
        'The sticky note is basically design perfection in yellow square form.',
      ],
    ),
    DesignExample(
      title: 'Bad Design: The Revolving Door',
      isGoodDesign: false,
      textSegments: [
        'Four compartments spinning at a speed that\'s either too fast or too slow.',
        'Someone always gets stuck.',
        'Someone always pushes the wrong way.',
        'And there\'s always that one person who treats it like a carnival ride.',
        'Revolving doors: making simple entrance and exit unnecessarily complicated since 1888.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
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
            padding: const EdgeInsets.all(24),
            child: ExampleCard(examples[index]),
          );
        },
      ),
    );
  }


  Widget ExampleCard(DesignExample example) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: example.isGoodDesign 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: example.isGoodDesign 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                example.isGoodDesign ? Icons.check_circle : Icons.cancel,
                color: example.isGoodDesign ? Colors.green[600] : Colors.red[600],
                size: 24,
              ),
              
              const Spacing.width(12),
              
              Expanded(
                child: Typography.headingSmall(example.title),
              ),
            ],
          ),
          
          const Spacing.height(16),
          
          ProgressiveText(
            textSegments: example.textSegments,
            textStyle: Typography.bodyMediumStyle,
            characterDelay: const Duration(milliseconds: 20),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ],
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