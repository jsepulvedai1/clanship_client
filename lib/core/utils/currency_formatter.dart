import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatea un valor numérico o cadena de dinero a formato estándar chileno (CLP):
/// Ejemplo: 20000 -> "$20.000", "20000.00" -> "$20.000".
String formatCurrency(
  dynamic amount, {
  bool includeSymbol = true,
  String defaultValue = '',
}) {
  if (amount == null) return defaultValue;
  num? parsed;

  if (amount is num) {
    parsed = amount;
  } else if (amount is String) {
    final s = amount.trim();
    if (s.isEmpty) return defaultValue;

    // Si ya viene formateado con separadores de miles estilo 20.000 o 1.500.000
    if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(s)) {
      parsed = int.tryParse(s.replaceAll('.', ''));
    } else {
      String clean = s;
      if (clean.contains(',') && !clean.contains('.')) {
        clean = clean.replaceAll(',', '.');
      }
      parsed = double.tryParse(clean);
    }
  }

  if (parsed == null) {
    return defaultValue.isNotEmpty ? defaultValue : amount.toString();
  }

  final formatted = NumberFormat.decimalPattern('es_CL').format(parsed.round());
  return includeSymbol ? '\$$formatted' : formatted;
}

/// Formateador de texto para campos de entrada monetarios:
/// Aplica separador de miles dinámicamente mientras el usuario escribe (ej. 20000 -> 20.000).
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int? value = int.tryParse(digitsOnly);
    if (value == null) {
      return oldValue;
    }

    final String newText = NumberFormat.decimalPattern('es_CL').format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
