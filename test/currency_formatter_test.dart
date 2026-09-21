import 'package:flutter_test/flutter_test.dart';
import 'package:clanship_cliente/core/utils/currency_formatter.dart';

void main() {
  group('formatCurrency', () {
    test('formats integers and floats to Chilean Peso format', () {
      expect(formatCurrency(20000), '\$20.000');
      expect(formatCurrency(20000.0), '\$20.000');
      expect(formatCurrency(1500000), '\$1.500.000');
      expect(formatCurrency(0), '\$0');
    });

    test('formats string numbers including .00 or ,00 without decimals', () {
      expect(formatCurrency('20000'), '\$20.000');
      expect(formatCurrency('20000.00'), '\$20.000');
      expect(formatCurrency('20000,00'), '\$20.000');
      expect(formatCurrency('20.000'), '\$20.000');
    });

    test('handles options includeSymbol and defaultValue', () {
      expect(formatCurrency(20000, includeSymbol: false), '20.000');
      expect(formatCurrency(null), '');
      expect(formatCurrency(null, defaultValue: 'A convenir'), 'A convenir');
      expect(formatCurrency('', defaultValue: 'A convenir'), 'A convenir');
    });
  });
}
