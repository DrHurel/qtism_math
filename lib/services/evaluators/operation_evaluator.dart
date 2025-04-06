abstract class OperationEvaluator {
  // Check if this operation is present in the equation parts
  bool containsOperation(String leftSide, String rightSide);
  
  // Generate explanation when equation is incorrect
  String generateExplanation(
    String leftSide, 
    String rightSide, 
    double leftValue, 
    double rightValue, 
    double error
  );
}