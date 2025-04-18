import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/common/enum.dart';
import 'package:qtism_math/services/problem_generator.dart';
import 'package:qtism_math/utils/string_formatter.dart';
import 'dart:developer' as developer;
import 'dart:math';

class ProblemService {
  String generatedProblem = "";
  ProblemType currentProblemType = ProblemType.none;
  bool? expectedTruthValue;
  String currentProblem = "";
  int expectedAnswer = 0;
  final _random = Random();
  final _operations = ["+", "-", "*"];
  
  // Callback for when problem state changes
  final Function(String displayText, bool isDefaultBubble) onProblemStateChanged;
  
  ProblemService({required this.onProblemStateChanged});
  
  String generateCalculationProblem() {
    // Debug what's being generated
    int num1 = _random.nextInt(10) + 1;
    int num2 = _random.nextInt(10) + 1;
    int operationIndex = _random.nextInt(_operations.length);
    String operation = _operations[operationIndex];
    
    currentProblem = "$num1 $operation $num2";
    
    // Calculate the expected answer based on the operation
    switch (operation) {
      case "+":
        expectedAnswer = num1 + num2;
        break;
      case "-":
        expectedAnswer = num1 - num2;
        break;
      case "*":
        expectedAnswer = num1 * num2;
        developer.log('Multiplication: $num1 * $num2 = $expectedAnswer', name: 'ProblemService');
        break;
      case "÷":
        expectedAnswer = (num1 / num2).round(); // Simple integer division
        break;
    }
  
    developer.log('Generated calculation problem: "$currentProblem"', name: 'ProblemService');
    developer.log('Expected answer: $expectedAnswer', name: 'ProblemService');
    
    currentProblemType = ProblemType.calculation;
    _updateProblemState("Calcule $currentProblem", true);
    return "Calcule $currentProblem";
  }
  
  String generateTrueOrFalseProblem() {
    final problemData = ProblemGenerator.generateTrueOrFalseProblem();
    final problem = problemData['problem'];
    final isTrue = problemData['isTrue'];
    
    generatedProblem = problem;
    currentProblemType = ProblemType.trueOrFalse;
    expectedTruthValue = isTrue;
    
    String displayText = StringFormatter.format(AppStrings.trueOrFalseQuestion, [problem]);
    onProblemStateChanged(displayText, true);
    
    return displayText;
  }
  
  String checkCalculationAnswer(int userAnswer) {
    // Add debug logging
    developer.log('ProblemService - Checking calculation answer', name: 'ProblemService');
    developer.log('  Current problem: $currentProblem', name: 'ProblemService');
    developer.log('  Expected answer: $expectedAnswer', name: 'ProblemService');
    developer.log('  User answer: $userAnswer', name: 'ProblemService');
    
    if (userAnswer == expectedAnswer) {
      developer.log('  Answer is correct!', name: 'ProblemService');
      _handleCorrectAnswer();
      return _getCorrectAnswerMessage();
    } else {
      developer.log('  Answer is incorrect!', name: 'ProblemService');
      _handleIncorrectAnswer();
      return "Non, ce n'est pas la bonne réponse. Le résultat de $currentProblem est $expectedAnswer.";
    }
  }
  
  String checkTrueFalseAnswer(bool? userAnswer) {
    if (userAnswer == null) {
      return "Je n'ai pas compris si votre réponse est vrai ou faux. Veuillez répondre par 'vrai' ou 'faux'.";
    }
    
    String valueAsText = userAnswer ? AppStrings.trueValue : AppStrings.falseValue;
    String expectedValueAsText = expectedTruthValue! ? AppStrings.trueValue : AppStrings.falseValue;
    String resultMessage;
    
    if (userAnswer == expectedTruthValue) {
      resultMessage = StringFormatter.format(
        AppStrings.correctTrueFalseAnswer,
        [generatedProblem, valueAsText]
      );
    } else {
      resultMessage = StringFormatter.format(
        AppStrings.incorrectTrueFalseAnswer,
        [generatedProblem, expectedValueAsText]
      );
    }
    
    resetProblemType();
    onProblemStateChanged(resultMessage, false);
    return resultMessage;
  }
  
  void resetProblemType() {
    currentProblemType = ProblemType.none;
  }
  
  void _updateProblemState(String displayText, bool isDefaultBubble) {
    onProblemStateChanged(displayText, isDefaultBubble);
  }
  
  void _handleCorrectAnswer() {
    resetProblemType();
  }
  
  void _handleIncorrectAnswer() {
    resetProblemType();
  }
  
  String _getCorrectAnswerMessage() {
    return "Oui, c'est la bonne réponse ! Le résultat de $currentProblem est $expectedAnswer.";
  }
}