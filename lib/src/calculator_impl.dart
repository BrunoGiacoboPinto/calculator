abstract class Calculator {
  Calculator._();

  int compute(String expression);

  factory Calculator() => _CalculatorImpl();
}

class _CalculatorImpl extends Calculator {
  _CalculatorImpl() : super._();

  static final alphabet = '+-/*0123456789()'.codeUnits;
  static final closeParentesis = ')'.codeUnits[0];
  static final openParentesis = '('.codeUnits[0];

  bool isInValidInput(String expression) {
    return expression.codeUnits.any((character) => !alphabet.contains(character)) || expression.isEmpty;
  }

  bool hasBalancedParentesis(String expression) {
    final closeParentesisCount = expression.codeUnits.where((character) => character == closeParentesis).length;
    final openParentesisCount = expression.codeUnits.where((character) => character == openParentesis).length;
    return closeParentesisCount == openParentesisCount;
  }

  _Expression? _parse(String expression) {
    return _SumExpression(_NumericExpression(2), _NumericExpression(2));
  }

  @override
  int compute(String expression) {
    final cleanExpression = expression.replaceAll(' ', ''); 
    if (isInValidInput(cleanExpression)) {
      throw ArgumentError();
    }

    if (!hasBalancedParentesis(cleanExpression)) {
      throw StateError('$expression does not have balanced parentesis');
    }

    final tree = _parse(cleanExpression);

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
