import 'package:flutter/services.dart';

import 'phone_country.dart';

/// Digit saja + buang trunk prefix `0` di depan (E.164 national significant).
class PhoneNationalDigitsFormatter extends TextInputFormatter {
  const PhoneNationalDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = stripLeadingTrunkZeros(newValue.text);
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
