import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';

/// Null = tutup tanpa ubah; non-null = terapkan.
class KaryaFilterSelection {
  const KaryaFilterSelection({
  this.year,
  this.language,
  this.sambasType,
  });

  final int? year;
  final String? language;
  final String? sambasType;
}

Future<KaryaFilterSelection?> showKaryaFilterSheet(
  BuildContext context, {
  required int? selectedYear,
  required String? selectedLanguage,
  required String? selectedSambasType,
}) {
  return showFSheet<KaryaFilterSelection>(
    context: context,
    side: FLayout.rtl,
    mainAxisMaxRatio: 0.86,
    useSafeArea: true,
    builder: (_) => _KaryaFilterSheetBody(
      selectedYear: selectedYear,
      selectedLanguage: selectedLanguage,
      selectedSambasType: selectedSambasType,
    ),
  );
}

class _KaryaFilterSheetBody extends StatefulWidget {
  const _KaryaFilterSheetBody({
    required this.selectedYear,
    required this.selectedLanguage,
    required this.selectedSambasType,
  });

  final int? selectedYear;
  final String? selectedLanguage;
  final String? selectedSambasType;

  @override
  State<_KaryaFilterSheetBody> createState() => _KaryaFilterSheetBodyState();
}

class _KaryaFilterSheetBodyState extends State<_KaryaFilterSheetBody> {
  late String? _sambasType = widget.selectedSambasType;
  late final TextEditingController _yearController = TextEditingController(
    text: widget.selectedYear?.toString() ?? '',
  );
  late final TextEditingController _languageController = TextEditingController(
    text: widget.selectedLanguage ?? '',
  );

  @override
  void dispose() {
    _yearController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _apply() {
    final yearRaw = _yearController.text.trim();
    int? year;
    if (yearRaw.isNotEmpty) {
      year = int.tryParse(yearRaw);
      if (year == null) return;
    }
    final lang = _languageController.text.trim();
    Navigator.of(context).pop(
      KaryaFilterSelection(
        year: year,
        language: lang.isEmpty ? null : lang,
        sambasType: _sambasType,
      ),
    );
  }

  void _reset() {
    setState(() {
      _sambasType = null;
      _yearController.clear();
      _languageController.clear();
    });
  }

  String _sambasLabel(AppLocalizations l10n, String type) => switch (type) {
        'creator_origin' => l10n.karyaSambasTypeCreatorOrigin,
        'language' => l10n.karyaSambasTypeLanguage,
        'location' => l10n.karyaSambasTypeLocation,
        'theme' => l10n.karyaSambasTypeTheme,
        _ => l10n.karyaSambasTypeOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    const types = [
      'creator_origin',
      'language',
      'location',
      'theme',
      'other',
    ];

    return ColoredBox(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.karyaFilterTitle,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonClose),
                ),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Text(
                  l10n.karyaFilterYear,
                  style: theme.typography.body.sm,
                ),
                const Gap(6),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _yearController,
                  ),
                  hint: l10n.karyaFilterYearHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const Gap(16),
                Text(
                  l10n.karyaFilterLanguage,
                  style: theme.typography.body.sm,
                ),
                const Gap(6),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _languageController,
                  ),
                  hint: l10n.karyaFilterLanguageHint,
                ),
                const Gap(16),
                Text(
                  l10n.karyaFilterSambasType,
                  style: theme.typography.body.sm,
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _typeChip(
                      label: l10n.karyaFilterSambasAll,
                      active: _sambasType == null,
                      onTap: () => setState(() => _sambasType = null),
                    ),
                    for (final type in types)
                      _typeChip(
                        label: _sambasLabel(l10n, type),
                        active: _sambasType == type,
                        onTap: () => setState(() => _sambasType = type),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: _reset,
                      child: Text(l10n.karyaFilterReset),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FButton(
                      onPress: _apply,
                      child: Text(l10n.karyaFilterApply),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: FBadge(
        variant: active ? FBadgeVariant.primary : FBadgeVariant.secondary,
        child: Text(label),
      ),
    );
  }
}