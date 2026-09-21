import 'package:flutter_test/flutter_test.dart';
import 'package:clanship_cliente/core/utils/text_formatter.dart';

void main() {
  group('formatBioText', () {
    test('formats Sergio Paredes bio sample accurately', () {
      const input = '''
servicio en área construcción, ampliación, remo
delación,pintura,soldadura,hormigón,corte  de
pasto            ,cierre            de
parcelas  ,etc..responsabilad  ,experiencia  y
limpieza en cada trabajo...
''';

      final result = formatBioText(input);

      expect(
        result,
        'Servicio en área construcción, ampliación, remodelación, pintura, soldadura, hormigón, corte de pasto, cierre de parcelas, etc., responsabilad, experiencia y limpieza en cada trabajo...',
      );
    });

    test('preserves intentional paragraphs', () {
      const input = 'Párrafo uno.\n\nPárrafo dos con más texto.';
      expect(formatBioText(input), 'Párrafo uno.\n\nPárrafo dos con más texto.');
    });

    test('preserves list items', () {
      const input = '''
Servicios:
- Gasfitería
- Pintura
- Electricidad
''';
      expect(
        formatBioText(input),
        'Servicios:\n- Gasfitería\n- Pintura\n- Electricidad',
      );
    });

    test('handles empty or null gracefully', () {
      expect(formatBioText(null), '');
      expect(formatBioText('   '), '');
    });
  });
}
