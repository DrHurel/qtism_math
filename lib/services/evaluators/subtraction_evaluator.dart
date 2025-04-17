import 'operation_evaluator.dart';

class SubtractionEvaluator implements OperationEvaluator {
  @override
  bool containsOperation(String leftSide, String rightSide) {
    return leftSide.contains("-") || rightSide.contains("-");
  }

  @override
  String generateExplanation(
    String leftSide,
    String rightSide,
    double leftValue,
    double rightValue,
    double error
  ) {
    return "Il y a une erreur dans une soustraction. "
        '\n'
        "En faisant les calculs, $leftSide donne ${leftValue.toInt()}. "
        '\n'
        "Mais ces résultats ne sont pas identiques ! "
        '\n'
        "La différence entre les deux est de ${error.toInt()}."
        '\n'
        "Fais bien attention en soustrayant."
        '\n';
  }
}