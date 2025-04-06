import 'package:flutter/material.dart';
import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/common/enum.dart';
import 'package:qtism_math/services/problem_generator.dart';
import 'package:qtism_math/services/emotion_manager.dart';
import 'package:qtism_math/services/speech_text.dart';
import 'package:qtism_math/services/math_expression_processor.dart';
import 'package:qtism_math/services/text_to_speech_service.dart';
import 'package:qtism_math/services/emotion_detector.dart';
import 'package:qtism_math/services/voice_input_parser.dart';
import 'package:qtism_math/utils/string_formatter.dart';

class QTController {
  // State variables
  String transcribedText = "";
  String resultText = "";
  bool isListening = false;
  String currentEmotion = "neutral";
  String previousEmotion = "neutral";
  bool isTransitioning = false;
  bool isCorrectAnswer = false;
  bool isDefaultBubbleStyle = true;
  ProblemType lastButtonClicked = ProblemType.none;
  String generatedProblem = "";
  bool? expectedTruthValue;

  // Services
  final TextToSpeechService _ttsService = TextToSpeechService();
  final EmotionManager emotionManager = EmotionManager();

  // State change notifier
  final Function(VoidCallback) setState;

  QTController(this.setState);

  // Forwards the calculation to the math service
  int calculateCorrectAnswer(String operation) {
    return MathExpressionProcessor.calculateResult(operation);
  }

  // Uses the TTS service to speak text
  Future<void> speakResult(String text) async {
    await _ttsService.speak(text);
  }

  void clearTranscription() {
    setState(() {
      transcribedText = "";
    });
  }

  void generateCalculationProblem() {
    final problemData = ProblemGenerator.generateCalculationProblem();
    final problem = problemData['problem'];

    _updateProblemState(
      ProblemType.calculation,
      problem,
      StringFormatter.format(AppStrings.calculateResult, [problem]),
      null // No truth value for calculation problems
    );

    speakResult(StringFormatter.format(AppStrings.calculateResultSpoken, [problem]));
    resetEmotion();
  }

  void generateTrueOrFalseProblem() {
    final problemData = ProblemGenerator.generateTrueOrFalseProblem();
    final problem = problemData['problem'];
    final isTrue = problemData['isTrue'];

    _updateProblemState(
      ProblemType.trueOrFalse,
      problem,
      StringFormatter.format(AppStrings.trueOrFalseQuestion, [problem]),
      isTrue
    );

    speakResult(StringFormatter.format(AppStrings.trueOrFalseQuestion, [problem]));
    resetEmotion();
  }
  
  // Helper method to update problem-related state
  void _updateProblemState(ProblemType type, String problem, String displayText, bool? truthValue) {
    setState(() {
      lastButtonClicked = type;
      generatedProblem = problem;
      resultText = displayText;
      expectedTruthValue = truthValue;
      isDefaultBubbleStyle = true;
    });
  }

  void resetEmotion() {
    if (emotionManager.emotion != "neutral") {
      setState(() {
        emotionManager.setEmotion("neutral");
        isTransitioning = true;
      });
    }
  }

  Future<void> handleVoiceInput(AnimationController animationController) async {
    resetEmotion();
    _resetAnimation(animationController);

    await SpeechText.toggleRecording(
      _updateTranscription,
      _processVoiceResult,
      clearTranscription,
      _updateListeningState,
    );
  }
  
  // Helper methods to handle callbacks
  void _updateTranscription(String transcription) {
    setState(() {
      transcribedText = transcription;
    });
  }
  
  void _processVoiceResult(String expression, String result) {
    if (lastButtonClicked == ProblemType.calculation) {
      handleCalculationVoiceSubmission(transcribedText);
    } else if (lastButtonClicked == ProblemType.trueOrFalse) {
      handleTrueOrFalseVoiceSubmission(transcribedText);
    } else {
      showResult(result, null);
    }
  }
  
  void _updateListeningState(bool value) {
    setState(() {
      isListening = value;
    });
  }
  
  void _resetAnimation(AnimationController animationController) {
    animationController.reset();
    animationController.forward();
  }

  void handleSubmitted(String text, AnimationController animationController) {
    if (text.isEmpty) return;

    setState(() {
      transcribedText = text;
    });

    switch (lastButtonClicked) {
      case ProblemType.calculation:
        handleCalculationSubmission(text, animationController);
        break;
      case ProblemType.trueOrFalse:
        handleTrueOrFalseSubmission(text, animationController);
        break;
      default:
        _processGeneralMathExpression(text, animationController);
    }
  }
  
  void _processGeneralMathExpression(String text, AnimationController animationController) {
    String mathExpression = SpeechText.convertToMathExpression(text);
    String result = SpeechText.evaluateMathExpression(mathExpression);
    showResult(result, animationController);
  }

  void handleCalculationSubmission(String text, AnimationController animationController) {
    try {
      int userAnswer = int.parse(text);
      _checkCalculationAnswer(userAnswer, animationController);
    } catch (e) {
      showResult(AppStrings.invalidNumberInput, animationController);
    }
  }
  
  void _checkCalculationAnswer(int userAnswer, AnimationController? animationController) {
    int correctAnswer = calculateCorrectAnswer(generatedProblem);
    String resultMessage;
    
    if (userAnswer == correctAnswer) {
      resultMessage = StringFormatter.format(
        AppStrings.correctCalculationAnswer, 
        [generatedProblem, correctAnswer]
      );
    } else {
      resultMessage = StringFormatter.format(
        AppStrings.incorrectCalculationAnswer, 
        [generatedProblem, correctAnswer]
      );
    }
    
    showResult(resultMessage, animationController);
    _resetProblemType();
  }
  
  void _resetProblemType() {
    setState(() {
      lastButtonClicked = ProblemType.none;
    });
  }

  void handleTrueOrFalseSubmission(String text, AnimationController animationController) {
    text = text.toLowerCase().trim();
    bool? userAnswer;

    if (text == AppStrings.trueValue || text == 'true') {
      userAnswer = true;
    } else if (text == AppStrings.falseValue || text == 'false') {
      userAnswer = false;
    }

    _processTrueFalseAnswer(userAnswer, animationController);
  }
  
  void _processTrueFalseAnswer(bool? userAnswer, AnimationController? animationController) {
    if (userAnswer == null) {
      showResult(AppStrings.invalidTrueFalseInput, animationController);
      return;
    }
    
    String valueAsText = userAnswer ? AppStrings.trueValue : AppStrings.falseValue;
    String expectedValueAsText = expectedTruthValue! ? AppStrings.trueValue : AppStrings.falseValue;
    String resultMessage;
    
    if (userAnswer == expectedTruthValue) {
      resultMessage = StringFormatter.format(
        AppStrings.correctTrueFalseAnswer, 
        [generatedProblem, valueAsText]
      );
    } else {
      resultMessage = StringFormatter.format(
        AppStrings.incorrectTrueFalseAnswer, 
        [generatedProblem, expectedValueAsText]
      );
    }
    
    showResult(resultMessage, animationController);
    _resetProblemType();
  }
  
  void handleCalculationVoiceSubmission(String text) {
    int? userAnswer = MathExpressionProcessor.extractNumberFromVoiceText(text);
    
    if (userAnswer != null) {
      _checkCalculationAnswer(userAnswer, null);
    } else {
      showResult(AppStrings.invalidVoiceNumberInput, null);
    }
  }

  void handleTrueOrFalseVoiceSubmission(String text) {
    bool? userAnswer = VoiceInputParser.parseTrueFalseResponse(
      text,
      additionalTrueKeywords: ['oui', 'yes', 'correct'],
      additionalFalseKeywords: ['non', 'no', 'incorrect']
    );
    
    _processTrueFalseAnswer(userAnswer, null);
  }

  void showResult(String result, AnimationController? animationController) {
    final emotionResult = EmotionDetector.detectFromText(result);
    String newEmotion = emotionResult.emotion;
    bool isCorrect = emotionResult.isCorrect;

    _updateEmotionAndText(newEmotion, result, isCorrect, animationController);
    speakResult(result);
  }
  
  void _updateEmotionAndText(String newEmotion, String result, bool isCorrect, AnimationController? animationController) {
    if (_needsEmotionTransition(newEmotion)) {
      _startEmotionTransition(newEmotion, result, isCorrect, animationController);
    } else {
      _updateEmotionDirectly(newEmotion, result, isCorrect);
    }
  }
  
  bool _needsEmotionTransition(String newEmotion) {
    return newEmotion != currentEmotion && currentEmotion != "neutral";
  }
  
  void _startEmotionTransition(String newEmotion, String result, bool isCorrect, AnimationController? animationController) {
    setState(() {
      previousEmotion = currentEmotion;
      currentEmotion = newEmotion;
      isTransitioning = true;
      resultText = result;
      isCorrectAnswer = isCorrect;
      isDefaultBubbleStyle = false;
    });

    if (animationController != null) {
      animationController.reset();
      animationController.forward();
    }
  }
  
  void _updateEmotionDirectly(String newEmotion, String result, bool isCorrect) {
    setState(() {
      currentEmotion = newEmotion;
      resultText = result;
      isCorrectAnswer = isCorrect;
      isDefaultBubbleStyle = false;
    });
  }
}