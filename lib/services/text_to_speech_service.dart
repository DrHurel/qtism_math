import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  final FlutterTts flutterTts = FlutterTts();
  
  factory TextToSpeechService() {
    return _instance;
  }
  
  TextToSpeechService._internal() {
    _initializeSettings();
  }
  
  Future<void> _initializeSettings() async {
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setPitch(1.1);
    await flutterTts.setSpeechRate(1);
  }
  
  Future<void> speak(String text) async {
    await flutterTts.speak(_formatTextForSpeech(text));
  }
  
  String _formatTextForSpeech(String text) {
    return text
      .replaceAll('**', '')
      .replaceAll('*', 'fois')
      .replaceAll('/', 'divisé par')
      .replaceAll('-', 'moins');
  }
}