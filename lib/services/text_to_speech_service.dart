import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> speak(String text) async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
