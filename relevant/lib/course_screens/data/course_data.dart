import 'package:relevant/course_screens/models/course_model.dart';

class CourseData {
  static const List<Course> availableCourses = [
    Course(
      id: 'viral_effect',
      title: 'The Viral Effect',
      description: 'Discover how ideas spread like wildfire',
      coverImagePath: 'assets/images/viral_effect_course.png',
      color: 'blue',
      sections: [
        CourseSection(
          id: 'viral_introduction',
          title: 'The Power of Virality',
          content: [
            TextContent(
              id: 'viral_intro',
              title: 'Welcome to The Viral Effect',
              text: 'Why do some ideas spread like wildfire while others vanish without a trace?\n\nIn this course, we\'ll decode the hidden mechanics behind viral content. You\'ll discover six universal principles that transform ordinary ideas into unstoppable movements. We\'ll explore everything from the Ice Bucket Challenge to TikTok trends that captivate millions.\n\nIn This Course, You\'ll Learn:\n• The psychology of social currency and why people share content\n• How to trigger emotional responses that compel action\n• The art of creating "stickiness" that makes ideas memorable\n• Real-world strategies for making your content irresistible to share\n• How to identify viral potential before ideas explode',
            ),
            TextContent(
              id: 'viral_story_1',
              title: 'The Ice Bucket Challenge Phenomenon',
              text: 'In 2014, a simple video challenge raised over \$115 million for ALS research.\n\nHow did pouring ice water on yourself become a global movement?\n\nThe secret lies in understanding the mechanics of viral content - the perfect storm of social currency, emotion, and shareability that transforms ordinary ideas into extraordinary movements.\n\nEvery viral moment follows predictable patterns that you can learn and apply.',
            ),
            TextContent(
              id: 'viral_story_2',
              title: 'Your Daily Viral Encounters',
              text: 'Every day, you encounter viral mechanics without realizing it.\n\nThat meme your friend shared...\nThe song stuck in your head...\nThe product everyone suddenly wants...\n\nThey all follow predictable patterns.\n\nUnderstanding these patterns gives you the power to create ideas that stick and spread.',
            ),
            QuestionContent(
              id: 'viral_awareness_question',
              title: 'Viral Recognition Challenge',
              question:
                  'Which of these recent phenomena demonstrates viral mechanics in action?',
              options: [
                QuestionOption(
                  text: 'A TikTok dance everyone knows',
                  hint: 'Easy to copy, fun to share',
                ),
                QuestionOption(
                  text: 'Your favorite Netflix series',
                  hint: 'Not necessarily viral',
                ),
                QuestionOption(
                  text: 'A restaurant with a long line',
                  hint: 'Visible social proof',
                ),
              ],
              correctAnswerIndices: [0, 2],
              explanation:
                  'TikTok dances and restaurant lines show viral mechanics: easy sharing, social proof, and visible status. Netflix shows are popular but not necessarily viral - virality requires active sharing and social currency.',
              followUpPrompts: [
                'What makes something shareable vs. just popular?',
                'How do you recognize viral potential before it spreads?',
              ],
            ),
            TextContent(
              id: 'viral_transition_1',
              title: 'Ready to Dive Deeper?',
              text: 'You\'ve seen how viral content can transform ideas into movements. But what makes some content irresistible to share?\n\nLet\'s explore the six psychological triggers that make content go viral!',
            ),
          ],
        ),
        CourseSection(
          id: 'viral_mechanics',
          title: 'The Six Principles of Virality',
          content: [
            TextContent(
              id: 'social_currency_story',
              title: 'Social Currency: Why We Share',
              text: 'People share content that makes them look good.\n\nWhen Spotify released "Wrapped," users eagerly shared their music stats not because Spotify asked them to, but because it made them appear interesting and unique.\n\nThink about it:\n• "Look how diverse my taste is!"\n• "I discovered this before it was cool!"\n• "My top artist shows I\'m deep!"\n\nYour ideas need to give people social currency - a reason to feel good about sharing.',
            ),
            QuestionContent(
              id: 'social_currency_quiz',
              title: 'Social Currency Detector',
              question:
                  'Your friend posts their Wordle score. What social currency are they seeking?',
              options: [
                QuestionOption(
                  text: 'Showing they\'re smart (solved it quickly)',
                ),
                QuestionOption(
                  text:
                      'Proving they\'re trendy (doing what\'s popular)',
                ),
                QuestionOption(text: 'Just sharing for no reason'),
              ],
              correctAnswerIndices: [0, 1],
              explanation:
                  'Wordle sharing hits multiple social currency notes: intelligence ("I solved it in 3 tries!") and trendiness ("I\'m part of this cultural moment"). People rarely share "just because" - there\'s always underlying social motivation.',
              followUpPrompts: [
                'What would make someone feel smart for sharing your idea?',
                'How can you tap into people\'s desire to look trendy?',
              ],
            ),
            TextContent(
              id: 'triggers_story',
              title: 'Triggers: Staying Top of Mind',
              text: 'Kit Kat sales skyrocketed when they linked their brand to coffee breaks.\n\nEvery time someone thought "coffee," they thought "Kit Kat."\n\nThis is the power of triggers:\n• Friday → "Thank God it\'s Friday"\n• Yellow → McDonald\'s golden arches\n• Hearing "Happy Birthday" → thinking of that one restaurant\n\nThe most successful viral ideas are triggered by everyday experiences, keeping them constantly in our minds.',
            ),
            TextContent(
              id: 'viral_reflection',
              title: 'Your Viral Potential',
              text: 'Think about the last piece of content you shared on social media. What made you want to share it? How did it make you feel about yourself when you posted it?\n\nMost viral content succeeds because it helps people express their identity or values. When you understand what makes people feel good about sharing, you unlock the secret to creating ideas that spread naturally.\n\nThink About:\n• What topics do you naturally get excited talking about?\n• When do your friends come to you for advice or opinions?\n• What would make someone feel smart or interesting for sharing your idea?',
            ),
            QuestionContent(
              id: 'viral_elements_question',
              title: 'The Viral Formula',
              question:
                  'Which elements made the Ice Bucket Challenge go viral?',
              options: [
                QuestionOption(
                  text: 'Social currency - it made people look good',
                ),
                QuestionOption(text: 'Complex technical requirements'),
                QuestionOption(
                  text: 'High emotional impact and shareability',
                ),
              ],
              correctAnswerIndices: [0, 2],
              explanation:
                  'The Ice Bucket Challenge succeeded because it gave people social currency (looking charitable) and created strong emotions (fun + charity). Simple participation was key - complexity would have killed it.',
            ),
            TextContent(
              id: 'viral_transition_2',
              title: 'Time to Apply What You\'ve Learned',
              text: 'You now understand the psychological triggers behind viral content. Ready to see how this applies to real situations?\n\nLet\'s put your viral knowledge to the test and see what you\'ve mastered!',
            ),
            TextContent(
              id: 'viral_summary',
              title: 'Congratulations! You\'ve Mastered Viral Mechanics',
              text: 'Viral content isn\'t random—it follows predictable patterns you can harness. The most powerful viral ideas give people social currency while triggering emotions and everyday reminders. Master these mechanics, and you\'ll never create forgettable content again.\n\nReal-World Success Stories:\n\n💼 Marketing Manager at SaaS Company\nApplied social currency principles to their product launch. Instead of focusing on features, they highlighted how early adopters would be seen as innovative pioneers in their industry.\nResult: Launch video shared 300% more than previous campaigns, generating 2,000 qualified leads in first week.\n\n🍽️ Local Restaurant Owner\nCreated an Instagram-worthy signature dish that customers felt proud to share. Added a "share your moment" discount for social posts.\nResult: Social media mentions increased 500%, weekend reservations booked solid for three months.\n\n🎥 Content Creator\nShifted from "how-to" videos to "behind-the-scenes" content that made followers feel like insiders with exclusive knowledge.\nResult: Engagement rates doubled, landed three brand partnership deals worth \$15K total.',
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'design_everyday_things',
      title: 'Design of Everyday Things',
      description: 'Transform how you see the world around you',
      coverImagePath: 'assets/images/design_course.png',
      color: 'green',
      sections: [
        CourseSection(
          id: 'design_introduction',
          title: 'The Hidden Language of Design',
          content: [
            TextContent(
              id: 'design_intro',
              title: 'Welcome to Design of Everyday Things',
              text: 'Why do you pull on doors that should be pushed, get confused by simple interfaces, and blame yourself when things don\'t work?\n\nIn this course, we\'ll unveil the invisible language of design that surrounds you every day. You\'ll learn to see the world through a designer\'s eyes, understanding why some objects feel intuitive while others frustrate us, and how to apply these insights to create better experiences.\n\nIn This Course, You\'ll Learn:\n• The psychology behind how objects communicate their purpose\n• Seven fundamental principles that make design intuitive or confusing\n• How to recognize good and bad design in everyday objects\n• The hidden affordances that guide our interactions with the world\n• How to apply design thinking to solve real-world problems',
            ),
            TextContent(
              id: 'door_story',
              title: 'The Door That Started a Revolution',
              text: 'Picture this: You approach a glass door at a coffee shop.\n\nNo handle visible, just a flat metal plate.\n\nDo you push or pull?\n\nYou push - nothing.\nYou pull - it opens.\n\nFrustrated? You just experienced bad design.\n\nDon Norman calls these "Norman doors," and they\'re everywhere, silently frustrating millions of people daily.',
            ),
            TextContent(
              id: 'design_psychology',
              title: 'The Psychology Behind Every Object',
              text: 'Every object tells you how to use it through its design.\n\nA button begs to be pressed...\nA handle invites pulling...\nA flat surface suggests pushing...\n\nWhen design and psychology align, magic happens - things just work intuitively.\n\nWhen they don\'t, we get confused, frustrated, and blame ourselves instead of the poor design.',
            ),
            QuestionContent(
              id: 'design_awareness_question',
              title: 'Design Detective Challenge',
              question:
                  'You see a door with a flat metal plate. What does this design communicate?',
              options: [
                QuestionOption(
                  text: 'Push this door',
                  hint: 'Flat surfaces suggest pushing',
                ),
                QuestionOption(
                  text: 'Pull this door',
                  hint: 'No handle visible',
                ),
                QuestionOption(
                  text: 'The design is confusing',
                  hint: 'Good design should be obvious',
                ),
              ],
              correctAnswerIndices: [0],
              explanation:
                  'A flat metal plate (push plate) is designed to be pushed. This is good design - the flat surface affords pushing, making the interaction obvious without thinking.',
              followUpPrompts: [
                'What other objects have clear affordances?',
                'When has bad design frustrated you recently?',
              ],
            ),
          ],
        ),
        CourseSection(
          id: 'design_principles',
          title: 'The Seven Fundamental Principles',
          content: [
            TextContent(
              id: 'affordances_story',
              title: 'Affordances: The Language of Possibility',
              text: 'A chair affords sitting...\nA button affords pressing...\nA handle affords pulling...\n\nThese "affordances" are the secret communication between objects and users.\n\nGreat design makes affordances obvious - you know exactly what to do without thinking.\n\nPoor design hides them, leaving you guessing.',
            ),
            TextContent(
              id: 'feedback_story',
              title: 'Feedback: The Design Conversation',
              text: 'When you press an elevator button and it lights up, that\'s feedback.\n\nWhen your phone vibrates after sending a message, that\'s feedback.\n\nWithout feedback, we\'re left wondering:\n• "Did it work?"\n• "Should I try again?"\n• "Is something broken?"\n\nGreat design constantly communicates with users, confirming actions and guiding next steps.',
            ),
            TextContent(
              id: 'design_reflection',
              title: 'Design Detective',
              text: 'Look around you right now. Pick any object within reach. How does its design tell you how to use it? What frustrates you about poorly designed objects in your daily life?\n\nOnce you start noticing design, you can\'t stop. Good design becomes invisible - it just works. Bad design screams for attention through confusion and frustration. The goal is to make your users\' lives effortless.\n\nThink About:\n• What objects do you use without thinking about how they work?\n• When was the last time you got confused by a simple interface?\n• How could you make something in your life more intuitive to use?',
            ),
            QuestionContent(
              id: 'door_design_scenario',
              title: 'The Confusing Door',
              question:
                  'You approach this door at a coffee shop. What should you do first?',
              type: QuestionType.scenario,
              scenarioContext:
                  'You see a glass door with a vertical metal handle on the right side. There are no visible instructions or signs. The handle looks like it could be pulled, but there\'s also a flat metal plate near the handle.',
              options: [
                QuestionOption(
                  text: 'Pull the handle toward you',
                  hint: 'Handles usually suggest pulling',
                ),
                QuestionOption(
                  text: 'Look for additional clues or signs',
                  hint: 'When in doubt, gather more information',
                ),
                QuestionOption(
                  text: 'Try both push and pull',
                  hint: 'Trial and error approach',
                ),
              ],
              correctAnswerIndices: [1],
              explanation:
                  'Good design should be obvious, but when it\'s not, looking for additional clues is the smart approach. This scenario illustrates a "Norman door" - poor design that forces users to guess. The best solution is redesigning the door to make its operation obvious.',
              followUpPrompts: [
                'How would you redesign this door to make it obvious?',
                'What other everyday objects confuse you similarly?',
              ],
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'lean_startup',
      title: 'The Lean Startup',
      description: 'Build products people actually want',
      coverImagePath: 'assets/images/lean_startup_course.png',
      color: 'purple',
      sections: [
        CourseSection(
          id: 'lean_introduction',
          title: 'The Startup Wasteland',
          content: [
            TextContent(
              id: 'lean_intro',
              title: 'Welcome to The Lean Startup',
              text: 'How do you build products people actually want instead of beautiful failures that nobody needs?\n\nIn this course, we\'ll explore the revolutionary methodology that transformed how successful companies are built. You\'ll learn to replace elaborate planning with rapid experimentation, turning assumptions into validated learning and dramatically increasing your chances of building something people love.\n\nIn This Course, You\'ll Learn:\n• The Build-Measure-Learn cycle that minimizes waste and maximizes learning\n• How to create Minimum Viable Products that test real demand\n• The art of validated learning and when to pivot vs. persevere\n• How to measure progress when everything is uncertain\n• Real strategies for testing ideas before building full products',
            ),
            TextContent(
              id: 'failure_story',
              title: 'The \$47 Million Mistake',
              text: 'Webvan raised \$1.2 billion to revolutionize grocery delivery.\n\nThey built massive warehouses...\nHired thousands of employees...\nLaunched in multiple cities...\n\nThey failed spectacularly in 2001.\n\nWhy? They built what they thought customers wanted instead of learning what customers actually needed.\n\nThis is the tragedy that inspired the Lean Startup methodology.',
            ),
            TextContent(
              id: 'lean_philosophy',
              title: 'The Art of Validated Learning',
              text: 'Traditional business plans are fiction - beautiful, detailed fiction.\n\nThe Lean Startup method replaces elaborate planning with rapid experimentation.\n\nInstead of asking "Can this product be built?" it asks:\n• "Should this product be built?"\n• "Can we build a sustainable business around this?"\n\nThe difference between these questions can save millions.',
            ),
            QuestionContent(
              id: 'startup_mistake_question',
              title: 'The Billion Dollar Question',
              question: 'What was Webvan\'s biggest mistake?',
              options: [
                QuestionOption(
                  text: 'They didn\'t have enough funding',
                  hint: 'They had \$1.2 billion',
                ),
                QuestionOption(
                  text: 'They built without validating customer needs',
                  hint: 'Assumptions vs. validation',
                ),
                QuestionOption(
                  text: 'The technology wasn\'t ready',
                  hint: 'Technology existed',
                ),
              ],
              correctAnswerIndices: [1],
              explanation:
                  'Webvan\'s fatal flaw was building a massive infrastructure based on assumptions rather than validated customer needs. They had money and technology, but they never confirmed that enough customers actually wanted grocery delivery at that time and price point.',
              followUpPrompts: [
                'How could Webvan have tested their idea with less risk?',
                'What assumptions are you making in your own projects?',
              ],
            ),
          ],
        ),
        CourseSection(
          id: 'build_measure_learn',
          title: 'The Build-Measure-Learn Loop',
          content: [
            TextContent(
              id: 'mvp_story',
              title: 'The Power of the Minimum Viable Product',
              text: 'Dropbox\'s first MVP wasn\'t even a product - it was a 3-minute video.\n\nThe video showed how file syncing would work.\n\nThis simple video generated thousands of signups and validated massive demand before writing a single line of code.\n\nThat\'s the power of starting small and learning fast.',
            ),
            TextContent(
              id: 'pivot_story',
              title: 'The Pivot That Saved Twitter',
              text: 'Twitter started as a podcast platform called Odeo.\n\nWhen Apple announced iTunes podcasting, the team realized they were doomed.\n\nInstead of giving up, they pivoted to a simple question: "What are you doing?"\n\nThat pivot created one of the world\'s most influential social media platforms.\n\nSometimes the best path forward is a complete change of direction.',
            ),
            TextContent(
              id: 'lean_reflection',
              title: 'Your Learning Mindset',
              text: 'Think about a time when you were completely wrong about something important. How did you realize your mistake? What did you learn from that experience?\n\nThe biggest risk isn\'t being wrong - it\'s staying wrong for too long. Successful entrepreneurs fail fast and learn faster. They treat every assumption as a hypothesis to be tested, not a truth to be defended.\n\nThink About:\n• What assumptions are you making about what people want?\n• How could you test your ideas with minimal investment?\n• What would you do differently if you knew you\'d be wrong 80% of the time?',
            ),
            QuestionContent(
              id: 'mvp_truth_question',
              title: 'MVP Reality Check',
              question:
                  'A Minimum Viable Product should be as simple and basic as possible.',
              type: QuestionType.trueOrFalse,
              options: [
                QuestionOption(text: 'True - simpler is always better'),
                QuestionOption(
                  text: 'False - it depends on the learning goal',
                ),
              ],
              correctAnswerIndices: [1],
              explanation:
                  'While MVPs should be simple, the goal isn\'t minimal features - it\'s maximum learning with minimum effort. Dropbox\'s video MVP was more complex than a basic file sharing app, but it was the fastest way to test their core hypothesis about user demand for seamless syncing.',
              followUpPrompts: [
                'What\'s the difference between "minimum" and "viable"?',
                'How do you know if your MVP taught you anything valuable?',
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
