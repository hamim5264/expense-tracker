import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) digits = digits.substring(0, 16);
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != digits.length) buf.write(' ');
    }
    final str = buf.toString();
    return newValue.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
