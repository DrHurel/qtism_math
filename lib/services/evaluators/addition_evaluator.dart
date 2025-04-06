import 'operation_evaluator.dart';

class AdditionEvaluator implements OperationEvaluator {
  @override
  bool containsOperation(String leftSide, String rightSide) {
    return leftSide.contains("+") || rightSide.contains("+");
  }

  @override
  String generateExplanation(
    String leftSide,
    String rightSide,
    double leftValue,
    double rightValue,
    double error
  ) {
    return "Tu as fait une erreur dans une addition. "
        '\n'
        "En calculant, **$leftSide** donne **${leftValue.toInt()}**. "
        '\n'
        "Mais ces deux nombres ne sont pas égaux ! "
        '\n'
        "L'écart est de **${error.toInt()}**."
        '\n'
        "N'oublie pas qu'en addition, on ajoute les nombres ensemble."
        '\n';
  }
}