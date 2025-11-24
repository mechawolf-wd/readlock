// Factory class for creating course content widgets from JSON data
// Provides wrapper widgets that convert JSON data to proper model objects

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/typography.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/course_screens/widgets/intro_content_widget.dart';
import 'package:readlock/course_screens/widgets/text_content_widget.dart';
import 'package:readlock/course_screens/widgets/question_content_widget.dart';
import 'package:readlock/course_screens/widgets/outro_content_widget.dart';
import 'package:readlock/course_screens/widgets/design_examples_showcase.dart';
import 'package:readlock/course_screens/widgets/reflection_content_widget.dart';
import 'package:readlock/course_screens/widgets/quote_content_widget.dart';
import 'package:readlock/course_screens/widgets/true_false_question_widget.dart';
import 'package:readlock/course_screens/widgets/fill_gap_question_widget.dart';
import 'package:readlock/course_screens/widgets/incorrect_statement_widget.dart';
import 'package:readlock/course_screens/widgets/estimate_percentage_widget.dart';

const String UNKNOWN_CONTENT_TYPE_MESSAGE = 'Unknown content type: ';

// Question type constants
const String QUESTION_TYPE_MULTIPLE_CHOICE = 'multiple-choice';
const String QUESTION_TYPE_TRUE_OR_FALSE = 'true-or-false';
const String QUESTION_TYPE_SCENARIO = 'scenario';
const String QUESTION_TYPE_REFLECTION = 'reflection';
const String QUESTION_TYPE_FILL_GAP = 'fill-gap';
const String QUESTION_TYPE_INCORRECT_STATEMENT = 'incorrect-statement';
const String QUESTION_TYPE_ESTIMATE_PERCENTAGE = 'estimate-percentage';

class JsonContentWidgetFactory {
  static Widget createContentWidget(Map<String, dynamic> contentData) {
    final String entityType = contentData['entity-type'] ?? '';

    switch (entityType) {
      case 'intro':
        {
          return JsonIntroContentWidget(contentData: contentData);
        }
      case 'text':
        {
          return JsonTextContentWidget(contentData: contentData);
        }
      case 'question':
        {
          return JsonQuestionContentWidget(contentData: contentData);
        }
      case 'outro':
        {
          return JsonOutroContentWidget(contentData: contentData);
        }
      case 'design-examples-showcase':
        {
          return JsonDesignExamplesShowcaseWidget(
            contentData: contentData,
          );
        }
      case 'reflection':
        {
          return JsonReflectionContentWidget(contentData: contentData);
        }
      case 'quote':
        {
          return JsonQuoteContentWidget(contentData: contentData);
        }
      case 'estimate-percentage':
        {
          return JsonEstimatePercentageWidget(contentData: contentData);
        }
      default:
        {
          return UnknownContentWidget(entityType: entityType);
        }
    }
  }
}

class UnknownContentWidget extends StatelessWidget {
  final String entityType;

  const UnknownContentWidget({super.key, required this.entityType});

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        Typography.text(
          '$UNKNOWN_CONTENT_TYPE_MESSAGE$entityType',
          textAlign: TextAlign.center,
        ),
      ],
      mainAxisAlignment: 'center',
      crossAxisAlignment: 'center',
    );
  }
}

// Wrapper widgets that convert JSON data to the expected format
class JsonIntroContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonIntroContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final introContent = IntroContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      introTextSegments: List<String>.from(
        contentData['intro-text-segments'] ?? [],
      ),
    );

    return IntroContentWidget(content: introContent);
  }
}

class JsonTextContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonTextContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final textContent = TextContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      textSegments: List<String>.from(
        contentData['text-segments'] ?? [],
      ),
      text: contentData['text'],
    );

    return TextContentWidget(content: textContent);
  }
}

class JsonQuestionContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonQuestionContentWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> optionsData =
        List<Map<String, dynamic>>.from(contentData['options'] ?? []);

    final questionContent = QuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: optionsData
          .map(
            (option) => QuestionOption(
              text: option['text'] ?? '',
              emoji: option['emoji'],
              hint: option['hint'],
            ),
          )
          .toList(),
      correctAnswerIndices: List<int>.from(
        contentData['correct-answer-indices'] ?? [],
      ),
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      type: _parseQuestionType(contentData['type']),
      scenarioContext: contentData['scenarioContext'],
      followUpPrompts: contentData['followUpPrompts'] != null
          ? List<String>.from(contentData['followUpPrompts'])
          : null,
    );

    void onAnswerSelectedCallback(int index, bool isCorrect) {}

    switch (questionContent.type) {
      case QuestionType.trueOrFalse:
        {
          return TrueFalseQuestionWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelectedCallback,
          );
        }
      case QuestionType.fillGap:
        {
          return FillGapQuestionWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelectedCallback,
          );
        }
      case QuestionType.incorrectStatement:
        {
          return IncorrectStatementWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelectedCallback,
          );
        }
      default:
        {
          return QuestionContentWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelectedCallback,
          );
        }
    }
  }

  QuestionType _parseQuestionType(String? type) {
    switch (type) {
      case QUESTION_TYPE_MULTIPLE_CHOICE:
        {
          return QuestionType.multipleChoice;
        }
      case QUESTION_TYPE_TRUE_OR_FALSE:
        {
          return QuestionType.trueOrFalse;
        }
      case QUESTION_TYPE_SCENARIO:
        {
          return QuestionType.scenario;
        }
      case QUESTION_TYPE_REFLECTION:
        {
          return QuestionType.reflection;
        }
      case QUESTION_TYPE_FILL_GAP:
        {
          return QuestionType.fillGap;
        }
      case QUESTION_TYPE_INCORRECT_STATEMENT:
        {
          return QuestionType.incorrectStatement;
        }
      case QUESTION_TYPE_ESTIMATE_PERCENTAGE:
        {
          return QuestionType.estimatePercentage;
        }
      default:
        {
          return QuestionType.multipleChoice;
        }
    }
  }
}

class JsonOutroContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonOutroContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final outroContent = OutroContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      outroTextSegments: List<String>.from(
        contentData['text-segments'] ?? [],
      ),
    );

    return OutroContentWidget(content: outroContent);
  }
}

class JsonDesignExamplesShowcaseWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonDesignExamplesShowcaseWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    return const DesignExamplesShowcase();
  }
}

class JsonReflectionContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonReflectionContentWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    final reflectionContent = ReflectionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      prompt: contentData['prompt'] ?? '',
      thinkingPoints: List<String>.from(
        contentData['thinking-points'] ?? [],
      ),
      emoji: contentData['emoji'],
    );

    return ReflectionContentWidget(content: reflectionContent);
  }
}

class JsonQuoteContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonQuoteContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final quoteContent = QuoteContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      quote: contentData['quote'] ?? '',
      author: contentData['author'] ?? '',
    );

    return QuoteContentWidget(content: quoteContent);
  }
}

class JsonEstimatePercentageWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonEstimatePercentageWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    final estimateContent = EstimatePercentageContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      correctPercentage: contentData['correct-percentage'] ?? 50,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      closeThreshold: contentData['close-threshold'] ?? 10,
    );

    void onAnswerSelectedCallback(int index, bool isCorrect) {}

    return EstimatePercentageWidget(
      content: estimateContent,
      onAnswerSelected: onAnswerSelectedCallback,
    );
  }
}
