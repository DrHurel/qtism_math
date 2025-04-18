import 'package:qtism_math/services/input_handler/ai.dart';
import 'package:qtism_math/services/input_handler/speech_text.dart';
import 'dart:developer' as developer;
import 'dart:async';

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
    bool processingCompleted = false;
    String latestTranscription = "";
    
    developer.log('Starting voice input recording', name: 'InputService');
    
    // Set up a timeout to ensure we always process the input
    Timer? timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!processingCompleted && latestTranscription.isNotEmpty) {
        developer.log('Voice input timeout - forcing processing with text: "$latestTranscription"', 
                     name: 'InputService');
        _processVoiceInput(latestTranscription, onResultProcessed);
        processingCompleted = true;
      }
    });
    
    try {
      await SpeechText.toggleRecording(
        (text) {
          developer.log('Voice transcription update: "$text"', name: 'InputService');
          latestTranscription = text; // Store the latest transcription
          _updateTranscription(text);
        },
        (expression, result) async {
          developer.log('Voice input processed - Expression: "$expression"', name: 'InputService');
          timeoutTimer.cancel(); // Cancel the timeout as normal processing occurred
          processingCompleted = true;
          await _processVoiceInput(expression, onResultProcessed);
        },
        clearTranscription,
        (state) {
          developer.log('Listening state changed: $state', name: 'InputService');
          _updateListeningState(state);
          
          // If listening has stopped and processing hasn't completed, process the latest transcription
          if (!state && !processingCompleted && latestTranscription.isNotEmpty) {
            developer.log('Listening stopped but processing not completed - forcing with text: "$latestTranscription"', 
                         name: 'InputService');
            timeoutTimer.cancel();
            _processVoiceInput(latestTranscription, onResultProcessed);
            processingCompleted = true;
          }
        },
      );
    } catch (e) {
      developer.log('Error in voice input processing: $e', name: 'InputService');
      if (!processingCompleted && latestTranscription.isNotEmpty) {
        _processVoiceInput(latestTranscription, onResultProcessed);
      } else if (!processingCompleted) {
        onResultProcessed("Désolé, je n'ai pas pu traiter votre entrée vocale.");
      }
      timeoutTimer.cancel();
    }
  }
  
  Future<void> _processVoiceInput(String text, Function(String result) onResultProcessed) async {
    developer.log('Using AI-based math extraction for: "$text"', name: 'InputService');
    
    // Check if user is requesting a question
    if (_isQuestionRequest(text)) {
      _handleQuestionRequest(text, onResultProcessed);
      return;
    }
    
    String aiResult = await ai.extractAndCalculateMathExpression(text);
    
    if (aiResult.isNotEmpty) {
      developer.log('AI extracted result: $aiResult', name: 'InputService');
      onResultProcessed(aiResult);
    } else {
      developer.log('No math expression found, returning error message', name: 'InputService');
      onResultProcessed("Je n'ai pas pu interpréter cette expression mathématique.");
    }
  }
  
  bool _isQuestionRequest(String text) {
    text = text.toLowerCase();
    return text.contains("pose") || text.contains("donne") || text.contains("demande") || 
           text.contains("vrai ou faux") || text.contains("calcul");
  }
  
  void _handleQuestionRequest(String text, Function(String result) onResultProcessed) {
    developer.log('Detected question request: "$text"', name: 'InputService');
    text = text.toLowerCase();
    
    // Using a command pattern to avoid callback nesting
    onResultProcessed("#COMMAND#${(_isTrueOrFalseRequest(text)) ? "GENERATE_TRUE_FALSE" : 
      (_isCalculationRequest(text)) ? "GENERATE_CALCULATION" : 
      "UNKNOWN_REQUEST"}");
  }
  
  bool _isTrueOrFalseRequest(String text) {
    text = text.toLowerCase();
    return text.contains("vrai ou faux") || 
           (text.contains("question") && text.contains("vrai")) ||
           (text.contains("pose") && text.contains("vrai"));
  }
  
  bool _isCalculationRequest(String text) {
    text = text.toLowerCase();
    return text.contains("calcul") || 
           (text.contains("question") && text.contains("calcul")) ||
           (text.contains("pose") && text.contains("mathématique")) ||
           (text.contains("problème") && text.contains("math"));
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