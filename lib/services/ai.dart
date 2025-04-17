import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:developer' as developer;

class AICommunication {
  final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash');

  Future<String> translateUserResponseTrueFalse(String text) async {
    developer.log('Starting true/false analysis: "$text"', name: 'AI');
    try {
      final prompt = [Content.text('Répond seulement par "vrai" ou par "faux". Dis moi si cette phrase est équivalente à "vrai" ou "faux" : $text')];
      final response = await model.generateContent(prompt);
      if (response.text != null){
        developer.log('True/false result: "${response.text}"', name: 'AI');
        return response.text!;
      }
      developer.log('Empty response from AI for true/false', name: 'AI');
      return "";
    } catch (e) {
      developer.log('Error in true/false processing: $e', name: 'AI');
      return "";
    }
  }

  Future<int?> extractUserResponseCalculValue(String text) async {
    developer.log('Starting number extraction: "$text"', name: 'AI');
    try {
      final prompt = [Content.text('Répond seulement par un nombre. Extrait le nombre donné dans cette phrase : $text')];
      final response = await model.generateContent(prompt);
      if (response.text != null){
        developer.log('Extracted number text: "${response.text}"', name: 'AI');
        return int.parse(response.text!);
      }
      developer.log('No number found in response', name: 'AI');
      return null;
    } catch (e) {
      developer.log('Error in number extraction: $e', name: 'AI');
      return null;
    }
  }
  
  Future<String> extractAndCalculateMathExpression(String text) async {
    developer.log('Starting math expression analysis: "$text"', name: 'AI');
    try {
      final prompt = [Content.text(
        'Extrait et calcule l\'opération mathématique contenue dans cette phrase. '
        'Réponds uniquement par le résultat numérique. '
        'Si aucune opération mathématique n\'est présente, réponds par une chaîne vide. '
        'Phrase: $text'
      )];
      final response = await model.generateContent(prompt);
      if (response.text != null){
        developer.log('Math calculation result: "${response.text?.trim()}"', name: 'AI');
        return response.text!.trim();
      }
      developer.log('Empty response from AI for math expression', name: 'AI');
      return "";
    } catch (e) {
      developer.log('Error in math expression processing: $e', name: 'AI');
      return "";
    }
  }
}