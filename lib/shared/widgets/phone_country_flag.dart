import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../utils/phone_country.dart';

/// Bendera negara: emoji di atas chip ISO2 (fallback Latin selalu terbaca).
///
/// Flutter tidak bisa mendeteksi gagal-render flag emoji; chip di belakang
/// memastikan kode negara tetap terlihat jika glyph kosong/tofu.
class PhoneCountryFlag extends StatelessWidget {
  const PhoneCountryFlag({
    super.key,
    required this.iso2,
    required this.flagEmoji,
    this.size = 22,
  });

  factory PhoneCountryFlag.fromCountry(
    PhoneCountry country, {
    Key? key,
    double size = 22,
  }) {
    return PhoneCountryFlag(
      key: key,
      iso2: country.iso2,
      flagEmoji: country.flagEmoji,
      size: size,
    );
  }

  final String iso2;
  final String flagEmoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = iso2.toUpperCase();
    final chipFontSize = size * 0.42;

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: size * 1.25,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: BorderRadius.circular(3),
              ),
              child: SizedBox.expand(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: chipFontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              flagEmoji,
              style: TextStyle(fontSize: size, height: 1),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
