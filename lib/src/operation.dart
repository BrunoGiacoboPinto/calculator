import 'package:calculator/src/sign.dart';
import 'package:calculator/src/validator.dart';

class Addition extends Operation {
  Addition(String input)
      : assert(input.contains(sign.symbol), 'A sum operation should contain a + (plus) sign!'),
        super(sign, input, (a, b) => a + b);

  static const sign = Sign.plus;
}

class Subtraction extends Operation {
  Subtraction(String input)
      : assert(input.contains(sign.symbol), 'A subtract operation should contain a - (minus) sign!'),
        super(sign, input, (a, b) => a - b);

  static const sign = Sign.minus;
}

class Multiplication extends Operation {
  Multiplication(String input)
      : assert(input.contains(sign.symbol), 'A multiply operation should contain a * (times) sign!'),
        super(sign, input, (a, b) => a * b);

  static const sign = Sign.times;
}

class Division extends Operation {
  Division(String input)
      : assert(input.contains(sign.symbol), 'A divide operation should contain a / (divide) sign!'),
        super(sign, input, (a, b) => a / b);

  static const sign = Sign.divide;
}

abstract class Operation {
  const Operation(this._sign, this._input, this._formula);

  final Sign _sign;
  final String _input;
  final num Function(num, num) _formula;

  num get result {
    final values = Validator.validateOperationInput(_sign, _input);

    return _formula(values.left, values.right);
  }
}
