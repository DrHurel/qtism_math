import 'operation_evaluator.dart';

class DivisionEvaluator implements OperationEvaluator {
  @override
  bool containsOperation(String leftSide, String rightSide) {
    return leftSide.contains("/") || rightSide.contains("/");
  }

  @override
  String generateExplanation(
    String leftSide,
    String rightSide,
    double leftValue,
    double rightValue,
    double error
  ) {
    return "Attention à la division ! "
        '\n'
        "Si on calcule, $leftSide donne ${leftValue.toInt()}. "
        '\n'
        "Mais ces deux valeurs sont différentes, avec une différence de ${error.toInt()}. "
        '\n'
        "En division, il faut bien vérifier combien de fois un nombre rentre dans un autre."
        '\n';
  }
}