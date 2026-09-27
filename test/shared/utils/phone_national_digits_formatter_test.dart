import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sambasku_mobile/shared/utils/phone_country.dart';
import 'package:sambasku_mobile/shared/utils/phone_national_digits_formatter.dart';

void main() {
  group('stripLeadingTrunkZeros', () {
    test('membuang 0 di depan', () {
      expect(stripLeadingTrunkZeros('0'), '');
      expect(stripLeadingTrunkZeros('081234567890'), '81234567890');
      expect(stripLeadingTrunkZeros('81234567890'), '81234567890');
    });
  });

  group('toInternationalPhoneDigits', () {
    test('gabung dial code + nasional', () {
      expect(
        toInternationalPhoneDigits(kPhoneCountryId, '81234567890'),
        '6281234567890',
      );
      expect(
        toInternationalPhoneDigits(kPhoneCountryMy, '0123456789'),
        '60123456789',
      );
      expect(toInternationalPhoneDigits(kPhoneCountryId, ''), '');
    });
  });

  group('parseStoredPhone', () {
    test('parse ID dan MY', () {
      final id = parseStoredPhone('6281234567890');
      expect(id.country.iso2, 'ID');
      expect(id.national, '81234567890');

      final my = parseStoredPhone('60123456789');
      expect(my.country.iso2, 'MY');
      expect(my.national, '123456789');
    });

    test('utama ID dan MY di depan daftar', () {
      expect(kPrimaryPhoneCountries.map((c) => c.iso2).toList(), ['ID', 'MY']);
    });
  });

  group('PhoneNationalDigitsFormatter', () {
    const formatter = PhoneNationalDigitsFormatter();

    TextEditingValue apply(String text) {
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
    }

    test('strip leading 0 saat ketik', () {
      expect(apply('0').text, '');
      expect(apply('08').text, '8');
      expect(apply('812').text, '812');
    });
  });
}
