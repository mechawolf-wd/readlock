// Factory class for creating course content widgets from JSON data
// Provides wrapper widgets that convert JSON data to proper model objects

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/course_screens/widgets/reading/CCIntro.dart';
import 'package:readlock/course_screens/widgets/reading/CCTextContent.dart';
import 'package:readlock/course_screens/widgets/reading/CCOutro.dart';
import 'package:readlock/course_screens/widgets/reading/CCDesignExamplesShowcase.dart';
import 'package:readlock/course_screens/widgets/reading/CCReflection.dart';
import 'package:readlock/course_screens/widgets/reading/CCQuote.dart';
import 'package:readlock/course_screens/widgets/reading/CCSkillCheck.dart';
import 'package:readlock/course_screens/widgets/interaction/CCTrueFalseQuestion.dart';
import 'package:readlock/course_screens/widgets/interaction/CCFillGapQuestion.dart';
import 'package:readlock/course_screens/widgets/interaction/CCIncorrectStatement.dart';
import 'package:readlock/course_screens/widgets/interaction/CCEstimatePercentage.dart';
import 'package:readlock/course_screens/widgets/interaction/CCMultipleChoice.dart';
import 'package:readlock/course_screens/widgets/interaction/CCSingleChoiceQuestion.dart';
import 'package:readlock/course_screens/widgets/interaction/CCReflectionQuestion.dart';
import 'package:readlock/course_screens/widgets/interaction/CCEmotionalSlide.dart';

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
  static Widget createContentWidget(
    Map<String, dynamic> contentData, {
    VoidCallback? onLessonComplete,
  }) {
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

      case 'multiple-choice-question':
        {
          return JsonMultipleChoiceQuestionWidget(contentData: contentData);
        }

      case 'single-choice-question':
        {
          return JsonSingleChoiceQuestionWidget(contentData: contentData);
        }

      case 'true-false-question':
        {
          return JsonTrueFalseQuestionWidget(contentData: contentData);
        }

      case 'fill-gap-question':
        {
          return JsonFillGapQuestionWidget(contentData: contentData);
        }

      case 'incorrect-statement-question':
        {
          return JsonIncorrectStatementQuestionWidget(contentData: contentData);
        }

      case 'reflection-question':
        {
          return JsonReflectionQuestionWidget(contentData: contentData);
        }

      case 'estimate-percentage-question':
        {
          return JsonEstimatePercentageQuestionWidget(contentData: contentData);
        }

      case 'outro':
        {
          return JsonOutroContentWidget(
            contentData: contentData,
            onLessonComplete: onLessonComplete,
          );
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

      case 'skill-check':
        {
          return const CCSkillCheck();
        }

      case 'emotional-slide':
        {
          return JsonEmotionalSlideWidget(contentData: contentData);
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
        RLTypography.text(
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
    return CCIntro(content: introContent);
  }

  IntroContent createIntroContentModel() {
    final List<String> textSegments = List<String>.from(
      contentData['text-segments'] ?? [],
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
    return CCTextContent(content: textContent);
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


// Outro content wrapper widget
class JsonOutroContentWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;
  final VoidCallback? onLessonComplete;

  const JsonOutroContentWidget({
    super.key, 
    required this.contentData,
    this.onLessonComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final outroContent = createOutroContentModel();

    // Widget rendering
    return CCOutro(
      content: outroContent,
      onLessonComplete: onLessonComplete,
    );
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
    return const CCDesignExamplesShowcase();
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
    return CCReflection(content: reflectionContent);
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
    return CCQuote(content: quoteContent);
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

// Question wrapper widgets for specific question types

// Multiple choice question wrapper widget
class JsonMultipleChoiceQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonMultipleChoiceQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final questionContent = createQuestionContentModel(QuestionType.multipleChoice);
    return CCMultipleChoice(
      content: questionContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }

  QuestionContent createQuestionContentModel(QuestionType type) {
    final List<QuestionOption> questionOptions = createQuestionOptions();
    final List<int> correctAnswerIndices = List<int>.from(
      contentData['correct-answer-indices'] ?? [],
    );

    return QuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: questionOptions,
      correctAnswerIndices: correctAnswerIndices,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      type: type,
      scenarioContext: contentData['scenarioContext'],
      followUpPrompts: createFollowUpPrompts(),
    );
  }

  List<QuestionOption> createQuestionOptions() {
    final List<Map<String, dynamic>> optionsData = 
        List<Map<String, dynamic>>.from(contentData['options'] ?? []);
    
    return optionsData.map((option) => QuestionOption(
      text: option['text'] ?? '',
      hint: option['hint'],
      consequenceMessage: option['consequence-message'],
    )).toList();
  }

  List<String>? createFollowUpPrompts() {
    return contentData['followUpPrompts'] != null
        ? List<String>.from(contentData['followUpPrompts'])
        : null;
  }
}

// Single choice question wrapper widget
class JsonSingleChoiceQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonSingleChoiceQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final questionContent = JsonMultipleChoiceQuestionWidget(contentData: contentData)
        .createQuestionContentModel(QuestionType.singleChoice);
    return CCSingleChoice(
      content: questionContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// True/False question wrapper widget
class JsonTrueFalseQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonTrueFalseQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final questionContent = JsonMultipleChoiceQuestionWidget(contentData: contentData)
        .createQuestionContentModel(QuestionType.trueOrFalse);
    return CCTrueFalseQuestion(
      content: questionContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Fill gap question wrapper widget  
class JsonFillGapQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonFillGapQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final questionContent = JsonMultipleChoiceQuestionWidget(contentData: contentData)
        .createQuestionContentModel(QuestionType.fillGap);
    return CCFillGapQuestion(
      content: questionContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Incorrect statement question wrapper widget
class JsonIncorrectStatementQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonIncorrectStatementQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final questionContent = JsonMultipleChoiceQuestionWidget(contentData: contentData)
        .createQuestionContentModel(QuestionType.incorrectStatement);
    return CCIncorrectStatement(
      content: questionContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Reflection question wrapper widget
class JsonReflectionQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonReflectionQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final questionContent = JsonMultipleChoiceQuestionWidget(contentData: contentData)
        .createQuestionContentModel(QuestionType.reflection);
    return CCReflectionQuestion(
      content: questionContent,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Estimate percentage question wrapper widget
class JsonEstimatePercentageQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonEstimatePercentageQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final estimateContent = EstimatePercentageContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      correctPercentage: () {
        final List<dynamic>? indices = contentData['correct-answer-indices'] as List<dynamic>?;
        if (indices != null && indices.isNotEmpty) {
          return indices[0] as int;
        }
        return 50;
      }(),
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      closeThreshold: contentData['close-threshold'] ?? 10,
    );
    
    return CCEstimatePercentage(
      content: estimateContent,
      onAnswerSelected: (int index, bool isCorrect) {},
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
    return CCEstimatePercentage(
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

// Emotional slide wrapper widget
class JsonEmotionalSlideWidget extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const JsonEmotionalSlideWidget({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    final String motivationalText = contentData['text'] ?? '';
    final String? iconName = contentData['icon'];

    return CCEmotionalSlide(
      text: motivationalText,
      iconName: iconName,
    );
  }
}
