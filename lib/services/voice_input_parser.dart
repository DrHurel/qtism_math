class VoiceInputParser {
  /// Tries to interpret voice input as a boolean true/false response
  static bool? parseTrueFalseResponse(String text, {List<String>? additionalTrueKeywords, List<String>? additionalFalseKeywords}) {
    String cleanedText = text.toLowerCase().trim();
    
    // Standard keywords
    List<String> trueKeywords = ['vrai', 'true', 'oui', 'yes', 'correct'];
    List<String> falseKeywords = ['faux', 'false', 'non', 'no', 'incorrect'];
    
    // Add any additional keywords
    if (additionalTrueKeywords != null) trueKeywords.addAll(additionalTrueKeywords);
    if (additionalFalseKeywords != null) falseKeywords.addAll(additionalFalseKeywords);
    
    // Check for matches
    for (String keyword in trueKeywords) {
      if (cleanedText.contains(keyword)) return true;
    }
    
    for (String keyword in falseKeywords) {
      if (cleanedText.contains(keyword)) return false;
    }
    
    return null; // No clear true/false response detected
  }
}