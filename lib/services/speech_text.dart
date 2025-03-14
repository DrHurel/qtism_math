import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechText {
  static Future<bool> toggleRecording(
      Function(String message) message, ValueChanged<bool> onListening) async {
    stt.SpeechToText speech = stt.SpeechToText();
    final bool available = await speech.initialize(
        onStatus: (value) => onListening(speech.isListening), onError: print);
    if (speech.isListening) {
      speech.stop();
      return true;
    }
    if (available) {
      speech.listen(onResult: (value) => message(value.recognizedWords));
    } else {
      print("The user has denied the use of speech recognition.");
    }
    return available;
  }
}
