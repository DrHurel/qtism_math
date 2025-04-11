import 'dart:math';
import 'operation.dart';

class DivisionOperation implements Operation {
  @override
  String get symbol => '/';

  @override
  (int a, int b) generateOperands(Random random) {
    final b = random.nextInt(9) + 1; // Ensure b is not zero
    final a = b * (random.nextInt(10) + 1);
    return (a, b);
  }

  @override
  int calculate(int a, int b) => a ~/ b;

  @override
  int generateFalseResult(int result, Random random) {
    return result + (random.nextInt(3) + 1);
  }
}