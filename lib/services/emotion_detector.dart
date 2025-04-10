class EmotionDetector {
  /// Determines the appropriate emotion based on the result text
  static EmotionResult detectFromText(String resultText) {
    if (resultText.startsWith("Oui, bonne réponse") ||
        resultText.startsWith("Oui, c'est la bonne réponse")) {
      return EmotionResult(emotion: "enjoy", isCorrect: true);
    } else if (resultText.startsWith("Non")) {
      return EmotionResult(emotion: "sad", isCorrect: false);
    } else {
      return EmotionResult(emotion: "happy", isCorrect: true);
    }
  }
}

class EmotionResult {
  final String emotion;
  final bool isCorrect;
  
  EmotionResult({required this.emotion, required this.isCorrect});
}