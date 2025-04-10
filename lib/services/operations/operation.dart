import 'dart:math';

abstract class Operation {
  String get symbol;
  
  // Generate appropriate values for a and b
  (int a, int b) generateOperands(Random random);
  
  // Calculate the result of the operation
  int calculate(int a, int b);
  
  // Generate a false result for true/false problems
  int generateFalseResult(int result, Random random);
}