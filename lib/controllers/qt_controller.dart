import 'package:flutter/material.dart';
import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/common/enum.dart';
import 'package:qtism_math/services/text_to_speech_service.dart';
import 'package:qtism_math/services/emotion_service.dart';
import 'package:qtism_math/services/problem_service.dart';
import 'package:qtism_math/services/input_service.dart';
import 'dart:developer' as developer;

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
    developer.log('QTController - Speaking: "$text"', name: 'QTController');
    await _ttsService.speak(text);
  }
  
  void clearTranscription() {
    developer.log('QTController - Clearing transcription', name: 'QTController');
    _inputService.clearTranscription();
  }
  
  void generateCalculationProblem() {
    developer.log('QTController - Generating calculation problem', name: 'QTController');
    String textToSpeak = _problemService.generateCalculationProblem();
    developer.log('QTController - Generated problem: "$textToSpeak"', name: 'QTController');
    speakResult(textToSpeak);
    _emotionService.resetEmotion();
  }
  
  void generateTrueOrFalseProblem() {
    developer.log('QTController - Generating true/false problem', name: 'QTController');
    String textToSpeak = _problemService.generateTrueOrFalseProblem();
    developer.log('QTController - Generated problem: "$textToSpeak"', name: 'QTController');
    speakResult(textToSpeak);
    _emotionService.resetEmotion();
  }
  
  void resetEmotion() {
    developer.log('QTController - Resetting emotion', name: 'QTController');
    _emotionService.resetEmotion();
  }
  
  void handleVoiceInput(AnimationController animationController) {
    developer.log('QTController - Starting voice input processing', name: 'QTController');
    resetEmotion();
    _resetAnimation(animationController);
    
    _inputService.handleVoiceInput((result) {
      developer.log('QTController - Voice input result received: "$result"', name: 'QTController');
      _processVoiceResult(result, animationController);
    });
  }
  
  void _processVoiceResult(String text, AnimationController animationController) {
    if (text.isEmpty) {
      developer.log('QTController - Empty voice result, ignoring', name: 'QTController');
      return;
    }
    
    setState(() {
      transcribedText = text;
    });
    
    developer.log('QTController - Processing voice result for problem type: ${_problemService.currentProblemType}', name: 'QTController');
    switch (_problemService.currentProblemType) {
      case ProblemType.calculation:
        developer.log('QTController - Handling as calculation problem', name: 'QTController');
        handleCalculationSubmission(text, animationController);
        break;
      case ProblemType.trueOrFalse:
        developer.log('QTController - Handling as true/false problem', name: 'QTController');
        handleTrueOrFalseSubmission(text, animationController);
        break;
      default:
        developer.log('QTController - Handling as general expression', name: 'QTController');
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
    developer.log('QTController - Submitting calculation answer: "$text"', name: 'QTController');
    _inputService.extractNumberFromText(text).then((value) {
      if (value != null) {
        developer.log('QTController - Extracted number: $value', name: 'QTController');
        String result = _problemService.checkCalculationAnswer(value);
        developer.log('QTController - Calculation check result: "$result"', name: 'QTController');
        showResult(result, animationController);
      } else {
        developer.log('QTController - Invalid number input', name: 'QTController');
        showResult(AppStrings.invalidNumberInput, animationController);
      }
    });
  }

  void handleTrueOrFalseSubmission(String text, AnimationController animationController) {
    developer.log('QTController - Submitting true/false answer: "$text"', name: 'QTController');
    _inputService.parseTrueFalseInput(text).then((value) {
      developer.log('QTController - Parsed true/false value: $value', name: 'QTController');
      String result = _problemService.checkTrueFalseAnswer(value);
      developer.log('QTController - True/false check result: "$result"', name: 'QTController');
      showResult(result, animationController);
    });
  }
  
  void showResult(String result, AnimationController? animationController) {
    developer.log('QTController - Showing result: "$result"', name: 'QTController');
    var emotionResult = _emotionService.processEmotionFromText(result, animationController);
    String newEmotion = emotionResult.emotion;
    bool isCorrect = emotionResult.isCorrect;

    developer.log('QTController - Emotion result: emotion=$newEmotion, isCorrect=$isCorrect', name: 'QTController');
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