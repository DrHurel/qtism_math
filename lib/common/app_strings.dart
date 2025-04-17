class AppStrings {
  // Calculation Problem
  static const String calculateResult = "Calcule le résultat de : {0}";
  static const String calculateResultSpoken = "Calcule le résultat de : {0}";

  // True or False Problem
  static const String trueOrFalseQuestion = "{0} est vrai ou faux ?";
  
  // Answer Evaluation - Calculation
  static const String correctCalculationAnswer = "Oui, bonne réponse. {0} = {1} est correct !";
  static const String incorrectCalculationAnswer = "Non, ce n'est pas la bonne réponse. Le résultat de {0} est {1}.";
  static const String invalidNumberInput = "Je n'ai pas compris votre réponse. Entrez un nombre.";
  
  // Answer Evaluation - True/False
  static const String correctTrueFalseAnswer = "Oui, c'est la bonne réponse ! {0} est {1}.";
  static const String incorrectTrueFalseAnswer = "Non, ce n'est pas la bonne réponse. {0} est en fait {1}.";
  static const String invalidTrueFalseInput = "Je n'ai pas compris votre réponse. Répondez par 'vrai' ou 'faux'.";
  
  // True/False Values
  static const String trueValue = "vrai";
  static const String falseValue = "faux";

  // Equation Evaluation
  static const String invalidEquationFormat = "Format d'équation invalide";
  static const String correctEquation = "Oui, bonne réponse. L'expression {0} = {1} est correcte";
  static const String incorrectEquation = "Non, l'expression {0} = {1} est incorrecte.";
  static const String correctAnswerWouldBe = "La bonne réponse serait : {0} = {1}";
  static const String equationEvaluationError = "Erreur dans l'évaluation de l'équation : {0}";
  
  // Math Expression Evaluation
  static const String mathExpressionResult = "Le résultat du calcul {0} est {1}";
  static const String mathExpressionParseError = "Je n'ai pas pu interpréter cette expression mathématique.";
  
  // Default explanation when no specific evaluator is found
  static const String defaultOperationError = "Hmm, il semble y avoir une erreur, mais je ne suis pas sûr du type d'opération.";
}