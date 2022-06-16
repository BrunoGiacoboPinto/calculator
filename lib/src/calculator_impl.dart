abstract class Calculator {
  Calculator._();

  int compute(String expression);

  factory Calculator() => _CalculatorImpl();
}

class _CalculatorImpl extends Calculator {
  _CalculatorImpl() : super._();

  @override
  int compute(String expression) {
    throw UnimplementedError();
  }
}
