import 'dart:collection';

abstract class Calculator {
  Calculator._();

  int compute(String expression);

  factory Calculator() => _CalculatorImpl();
}

class _CalculatorImpl extends Calculator {
  _CalculatorImpl() : super._();

  static final kAlphabet = '+-/*0123456789().'.codeUnits;
  static final kCloseParentesis = ')'.codeUnits[0];
  static final kOpenParentesis = '('.codeUnits[0];
  static final kOperators = '+-/*';

  // TODO(giacobo): put back support for negative numbers. Probably via peek ahead
  static final kNumberRegex = RegExp(r'^(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  bool isInValidInput(String expression) {
    return expression.codeUnits.any((character) => !kAlphabet.contains(character)) || expression.isEmpty;
  }

  bool hasBalancedParentesis(String expression) {
    final closeParentesisCount = expression.codeUnits.where((character) => character == kCloseParentesis).length;
    final openParentesisCount = expression.codeUnits.where((character) => character == kOpenParentesis).length;
    return closeParentesisCount == openParentesisCount;
  }

  bool isNumeric(String value) {
    return kNumberRegex.hasMatch(value);
  }

  bool isOperateor(String value) {
    return kOperators.contains(value);
  }

  List<_Token> tokenize(String expression) {
    final tokens = <_Token>[];

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        tokens.add(_OpenBracketToken());
      } else if (expression[i] == ')') {
        tokens.add(_CloseBracketToken());
      } else if (kOperators.contains(expression[i])) {
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
    final tree = Queue<_AritimeticExpression>();

    void addExpressionToTree(_Token token, _Expression<int> left, _Expression<int> right) {
      if (token is _OperatorToken) {
        switch (token.value) {
          case '+':
            {
              tree.addLast(_AdditionExpression(left, right));
              break;
            }
          case '-':
            {
              tree.addLast(_SubtractionExpression(left, right));
              break;
            }
          case '*':
            {
              tree.addLast(_MultiplicationExpression(left, right));
              break;
            }
          case '/':
            {
              tree.addLast(_DivisionExpression(left, right));
              break;
            }
        }
      }
    }

    final output = Queue<_Token>();
    final operators = Queue<_Token>();
    final numbers = Queue<_NumericExpression>();

    final tokens = tokenize(expression);

    for (final token in tokens) {
      if (token is _NumberToken) {
        output.add(token);
        numbers.add(_NumericExpression(token.value));
      } else if (token is _OpenBracketToken) {
        operators.addLast(token);
      } else if (token is _CloseBracketToken) {
        if (operators.isNotEmpty) {
          _Token operator = operators.removeLast();
          while (operator is! _OpenBracketToken) {
            output.add(operator);
            _Expression<int> right, left;
            if (numbers.length > 1) {
              right = numbers.removeLast();
              left = numbers.removeLast();
            } else {
              right = numbers.removeLast();
              left = tree.removeLast();
            }
            addExpressionToTree(operator, left, right);
            if (operators.isEmpty) {
              break;
            }
            operator = operators.removeLast();
          }
        }
      } else if (token is _OperatorToken) {
        if (operators.isNotEmpty && operators.last is _OperatorToken) {
          for (var operator = operators.last; operator is _OperatorToken; operator = operators.last) {
            if (token.precedence <= operator.precedence) {
              output.add(operator);
              operators.removeLast();
              _Expression<int> right, left;
              if (numbers.length > 1) {
                right = numbers.removeLast();
                left = numbers.removeLast();
              } else {
                right = numbers.removeLast();
                left = tree.removeLast();
              }
              addExpressionToTree(operator, left, right);
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
      final operator = operators.removeLast();
      late _Expression<int> left, right;

      if (operators.length.isEven) {
        if (numbers.length > 1) {
          right = numbers.removeLast();
          left = numbers.removeLast();
        } else {
          right = numbers.removeLast();
          left = tree.removeLast();
        }
      } else {
        right = tree.removeLast();
        left = tree.removeLast();
      }

      addExpressionToTree(operator, left, right);
    }

    // TODO(giacobo): remove this print and add logger
    final shuntingYard = StringBuffer();

    for (final token in output) {
      shuntingYard.write(token.value);
    }

    print(shuntingYard);

    return tree.removeLast();
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
        ? throw StateError('$expression is not a valid aritmetic expression')
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

class _AdditionExpression extends _AritimeticExpression {
  _AdditionExpression(super.left, super.right);

  @override
  int evaluate() => left.evaluate() + right.evaluate();

  @override
  String toString() => '+';
}

class _SubtractionExpression extends _AritimeticExpression {
  _SubtractionExpression(super.left, super.right);

  @override
  int evaluate() => left.evaluate() - right.evaluate();

  @override
  String toString() => '-';
}

class _MultiplicationExpression extends _AritimeticExpression {
  _MultiplicationExpression(super.left, super.right);

  @override
  int evaluate() => left.evaluate() * right.evaluate();

  @override
  String toString() => '*';
}

class _DivisionExpression extends _AritimeticExpression {
  _DivisionExpression(super.left, super.right);

  @override
  int evaluate() => left.evaluate() ~/ right.evaluate();

  @override
  String toString() => '/';
}

class _NumericExpression extends _Expression<int> {
  _NumericExpression(this.value);

  final int value;

  @override
  int evaluate() => value;

  @override
  String toString() {
    return value.toString();
  }
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

/*
  TODO:
    - Adicionar github actions
    - Adiconar mais testes
    - Tratar sinal de menos
    - Adicionar ponto flutuante
    - Adicionar exponenciacao
    - Adicionar referencias
    - Adicionar implementacao da main
    - Atualizar readme com bibliotecas liberadas
    - Fazer TODO não aparecer no linter
    - Adicionar infos do setup no readme
    - Adicionar licença
    - Adicionar badge de build
    - Arrumar o xcode
    - Melhorias gerais, tipo enum para precedence
 */
