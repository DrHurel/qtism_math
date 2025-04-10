import 'package:flutter/material.dart';
import 'package:qtism_math/services/emotion_detector.dart';
import 'package:qtism_math/services/emotion_manager.dart';

class EmotionService {
  // State variables
  String currentEmotion = "neutral";
  String previousEmotion = "neutral";
  bool isTransitioning = false;
  final EmotionManager emotionManager = EmotionManager();
  
  // State change callback
  final Function(String emotion, String previousEmotion, bool isTransitioning) onEmotionChanged;
  
  EmotionService({required this.onEmotionChanged});
  
  void resetEmotion() {
    if (emotionManager.emotion != "neutral") {
      emotionManager.setEmotion("neutral");
      isTransitioning = true;
      onEmotionChanged("neutral", currentEmotion, true);
    }
  }
  
  EmotionResult processEmotionFromText(String text, AnimationController? animationController) {
    final emotionResult = EmotionDetector.detectFromText(text);
    String newEmotion = emotionResult.emotion;
    bool isCorrect = emotionResult.isCorrect;
    
    updateEmotion(newEmotion, isCorrect, animationController);
    return emotionResult;
  }

  void updateEmotion(String newEmotion, bool isCorrect, AnimationController? animationController) {
    if (_shouldAnimateEmotionChange(newEmotion)) {
      _animateEmotionTransition(newEmotion, isCorrect, animationController);
    } else {
      _applyEmotionImmediately(newEmotion, isCorrect);
    }
  }
  
  bool _shouldAnimateEmotionChange(String newEmotion) {
    return currentEmotion != "neutral" && newEmotion != currentEmotion;
  }
  
  void _animateEmotionTransition(String newEmotion, bool isCorrect, AnimationController? animationController) {
    // Store previous emotion
    previousEmotion = currentEmotion;
    currentEmotion = newEmotion;
    isTransitioning = true;
    
    // Notify about the change
    onEmotionChanged(newEmotion, previousEmotion, true);
    
    // Start animation if controller is available
    if (animationController != null) {
      animationController.reset();
      animationController.forward();
    }
  }
  
  void _applyEmotionImmediately(String newEmotion, bool isCorrect) {
    currentEmotion = newEmotion;
    isTransitioning = false;
    
    // Notify about the change
    onEmotionChanged(newEmotion, previousEmotion, false);
  }
}