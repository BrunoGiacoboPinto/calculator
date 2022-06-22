import 'package:calculator/src/operation.dart';
import 'package:calculator/src/sign.dart';
import 'package:calculator/src/validator.dart';

abstract class Calculator {
  const Calculator._();

  factory Calculator() => _CalculatorImpl();

  num compute(String expression) {
    String newExpression = expression.clearSignAmbiguity();

    int? firstSignIndex = newExpression.getFirstSignIndex();
    int? nextSignIndex = newExpression.getNextSignIndex(firstSignIndex);

    if (firstSignIndex == null) {
      return num.parse(newExpression);
    } else {
      num result = 0;

      while (firstSignIndex != null) {
        final sign = Sign.fromSymbol(newExpression[firstSignIndex]);
        final smallExpression = nextSignIndex != null ? newExpression.substring(0, nextSignIndex) : newExpression;

        result = sign.selectOperation(smallExpression).result;
        newExpression = newExpression.replaceRange(0, nextSignIndex, '$result');

        if (nextSignIndex != null) {
          firstSignIndex = newExpression.getFirstSignIndex();
          nextSignIndex = newExpression.getNextSignIndex(firstSignIndex);
        } else {
          firstSignIndex = null;
        }
      }

      return result;
    }
  }
}

class _CalculatorImpl extends Calculator {
  const _CalculatorImpl() : super._();

  @override
  num compute(String expression) {
    var newExpression = expression.trim().clearSignAmbiguity();

    if (newExpression.contains(_StringPattern.parenthesis)) {
      Validator.checkParenthesis(newExpression);

      return _ParenthesisCalculator().compute(newExpression);
    } else if (expression.contains('*') || newExpression.contains('/')) {
      return _PriorityCalculator().compute(newExpression);
    } else {
      return super.compute(newExpression);
    }
  }
}

class _ParenthesisCalculator extends Calculator {
  const _ParenthesisCalculator() : super._();

  @override
  num compute(String expression) {
    var newExpression = expression;

    num getResult(String expression) {
      if (expression.contains('*') || newExpression.contains('/')) {
        return _PriorityCalculator().compute(expression);
      } else {
        return super.compute(expression);
      }
    }

    while (newExpression.contains(_StringPattern.parenthesisContent)) {
      newExpression = newExpression.clearSignAmbiguity().replaceParenthesis(
            (newExpression) => getResult(newExpression).toString(),
          );
    }

    return getResult(newExpression);
  }
}

class _PriorityCalculator extends Calculator {
  const _PriorityCalculator() : super._();

  @override
  num compute(String expression) {
    var newExpression = expression;
    var previousSignIndex = 0;
    int? actualSignIndex;
    int? lastSignIndex;

    var index = 0;
    while (index < newExpression.length) {
      final symbol = newExpression[index];

      if (symbol.isSign) {
        if (Sign.fromSymbol(symbol).hasPriority) {
          actualSignIndex = index;

          if (newExpression[index + 1] == Sign.plus.symbol || newExpression[index + 1] == Sign.minus.symbol) {
            index++;
          }
        } else {
          if (actualSignIndex == null) {
            previousSignIndex = index;
          } else {
            lastSignIndex = index;
          }
        }
      }

      if (lastSignIndex != null) {
        final priorityExpression = newExpression.substring(previousSignIndex + 1, lastSignIndex);
        newExpression = newExpression.replaceAll(priorityExpression, super.compute(priorityExpression).toString());

        actualSignIndex = null;
        lastSignIndex = null;
      }

      if (index == newExpression.length - 1 && actualSignIndex != null) {
        final priorityExpression = newExpression.substring(previousSignIndex);
        newExpression = newExpression.replaceAll(priorityExpression, super.compute(priorityExpression).toString());

        actualSignIndex = null;
      }

      index++;
    }

    return super.compute(newExpression);
  }
}

extension on Sign {
  Operation selectOperation(String expression) {
    switch (this) {
      case Sign.plus:
        return Addition(expression);
      case Sign.minus:
        return Subtraction(expression);
      case Sign.times:
        return Multiplication(expression);
      case Sign.divide:
        return Division(expression);
    }
  }
}

extension _StringPattern on String {
  static final parenthesis = RegExp(r'[)(]');
  static final parenthesisContent = RegExp(r'\(([^\)(]+)\)');
  static final equalMinusSignPattern = RegExp(r'(\+\-)|(\-\+)');
  static final equalPlusSignPattern = RegExp(r'(\+\+)|(\-\-)');
}

extension on String {
  String replaceParenthesis([String Function(String)? computation]) {
    return replaceAllMapped(_StringPattern.parenthesisContent, (match) {
      final newExpression = match[0]!.replaceAll(_StringPattern.parenthesis, '');

      return computation?.call(newExpression) ?? newExpression;
    });
  }

  String clearSignAmbiguity() {
    String newExpression = this;

    if (newExpression.contains(_StringPattern.equalMinusSignPattern)) {
      newExpression = newExpression.replaceAll(_StringPattern.equalMinusSignPattern, '-');
    }

    if (newExpression.contains(_StringPattern.equalPlusSignPattern)) {
      newExpression = newExpression.replaceAll(_StringPattern.equalPlusSignPattern, '+');
    }

    return newExpression;
  }

  bool get isSign => Sign.values.map((e) => e.symbol).contains(this);

  int? getFirstSignIndex() {
    int startIndex = 0;

    if (this[startIndex] == Sign.minus.symbol) {
      startIndex++;
    }

    for (var index = startIndex; index < length; index++) {
      if (this[index].isSign) {
        return index;
      }
    }

    return null;
  }

  int? getNextSignIndex([int? firstIndex]) {
    if (firstIndex != null) {
      int startIndex = firstIndex + 1;

      if (this[startIndex] == Sign.plus.symbol || this[startIndex] == Sign.minus.symbol) {
        startIndex++;
      }

      for (var index = startIndex; index < length; index++) {
        if (this[index].isSign) {
          return index;
        }
      }
    }

    return null;
  }
}
