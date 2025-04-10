class MathExpressionProcessor {
  /// Calculates the result of a simple mathematical operation
  static int calculateResult(String operation) {
    if (operation.contains('+')) {
      List<String> parts = operation.split('+');
      return int.parse(parts[0].trim()) + int.parse(parts[1].trim());
    } else if (operation.contains('-')) {
      List<String> parts = operation.split('-');
      return int.parse(parts[0].trim()) - int.parse(parts[1].trim());
    } else if (operation.contains('×')) {
      List<String> parts = operation.split('×');
      return int.parse(parts[0].trim()) * int.parse(parts[1].trim());
    } else if (operation.contains('÷')) {
      List<String> parts = operation.split('÷');
      return int.parse(parts[0].trim()) ~/ int.parse(parts[1].trim());
    }
    return -1;
  }
  
  /// Extracts a number from voice transcription text
  static int? extractNumberFromVoiceText(String text) {
    // Clean the text first
    String cleanedText = text.replaceAll(RegExp(r'[^0-9-]'), '').trim();

    // Try to parse as direct number
    if (RegExp(r'^-?\d+$').hasMatch(cleanedText)) {
      return int.parse(cleanedText);
    } 
    
    // Otherwise find first number in text
    RegExp regExp = RegExp(r'-?\d+');
    var matches = regExp.allMatches(text);
    if (matches.isNotEmpty) {
      return int.parse(matches.first.group(0)!);
    }
    
    return null;
  }
}