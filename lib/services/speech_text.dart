import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:math_expressions/math_expressions.dart';
import 'dart:async';

class SpeechText {
  static Timer? _silenceTimer;
  static String _currentText = "";

  static Future<bool> toggleRecording(
      Function(String transcription) onTranscription,
      Function(String expression, String result) onResult,
      Function() onProcessingComplete,
      ValueChanged<bool> onListening) async {
    stt.SpeechToText speech = stt.SpeechToText();
    final bool available = await speech.initialize(
        onStatus: (value) {
          onListening(speech.isListening);
          if (!speech.isListening) {
            _silenceTimer?.cancel();
          }
        },
        onError: print);

    if (speech.isListening) {
      speech.stop();
      return true;
    }

    if (available) {
      _currentText = "";
      speech.listen(
        onResult: (value) {
          String recognizedText = value.recognizedWords;
          if (recognizedText.isNotEmpty) {
            _currentText = recognizedText;
            onTranscription(_currentText);
            _silenceTimer?.cancel();
            _silenceTimer = Timer(const Duration(seconds: 2), () {
              if (_currentText.isNotEmpty) {
                String mathExpression = convertToMathExpression(_currentText);
                String result = evaluateMathExpression(mathExpression);
                onResult(mathExpression, result);
                _currentText = "";
                speech.stop();
                Timer(const Duration(milliseconds: 500), () {
                  onProcessingComplete();
                });
              }
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      print("The user has denied the use of speech recognition.");
    }
    return available;
  }

  static String convertToMathExpression(String text) {
    text = text
        .toLowerCase()
        .replaceAll("plus", "+")
        .replaceAll("moins", "-")
        .replaceAll("multiplié par", "*")
        .replaceAll("divisé par", "/")
        .replaceAll("fois", "*")
        .replaceAll("puissance", "^")
        .replaceAll("égal", "=")
        .replaceAll("égale", "=")
        .replaceAll("égaux", "=");

    return text;
  }

  static String evaluateMathExpression(String expression) {
    try {
      // Check if this is an equation (contains =)
      if (expression.contains('=')) {
        return evaluateEquation(expression);
      }

      // Regular expression evaluation
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return "Le résultat du calcul **$expression** est **${eval.toString()}**";
    } catch (e) {
      return "Je n'ai pas compris votre demande, reformulez votre proposition mathématique";
    }
  }

  static String evaluateEquation(String equation) {
    try {
      List<String> parts = equation.split('=');

      if (parts.length != 2) {
        return "Format d'équation invalide";
      }

      String leftSide = parts[0].trim();
      String rightSide = parts[1].trim();

      Parser p = Parser();
      ContextModel cm = ContextModel();

      Expression leftExp = p.parse(leftSide);
      Expression rightExp = p.parse(rightSide);

      double leftValue = leftExp.evaluate(EvaluationType.REAL, cm);
      double rightValue = rightExp.evaluate(EvaluationType.REAL, cm);

      const double epsilon = 1e-10;
      bool isEqual = (leftValue - rightValue).abs() < epsilon;

      if (isEqual) {
        return "Oui, bonne réponse. L'expression **$leftSide = $rightSide** est correcte";
      } else {
        String explanation;
        double error = (leftValue - rightValue).abs();

        if (leftSide.contains("+") || rightSide.contains("+")) {
          explanation = "Tu as fait une erreur dans une addition. "
              '\n'
              "En calculant, **$leftSide** donne **$leftValue**. "
              '\n'
              "Mais ces deux nombres ne sont pas égaux ! "
              '\n'
              "L'écart est de **$error**."
              '\n'
              "N'oublie pas qu'en addition, on ajoute les nombres ensemble."
              '\n';
        } else if (leftSide.contains("-") || rightSide.contains("-")) {
          explanation = "Il y a une erreur dans une soustraction. "
              '\n'
              "En faisant les calculs, **$leftSide** donne **$leftValue**. "
              '\n'
              "Mais ces résultats ne sont pas identiques ! "
              '\n'
              "La différence entre les deux est de **$error**."
              '\n'
              "Fais bien attention en soustrayant."
              '\n';
        } else if (leftSide.contains("*") || rightSide.contains("*")) {
          explanation = "Oups, une petite erreur dans une multiplication ! "
              '\n'
              "Si on fait les calculs, **$leftSide** vaut **$leftValue**. "
              '\n'
              "Ils ne sont pas égaux, il y a une différence de **$error**. "
              '\n'
              "N'oublie pas que multiplier, c'est comme ajouter plusieurs fois le même nombre.";
        } else if (leftSide.contains("/") || rightSide.contains("/")) {
          explanation = "Attention à la division ! "
              '\n'
              "Si on calcule, **$leftSide** donne **$leftValue**. "
              '\n'
              "Mais ces deux valeurs sont différentes, avec une différence de **$error**. "
              '\n'
              "En division, il faut bien vérifier combien de fois un nombre rentre dans un autre."
              '\n';
        } else {
          explanation =
              "Hmm, il semble y avoir une erreur, mais je ne suis pas sûr du type d'opération.";
        }
        return "Non, l'expression **$leftSide = $rightSide** est incorrecte. "
            '\n'
            "$explanation"
            "La bonne réponse serait : **$leftSide = $leftValue**";
      }
    } catch (e) {
      return "Erreur dans l'évaluation de l'équation : $e";
    }
  }
}
