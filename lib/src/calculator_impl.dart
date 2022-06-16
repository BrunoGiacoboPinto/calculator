abstract class Calculator {
  Calculator._();

  int compute(String expression);

  factory Calculator() => _CalculatorImpl();
}

class _CalculatorImpl extends Calculator {
  _CalculatorImpl() : super._();

  static final alphabet = '+-/*0123456789'.codeUnits;

  bool isInValidInput(String expression) {
    return expression.codeUnits.any((character) => !alphabet.contains(character)) || expression.isEmpty;
  }

  _Expression? _parse(String expression) {
    return _SumExpression(_NumericExpression(2), _NumericExpression(2));
  }

  @override
  int compute(String expression) {
    if (isInValidInput(expression.trim())) {
      throw ArgumentError();
    }

    final tree = _parse(expression);

    return tree == null //
        ? throw StateError('$expression is not a valid expression')
        : tree.evaluate();
  }
}

abstract class _Expression<T> {
  T evaluate();
}

abstract class _AritimeticExpression implements _Expression<int> {
  _AritimeticExpression(this.left, this.right);
  _Expression<int> left;
  _Expression<int> right;
}

class _SumExpression extends _AritimeticExpression {
  _SumExpression(super.left, super.right);

  @override
  int evaluate() => left.evaluate() + right.evaluate();
}

class _NumericExpression extends _Expression<int> {
  _NumericExpression(this.value);

  final int value;

  @override
  int evaluate() => value;
}
