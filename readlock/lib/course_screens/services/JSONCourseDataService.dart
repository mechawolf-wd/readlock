// Simple JSON file service for course data - loads from assets
// Uses JSON file for development and testing

// ignore_for_file: prefer_single_quotes

import 'dart:convert';
import 'package:flutter/services.dart';

class JsonCourseDataService {
  static Map<String, dynamic>? cachedData;

  static final Map<String, dynamic> mockCourseData = {
    "courses": [
      {
        "id": "design-everyday-things",
        "title": "The Design of Everyday Things",
        "description": "Based on Don Norman's classic book",
        "cover-image-path": "assets/images/design_course.png",
        "color": "green",
        "genres": ["design", "user-experience", "psychology"],
        "lessons": [
          // First lesson of the course
          {
            "id": "design-course",
            "title": "Introduction to design principles",
            "content": [
              {
                "entity-type": "intro",
                "id": "design-intro",
                "title": "Doors, Faucets, and Frustration",
                "intro-text-segments": [
                  "Every day, you interact with hundreds of designed objects. Most work flawlessly, becoming invisible extensions of your intent.",
                  "Yet it's the failures that linger: the hotel door whose handle suggests pulling while demanding a push.",
                  "Those shower controls that seem engineered by someone who has never experienced scalding water.",
                  "These aren't accidents—they represent a disconnect between the designer's mental model and your intuitive expectations.",
                  "Don Norman spent decades studying why intelligent people struggle with objects designed for their use.",
                  "His insights reveal the hidden psychology woven into every handle, button, and interface we encounter.",
                  "What emerges isn't about aesthetics, but understanding how the mind interprets the designed world.",
                ],
              },
              {
                "entity-type": "text",
                "id": "story-1",
                "title": "Story 1",
                "text-segments": [
                  "Sarah approaches the hotel door.",
                  "Glass panel with a vertical metal plate.",
                  "The plate looks like a handle.",
                  "Her brain screams \"pull this!\"",
                  "What choice did evolution give her?",
                  "She grabs and pulls. Nothing.",
                  "Confused, she pushes. The door opens.",
                  "This is a Norman door.",
                  "It gives the wrong signal.",
                ],
              },
              {
                "entity-type": "text",
                "id": "story-2",
                "title": "Story 2",
                "text-segments": [
                  "David faces the bathroom faucet.",
                  "Two identical handles side by side.",
                  "Hot or cold? Left or right?",
                  "Which way do you turn for hot water?",
                  "There are no labels, no indicators.",
                  "He turns the left handle clockwise.",
                  "Ice cold water blasts his hands.",
                  "The mapping was backwards.",
                  "Why should he have to guess?",
                ],
              },
              {
                "entity-type": "text",
                "id": "story-3",
                "title": "Story 3",
                "text-segments": [
                  "Maria sits in front of the stove.",
                  "Four burners, four control knobs.",
                  "But which knob controls which burner?",
                  "The knobs are arranged in a straight line.",
                  "How does that map to a square grid?",
                  "She turns the leftmost knob.",
                  "The back-right burner ignites.",
                  "This violates natural mapping.",
                  "The control should match the layout.",
                ],
              },
              {
                "entity-type": "question",
                "id": "basic-question",
                "title": "Common Sense Check",
                "question":
                    "When you see a door with a handle, what does your brain assume?",
                "options": [
                  {"text": "You should pull it"},
                  {"text": "You should push it"},
                  {"text": "You should knock first"},
                ],
                "correct-answer-indices": [0],
                "explanation":
                    "Handles suggest pulling. This is called an \"affordance.\"",
                "type": "multiple-choice",
              },
              {
                "entity-type": "text",
                "id": "clarification-1",
                "title": "Clarification 1",
                "text-segments": [
                  "Don Norman identified seven fundamental principles that separate good design from frustrating experiences we encounter daily.",
                  "The first principle is affordances - the relationship between the properties of an object and the capabilities of the person that determines how the object could be used.",
                  "A door handle naturally affords grasping and pulling, while a flat metal plate clearly affords pushing.",
                  "When affordances are clear and obvious, you instinctively know what to do without thinking.",
                  "When they're unclear or misleading, you're forced to guess, often failing and feeling foolish for something that isn't your fault.",
                ],
              },
              {
                "entity-type": "text",
                "id": "clarification-2",
                "title": "Clarification 2",
                "text-segments": [
                  "The second principle is feedback - every action needs a clear and immediate reaction to confirm it worked.",
                  "When you press a button, you should see a light, hear a click, or feel the button depress.",
                  "When you turn a knob, you need to feel resistance and see or hear the results of your action.",
                  "Without proper feedback, you're operating completely blind, never sure if your actions had any effect.",
                  "Good feedback is immediate and informative, while poor feedback leaves you wondering if anything happened at all.",
                ],
              },
              {
                "entity-type": "text",
                "id": "clarification-3",
                "title": "Clarification 3",
                "text-segments": [
                  "The third principle is natural mapping - controls should spatially and logically relate to their effects in the world.",
                  "A steering wheel maps rotation directly to the direction your car turns, making it intuitive.",
                  "Light switches should be positioned to map naturally to the lights they control in the room.",
                  "When mapping feels natural and follows spatial relationships, learning becomes instant and effortless.",
                  "When it's arbitrary or contradicts expectations, you need instruction manuals for the simplest tasks.",
                ],
              },
              {
                "entity-type": "question",
                "id": "humor-question-1",
                "title": "The USB Mystery",
                "question":
                    "Why does a USB cable never fit on the first try?",
                "options": [
                  {"text": "The USB exists in quantum superposition"},
                  {
                    "text":
                        "Poor visual design makes orientation unclear",
                  },
                ],
                "correct-answer-indices": [1],
                "explanation":
                    "USB connectors look identical from both sides. Good design makes orientation obvious.",
                "type": "multiple-choice",
              },
              {
                "entity-type": "text",
                "id": "usability-research",
                "title": "Usability Research",
                "text-segments": [
                  "Decades of usability research have revealed startling statistics about how we interact with everyday objects.",
                  "These studies consistently show that when design doesn't match human expectations, failure rates skyrocket.",
                  "The cost of poor design isn't just frustration - it leads to accidents, errors, and sometimes catastrophic failures.",
                  "Understanding these patterns helps designers create interfaces that work with, not against, human nature.",
                ],
              },
              {
                "entity-type": "question",
                "id": "estimate-error-rate",
                "title": "User Error Statistics",
                "question":
                    "What percentage of so-called 'user errors' in airplane accidents were actually caused by poor cockpit design, according to FAA studies?",
                "options": [],
                "correct-answer-indices": [82],
                "explanation":
                    "FAA studies revealed that 82% of pilot errors were actually design-induced errors. Poor placement of controls, confusing displays, and non-intuitive interfaces led to mistakes that were blamed on pilots but were really design failures.",
                "type": "estimate-percentage",
              },
              {
                "entity-type": "question",
                "id": "humor-question-2",
                "title": "The Microwave Paradox",
                "question":
                    "Why can you launch a space shuttle but not figure out your hotel microwave?",
                "options": [
                  {"text": "Space shuttles have better user manuals"},
                  {
                    "text":
                        "Microwaves prioritize features over usability",
                  },
                ],
                "correct-answer-indices": [1],
                "explanation":
                    "Microwaves prioritize features over simple usability. Complexity without purpose is bad design.",
                "type": "multiple-choice",
              },
              {
                "entity-type": "question",
                "id": "estimate-confusion-rate",
                "title": "Control Confusion",
                "question":
                    "In a study of hotel guests, what percentage couldn't figure out how to turn on the shower within 10 seconds?",
                "options": [],
                "correct-answer-indices": [47],
                "explanation":
                    "Nearly half (47%) of hotel guests struggled with unfamiliar shower controls. Each hotel has different designs with no standardization - some pull, some push, some twist, and the hot/cold directions vary. This lack of consistency forces users to experiment every time.",
                "type": "estimate-percentage",
              },
              {
                "entity-type": "text",
                "id": "design-evolution",
                "title": "Evolution of Design Thinking",
                "text-segments": [
                  "The field of user-centered design didn't emerge overnight but evolved through decades of observing human frustration with everyday objects.",
                  "Engineers once designed products focusing solely on functionality, assuming users would adapt to whatever interface they created.",
                  "This led to countless disasters - from confusing airplane cockpits that caused crashes to medical devices that led to fatal dosing errors.",
                  "The shift toward human-centered design recognizes that good design must account for human psychology, limitations, and natural behaviors.",
                  "Today's best designers spend as much time studying users as they do crafting solutions.",
                ],
              },
              {
                "entity-type": "question",
                "id": "true-false-design",
                "title": "Design Principle Check",
                "question":
                    "Good design should require extensive user manuals to understand.",
                "options": [
                  {"text": "True"},
                  {"text": "False"},
                ],
                "correct-answer-indices": [1],
                "explanation":
                    "Good design should be intuitive and self-explanatory. If it needs a manual, the design has failed to communicate its function clearly.",
                "type": "true-or-false",
              },
              {
                "entity-type": "question",
                "id": "estimate-medical-errors",
                "title": "Medical Device Errors",
                "question":
                    "What percentage of fatal medical device errors are attributed to interface design problems rather than device malfunction?",
                "options": [],
                "correct-answer-indices": [67],
                "explanation":
                    "Studies show that 67% of fatal medical device errors stem from poor interface design, not mechanical failure. Confusing displays, similar-looking controls, and poor feedback mechanisms lead to dosing errors and misread vital signs that can be deadly.",
                "type": "estimate-percentage",
              },
              {
                "entity-type": "text",
                "id": "importance-of-feedback",
                "title": "The Importance of Feedback",
                "text-segments": [
                  "Every action we take with an object should produce immediate and clear feedback to confirm it worked.",
                  "Without feedback, we operate in the dark, unsure if our actions had any effect or if we need to try something different.",
                  "Good feedback doesn't just confirm an action - it provides information about the system's state and what will happen next.",
                  "The best designed systems provide multiple forms of feedback: visual, auditory, and tactile cues that reinforce each other.",
                ],
              },
              {
                "entity-type": "question",
                "id": "fill-gap-design",
                "title": "Complete the Principle",
                "question":
                    "Norman's principle states that good design makes things ___ and provides clear ___.",
                "options": [
                  {"text": "visible"},
                  {"text": "complex"},
                  {"text": "feedback"},
                  {"text": "expensive"},
                ],
                "correct-answer-indices": [0, 2],
                "explanation":
                    "Good design makes things visible and provides clear feedback. Visibility helps users understand what actions are possible, and feedback confirms that their actions had an effect.",
                "type": "fill-gap",
              },
              {
                "entity-type": "question",
                "id": "estimate-study-percentage",
                "title": "Research Finding",
                "question":
                    "In Norman's study of door-related accidents in public buildings, what percentage of people pulled a push door on their first attempt?",
                "options": [],
                "correct-answer-indices": [73],
                "explanation":
                    "Norman's study found that 73% of people initially pulled doors that were meant to be pushed when the door had a vertical handle. This demonstrates how powerful affordances are in shaping our behavior - handles strongly suggest pulling, regardless of signage.",
                "type": "estimate-percentage",
              },
              {
                "entity-type": "question",
                "id": "estimate-smartphone-usage",
                "title": "Smartphone Adoption",
                "question":
                    "What percentage of smartphone users never use more than 30% of their phone's features, according to usability studies?",
                "options": [],
                "correct-answer-indices": [89],
                "explanation":
                    "Studies show that 89% of smartphone users utilize less than 30% of available features. This isn't because users are incapable - it's because feature discovery is poor, interfaces are complex, and many functions are buried in confusing menus.",
                "type": "estimate-percentage",
              },
              {
                "entity-type": "text",
                "id": "design-in-practice",
                "title": "Design in Practice",
                "text-segments": [
                  "Great design often goes unnoticed because it works so seamlessly that we never have to think about it.",
                  "Consider the humble zipper - once you understand pulling the tab up closes it and down opens it, you never forget.",
                  "Or think about scissors - the finger holes immediately show where to place your fingers, and the cutting action maps naturally to the squeezing motion.",
                  "These designs succeed because they align perfectly with our mental models and physical capabilities.",
                  "The best designs become invisible through their excellence, while poor designs announce themselves through frustration.",
                ],
              },
              {
                "entity-type": "quote",
                "id": "design-quote",
                "title": "Design Philosophy",
                "quote":
                    "Good design is obvious. Great design is transparent.",
                "author": "Joe Sparano",
              },
              {
                "entity-type": "reflection",
                "id": "reflection-1",
                "title": "Design in Your Life",
                "prompt":
                    "Think about a recent time when you struggled with a poorly designed object or interface. What made it confusing?",
                "thinking-points": [
                  "What did you expect to happen vs. what actually happened?",
                  "Were there visual cues that led you astray?",
                  "How would you redesign it to be more intuitive?",
                  "Who might be most affected by this poor design?",
                ],
              },
              {
                "entity-type": "text",
                "id": "example-1",
                "title": "Example 1",
                "text-segments": [
                  "The Three Mile Island nuclear accident.",
                  "March 28, 1979.",
                  "A cooling pump failed.",
                  "The control room had hundreds of indicators.",
                  "Critical information was buried in the noise.",
                  "Operators couldn't see the real problem.",
                  "Poor visibility led to near-catastrophe.",
                  "Norman uses this as his prime example.",
                ],
              },
              {
                "entity-type": "text",
                "id": "example-2",
                "title": "Example 2",
                "text-segments": [
                  "Consider a simple teapot.",
                  "The spout shows where liquid comes out.",
                  "The handle shows where to grip.",
                  "The lid suggests where to fill.",
                  "Every part has a clear affordance.",
                  "No instruction manual needed.",
                  "This is what good design looks like.",
                  "It's been perfected over centuries.",
                ],
              },
              {
                "entity-type": "text",
                "id": "example-3",
                "title": "Example 3",
                "text-segments": [
                  "Computer keyboards follow typewriter layout.",
                  "QWERTY was designed to slow typists down.",
                  "Why do we still use this today?",
                  "Because changing established conventions is hard.",
                  "Even bad design becomes standard.",
                  "Sometimes compatibility trumps optimization.",
                  "Legacy constraints shape modern design.",
                  "History haunts our interfaces.",
                ],
              },
              {
                "entity-type": "question",
                "id": "estimate-satisfaction",
                "title": "User Satisfaction",
                "question":
                    "After redesigning products using Norman's principles, by what percentage did user satisfaction scores typically increase?",
                "options": [],
                "correct-answer-indices": [42],
                "explanation":
                    "Companies that applied human-centered design principles saw an average 42% increase in user satisfaction scores. This translated directly to reduced support calls, fewer returns, and increased brand loyalty - proving that good design is good business.",
                "type": "estimate-percentage",
              },
              {
                "entity-type": "outro",
                "id": "design-conclusion",
                "title": "Your New Burden",
                "text-segments": [
                  "You can't unsee what you've learned.",
                  "Every bad door will now annoy you.",
                  "Every confusing interface will frustrate you.",
                  "This knowledge is both a gift and a curse.",
                  "Use it to make the world slightly less stupid.",
                ],
              },
              {
                "entity-type": "design-examples-showcase",
                "id": "design-examples",
                "title": "Good vs Bad Design Examples",
              },
            ],
          },
        ],
      },
    ],
  };

  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      // Try to load from actual JSON file first
      if (cachedData == null) {
        final String jsonString = await rootBundle.loadString(
          'assets/data/course_data.json',
        );
        cachedData = json.decode(jsonString);
      }

      final List<dynamic> courses = cachedData!['courses'] ?? [];
      return List<Map<String, dynamic>>.from(courses);
    } on Exception {
      // Fallback to mock data if JSON file loading fails
      final List<dynamic> courses = mockCourseData['courses'] ?? [];
      return List<Map<String, dynamic>>.from(courses);
    }
  }

  static Future<Map<String, dynamic>?> getCourseById(
    String courseId,
  ) async {
    final List<Map<String, dynamic>> courses = await getCourses();
    final List<Map<String, dynamic>> matchingCourses = courses
        .where((course) => course['id'] == courseId)
        .toList();

    return matchingCourses.isEmpty ? null : matchingCourses.first;
  }
}
