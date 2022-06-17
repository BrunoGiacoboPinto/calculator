import 'dart:collection';

abstract class Calculator {
  Calculator._();

  int compute(String expression);

  factory Calculator() => _CalculatorImpl();
}

class _CalculatorImpl extends Calculator {
  _CalculatorImpl() : super._();

  static final alphabet = '+-/*0123456789().'.codeUnits;
  static final closeParentesis = ')'.codeUnits[0];
  static final openParentesis = '('.codeUnits[0];
  static final operators = '+-/*';

  // TODO(giacobo): put back support for negative numbers. Probably via peek ahead
  static final numberRegex = RegExp(r'^(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  bool isInValidInput(String expression) {
    return expression.codeUnits.any((character) => !alphabet.contains(character)) || expression.isEmpty;
  }

  bool hasBalancedParentesis(String expression) {
    final closeParentesisCount = expression.codeUnits.where((character) => character == closeParentesis).length;
    final openParentesisCount = expression.codeUnits.where((character) => character == openParentesis).length;
    return closeParentesisCount == openParentesisCount;
  }

  bool isNumeric(String value) {
    return numberRegex.hasMatch(value);
  }

  bool isOperateor(String value) {
    return operators.contains(value);
  }

  List<_Token> tokenize(String expression) {
    final tokens = <_Token>[];

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        tokens.add(_OpenBracketToken());
      } else if (expression[i] == ')') {
        tokens.add(_CloseBracketToken());
      } else if (operators.contains(expression[i])) {
        tokens.add(_OperatorToken(expression[i]));
      } else if (isNumeric(expression[i])) {
        final number = StringBuffer();
        int indexOfNumber = i;
        do {
          number.write(expression[indexOfNumber]);
          indexOfNumber++;

          if (indexOfNumber == expression.length) {
            break;
          }
        } while (isNumeric(expression[indexOfNumber]) || expression[indexOfNumber] == '.');

        i = indexOfNumber - 1;

        tokens.add(
          _NumberToken(int.parse(number.toString())),
        );
      }
    }

    return tokens;
  }

  // For more info check: https://aquarchitect.github.io/swift-algorithm-club/Shunting%20Yard/
  _Expression? shuntingYard(String expression) {
    final output = Queue<_Token>();
    final operators = Queue<_Token>();

    final tokens = tokenize(expression);

    for (final token in tokens) {
      if (token is _NumberToken) {
        output.add(token);
      } else if (token is _OpenBracketToken) {
        operators.addLast(token);
      } else if (token is _CloseBracketToken) {
        if (operators.isNotEmpty) {
          _Token operator = operators.removeLast();
          while (operator is! _OpenBracketToken) {
            output.add(operator);
            operator = operators.removeLast();
            if (operators.isEmpty) {
              break;
            }
          }
        }
      } else if (token is _OperatorToken) {
        if (operators.isNotEmpty && operators.last is _OperatorToken) {
          for (var operator = operators.last; operator is _OperatorToken; operator = operators.last) {
            if (token.precedence <= operator.precedence) {
              output.add(operator);
              operators.removeLast();
            } else {
              break;
            }

            if (operators.isEmpty) {
              break;
            }
          }
        }

        operators.addLast(token);
      }
    }

    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }

    // TODO(giacobo): remove this print and add logger
    final shuntingYard = StringBuffer();

    for (final token in output) {
      shuntingYard.write(token.value);
    }

    print(shuntingYard);

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

    final tree = shuntingYard(cleanExpression);

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

abstract class _Token<T> {
  _Token(this.value);

  final T value;

  @override
  String toString() {
    return value.toString();
  }
}

class _NumberToken extends _Token<int> {
  _NumberToken(super.value);
}

class _OpenBracketToken extends _Token<String> {
  _OpenBracketToken() : super('(');
}

class _CloseBracketToken extends _Token<String> {
  _CloseBracketToken() : super(')');
}

class _OperatorToken extends _Token<String> {
  _OperatorToken(super.value);

  static final _precedence = <String, int>{
    '-': 1,
    '+': 1,
    '*': 2,
    '/': 2,
  };

  int get precedence => _precedence[value]!;
}
