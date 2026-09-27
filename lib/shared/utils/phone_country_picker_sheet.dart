import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import 'phone_country.dart';

/// Bottomsheet pilih negara: Utama (ID, MY) lalu Lainnya (+ cari).
/// List dibangun lazy (`ListView.builder`) agar buka sheet tidak ngelag.
Future<PhoneCountry?> showPhoneCountryPickerSheet(
  BuildContext context, {
  PhoneCountry? selected,
}) {
  return showModalBottomSheet<PhoneCountry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _PhoneCountryPickerBody(selected: selected ?? kPhoneCountryId);
    },
  );
}

sealed class _Row {
  const _Row();
}

class _HeaderRow extends _Row {
  const _HeaderRow(this.label);
  final String label;
}

class _CountryRow extends _Row {
  const _CountryRow(this.country);
  final PhoneCountry country;
}

class _EmptyRow extends _Row {
  const _EmptyRow();
}

class _PhoneCountryPickerBody extends StatefulWidget {
  const _PhoneCountryPickerBody({required this.selected});

  final PhoneCountry selected;

  @override
  State<_PhoneCountryPickerBody> createState() =>
      _PhoneCountryPickerBodyState();
}

class _PhoneCountryPickerBodyState extends State<_PhoneCountryPickerBody> {
  final _query = TextEditingController();
  late List<_Row> _rows;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows('');
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(PhoneCountry c, String needle) {
    if (needle.isEmpty) return true;
    return c.nameId.toLowerCase().contains(needle) ||
        c.dialCode.contains(needle) ||
        c.iso2.toLowerCase().contains(needle);
  }

  List<_Row> _buildRows(String rawQuery) {
    final needle = rawQuery.trim().toLowerCase();
    final primary =
        kPrimaryPhoneCountries.where((c) => _matches(c, needle)).toList();
    final others =
        kOtherPhoneCountries.where((c) => _matches(c, needle)).toList();

    if (primary.isEmpty && others.isEmpty) {
      return const [_EmptyRow()];
    }

    return [
      if (primary.isNotEmpty) ...[
        const _HeaderRow('Utama'),
        for (final c in primary) _CountryRow(c),
      ],
      if (others.isNotEmpty) ...[
        const _HeaderRow('Lainnya'),
        for (final c in others) _CountryRow(c),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final height = MediaQuery.sizeOf(context).height * 0.75;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih negara',
                style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(12),
              FTextField(
                control: .managed(
                  controller: _query,
                  onChange: (value) {
                    setState(() => _rows = _buildRows(value.text));
                  },
                ),
                hint: 'Cari nama atau kode',
              ),
              const Gap(12),
              Expanded(
                child: ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    final row = _rows[index];
                    return switch (row) {
                      _HeaderRow(:final label) => Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : 12,
                          bottom: 4,
                        ),
                        child: Text(
                          label,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _CountryRow(:final country) => _CountryListTile(
                        country: country,
                        selected: country.iso2 == widget.selected.iso2,
                        onTap: () => Navigator.of(context).pop(country),
                      ),
                      _EmptyRow() => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Tidak ada negara yang cocok',
                          textAlign: TextAlign.center,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baris ringan (bukan FTile) agar list panjang tidak mahal.
class _CountryListTile extends StatelessWidget {
  const _CountryListTile({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  final PhoneCountry country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Text(country.flagEmoji, style: const TextStyle(fontSize: 22)),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.nameId,
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '+${country.dialCode}',
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                FLucideIcons.check,
                size: 16,
                color: theme.colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
