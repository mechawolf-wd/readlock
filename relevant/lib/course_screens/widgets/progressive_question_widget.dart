// Progressive Question Widget
//
// This file contains the ProgressiveQuestionWidget that animates question reveal
// first showing the question text word by word, then revealing answer options
// with click-to-reveal functionality for engaging quiz interactions.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/course_screens/models/course_model.dart';

class ProgressiveQuestionWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const ProgressiveQuestionWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<ProgressiveQuestionWidget> createState() =>
      ProgressiveQuestionWidgetState();
}

class ProgressiveQuestionWidgetState extends State<ProgressiveQuestionWidget>
    with TickerProviderStateMixin {
  late List<String> questionSentences;
  int currentQuestionSentenceIndex = 0;
  bool isRevealingCurrentQuestionSentence = false;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  // Word-by-word reveal within current question sentence
  late List<String> currentQuestionSentenceWords;
  int currentWordInQuestionSentence = 0;
  String currentQuestionSentenceRevealedText = '';

  // Answer options reveal state
  bool showAnswers = false;
  int? selectedAnswerIndex;
  List<int> selectedAnswerIndices = [];
  bool hasAnswered = false;

  /// @Method: Initialize widget state and prepare question sentences for reveal
  @override
  void initState() {
    super.initState();

    questionSentences = splitIntoSentences(widget.content.question);

    final bool hasQuestionSentences = questionSentences.isNotEmpty;
    if (hasQuestionSentences) {
      initializeCurrentQuestionSentence();
    }

    animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    // Always start revealing the first question sentence immediately
    if (hasQuestionSentences) {
      startCurrentQuestionSentenceReveal();
    }
  }

  /// @Method: Split text into sentences while preserving structure
  List<String> splitIntoSentences(String text) {
    final List<String> rawSentences = text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .map((sentence) => sentence.trim())
        .toList();

    return rawSentences;
  }

  /// @Method: Initialize the current question sentence for word-by-word reveal
  void initializeCurrentQuestionSentence() {
    final bool hasCurrentQuestionSentence =
        currentQuestionSentenceIndex < questionSentences.length;
    if (hasCurrentQuestionSentence) {
      currentQuestionSentenceWords = questionSentences[currentQuestionSentenceIndex].split(
        RegExp(r'\s+'),
      );
      currentWordInQuestionSentence = 0;
      currentQuestionSentenceRevealedText = '';
    }
  }

  /// @Method: Start revealing the current question sentence word by word
  void startCurrentQuestionSentenceReveal() async {
    final bool canReveal =
        !isRevealingCurrentQuestionSentence && currentQuestionSentenceWords.isNotEmpty;
    if (!canReveal) {
      return;
    }

    setState(() {
      isRevealingCurrentQuestionSentence = true;
      currentQuestionSentenceRevealedText = '';
      currentWordInQuestionSentence = 0;
    });

    for (
      int wordIndex = 0;
      wordIndex < currentQuestionSentenceWords.length && mounted;
      wordIndex++
    ) {
      final bool shouldContinue = mounted && isRevealingCurrentQuestionSentence;
      if (!shouldContinue) {
        break;
      }

      setState(() {
        currentWordInQuestionSentence = wordIndex;
        final bool isFirstWord = wordIndex == 0;
        if (isFirstWord) {
          currentQuestionSentenceRevealedText = currentQuestionSentenceWords[wordIndex];
        } else {
          currentQuestionSentenceRevealedText +=
              ' ${currentQuestionSentenceWords[wordIndex]}';
        }
      });

      // Quick delay between words (AI-like streaming)
      await Future.delayed(const Duration(milliseconds: 80));
    }

    setState(() {
      isRevealingCurrentQuestionSentence = false;
    });
  }

  /// @Method: Move to next question sentence and start revealing it
  void revealNextQuestionSentence() {
    final bool hasNextQuestionSentence =
        currentQuestionSentenceIndex < questionSentences.length - 1;
    if (hasNextQuestionSentence) {
      setState(() {
        currentQuestionSentenceIndex++;
      });

      initializeCurrentQuestionSentence();
      startCurrentQuestionSentenceReveal();
    } else {
      // All question sentences revealed, show answers
      setState(() {
        showAnswers = true;
      });
    }
  }

  /// @Method: Clean up animation controller
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitle(),

          const SizedBox(height: AppTheme.spacingXXL),

          ScenarioContextSection(),

          const SizedBox(height: AppTheme.spacingXL),

          ProgressiveQuestionText(),

          const SizedBox(height: AppTheme.spacingXXXL),

          AnswersSection(),

          const SizedBox(height: AppTheme.spacingXL),

          ExplanationSection(),

          const SizedBox(height: AppTheme.spacingXL),

          FollowUpPromptsSection(),
        ],
      ),
    );
  }

  /// @Method: Handle tap/click to reveal next question sentence or answers
  void handleTap() {
    final bool canRevealNextQuestionSentence = !isRevealingCurrentQuestionSentence && 
        currentQuestionSentenceIndex < questionSentences.length - 1;
    final bool canShowAnswers = !isRevealingCurrentQuestionSentence && 
        currentQuestionSentenceIndex == questionSentences.length - 1 && 
        !showAnswers;
    
    if (canRevealNextQuestionSentence) {
      revealNextQuestionSentence();
    } else if (canShowAnswers) {
      setState(() {
        showAnswers = true;
      });
    }
  }

  /// @Widget: Large heading displaying the quiz or question title
  Widget QuestionTitle() {
    return Text(widget.content.title, style: AppTheme.headingLarge);
  }

  /// @Widget: Background context or scenario setup for the question
  Widget ScenarioContextSection() {
    final bool hasScenarioContext = widget.content.scenarioContext != null;
    if (!hasScenarioContext) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: ContentBackgroundStyles.scenarioContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcons.GetColoredIcon(
                AppIcons.theater,
                AppTheme.purple600,
              ),

              const SizedBox(width: AppTheme.spacingS),

              Text(
                'Scenario',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            widget.content.scenarioContext ?? '',
            style: AppTheme.bodyMedium.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  /// @Widget: Progressive question text with click-to-reveal functionality
  Widget ProgressiveQuestionText() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: handleTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100.0),
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Center(
            child: RevealedQuestionText(),
          ),
        ),
      ),
    );
  }

  /// @Widget: Text content showing completed question sentences and current revealing sentence
  Widget RevealedQuestionText() {
    final List<Widget> sentenceWidgets = [];

    // Show all completed question sentences (blurred)
    for (
      int sentenceIndex = 0;
      sentenceIndex < currentQuestionSentenceIndex;
      sentenceIndex++
    ) {
      Widget sentenceWidget = Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
        child: Text(
          '${questionSentences[sentenceIndex]}.',
          style: AppTheme.headingSmall.copyWith(height: 1.6),
          textAlign: TextAlign.center,
        ),
      );

      // Apply blur to completed sentences
      sentenceWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: Opacity(opacity: 0.3, child: sentenceWidget),
      );

      sentenceWidgets.add(sentenceWidget);
    }

    // Show current question sentence being revealed word by word
    final bool hasCurrentQuestionSentence =
        currentQuestionSentenceIndex < questionSentences.length;
    if (hasCurrentQuestionSentence) {
      sentenceWidgets.add(buildCurrentQuestionSentence());
    }

    return Column(
      children: sentenceWidgets,
    );
  }

  /// @Widget: Build the current question sentence with word-by-word reveal
  Widget buildCurrentQuestionSentence() {
    final bool hasRevealedText = currentQuestionSentenceRevealedText.isNotEmpty;
    if (!hasRevealedText) {
      return const SizedBox.shrink();
    }

    final List<String> revealedWords = currentQuestionSentenceRevealedText
        .split(' ');
    final List<Widget> wordWidgets = [];

    for (
      int wordIndex = 0;
      wordIndex < revealedWords.length;
      wordIndex++
    ) {
      final Widget wordWidget = Text(
        '${revealedWords[wordIndex]} ',
        style: AppTheme.headingSmall.copyWith(height: 1.6),
      );

      wordWidgets.add(wordWidget);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Wrap(
        children: wordWidgets,
      ),
    );
  }

  /// @Widget: Answer options section that appears after question is fully revealed
  Widget AnswersSection() {
    final bool shouldShowAnswers = showAnswers;
    if (!shouldShowAnswers) {
      return const SizedBox.shrink();
    }

    return OptionsList();
  }

  /// @Widget: Vertical list of selectable answer options
  Widget OptionsList() {
    final List<Widget> optionWidgets = [];

    for (
      int optionIndex = 0;
      optionIndex < widget.content.options.length;
      optionIndex++
    ) {
      final QuestionOption option = widget.content.options[optionIndex];

      optionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Center(child: OptionButton(optionIndex, option)),
        ),
      );
    }

    return Column(children: optionWidgets);
  }

  /// @Widget: Interactive button for each answer choice with visual feedback
  Widget OptionButton(int optionIndex, QuestionOption option) {
    final bool isMultipleChoice =
        widget.content.hasMultipleCorrectAnswers;
    final bool isSelected = isMultipleChoice
        ? selectedAnswerIndices.contains(optionIndex)
        : selectedAnswerIndex == optionIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );
    final bool shouldShowFeedback = hasAnswered && isSelected;
    final QuestionOptionColors colors =
        AppTheme.getQuestionOptionColors(
          isSelected: isSelected,
          shouldShowFeedback: shouldShowFeedback,
          isCorrect: isCorrect,
        );

    return ElevatedButton(
      onPressed: hasAnswered ? null : () => selectAnswer(optionIndex),
      style:
          AppTheme.getElevatedButtonStyle(
            backgroundColor: colors.backgroundColor,
            foregroundColor: colors.textColor,
          ).copyWith(
            elevation: WidgetStateProperty.all(
              isSelected ? AppTheme.elevationLow : 0,
            ),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shouldShowFeedback)
            AppIcons.GetColoredIcon(
              isCorrect ? AppIcons.checkCircle : AppIcons.cancel,
              isCorrect ? AppTheme.green800 : AppTheme.red800,
            ),

          if (shouldShowFeedback)
            const SizedBox(width: AppTheme.spacingM),

          Text(
            option.text,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Detailed explanation shown after answering the question
  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;
    if (!shouldShowExplanation) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Text(
        widget.content.explanation,
        style: AppTheme.bodyMedium.copyWith(height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// @Widget: Additional prompts or questions shown after main answer
  Widget FollowUpPromptsSection() {
    final bool shouldShowFollowUps = hasAnswered && widget.content.followUpPrompts != null;
    if (!shouldShowFollowUps) {
      return const SizedBox.shrink();
    }

    final List<Widget> promptWidgets = [];

    for (final String prompt in widget.content.followUpPrompts ?? []) {
      promptWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: Text(
            prompt,
            style: AppTheme.bodyMedium.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(children: promptWidgets),
    );
  }

  /// @Method: Handle answer selection
  void selectAnswer(int optionIndex) {
    final bool canAnswer = !hasAnswered;
    if (!canAnswer) {
      return;
    }

    if (widget.content.hasMultipleCorrectAnswers) {
      setState(() {
        final bool isAlreadySelected = selectedAnswerIndices.contains(optionIndex);
        if (isAlreadySelected) {
          selectedAnswerIndices.remove(optionIndex);
        } else {
          selectedAnswerIndices.add(optionIndex);
        }
      });

      // Auto-submit for multiple choice questions
      final bool hasSelections = selectedAnswerIndices.isNotEmpty;
      if (hasSelections) {
        submitMultipleChoiceAnswer();
      }
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );

    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnswered = true;
    });

    widget.onAnswerSelected(optionIndex, isCorrect);
  }

  /// @Method: Submit multiple choice answer
  void submitMultipleChoiceAnswer() {
    final bool canSubmit = !hasAnswered && selectedAnswerIndices.isNotEmpty;
    if (!canSubmit) {
      return;
    }

    final Set<int> correctIndices = widget.content.correctAnswerIndices
        .toSet();
    final Set<int> selectedIndicesSet = selectedAnswerIndices.toSet();

    final bool isCorrect =
        correctIndices.difference(selectedIndicesSet).isEmpty &&
        selectedIndicesSet.difference(correctIndices).isEmpty;

    setState(() {
      hasAnswered = true;
    });

    widget.onAnswerSelected(selectedAnswerIndices.first, isCorrect);
  }
}