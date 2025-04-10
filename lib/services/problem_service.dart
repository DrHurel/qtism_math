import 'package:qtism_math/common/app_strings.dart';
import 'package:qtism_math/common/enum.dart';
import 'package:qtism_math/services/problem_generator.dart';
import 'package:qtism_math/services/math_expression_processor.dart';
import 'package:qtism_math/utils/string_formatter.dart';

class ProblemService {
  String generatedProblem = "";
  ProblemType currentProblemType = ProblemType.none;
  bool? expectedTruthValue;
  
  // Callback for when problem state changes
  final Function(String displayText, bool isDefaultBubble) onProblemStateChanged;
  
  ProblemService({required this.onProblemStateChanged});
  
  String generateCalculationProblem() {
    final problemData = ProblemGenerator.generateCalculationProblem();
    final problem = problemData['problem'];
    
    generatedProblem = problem;
    currentProblemType = ProblemType.calculation;
    expectedTruthValue = null;
    
    String displayText = StringFormatter.format(AppStrings.calculateResult, [problem]);
    onProblemStateChanged(displayText, true);
    
    return StringFormatter.format(AppStrings.calculateResultSpoken, [problem]);
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
    int correctAnswer = MathExpressionProcessor.calculateResult(generatedProblem);
    bool isCorrect = userAnswer == correctAnswer;
    
    String resultMessage;
    if (isCorrect) {
      resultMessage = StringFormatter.format(
        AppStrings.correctCalculationAnswer,
        [generatedProblem, correctAnswer]
      );
    } else {
      resultMessage = StringFormatter.format(
        AppStrings.incorrectCalculationAnswer,
        [generatedProblem, correctAnswer]
      );
    }
    
    resetProblemType();
    onProblemStateChanged(resultMessage, false);
    return resultMessage;
  }
  
  String checkTrueFalseAnswer(bool? userAnswer) {
    if (userAnswer == null) {
      return AppStrings.invalidTrueFalseInput;
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
}