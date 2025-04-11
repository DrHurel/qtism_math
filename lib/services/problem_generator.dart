import 'dart:math';
import 'operations/operation.dart';
import 'operations/addition_operation.dart';
import 'operations/subtraction_operation.dart';
import 'operations/multiplication_operation.dart';
import 'operations/division_operation.dart';

class ProblemGenerator {
  static final List<Operation> _operations = [
    AdditionOperation(),
    SubtractionOperation(),
    MultiplicationOperation(),
    DivisionOperation(),
  ];

  static Map<String, dynamic> generateCalculationProblem() {
    final random = Random();
    final operation = _operations[random.nextInt(_operations.length)];

    final (a, b) = operation.generateOperands(random);
    
    String problem = "$a ${operation.symbol} $b";
    return {
      'problem': problem, 
      'operation': operation.symbol, 
      'a': a, 
      'b': b
    };
  }

  static Map<String, dynamic> generateTrueOrFalseProblem() {
    final random = Random();
    final operation = _operations[random.nextInt(_operations.length)];

    final (a, b) = operation.generateOperands(random);
    final result = operation.calculate(a, b);
    final falseResult = operation.generateFalseResult(result, random);

    final isTrue = random.nextBool();
    String problem = isTrue
        ? "$a ${operation.symbol} $b = $result"
        : "$a ${operation.symbol} $b = $falseResult";

    return {'problem': problem, 'isTrue': isTrue};
  }
}

