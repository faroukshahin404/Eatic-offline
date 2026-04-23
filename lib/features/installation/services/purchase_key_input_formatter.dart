import 'package:flutter/services.dart';

class PurchaseKeyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited =
        digitsOnly.length > 16 ? digitsOnly.substring(0, 16) : digitsOnly;
    final formatted = _formatWithGroups(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithGroups(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}
