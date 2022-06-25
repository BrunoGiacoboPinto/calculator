import 'package:calculator/calculator.dart';
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    final calculator = Calculator();
    test('should not allow invalid characters as input', () {
      expect(() => calculator.compute('🎉🎉🎉🎉🎉'), throwsArgumentError);
      expect(() => calculator.compute('..'), throwsFormatException);
      expect(() => calculator.compute('\t\n23'), throwsArgumentError);
      expect(() => calculator.compute('@ + 10'), throwsArgumentError);
      expect(() => calculator.compute('abcd'), throwsArgumentError);
      expect(() => calculator.compute('.'), throwsFormatException);
      expect(() => calculator.compute(' '), throwsArgumentError);
      expect(() => calculator.compute(''), throwsArgumentError);
      expect(calculator.compute('10'), 10);
    });

    test('should handle balanced parentesis', () {
      expect(() => calculator.compute('((1+2) + 1'), throwsStateError);
      expect(() => calculator.compute('((2+2)'), throwsStateError);
      expect(() => calculator.compute('1+1)'), throwsStateError);
      expect(() => calculator.compute('(1+1'), throwsStateError);
      expect(() => calculator.compute(')'), throwsStateError);
      expect(() => calculator.compute('('), throwsStateError);
      expect(calculator.compute('(((3+3)))'), 6);
    });

    test('should support all basic arithmetic operations', () {
      expect(calculator.compute('1 + 1'), 2);
      expect(calculator.compute('1 - 5'), -4);
      expect(calculator.compute('3 * 9'), 27);
      expect(calculator.compute('27 / 3'), 9);
    });

    test('should compute complex expression', () {
      expect(calculator.compute('4 + 4 * 2 /(1-5)'), 2);
      expect(calculator.compute('10 + 10 + 10 + 10 + 10'), 50);
      expect(calculator.compute('4 * 2 / ( 1 - 5 )'), -2);
      expect(calculator.compute('4 * (2-1)'), 4);
      expect(calculator.compute('2+(1-2)'), 1);
    });
  });
}
