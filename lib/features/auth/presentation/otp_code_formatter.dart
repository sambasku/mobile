import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../otp_code.dart';

/// Slot [FOtpField] untuk OTP 6 karakter: XXX | YYY.
const otpFieldChildren = <Widget>[
  FOtpItem(),
  FOtpItem(),
  FOtpItem(),
  FOtpDivider(),
  FOtpItem(),
  FOtpItem(),
  FOtpItem(),
];

/// Slot lebih besar + font display digital (Orbitron).
///
/// Warna per-variant (disabled/error) tetap dari tema; hanya tipografi diganti.
FOtpFieldStyleDelta otpFieldStyle() {
  // Side-effect: daftarkan face ke FontLoader google_fonts.
  final digital = GoogleFonts.orbitron();
  return .delta(
    itemSize: const Size(40, 48),
    itemStyles: .delta([
      .all(
        .delta(
          contentTextStyle: .delta(
            fontFamily: digital.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            height: 1,
          ),
        ),
      ),
    ]),
  );
}

/// Input OTP 6 karakter 0-9A-Z, tampilan XXX-YYY (untuk [FTextField]).
class OtpCodeDashFormatter extends TextInputFormatter {
  const OtpCodeDashFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final display = formatOtpDisplay(newValue.text);
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}

/// Input OTP 6 karakter 0-9A-Z tanpa dash (divider visual di [FOtpField]).
class OtpCodeAlphanumericFormatter extends TextInputFormatter {
  const OtpCodeAlphanumericFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final code = normalizeOtpInput(newValue.text);
    final clipped = code.length > otpCodeLength
        ? code.substring(0, otpCodeLength)
        : code;
    return TextEditingValue(
      text: clipped,
      selection: TextSelection.collapsed(offset: clipped.length),
    );
  }
}
