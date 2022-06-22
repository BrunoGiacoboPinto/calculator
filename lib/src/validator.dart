import 'package:calculator/src/sign.dart';

class Validator {
  static void checkParenthesis(String input) {
    var startParenthesisIndexList = List<int>.empty(growable: true);
    var endParenthesisIndexList = List<int>.empty(growable: true);

    for (var index = 0; index < input.length; index++) {
      if (input[index] == '(') {
        startParenthesisIndexList.add(index);
      } else if (input[index] == ')') {
        endParenthesisIndexList.add(index);
      }
    }

    if (startParenthesisIndexList.length != endParenthesisIndexList.length) {
      throw UnequalParenthesisAmountException();
    }

    for (var index = 0; index < startParenthesisIndexList.length; index++) {
      if (endParenthesisIndexList[index] < startParenthesisIndexList[index]) {
        throw OpenParenthesisGroupException();
      }
    }
  }

  static num validateNumber(String value) {
    try {
      return num.parse(value);
    } catch (_) {
      throw NotANumberException(value);
    }
  }

  static ValidOperationValues validateOperationInput(Sign sign, String input) {
    List<String> values;
    String left;
    String right;

    if (input.length == 2) {
      left = '';
      right = input;
    } else if (input[0] == sign.symbol) {
      values = input.substring(1).split(sign.symbol);
      left = '${input[0]}${values.first}';
      right = values.last;
    } else {
      values = input.split(sign.symbol);
      left = values.first;
      right = values.last;
    }

    for (final rule in sign.rules) {
      switch (rule) {
        case SignRule.shouldHaveLeftAndRight:
          if (left.isEmpty || right.isEmpty) {
            throw ShouldHaveLeftAndRightRuleException();
          }

          break;
        case SignRule.mayHaveAtLeastRight:
          if (right.isEmpty) {
            throw MayHaveAtLeastRightRuleException();
          }

          break;
        case SignRule.rightIsZeroDifferent:
          if (num.parse(right) == 0.0) {
            throw RightIsZeroDifferentRuleException();
          }

          break;
        default:
          break;
      }
    }

    final leftValue = left.isNotEmpty ? validateNumber(left) : 0;
    final rightValue = validateNumber(right);

    return ValidOperationValues(leftValue, rightValue);
  }
}

class ValidOperationValues {
  const ValidOperationValues(this.left, this.right);

  final num left;
  final num right;
}

class NotANumberException implements Exception {
  const NotANumberException(this.value);

  final String value;

  @override
  String toString() {
    return '$value is not a number!';
  }
}

class ParenthesisValidationException implements Exception {
  @override
  String toString() {
    return 'Something went wrong while validating parenthesis!';
  }
}

class UnequalParenthesisAmountException extends ParenthesisValidationException {
  @override
  String toString() {
    return "${super.toString()}\nThere should be an equal amount of start '(' and end ')' parenthesis.";
  }
}

class OpenParenthesisGroupException extends ParenthesisValidationException {
  @override
  String toString() {
    return "${super.toString()}\nSome parenthesis group is not closed! Be sure that for each '(', there should be a ')',"
        " where '(' should come first.";
  }
}

class SingRuleException implements Exception {
  @override
  String toString() {
    return 'A sign rule has been broken!';
  }
}

class ShouldHaveLeftAndRightRuleException extends SingRuleException {
  @override
  String toString() {
    return "${super.toString()}\nSome Signs require that both sides have a value."
        " For example, '19 * 5', instead of '* 5' or '19 /'.";
  }
}

class MayHaveAtLeastRightRuleException extends SingRuleException {
  @override
  String toString() {
    return "${super.toString()}\nSome Signs may require that both sides have a value,"
        " or at least the right side should have."
        " For example, '19 + 5' and '+ 5' are valid, but '19 +' is not.";
  }
}

class RightIsZeroDifferentRuleException extends SingRuleException {
  @override
  String toString() {
    return "${super.toString()}\nSome Signs require that the right value should be different from 0 (zero)."
        " For example, '1 / 5' and '0 / 5' are valid, but '1 / 0' is not.";
  }
}
