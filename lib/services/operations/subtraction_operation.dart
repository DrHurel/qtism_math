import 'dart:math';
import 'operation.dart';

class SubtractionOperation implements Operation {
  @override
  String get symbol => '-';

  @override
  (int a, int b) generateOperands(Random random) {
    final a = random.nextInt(21);
    final b = random.nextInt(a + 1);
    return (a, b);
  }

  @override
  int calculate(int a, int b) => a - b;

  @override
  int generateFalseResult(int result, Random random) {
    return result - (random.nextInt(3) + 1);
  }
}