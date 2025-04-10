import 'package:flutter/material.dart';
import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/common/enum.dart';
import 'package:qtism_math/services/text_to_speech_service.dart';
import 'package:qtism_math/services/emotion_service.dart';
import 'package:qtism_math/services/problem_service.dart';
import 'package:qtism_math/services/input_service.dart';

class QTController {
  // State variables
  String resultText = "";
  bool isCorrectAnswer = false;
  bool isDefaultBubbleStyle = true;
  String currentEmotion = "neutral";
  String previousEmotion = "neutral";
  bool isTransitioning = false;
  String transcribedText = "";
  bool isListening = false;

  // Services
  final TextToSpeechService _ttsService = TextToSpeechService();
  late final EmotionService _emotionService;
  late final ProblemService _problemService;
  late final InputService _inputService;

  // State change notifier
  final Function(VoidCallback) setState;

  QTController(this.setState) {
    _initServices();
  }
  
  void _initServices() {
    _emotionService = EmotionService(
      onEmotionChanged: _handleEmotionChanged,
    );
    
    _problemService = ProblemService(
      onProblemStateChanged: _handleProblemStateChanged,
    );
    
    _inputService = InputService(
      onTranscriptionChanged: _handleTranscriptionChanged,
      onListeningStateChanged: _handleListeningStateChanged,
    );
  }
  
  // Callback handlers
  void _handleEmotionChanged(String emotion, String previousEmotion, bool isTransitioning) {
    setState(() {
      this.currentEmotion = emotion;
      this.previousEmotion = previousEmotion;
      this.isTransitioning = isTransitioning;
    });
  }
  
  void _handleProblemStateChanged(String displayText, bool isDefaultBubble) {
    setState(() {
      resultText = displayText;
      isDefaultBubbleStyle = isDefaultBubble;
    });
  }
  
  void _handleTranscriptionChanged(String transcription) {
    setState(() {
      transcribedText = transcription;
    });
  }
  
  void _handleListeningStateChanged(bool isListening) {
    setState(() {
      this.isListening = isListening;
    });
  }
  
  // Public API methods
  Future<void> speakResult(String text) async {
    await _ttsService.speak(text);
  }
  
  void clearTranscription() {
    _inputService.clearTranscription();
  }
  
  void generateCalculationProblem() {
    String textToSpeak = _problemService.generateCalculationProblem();
    speakResult(textToSpeak);
    _emotionService.resetEmotion();
  }
  
  void generateTrueOrFalseProblem() {
    String textToSpeak = _problemService.generateTrueOrFalseProblem();
    speakResult(textToSpeak);
    _emotionService.resetEmotion();
  }
  
  void resetEmotion() {
    _emotionService.resetEmotion();
  }
  
  Future<void> handleVoiceInput(AnimationController animationController) async {
    resetEmotion();
    _resetAnimation(animationController);
    
    await _inputService.handleVoiceInput((result) {
      _processVoiceResult(result, animationController);
    });
  }
  
  void _processVoiceResult(String text, AnimationController? animationController) {
    switch (_problemService.currentProblemType) {
      case ProblemType.calculation:
        handleCalculationVoiceSubmission(text, animationController);
        break;
      case ProblemType.trueOrFalse:
        handleTrueOrFalseVoiceSubmission(text, animationController);
        break;
      default:
        showResult(text, animationController);
    }
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
    
    switch (_problemService.currentProblemType) {
      case ProblemType.calculation:
        handleCalculationSubmission(text, animationController);
        break;
      case ProblemType.trueOrFalse:
        handleTrueOrFalseSubmission(text, animationController);
        break;
      default:
        String result = _inputService.processGeneralMathExpression(text);
        showResult(result, animationController);
    }
  }
  
  void handleCalculationSubmission(String text, AnimationController animationController) {
    int? userAnswer = _inputService.parseCalculationInput(text);
    
    if (userAnswer != null) {
      String result = _problemService.checkCalculationAnswer(userAnswer);
      showResult(result, animationController);
    } else {
      showResult(AppStrings.invalidNumberInput, animationController);
    }
  }
  
  void handleCalculationVoiceSubmission(String text, AnimationController? animationController) {
    int? userAnswer = _inputService.extractNumberFromVoiceText(text);
    
    if (userAnswer != null) {
      String result = _problemService.checkCalculationAnswer(userAnswer);
      showResult(result, animationController);
    } else {
      showResult(AppStrings.invalidVoiceNumberInput, animationController);
    }
  }
  
  void handleTrueOrFalseSubmission(String text, AnimationController animationController) {
    bool? userAnswer = _inputService.parseTrueFalseInput(text);
    String result = _problemService.checkTrueFalseAnswer(userAnswer);
    showResult(result, animationController);
  }
  
  void handleTrueOrFalseVoiceSubmission(String text, AnimationController? animationController) {
    bool? userAnswer = _inputService.parseTrueFalseVoiceInput(text);
    String result = _problemService.checkTrueFalseAnswer(userAnswer);
    showResult(result, animationController);
  }
  
  void showResult(String result, AnimationController? animationController) {
    var emotionResult = _emotionService.processEmotionFromText(result, animationController);
    String newEmotion = emotionResult.emotion;
    bool isCorrect = emotionResult.isCorrect;

    _updateEmotionAndText(newEmotion, result, isCorrect, animationController);
    speakResult(result);
  }
  
  void _updateEmotionAndText(String newEmotion, String result, bool isCorrect, AnimationController? animationController) {
    if (_shouldAnimateEmotionChange(newEmotion)) {
      _animateEmotionTransition(newEmotion, result, isCorrect, animationController);
    } else {
      _applyEmotionImmediately(newEmotion, result, isCorrect);
    }
  }
  
  bool _shouldAnimateEmotionChange(String newEmotion) {
    return currentEmotion != "neutral" && newEmotion != currentEmotion;
  }
  
  void _animateEmotionTransition(String newEmotion, String result, bool isCorrect, AnimationController? animationController) {
    _updateEmotionState(
      newEmotion: newEmotion,
      result: result, 
      isCorrect: isCorrect,
      isTransitioning: true,
      storePrevious: true
    );

    if (animationController != null) {
      animationController.reset();
      animationController.forward();
    }
  }
  
  void _applyEmotionImmediately(String newEmotion, String result, bool isCorrect) {
    _updateEmotionState(
      newEmotion: newEmotion,
      result: result,
      isCorrect: isCorrect,
      isTransitioning: false,
      storePrevious: false
    );
  }
  
  void _updateEmotionState({
    required String newEmotion,
    required String result,
    required bool isCorrect,
    required bool isTransitioning,
    required bool storePrevious,
  }) {
    setState(() {
      if (storePrevious) {
        previousEmotion = currentEmotion;
      }
      currentEmotion = newEmotion;
      this.isTransitioning = isTransitioning;
      resultText = result;
      isCorrectAnswer = isCorrect;
      isDefaultBubbleStyle = false;
    });
  }
}