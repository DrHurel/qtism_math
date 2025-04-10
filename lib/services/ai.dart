import 'package:firebase_vertexai/firebase_vertexai.dart';

class AICommunication {
  final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash');

  // To generate text output, call generateContent with the text input
  Future<String> translateUserResponseTrueFalse(String text) async {
    // Provide a prompt that contains text
    final prompt = [Content.text('Répond seulement par "vrai" ou par "faux". Dis moi si cette phrase est équivalente à "vrai" ou "faux" : $text')];
    final response = await model.generateContent(prompt);
    if (response.text != null){
      return response.text!;
    }
    return "";
  }


  Future<int?> extractUserResponseCalculValue(String text) async {
    // Provide a prompt that contains text
    final prompt = [Content.text('Répond seulement par un nombre. Extrait le nombre donné dans cette phrase : $text')];
    final response = await model.generateContent(prompt);
    if (response.text != null){
      return int.parse(response.text!);
    }
    return null;
  }
}