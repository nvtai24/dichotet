import 'package:flutter/services.dart';

/// Formats a number input with thousand-separator commas (e.g. 1000000 → 1,000,000).
/// Always positions the cursor at the end.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = _addCommas(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _addCommas(String digits) {
    final buffer = StringBuffer();
    final start = digits.length % 3;
    if (start > 0) buffer.write(digits.substring(0, start));
    for (int i = start; i < digits.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(digits.substring(i, i + 3));
    }
    return buffer.toString();
  }
}

/// Strips commas and parses to double. Returns 0 if invalid.
double parseCurrency(String text) =>
    double.tryParse(text.replaceAll(',', '')) ?? 0;

/// Formats an initial numeric value for display in a currency text field.
String formatCurrencyInitial(num value) {
  final digits = value.toInt().toString();
  return CurrencyInputFormatter._addCommas(digits);
}
