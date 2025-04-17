import 'operation_evaluator.dart';

class MultiplicationEvaluator implements OperationEvaluator {
  @override
  bool containsOperation(String leftSide, String rightSide) {
    return leftSide.contains("*") || rightSide.contains("*");
  }

  @override
  String generateExplanation(
    String leftSide,
    String rightSide,
    double leftValue,
    double rightValue,
    double error
  ) {
    return "Oups, une petite erreur dans une multiplication ! "
        '\n'
        "Si on fait les calculs, $leftSide vaut ${leftValue.toInt()}. "
        '\n'
        "Ils ne sont pas égaux, il y a une différence de ${error.toInt()}. "
        '\n'
        "N'oublie pas que multiplier, c'est comme ajouter plusieurs fois le même nombre.";
  }
}