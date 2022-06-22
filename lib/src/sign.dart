enum Sign {
  plus('+', {SignRule.mayHaveAtLeastRight}),
  minus('-', {SignRule.mayHaveAtLeastRight}),
  times('*', {SignRule.shouldHaveLeftAndRight, SignRule.shouldHavePriority}),
  divide('/', {SignRule.shouldHaveLeftAndRight, SignRule.rightIsZeroDifferent, SignRule.shouldHavePriority});

  const Sign(this.symbol, this.rules);

  factory Sign.fromSymbol(String value) {
    try {
      return Sign.values.singleWhere((sign) => sign.symbol == value);
    } catch (_) {
      throw UnrecognizedSymbolException(value);
    }
  }

  final String symbol;
  final Set<SignRule> rules;

  bool get hasPriority => rules.contains(SignRule.shouldHavePriority);
}

enum SignRule {
  shouldHavePriority,
  shouldHaveLeftAndRight,
  mayHaveAtLeastRight,
  rightIsZeroDifferent;
}

class UnrecognizedSymbolException {
  const UnrecognizedSymbolException(this.value);

  final String value;

  @override
  String toString() {
    return 'It was not possible to find a Sign that matches the symbol $value';
  }
}
