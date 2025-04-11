import 'package:qtism_math/services/ai.dart';
import 'package:qtism_math/services/speech_text.dart';
import 'dart:developer' as developer;

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
    developer.log('Clearing transcription', name: 'InputService');
    transcribedText = "";
    onTranscriptionChanged("");
  }
  
  Future<void> handleVoiceInput(
    Function(String result) onResultProcessed
  ) async {
    clearTranscription();
    
    developer.log('Starting voice input recording', name: 'InputService');
    await SpeechText.toggleRecording(
      (text) {
        developer.log('Voice transcription update: "$text"', name: 'InputService');
        _updateTranscription(text);
      },
      (expression, result) async {
        developer.log('Voice input processed - Expression: "$expression"', name: 'InputService');
        
        // Always use AI-based extraction as per requirement
        developer.log('Using AI-based math extraction', name: 'InputService');
        String aiResult = await ai.extractAndCalculateMathExpression(expression);
        
        if (aiResult.isNotEmpty) {
          developer.log('AI extracted result: $aiResult', name: 'InputService');
          onResultProcessed(aiResult);
        } else {
          onResultProcessed("Je n'ai pas pu interpréter cette expression mathématique.");
        }
      },
      clearTranscription,
      (state) {
        developer.log('Listening state changed: $state', name: 'InputService');
        _updateListeningState(state);
      },
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
    developer.log('Processing math expression: "$text"', name: 'InputService');
    String mathExpression = SpeechText.convertToMathExpression(text);
    developer.log('Converted to math expression: "$mathExpression"', name: 'InputService');
    String result = SpeechText.evaluateMathExpression(mathExpression);
    developer.log('Evaluated result: "$result"', name: 'InputService');
    return result;
  }
  
  Future<int?> extractNumberFromText(String text) async {
    developer.log('Extracting number from: "$text"', name: 'InputService');
    int? result = await ai.extractUserResponseCalculValue(text);
    developer.log('Extracted number: ${result ?? "null"}', name: 'InputService');
    return result;
  }
  
  Future<bool?> parseTrueFalseInput(String text) async {
    developer.log('Parsing true/false input: "$text"', name: 'InputService');
    String aiResponse = await ai.translateUserResponseTrueFalse(text);
    developer.log('AI response for true/false: "$aiResponse"', name: 'InputService');

    aiResponse = aiResponse.toLowerCase().trim();

    bool? result;
    if (aiResponse.contains("vrai")) result = true;
    if (aiResponse.contains("faux")) result = false;
    
    developer.log('Parsed true/false result: ${result != null ? (result ? "true" : "false") : "null"}', 
                 name: 'InputService');
    return result; // indécis ou réponse imprévisible
  }
}