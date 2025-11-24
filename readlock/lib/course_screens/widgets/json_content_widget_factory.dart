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
  // Factory method for creating content widgets from JSON data
  static Widget createContentWidget(Map<String, dynamic> contentData) {
    final String entityType = contentData['entity-type'] ?? '';

    // Content type switching based on entity type
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

// Error widget for unknown content types
class UnknownContentWidget extends StatelessWidget {
  final String entityType;

  const UnknownContentWidget({super.key, required this.entityType});

  @override
  Widget build(BuildContext context) {
    // Error message display
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

// Intro content wrapper widget
class JsonIntroContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonIntroContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final introContent = createIntroContentModel();

    // Widget rendering
    return IntroContentWidget(content: introContent);
  }

  IntroContent createIntroContentModel() {
    final List<String> textSegments = List<String>.from(
      contentData['intro-text-segments'] ?? [],
    );

    return IntroContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      introTextSegments: textSegments,
    );
  }
}

// Text content wrapper widget
class JsonTextContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonTextContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final textContent = createTextContentModel();

    // Widget rendering
    return TextContentWidget(content: textContent);
  }

  TextContent createTextContentModel() {
    final List<String> textSegments = List<String>.from(
      contentData['text-segments'] ?? [],
    );

    return TextContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      textSegments: textSegments,
      text: contentData['text'],
    );
  }
}

// Question content wrapper widget
class JsonQuestionContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonQuestionContentWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final questionContent = createQuestionContentModel();

    // Question type-specific widget routing
    return QuestionWidget(questionContent);
  }

  QuestionContent createQuestionContentModel() {
    final List<QuestionOption> questionOptions =
        createQuestionOptions();
    final List<int> correctAnswerIndices = List<int>.from(
      contentData['correct-answer-indices'] ?? [],
    );
    final List<String>? followUpPrompts = createFollowUpPrompts();

    return QuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: questionOptions,
      correctAnswerIndices: correctAnswerIndices,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      type: parseQuestionType(contentData['type']),
      scenarioContext: contentData['scenarioContext'],
      followUpPrompts: followUpPrompts,
    );
  }

  List<QuestionOption> createQuestionOptions() {
    final List<Map<String, dynamic>> optionsData =
        List<Map<String, dynamic>>.from(contentData['options'] ?? []);

    return optionsData
        .map(
          (option) => QuestionOption(
            text: option['text'] ?? '',
            emoji: option['emoji'],
            hint: option['hint'],
          ),
        )
        .toList();
  }

  List<String>? createFollowUpPrompts() {
    return contentData['followUpPrompts'] != null
        ? List<String>.from(contentData['followUpPrompts'])
        : null;
  }

  Widget QuestionWidget(QuestionContent questionContent) {
    // Default empty callback for widgets that require it
    void onAnswerSelected(int index, bool isCorrect) {}
    switch (questionContent.type) {
      case QuestionType.trueOrFalse:
        {
          return TrueFalseQuestionWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelected,
          );
        }

      case QuestionType.fillGap:
        {
          return FillGapQuestionWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelected,
          );
        }

      case QuestionType.incorrectStatement:
        {
          return IncorrectStatementWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelected,
          );
        }

      default:
        {
          return QuestionContentWidget(
            content: questionContent,
            onAnswerSelected: onAnswerSelected,
          );
        }
    }
  }

  QuestionType parseQuestionType(String? type) {
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

// Outro content wrapper widget
class JsonOutroContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonOutroContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final outroContent = createOutroContentModel();

    // Widget rendering
    return OutroContentWidget(content: outroContent);
  }

  OutroContent createOutroContentModel() {
    final List<String> textSegments = List<String>.from(
      contentData['text-segments'] ?? [],
    );

    return OutroContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      outroTextSegments: textSegments,
    );
  }
}

// Design examples showcase wrapper widget
class JsonDesignExamplesShowcaseWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonDesignExamplesShowcaseWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    // Static design examples showcase
    return const DesignExamplesShowcase();
  }
}

// Reflection content wrapper widget
class JsonReflectionContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonReflectionContentWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final reflectionContent = createReflectionContentModel();

    // Widget rendering
    return ReflectionContentWidget(content: reflectionContent);
  }

  ReflectionContent createReflectionContentModel() {
    final List<String> thinkingPoints = List<String>.from(
      contentData['thinking-points'] ?? [],
    );

    return ReflectionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      prompt: contentData['prompt'] ?? '',
      thinkingPoints: thinkingPoints,
      emoji: contentData['emoji'],
    );
  }
}

// Quote content wrapper widget
class JsonQuoteContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonQuoteContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final quoteContent = createQuoteContentModel();

    // Widget rendering
    return QuoteContentWidget(content: quoteContent);
  }

  QuoteContent createQuoteContentModel() {
    return QuoteContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      quote: contentData['quote'] ?? '',
      author: contentData['author'] ?? '',
    );
  }
}

// Estimate percentage content wrapper widget
class JsonEstimatePercentageWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonEstimatePercentageWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final estimateContent = createEstimatePercentageContentModel();

    // Widget rendering with empty callback
    return EstimatePercentageWidget(
      content: estimateContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }

  EstimatePercentageContent createEstimatePercentageContentModel() {
    return EstimatePercentageContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      correctPercentage: contentData['correct-percentage'] ?? 50,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      closeThreshold: contentData['close-threshold'] ?? 10,
    );
  }
}
