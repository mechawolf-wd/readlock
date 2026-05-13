// Maps raw JSON content items (from the course's `content` array) to their
// CC widget counterparts. Each entity-type string routes to a thin wrapper
// that extracts the typed model from the JSON and hands it to the widget.
// Entity types are produced by the lockie PackageTextParser.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/course_screens/widgets/reading/CCTextContent.dart';
import 'package:readlock/course_screens/widgets/reading/CCReflect.dart';
import 'package:readlock/course_screens/widgets/reading/CCQuote.dart';
import 'package:readlock/course_screens/widgets/interaction/CCTrueFalseQuestion.dart';
import 'package:readlock/course_screens/widgets/interaction/CCEstimate.dart';
import 'package:readlock/course_screens/widgets/interaction/CCQuestion.dart';
import 'package:readlock/course_screens/widgets/interaction/CCPause.dart';

class CCJSONContentFactory {
  static Widget createContentWidget(JSONMap contentData) {
    final String entityType = contentData['entity-type'] ?? '';

    switch (entityType) {
      case 'text':
        {
          return JsonTextWidget(contentData: contentData);
        }

      case 'question':
        {
          return JsonQuestionWidget(contentData: contentData);
        }

      case 'true-false-question':
        {
          return JsonTrueFalseQuestionWidget(contentData: contentData);
        }

      case 'estimate':
        {
          return JsonEstimateWidget(contentData: contentData);
        }

      case 'reflect':
        {
          return JsonReflectWidget(contentData: contentData);
        }

      case 'quote':
        {
          return JsonQuoteWidget(contentData: contentData);
        }

      case 'pause':
        {
          return JsonPauseWidget(contentData: contentData);
        }

      default:
        {
          return UnknownContentWidget(entityType: entityType);
        }
    }
  }
}

// Fallback widget rendered when the entity-type string is unrecognised.
// Surfaces the unknown type name so content authors can catch typos
// during development without a silent blank page.
class UnknownContentWidget extends StatelessWidget {
  final String entityType;

  const UnknownContentWidget({super.key, required this.entityType});

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        RLTypography.bodyMedium(
          '${RLUIStrings.UNKNOWN_CONTENT_TYPE_MESSAGE}$entityType',
          textAlign: TextAlign.center,
        ),
      ],
      mainAxisAlignment: 'center',
      crossAxisAlignment: 'center',
    );
  }
}

// * Wrapper widgets that convert JSON data to the expected format

// Text content wrapper
class JsonTextWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonTextWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final textContent = createTextSwipeModel();

    return CCTextContent(content: textContent);
  }

  TextSwipe createTextSwipeModel() {
    final List<String> textSegments = List<String>.from(contentData['text-segments'] ?? []);

    return TextSwipe(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      textSegments: textSegments,
      text: contentData['text'],
    );
  }
}

// Reflect content wrapper
class JsonReflectWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonReflectWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final reflectionContent = createReflectSwipeModel();

    return CCReflect(content: reflectionContent);
  }

  ReflectSwipe createReflectSwipeModel() {
    final List<String> thinkingPoints = List<String>.from(contentData['thinking-points'] ?? []);

    return ReflectSwipe(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      prompt: contentData['prompt'] ?? '',
      thinkingPoints: thinkingPoints,
    );
  }
}

// Quote content wrapper
class JsonQuoteWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonQuoteWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final quoteContent = createQuoteSwipeModel();

    return CCQuote(content: quoteContent);
  }

  QuoteSwipe createQuoteSwipeModel() {
    return QuoteSwipe(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      quote: contentData['quote'] ?? '',
      author: contentData['author'] ?? '',
    );
  }
}

// * Question wrapper widgets

// Shared helper for parsing question options from JSON.
// Cloud Function responses return nested maps as Map<Object?, Object?>,
// so each option must be deep-cast to Map<String, dynamic>.
List<QuestionOption> parseQuestionOptions(JSONMap contentData) {
  final List<dynamic> rawOptions = contentData['options'] as List<dynamic>? ?? [];

  return rawOptions
      .map(
        (raw) {
          final JSONMap option = JSONMap.from(raw as Map);

          return QuestionOption(
            text: option['text'] ?? '',
            hint: option['hint'],
            consequenceMessage: option['consequence-message'],
          );
        },
      )
      .toList();
}

// Question wrapper (single-choice)
class JsonQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> indices = List<int>.from(contentData['correct-answer-indices'] ?? []);
    final bool hasCorrectAnswerIndex = indices.isNotEmpty;
    final int correctAnswerIndex = hasCorrectAnswerIndex ? indices.first : -1;

    final QuestionSwipe content = QuestionSwipe(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
    );

    return CCQuestion(content: content, onAnswerSelected: (int index, bool isCorrect) {});
  }
}

// True/False question wrapper
class JsonTrueFalseQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonTrueFalseQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> indices = List<int>.from(contentData['correct-answer-indices'] ?? []);
    final bool hasCorrectAnswerIndex = indices.isNotEmpty;
    final int correctAnswerIndex = hasCorrectAnswerIndex ? indices.first : -1;

    final TrueFalseSwipe content = TrueFalseSwipe(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
    );

    return CCTrueFalseQuestion(
      content: content,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Estimate wrapper
class JsonEstimateWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonEstimateWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final int correctPercentage = getCorrectPercentage();

    final estimateContent = EstimateSwipe(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      correctPercentage: correctPercentage,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      closeThreshold: contentData['close-threshold'] ?? 10,
    );

    return CCEstimate(
      content: estimateContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }

  int getCorrectPercentage() {
    final List<dynamic>? indices = contentData['correct-answer-indices'] as List<dynamic>?;
    final bool hasValidIndices = indices != null && indices.isNotEmpty;

    if (hasValidIndices) {
      return indices[0] as int;
    }

    return 50;
  }
}

// Pause wrapper (emotional slide)
class JsonPauseWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonPauseWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final String motivationalText = contentData['text'] ?? '';
    final String? iconName = contentData['icon'];

    return CCPause(text: motivationalText, iconName: iconName);
  }
}
