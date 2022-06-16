import 'package:calculator/calculator.dart';
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    final calculator = Calculator();
    test('should not allow invalid characters as input', () {
      expect(() => calculator.compute('@ + 10'), throwsArgumentError);
      expect(() => calculator.compute('abcd'), throwsArgumentError);
      expect(() => calculator.compute(''), throwsArgumentError);
    });

    test('should compute simple expression', () {
      expect(calculator.compute('2+2'), 4);
    });
  });
}
