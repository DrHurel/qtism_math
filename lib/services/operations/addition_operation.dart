import 'dart:math';
import 'operation.dart';

class AdditionOperation implements Operation {
  @override
  String get symbol => '+';

  @override
  (int a, int b) generateOperands(Random random) {
    return (random.nextInt(21), random.nextInt(21));
  }

  @override
  int calculate(int a, int b) => a + b;

  @override
  int generateFalseResult(int result, Random random) {
    return result + (random.nextInt(3) + 1);
  }
}