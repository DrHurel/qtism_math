import 'package:flutter/material.dart';

class EmotionManager extends ChangeNotifier {



  String _emotion = "neutral";
  String get emotion => _emotion;

  void setEmotion(String newEmotion) {
    _emotion = newEmotion;
    notifyListeners();
  }

  void resetEmotion() {
    _emotion = "neutral";
    notifyListeners();
  }
  void setEmotionFromText(String text) {
    if (text.contains("triste") || text.contains("malheureux")) {
      _emotion = "sad";
    } else if (text.contains("heureux") || text.contains("content")) {
      _emotion = "happy";
    } else if (text.contains("en colère") || text.contains("furieux")) {
      _emotion = "angry";
    } else if (text.contains("surpris") || text.contains("étonné")) {
      _emotion = "surprised";
    } else if (text.contains("neutre") || text.contains("calme")) {
      _emotion = "neutral";
    } else {
      _emotion = "neutral"; // Default to neutral if no match
    }
    notifyListeners();
  }
  void setEmotionFromMathResult(String result) {
    if (result.contains("erreur") || result.contains("faux")) {
      _emotion = "sad";
    } else if (result.contains("correct") || result.contains("vrai")) {
      _emotion = "happy";
    } else {
      _emotion = "neutral"; // Default to neutral if no match
    }
    notifyListeners();
  }
  void setEmotionFromMathExpression(String expression) {
    if (expression.contains("erreur") || expression.contains("faux")) {
      _emotion = "sad";
    } else if (expression.contains("correct") || expression.contains("vrai")) {
      _emotion = "happy";
    } else {
      _emotion = "neutral"; // Default to neutral if no match
    }
    notifyListeners();
  }
  bool isHappy() {
    return _emotion == "happy";
  }
  bool isSad() {
    return _emotion == "sad";
  }
  bool isAngry() {
    return _emotion == "angry";
  }
  bool isSurprised() {
    return _emotion == "surprised";
  }
  bool isNeutral() {
    return _emotion == "neutral";
  }
  bool isEmotion(String emotion) {
    return _emotion == emotion;
  }
  bool isNotEmotion(String emotion) {
    return _emotion != emotion;
  }
  bool isEmotionInList(List<String> emotions) {
    return emotions.contains(_emotion);
  }
  bool isNotEmotionInList(List<String> emotions) {
    return !emotions.contains(_emotion);
  }
  bool isEmotionInListAndNotInList(List<String> emotions, List<String> notEmotions) {
    return emotions.contains(_emotion) && !notEmotions.contains(_emotion);
  }
  bool isEmotionInListOrNotInList(List<String> emotions, List<String> notEmotions) {
    return emotions.contains(_emotion) || !notEmotions.contains(_emotion);
  }
  bool isEmotionInListAndNotInListOrNotInList(List<String> emotions, List<String> notEmotions) {
    return emotions.contains(_emotion) && !notEmotions.contains(_emotion);
  }
}