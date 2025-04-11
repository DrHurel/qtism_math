import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/services/ai.dart';
import 'package:qtism_math/services/speech_text.dart';
import 'package:qtism_math/services/math_expression_processor.dart';

class InputService {
  String transcribedText = "";
  bool isListening = false;
  final AICommunication ai = AICommunication();
  
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
  
  Future<int?> extractNumberFromText(String text) async {
    return await ai.extractUserResponseCalculValue(text);
  }
  
  Future<bool?> parseTrueFalseInput(String text) async {
    String aiResponse = await ai.translateUserResponseTrueFalse(text);

    aiResponse = aiResponse.toLowerCase().trim();

    if (aiResponse.contains("vrai")) return true;
    if (aiResponse.contains("faux")) return false;

    return null; // indécis ou réponse imprévisible
  }
  
}