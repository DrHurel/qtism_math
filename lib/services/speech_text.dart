// Dans le fichier speech_text.dart, ajoutons une fonction pour préparer le texte pour TTS

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

import '../common/app_strings.dart';
import 'evaluators/operation_evaluator.dart';
import 'evaluators/addition_evaluator.dart';
import 'evaluators/subtraction_evaluator.dart';
import 'evaluators/multiplication_evaluator.dart';
import 'evaluators/division_evaluator.dart';

class SpeechText {
  static Timer? _silenceTimer;
  static String _currentText = "";
  static final FlutterTts _flutterTts = FlutterTts();
  static final GrammarParser grammarParser = GrammarParser();

  static final List<OperationEvaluator> _evaluators = [
    AdditionEvaluator(),
    SubtractionEvaluator(),
    MultiplicationEvaluator(),
    DivisionEvaluator(),
  ];

  static Future<void> speakResult(String text) async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setPitch(1.1);
    await _flutterTts.setSpeechRate(1);
    await _flutterTts.speak(text
        .replaceAll('*', 'fois')
        .replaceAll('/', 'divisé par')
        .replaceAll('-', 'moins'));
  }

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

            // Détecter si l'utilisateur a fini de parler
            _silenceTimer?.cancel();
            _silenceTimer = Timer(const Duration(seconds: 2), () {
              if (_currentText.isNotEmpty) {
                // Traiter le texte comme une expression mathématique si nécessaire
                String mathExpression = convertToMathExpression(_currentText);
                if (mathExpression.contains('=') ||
                    isValidMathExpression(mathExpression)) {
                  String result = mathExpression.contains('=')
                      ? evaluateEquation(mathExpression)
                      : evaluateMathExpression(mathExpression);

                  onResult(mathExpression, result);
                  _currentText = "";
                  speech.stop();

                  Timer(const Duration(milliseconds: 500), () {
                    onProcessingComplete();
                  });
                } else {
                  // Si ce n'est pas une expression mathématique valide, renvoyer juste la transcription
                  // pour que l'application puisse la traiter selon son contexte
                  onResult(_currentText, "");
                  _currentText = "";
                  speech.stop();

                  Timer(const Duration(milliseconds: 500), () {
                    onProcessingComplete();
                  });
                }
              }
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenMode: stt.ListenMode.confirmation,
        localeId: 'fr_FR',
      );
    } else {
      print("The user has denied the use of speech recognition.");
    }
    return available;
  }

  // Existing methods remain the same...
  static bool isValidMathExpression(String expression) {
    try {
    
      grammarParser.parse(expression);
      return true;
    } catch (e) {
      return false;
    }
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
        .replaceAll("égaux", "=")
        .replaceAll(" ", "");
    return text;
  }

  static String evaluateMathExpression(String expression) {
    try {
      if (expression.contains('=')) {
        return evaluateEquation(expression);
      }

     
      Expression exp = grammarParser.parse(expression);
      ContextModel cm = ContextModel();

      double eval = exp.evaluate(EvaluationType.REAL, cm);

      return _formatString(AppStrings.mathExpressionResult, 
          [expression, eval.toInt()]);
    } catch (e) {
      try {
        return evaluateEquation(expression);
      } catch (_) {
        return _formatString(AppStrings.mathExpressionParseError, [e]);
      }
    }
  }

  static String evaluateEquation(String equation) {
    try {
      List<String> parts = equation.split('=');

      if (parts.length != 2) {
        return AppStrings.invalidEquationFormat;
      }

      String leftSide = parts[0].trim();
      String rightSide = parts[1].trim();

      
      ContextModel cm = ContextModel();

      Expression leftExp = grammarParser.parse(leftSide);
      Expression rightExp = grammarParser.parse(rightSide);

      double leftValue = leftExp.evaluate(EvaluationType.REAL, cm);
      double rightValue = rightExp.evaluate(EvaluationType.REAL, cm);

      const double epsilon = 0.001;
      bool isEqual = (leftValue - rightValue).abs() < epsilon;

      if (isEqual) {
        return _formatString(AppStrings.correctEquation, [leftSide, rightSide]);
      } else {
        String explanation;
        double error = (leftValue - rightValue).abs();
        
        // Find appropriate evaluator based on the operation (improved)
        final matchingEvaluators = _evaluators.where(
          (e) => e.containsOperation(leftSide, rightSide),
        );
        OperationEvaluator? evaluator = matchingEvaluators.isNotEmpty ? matchingEvaluators.first : null;
        
        if (evaluator != null) {
          explanation = evaluator.generateExplanation(
            leftSide, 
            rightSide, 
            leftValue, 
            rightValue, 
            error
          );
        } else {
          explanation = AppStrings.defaultOperationError;
        }
              
        return '${_formatString(AppStrings.incorrectEquation, [leftSide, rightSide])}\n$explanation${_formatString(AppStrings.correctAnswerWouldBe, [leftSide, leftValue.toInt()])}';
      }
    } catch (e) {
      return _formatString(AppStrings.equationEvaluationError, [e]);
    }
  }

  static String _formatString(String template, List<dynamic> arguments) {
    String result = template;
    for (int i = 0; i < arguments.length; i++) {
      result = result.replaceAll('{$i}', arguments[i].toString());
    }
    return result;
  }
}
