const otpCodeLength = 6;

/// Buang selain 0-9A-Z, huruf besar. Tidak memotong panjang.
String normalizeOtpInput(String raw) =>
    raw.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();

/// Tampilan `XXX-YYY`, max 6 karakter.
String formatOtpDisplay(String raw) {
  final code = normalizeOtpInput(raw);
  final clipped = code.length > otpCodeLength
      ? code.substring(0, otpCodeLength)
      : code;
  if (clipped.length <= 3) return clipped;
  return '${clipped.substring(0, 3)}-${clipped.substring(3)}';
}
