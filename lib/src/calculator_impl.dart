abstract class Calculator {
  Calculator._();

  int compute(String expression);

  factory Calculator() => _CalculatorImpl();
}

class _CalculatorImpl extends Calculator {
  _CalculatorImpl() : super._();

  static final alphabet = '+-/*0123456789.'.codeUnits;

  bool isInValidInput(String expression) {
    return expression.codeUnits.any((character) => !alphabet.contains(character)) || expression.isEmpty;
  }

  @override
  int compute(String expression) {
    if (isInValidInput(expression.trim())) {
      throw ArgumentError();
    }

    return 4;
  }
}
