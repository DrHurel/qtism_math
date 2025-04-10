import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/services/speech_text.dart';
import 'package:qtism_math/services/math_expression_processor.dart';
import 'package:qtism_math/services/voice_input_parser.dart';

class InputService {
  String transcribedText = "";
  bool isListening = false;
  
  // Callback for updating UI when input changes
  final Function(String transcription) onTranscriptionChanged;
  final Function(bool isListening) onListeningStateChanged;
  
  InputService({
    required this.onTranscriptionChanged,
    required this.onListeningStateChanged,
  });
  
  void clearTranscription() {
    transcribedText = "";
    onTranscriptionChanged("");
  }
  
  Future<void> handleVoiceInput(
    Function(String result) onResultProcessed
  ) async {
    clearTranscription();
    
    await SpeechText.toggleRecording(
      _updateTranscription,
      (expression, result) => onResultProcessed(result),
      clearTranscription,
      _updateListeningState,
    );
  }
  
  void _updateTranscription(String transcription) {
    transcribedText = transcription;
    onTranscriptionChanged(transcription);
  }
  
  void _updateListeningState(bool value) {
    isListening = value;
    onListeningStateChanged(value);
  }
  
  String processGeneralMathExpression(String text) {
    String mathExpression = SpeechText.convertToMathExpression(text);
    return SpeechText.evaluateMathExpression(mathExpression);
  }
  
  int? parseCalculationInput(String text) {
    try {
      return int.parse(text);
    } catch (e) {
      return null;
    }
  }
  
  int? extractNumberFromVoiceText(String text) {
    return MathExpressionProcessor.extractNumberFromVoiceText(text);
  }
  
  bool? parseTrueFalseInput(String text) {
    text = text.toLowerCase().trim();
    
    if (text == AppStrings.trueValue || text == 'true') {
      return true;
    } else if (text == AppStrings.falseValue || text == 'false') {
      return false;
    }
    return null;
  }
  
  bool? parseTrueFalseVoiceInput(String text) {
    return VoiceInputParser.parseTrueFalseResponse(
      text,
      additionalTrueKeywords: ['oui', 'yes', 'correct'],
      additionalFalseKeywords: ['non', 'no', 'incorrect']
    );
  }
}