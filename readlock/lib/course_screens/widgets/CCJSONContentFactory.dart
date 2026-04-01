// Factory class for creating course content widgets from JSON data
// Provides wrapper widgets that convert JSON data to proper model objects

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/DartAliases.dart';
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

class CCJSONContentFactory {
  // Factory method for creating content widgets from JSON data
  static Widget createContentWidget(JSONMap contentData, {VoidCallback? onLessonComplete}) {
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
          return CCSkillCheck(
            title: contentData['title'] ?? 'Skill Check',
            subtitle: contentData['subtitle'] ?? 'Test Your Understanding',
            iconName: contentData['icon'] ?? 'check',
          );
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
        Text(
          '$RLUIStrings.UNKNOWN_CONTENT_TYPE_MESSAGE$entityType',
          style: RLTypography.bodyMediumStyle,
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
  final JSONMap contentData;

  const JsonIntroContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final introContent = createIntroContentModel();

    // Widget rendering
    return CCIntro(content: introContent);
  }

  IntroContent createIntroContentModel() {
    final List<String> textSegments = List<String>.from(contentData['text-segments'] ?? []);

    return IntroContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      introTextSegments: textSegments,
    );
  }
}

// Text content wrapper widget
class JsonTextContentWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonTextContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final textContent = createTextContentModel();

    // Widget rendering
    return CCTextContent(content: textContent);
  }

  TextContent createTextContentModel() {
    final List<String> textSegments = List<String>.from(contentData['text-segments'] ?? []);

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
  final JSONMap contentData;
  final VoidCallback? onLessonComplete;

  const JsonOutroContentWidget({super.key, required this.contentData, this.onLessonComplete});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final outroContent = createOutroContentModel();

    // Widget rendering
    return CCOutro(content: outroContent, onLessonComplete: onLessonComplete);
  }

  OutroContent createOutroContentModel() {
    final List<String> textSegments = List<String>.from(contentData['text-segments'] ?? []);

    return OutroContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      outroTextSegments: textSegments,
    );
  }
}

// Design examples showcase wrapper widget
class JsonDesignExamplesShowcaseWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonDesignExamplesShowcaseWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Static design examples showcase
    return const CCDesignExamplesShowcase();
  }
}

// Reflection content wrapper widget
class JsonReflectionContentWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonReflectionContentWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    // Data transformation from JSON to model
    final reflectionContent = createReflectionContentModel();

    // Widget rendering
    return CCReflection(content: reflectionContent);
  }

  ReflectionContent createReflectionContentModel() {
    final List<String> thinkingPoints = List<String>.from(contentData['thinking-points'] ?? []);

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
  final JSONMap contentData;

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

// * Shared helper for parsing question options from JSON

List<QuestionOption> parseQuestionOptions(JSONMap contentData) {
  final JSONList optionsData = JSONList.from(contentData['options'] ?? []);

  return optionsData
      .map(
        (option) => QuestionOption(
          text: option['text'] ?? '',
          hint: option['hint'],
          consequenceMessage: option['consequence-message'],
        ),
      )
      .toList();
}

// Multiple choice question wrapper widget
class JsonMultipleChoiceQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonMultipleChoiceQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> correctAnswerIndices = List<int>.from(
      contentData['correct-answer-indices'] ?? [],
    );

    final MultipleChoiceQuestionContent content = MultipleChoiceQuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndices: correctAnswerIndices,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
    );

    return CCMultipleChoice(content: content, onAnswerSelected: (int index, bool isCorrect) {});
  }
}

// Single choice question wrapper widget
class JsonSingleChoiceQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonSingleChoiceQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> indices = List<int>.from(contentData['correct-answer-indices'] ?? []);
    final int correctAnswerIndex = indices.isNotEmpty ? indices.first : -1;

    final SingleChoiceQuestionContent content = SingleChoiceQuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
    );

    return CCSingleChoice(content: content, onAnswerSelected: (int index, bool isCorrect) {});
  }
}

// True/False question wrapper widget
class JsonTrueFalseQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonTrueFalseQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> indices = List<int>.from(contentData['correct-answer-indices'] ?? []);
    final int correctAnswerIndex = indices.isNotEmpty ? indices.first : -1;

    final TrueFalseQuestionContent content = TrueFalseQuestionContent(
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

// Fill gap question wrapper widget
class JsonFillGapQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonFillGapQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> correctAnswerIndices = List<int>.from(
      contentData['correct-answer-indices'] ?? [],
    );

    final FillGapQuestionContent content = FillGapQuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndices: correctAnswerIndices,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
    );

    return CCFillGapQuestion(
      content: content,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Incorrect statement question wrapper widget
class JsonIncorrectStatementQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonIncorrectStatementQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> correctAnswerIndices = List<int>.from(
      contentData['correct-answer-indices'] ?? [],
    );

    final IncorrectStatementQuestionContent content = IncorrectStatementQuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndices: correctAnswerIndices,
      explanation: contentData['explanation'] ?? '',
    );

    return CCIncorrectStatement(
      content: content,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Reflection question wrapper widget
class JsonReflectionQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonReflectionQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final List<QuestionOption> options = parseQuestionOptions(contentData);
    final List<int> correctAnswerIndices = List<int>.from(
      contentData['correct-answer-indices'] ?? [],
    );

    final ReflectionQuestionContent content = ReflectionQuestionContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      options: options,
      correctAnswerIndices: correctAnswerIndices,
      explanation: contentData['explanation'] ?? '',
    );

    return CCReflectionQuestion(
      content: content,
      onAnswerSelected: (int index, bool isCorrect) {},
    );
  }
}

// Estimate percentage question wrapper widget
class JsonEstimatePercentageQuestionWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonEstimatePercentageQuestionWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final int correctPercentage = getCorrectPercentage();

    final estimateContent = EstimatePercentageContent(
      id: contentData['id'] ?? '',
      title: contentData['title'] ?? '',
      question: contentData['question'] ?? '',
      correctPercentage: correctPercentage,
      explanation: contentData['explanation'] ?? '',
      hint: contentData['hint'],
      closeThreshold: contentData['close-threshold'] ?? 10,
    );

    return CCEstimatePercentage(
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

// Estimate percentage content wrapper widget
class JsonEstimatePercentageWidget extends StatelessWidget {
  final JSONMap contentData;

  const JsonEstimatePercentageWidget({super.key, required this.contentData});

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
  final JSONMap contentData;

  const JsonEmotionalSlideWidget({super.key, required this.contentData});

  @override
  Widget build(BuildContext context) {
    final String motivationalText = contentData['text'] ?? '';
    final String? iconName = contentData['icon'];

    return CCEmotionalSlide(text: motivationalText, iconName: iconName);
  }
}
