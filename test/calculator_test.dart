import 'package:calculator/calculator.dart';
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    final calculator = Calculator();
    test('should not allow invalid characters as input', () {
      expect(() => calculator.compute('\t\n23'), throwsArgumentError);
      expect(() => calculator.compute('@ + 10'), throwsArgumentError);
      expect(() => calculator.compute('abcd'), throwsArgumentError);
      expect(() => calculator.compute(' '), throwsArgumentError);
      expect(() => calculator.compute('.'), throwsArgumentError);
      expect(() => calculator.compute(''), throwsArgumentError);
    });

    test('should handle balanced parentesis', () {
      expect(() => calculator.compute('((1+2) + 1'), throwsStateError);
      expect(() => calculator.compute('1+1)'), throwsStateError);
      expect(() => calculator.compute('(1+1'), throwsStateError);
      expect(() => calculator.compute(')'), throwsStateError);
      expect(() => calculator.compute('('), throwsStateError);
      expect(calculator.compute('(2+2)'), 4);
      expect(calculator.compute('2+2'), 4);
    });

    test('should compute simple expression', () {
      expect(calculator.compute('2+2'), 4);
    });
  });
}
