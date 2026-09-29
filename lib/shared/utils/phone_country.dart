/// Negara untuk dial code No. HP (simpan API: digit internasional tanpa '+').
class PhoneCountry {
  const PhoneCountry({
    required this.iso2,
    required this.dialCode,
    required this.flagEmoji,
    required this.nameId,
  });

  final String iso2;
  final String dialCode;
  final String flagEmoji;
  final String nameId;

  /// Dial code untuk prefix field (`+62`). Bendera pakai [PhoneCountryFlag].
  String get prefixLabel => '+$dialCode';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneCountry &&
          iso2 == other.iso2 &&
          dialCode == other.dialCode;

  @override
  int get hashCode => Object.hash(iso2, dialCode);
}

const kPhoneCountryId = PhoneCountry(
  iso2: 'ID',
  dialCode: '62',
  flagEmoji: '🇮🇩',
  nameId: 'Indonesia',
);

const kPhoneCountryMy = PhoneCountry(
  iso2: 'MY',
  dialCode: '60',
  flagEmoji: '🇲🇾',
  nameId: 'Malaysia',
);

/// Dipin di section Utama bottomsheet.
const kPrimaryPhoneCountries = <PhoneCountry>[
  kPhoneCountryId,
  kPhoneCountryMy,
];

/// Daftar lengkap (urut nama ID). ID/MY ikut; sheet memisahkan ke Utama.
const kAllPhoneCountries = <PhoneCountry>[
  PhoneCountry(iso2: 'AF', dialCode: '93', flagEmoji: '🇦🇫', nameId: 'Afghanistan'),
  PhoneCountry(iso2: 'ZA', dialCode: '27', flagEmoji: '🇿🇦', nameId: 'Afrika Selatan'),
  PhoneCountry(iso2: 'AL', dialCode: '355', flagEmoji: '🇦🇱', nameId: 'Albania'),
  PhoneCountry(iso2: 'DZ', dialCode: '213', flagEmoji: '🇩🇿', nameId: 'Aljazair'),
  PhoneCountry(iso2: 'US', dialCode: '1', flagEmoji: '🇺🇸', nameId: 'Amerika Serikat'),
  PhoneCountry(iso2: 'AD', dialCode: '376', flagEmoji: '🇦🇩', nameId: 'Andorra'),
  PhoneCountry(iso2: 'AO', dialCode: '244', flagEmoji: '🇦🇴', nameId: 'Angola'),
  PhoneCountry(iso2: 'SA', dialCode: '966', flagEmoji: '🇸🇦', nameId: 'Arab Saudi'),
  PhoneCountry(iso2: 'AR', dialCode: '54', flagEmoji: '🇦🇷', nameId: 'Argentina'),
  PhoneCountry(iso2: 'AM', dialCode: '374', flagEmoji: '🇦🇲', nameId: 'Armenia'),
  PhoneCountry(iso2: 'AU', dialCode: '61', flagEmoji: '🇦🇺', nameId: 'Australia'),
  PhoneCountry(iso2: 'AT', dialCode: '43', flagEmoji: '🇦🇹', nameId: 'Austria'),
  PhoneCountry(iso2: 'AZ', dialCode: '994', flagEmoji: '🇦🇿', nameId: 'Azerbaijan'),
  PhoneCountry(iso2: 'BH', dialCode: '973', flagEmoji: '🇧🇭', nameId: 'Bahrain'),
  PhoneCountry(iso2: 'BD', dialCode: '880', flagEmoji: '🇧🇩', nameId: 'Bangladesh'),
  PhoneCountry(iso2: 'BE', dialCode: '32', flagEmoji: '🇧🇪', nameId: 'Belgia'),
  PhoneCountry(iso2: 'BJ', dialCode: '229', flagEmoji: '🇧🇯', nameId: 'Benin'),
  PhoneCountry(iso2: 'BT', dialCode: '975', flagEmoji: '🇧🇹', nameId: 'Bhutan'),
  PhoneCountry(iso2: 'BY', dialCode: '375', flagEmoji: '🇧🇾', nameId: 'Belarus'),
  PhoneCountry(iso2: 'BZ', dialCode: '501', flagEmoji: '🇧🇿', nameId: 'Belize'),
  PhoneCountry(iso2: 'BO', dialCode: '591', flagEmoji: '🇧🇴', nameId: 'Bolivia'),
  PhoneCountry(iso2: 'BA', dialCode: '387', flagEmoji: '🇧🇦', nameId: 'Bosnia dan Herzegovina'),
  PhoneCountry(iso2: 'BW', dialCode: '267', flagEmoji: '🇧🇼', nameId: 'Botswana'),
  PhoneCountry(iso2: 'BR', dialCode: '55', flagEmoji: '🇧🇷', nameId: 'Brasil'),
  PhoneCountry(iso2: 'BN', dialCode: '673', flagEmoji: '🇧🇳', nameId: 'Brunei'),
  PhoneCountry(iso2: 'BG', dialCode: '359', flagEmoji: '🇧🇬', nameId: 'Bulgaria'),
  PhoneCountry(iso2: 'BF', dialCode: '226', flagEmoji: '🇧🇫', nameId: 'Burkina Faso'),
  PhoneCountry(iso2: 'BI', dialCode: '257', flagEmoji: '🇧🇮', nameId: 'Burundi'),
  PhoneCountry(iso2: 'CZ', dialCode: '420', flagEmoji: '🇨🇿', nameId: 'Ceko'),
  PhoneCountry(iso2: 'TD', dialCode: '235', flagEmoji: '🇹🇩', nameId: 'Chad'),
  PhoneCountry(iso2: 'CL', dialCode: '56', flagEmoji: '🇨🇱', nameId: 'Chili'),
  PhoneCountry(iso2: 'CN', dialCode: '86', flagEmoji: '🇨🇳', nameId: 'China'),
  PhoneCountry(iso2: 'DK', dialCode: '45', flagEmoji: '🇩🇰', nameId: 'Denmark'),
  PhoneCountry(iso2: 'EC', dialCode: '593', flagEmoji: '🇪🇨', nameId: 'Ekuador'),
  PhoneCountry(iso2: 'SV', dialCode: '503', flagEmoji: '🇸🇻', nameId: 'El Salvador'),
  PhoneCountry(iso2: 'AE', dialCode: '971', flagEmoji: '🇦🇪', nameId: 'Emirat Arab'),
  PhoneCountry(iso2: 'ER', dialCode: '291', flagEmoji: '🇪🇷', nameId: 'Eritrea'),
  PhoneCountry(iso2: 'EE', dialCode: '372', flagEmoji: '🇪🇪', nameId: 'Estonia'),
  PhoneCountry(iso2: 'ET', dialCode: '251', flagEmoji: '🇪🇹', nameId: 'Ethiopia'),
  PhoneCountry(iso2: 'FJ', dialCode: '679', flagEmoji: '🇫🇯', nameId: 'Fiji'),
  PhoneCountry(iso2: 'PH', dialCode: '63', flagEmoji: '🇵🇭', nameId: 'Filipina'),
  PhoneCountry(iso2: 'FI', dialCode: '358', flagEmoji: '🇫🇮', nameId: 'Finlandia'),
  PhoneCountry(iso2: 'GA', dialCode: '241', flagEmoji: '🇬🇦', nameId: 'Gabon'),
  PhoneCountry(iso2: 'GM', dialCode: '220', flagEmoji: '🇬🇲', nameId: 'Gambia'),
  PhoneCountry(iso2: 'GE', dialCode: '995', flagEmoji: '🇬🇪', nameId: 'Georgia'),
  PhoneCountry(iso2: 'GH', dialCode: '233', flagEmoji: '🇬🇭', nameId: 'Ghana'),
  PhoneCountry(iso2: 'GI', dialCode: '350', flagEmoji: '🇬🇮', nameId: 'Gibraltar'),
  PhoneCountry(iso2: 'GR', dialCode: '30', flagEmoji: '🇬🇷', nameId: 'Yunani'),
  PhoneCountry(iso2: 'GT', dialCode: '502', flagEmoji: '🇬🇹', nameId: 'Guatemala'),
  PhoneCountry(iso2: 'GN', dialCode: '224', flagEmoji: '🇬🇳', nameId: 'Guinea'),
  PhoneCountry(iso2: 'GY', dialCode: '592', flagEmoji: '🇬🇾', nameId: 'Guyana'),
  PhoneCountry(iso2: 'HT', dialCode: '509', flagEmoji: '🇭🇹', nameId: 'Haiti'),
  PhoneCountry(iso2: 'HN', dialCode: '504', flagEmoji: '🇭🇳', nameId: 'Honduras'),
  PhoneCountry(iso2: 'HK', dialCode: '852', flagEmoji: '🇭🇰', nameId: 'Hong Kong'),
  PhoneCountry(iso2: 'HU', dialCode: '36', flagEmoji: '🇭🇺', nameId: 'Hungaria'),
  PhoneCountry(iso2: 'IN', dialCode: '91', flagEmoji: '🇮🇳', nameId: 'India'),
  kPhoneCountryId,
  PhoneCountry(iso2: 'GB', dialCode: '44', flagEmoji: '🇬🇧', nameId: 'Inggris'),
  PhoneCountry(iso2: 'IQ', dialCode: '964', flagEmoji: '🇮🇶', nameId: 'Irak'),
  PhoneCountry(iso2: 'IR', dialCode: '98', flagEmoji: '🇮🇷', nameId: 'Iran'),
  PhoneCountry(iso2: 'IE', dialCode: '353', flagEmoji: '🇮🇪', nameId: 'Irlandia'),
  PhoneCountry(iso2: 'IS', dialCode: '354', flagEmoji: '🇮🇸', nameId: 'Islandia'),
  PhoneCountry(iso2: 'IL', dialCode: '972', flagEmoji: '🇮🇱', nameId: 'Israel'),
  PhoneCountry(iso2: 'IT', dialCode: '39', flagEmoji: '🇮🇹', nameId: 'Italia'),
  PhoneCountry(iso2: 'JM', dialCode: '1876', flagEmoji: '🇯🇲', nameId: 'Jamaika'),
  PhoneCountry(iso2: 'JP', dialCode: '81', flagEmoji: '🇯🇵', nameId: 'Jepang'),
  PhoneCountry(iso2: 'DE', dialCode: '49', flagEmoji: '🇩🇪', nameId: 'Jerman'),
  PhoneCountry(iso2: 'DJ', dialCode: '253', flagEmoji: '🇩🇯', nameId: 'Jibuti'),
  PhoneCountry(iso2: 'JO', dialCode: '962', flagEmoji: '🇯🇴', nameId: 'Yordania'),
  PhoneCountry(iso2: 'CA', dialCode: '1', flagEmoji: '🇨🇦', nameId: 'Kanada'),
  PhoneCountry(iso2: 'KZ', dialCode: '7', flagEmoji: '🇰🇿', nameId: 'Kazakhstan'),
  PhoneCountry(iso2: 'KH', dialCode: '855', flagEmoji: '🇰🇭', nameId: 'Kamboja'),
  PhoneCountry(iso2: 'CM', dialCode: '237', flagEmoji: '🇨🇲', nameId: 'Kamerun'),
  PhoneCountry(iso2: 'QA', dialCode: '974', flagEmoji: '🇶🇦', nameId: 'Qatar'),
  PhoneCountry(iso2: 'KE', dialCode: '254', flagEmoji: '🇰🇪', nameId: 'Kenya'),
  PhoneCountry(iso2: 'CO', dialCode: '57', flagEmoji: '🇨🇴', nameId: 'Kolombia'),
  PhoneCountry(iso2: 'KR', dialCode: '82', flagEmoji: '🇰🇷', nameId: 'Korea Selatan'),
  PhoneCountry(iso2: 'KP', dialCode: '850', flagEmoji: '🇰🇵', nameId: 'Korea Utara'),
  PhoneCountry(iso2: 'CR', dialCode: '506', flagEmoji: '🇨🇷', nameId: 'Kosta Rika'),
  PhoneCountry(iso2: 'HR', dialCode: '385', flagEmoji: '🇭🇷', nameId: 'Kroasia'),
  PhoneCountry(iso2: 'CU', dialCode: '53', flagEmoji: '🇨🇺', nameId: 'Kuba'),
  PhoneCountry(iso2: 'KW', dialCode: '965', flagEmoji: '🇰🇼', nameId: 'Kuwait'),
  PhoneCountry(iso2: 'KG', dialCode: '996', flagEmoji: '🇰🇬', nameId: 'Kirgizstan'),
  PhoneCountry(iso2: 'LA', dialCode: '856', flagEmoji: '🇱🇦', nameId: 'Laos'),
  PhoneCountry(iso2: 'LV', dialCode: '371', flagEmoji: '🇱🇻', nameId: 'Latvia'),
  PhoneCountry(iso2: 'LB', dialCode: '961', flagEmoji: '🇱🇧', nameId: 'Lebanon'),
  PhoneCountry(iso2: 'LY', dialCode: '218', flagEmoji: '🇱🇾', nameId: 'Libya'),
  PhoneCountry(iso2: 'LI', dialCode: '423', flagEmoji: '🇱🇮', nameId: 'Liechtenstein'),
  PhoneCountry(iso2: 'LT', dialCode: '370', flagEmoji: '🇱🇹', nameId: 'Lituania'),
  PhoneCountry(iso2: 'LU', dialCode: '352', flagEmoji: '🇱🇺', nameId: 'Luksemburg'),
  PhoneCountry(iso2: 'MO', dialCode: '853', flagEmoji: '🇲🇴', nameId: 'Makau'),
  PhoneCountry(iso2: 'MG', dialCode: '261', flagEmoji: '🇲🇬', nameId: 'Madagaskar'),
  PhoneCountry(iso2: 'MK', dialCode: '389', flagEmoji: '🇲🇰', nameId: 'Makedonia Utara'),
  kPhoneCountryMy,
  PhoneCountry(iso2: 'MW', dialCode: '265', flagEmoji: '🇲🇼', nameId: 'Malawi'),
  PhoneCountry(iso2: 'MV', dialCode: '960', flagEmoji: '🇲🇻', nameId: 'Maladewa'),
  PhoneCountry(iso2: 'ML', dialCode: '223', flagEmoji: '🇲🇱', nameId: 'Mali'),
  PhoneCountry(iso2: 'MT', dialCode: '356', flagEmoji: '🇲🇹', nameId: 'Malta'),
  PhoneCountry(iso2: 'MA', dialCode: '212', flagEmoji: '🇲🇦', nameId: 'Maroko'),
  PhoneCountry(iso2: 'MX', dialCode: '52', flagEmoji: '🇲🇽', nameId: 'Meksiko'),
  PhoneCountry(iso2: 'EG', dialCode: '20', flagEmoji: '🇪🇬', nameId: 'Mesir'),
  PhoneCountry(iso2: 'MD', dialCode: '373', flagEmoji: '🇲🇩', nameId: 'Moldova'),
  PhoneCountry(iso2: 'MC', dialCode: '377', flagEmoji: '🇲🇨', nameId: 'Monako'),
  PhoneCountry(iso2: 'MN', dialCode: '976', flagEmoji: '🇲🇳', nameId: 'Mongolia'),
  PhoneCountry(iso2: 'ME', dialCode: '382', flagEmoji: '🇲🇪', nameId: 'Montenegro'),
  PhoneCountry(iso2: 'MZ', dialCode: '258', flagEmoji: '🇲🇿', nameId: 'Mozambik'),
  PhoneCountry(iso2: 'MM', dialCode: '95', flagEmoji: '🇲🇲', nameId: 'Myanmar'),
  PhoneCountry(iso2: 'NA', dialCode: '264', flagEmoji: '🇳🇦', nameId: 'Namibia'),
  PhoneCountry(iso2: 'NP', dialCode: '977', flagEmoji: '🇳🇵', nameId: 'Nepal'),
  PhoneCountry(iso2: 'NL', dialCode: '31', flagEmoji: '🇳🇱', nameId: 'Belanda'),
  PhoneCountry(iso2: 'NZ', dialCode: '64', flagEmoji: '🇳🇿', nameId: 'Selandia Baru'),
  PhoneCountry(iso2: 'NI', dialCode: '505', flagEmoji: '🇳🇮', nameId: 'Nikaragua'),
  PhoneCountry(iso2: 'NG', dialCode: '234', flagEmoji: '🇳🇬', nameId: 'Nigeria'),
  PhoneCountry(iso2: 'NO', dialCode: '47', flagEmoji: '🇳🇴', nameId: 'Norwegia'),
  PhoneCountry(iso2: 'OM', dialCode: '968', flagEmoji: '🇴🇲', nameId: 'Oman'),
  PhoneCountry(iso2: 'PK', dialCode: '92', flagEmoji: '🇵🇰', nameId: 'Pakistan'),
  PhoneCountry(iso2: 'PA', dialCode: '507', flagEmoji: '🇵🇦', nameId: 'Panama'),
  PhoneCountry(iso2: 'PY', dialCode: '595', flagEmoji: '🇵🇾', nameId: 'Paraguay'),
  PhoneCountry(iso2: 'PE', dialCode: '51', flagEmoji: '🇵🇪', nameId: 'Peru'),
  PhoneCountry(iso2: 'PL', dialCode: '48', flagEmoji: '🇵🇱', nameId: 'Polandia'),
  PhoneCountry(iso2: 'PT', dialCode: '351', flagEmoji: '🇵🇹', nameId: 'Portugal'),
  PhoneCountry(iso2: 'FR', dialCode: '33', flagEmoji: '🇫🇷', nameId: 'Prancis'),
  PhoneCountry(iso2: 'RO', dialCode: '40', flagEmoji: '🇷🇴', nameId: 'Rumania'),
  PhoneCountry(iso2: 'RU', dialCode: '7', flagEmoji: '🇷🇺', nameId: 'Rusia'),
  PhoneCountry(iso2: 'RW', dialCode: '250', flagEmoji: '🇷🇼', nameId: 'Rwanda'),
  PhoneCountry(iso2: 'SN', dialCode: '221', flagEmoji: '🇸🇳', nameId: 'Senegal'),
  PhoneCountry(iso2: 'RS', dialCode: '381', flagEmoji: '🇷🇸', nameId: 'Serbia'),
  PhoneCountry(iso2: 'SG', dialCode: '65', flagEmoji: '🇸🇬', nameId: 'Singapura'),
  PhoneCountry(iso2: 'CY', dialCode: '357', flagEmoji: '🇨🇾', nameId: 'Siprus'),
  PhoneCountry(iso2: 'SK', dialCode: '421', flagEmoji: '🇸🇰', nameId: 'Slovakia'),
  PhoneCountry(iso2: 'SI', dialCode: '386', flagEmoji: '🇸🇮', nameId: 'Slovenia'),
  PhoneCountry(iso2: 'SO', dialCode: '252', flagEmoji: '🇸🇴', nameId: 'Somalia'),
  PhoneCountry(iso2: 'ES', dialCode: '34', flagEmoji: '🇪🇸', nameId: 'Spanyol'),
  PhoneCountry(iso2: 'LK', dialCode: '94', flagEmoji: '🇱🇰', nameId: 'Sri Lanka'),
  PhoneCountry(iso2: 'SD', dialCode: '249', flagEmoji: '🇸🇩', nameId: 'Sudan'),
  PhoneCountry(iso2: 'SE', dialCode: '46', flagEmoji: '🇸🇪', nameId: 'Swedia'),
  PhoneCountry(iso2: 'CH', dialCode: '41', flagEmoji: '🇨🇭', nameId: 'Swiss'),
  PhoneCountry(iso2: 'SY', dialCode: '963', flagEmoji: '🇸🇾', nameId: 'Suriah'),
  PhoneCountry(iso2: 'TW', dialCode: '886', flagEmoji: '🇹🇼', nameId: 'Taiwan'),
  PhoneCountry(iso2: 'TJ', dialCode: '992', flagEmoji: '🇹🇯', nameId: 'Tajikistan'),
  PhoneCountry(iso2: 'TZ', dialCode: '255', flagEmoji: '🇹🇿', nameId: 'Tanzania'),
  PhoneCountry(iso2: 'TH', dialCode: '66', flagEmoji: '🇹🇭', nameId: 'Thailand'),
  PhoneCountry(iso2: 'TL', dialCode: '670', flagEmoji: '🇹🇱', nameId: 'Timor Leste'),
  PhoneCountry(iso2: 'TG', dialCode: '228', flagEmoji: '🇹🇬', nameId: 'Togo'),
  PhoneCountry(iso2: 'TO', dialCode: '676', flagEmoji: '🇹🇴', nameId: 'Tonga'),
  PhoneCountry(iso2: 'TN', dialCode: '216', flagEmoji: '🇹🇳', nameId: 'Tunisia'),
  PhoneCountry(iso2: 'TR', dialCode: '90', flagEmoji: '🇹🇷', nameId: 'Turki'),
  PhoneCountry(iso2: 'TM', dialCode: '993', flagEmoji: '🇹🇲', nameId: 'Turkmenistan'),
  PhoneCountry(iso2: 'UG', dialCode: '256', flagEmoji: '🇺🇬', nameId: 'Uganda'),
  PhoneCountry(iso2: 'UA', dialCode: '380', flagEmoji: '🇺🇦', nameId: 'Ukraina'),
  PhoneCountry(iso2: 'UY', dialCode: '598', flagEmoji: '🇺🇾', nameId: 'Uruguay'),
  PhoneCountry(iso2: 'UZ', dialCode: '998', flagEmoji: '🇺🇿', nameId: 'Uzbekistan'),
  PhoneCountry(iso2: 'VU', dialCode: '678', flagEmoji: '🇻🇺', nameId: 'Vanuatu'),
  PhoneCountry(iso2: 'VE', dialCode: '58', flagEmoji: '🇻🇪', nameId: 'Venezuela'),
  PhoneCountry(iso2: 'VN', dialCode: '84', flagEmoji: '🇻🇳', nameId: 'Vietnam'),
  PhoneCountry(iso2: 'YE', dialCode: '967', flagEmoji: '🇾🇪', nameId: 'Yaman'),
  PhoneCountry(iso2: 'ZM', dialCode: '260', flagEmoji: '🇿🇲', nameId: 'Zambia'),
  PhoneCountry(iso2: 'ZW', dialCode: '263', flagEmoji: '🇿🇼', nameId: 'Zimbabwe'),
];

/// Negara selain yang dipin di Utama, urut nama (di-cache sekali).
final List<PhoneCountry> kOtherPhoneCountries = () {
  final primaryIso = {for (final c in kPrimaryPhoneCountries) c.iso2};
  return kAllPhoneCountries.where((c) => !primaryIso.contains(c.iso2)).toList()
    ..sort((a, b) => a.nameId.compareTo(b.nameId));
}();

/// @deprecated Pakai [kOtherPhoneCountries].
List<PhoneCountry> otherPhoneCountries() => kOtherPhoneCountries;

String stripLeadingTrunkZeros(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.replaceFirst(RegExp(r'^0+'), '');
}

/// Gabung dial code + digit nasional → digit internasional tanpa '+'.
String toInternationalPhoneDigits(PhoneCountry country, String nationalRaw) {
  final national = stripLeadingTrunkZeros(nationalRaw);
  if (national.isEmpty) return '';
  return '${country.dialCode}$national';
}

/// Parse nomor tersimpan (digit internasional) → negara + digit nasional.
({PhoneCountry country, String national}) parseStoredPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return (country: kPhoneCountryId, national: '');
  }

  // Prefer ID / MY dulu, lalu dial code terpanjang agar '1876' menang vs '1'.
  final candidates = <PhoneCountry>[
    ...kPrimaryPhoneCountries,
    ...kAllPhoneCountries,
  ];
  final seen = <String>{};
  PhoneCountry? best;
  for (final c in candidates) {
    if (!seen.add(c.iso2)) continue;
    if (!digits.startsWith(c.dialCode)) continue;
    if (best == null || c.dialCode.length > best.dialCode.length) {
      best = c;
    } else if (c.dialCode.length == best.dialCode.length &&
        kPrimaryPhoneCountries.contains(c)) {
      best = c;
    }
  }

  final country = best ?? kPhoneCountryId;
  final national = digits.startsWith(country.dialCode)
      ? digits.substring(country.dialCode.length)
      : digits;
  return (country: country, national: national);
}
