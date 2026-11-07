import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../explore/domain/entities/region.dart';
import '../../../explore/presentation/providers/regions_providers.dart';

/// Hasil pilihan filter. Null dari [showUsahaFilterSheet] = user tutup tanpa
/// ubah. Instance non-null = terapkan (regionId boleh null = semua kecamatan).
class UsahaFilterSelection {
  const UsahaFilterSelection({this.regionId});

  final String? regionId;
}

/// Drawer kanan: filter listing usaha. Field (kecamatan, nanti lainnya) di
/// dalam drawer; pilihan kecamatan lewat bottom sheet.
Future<UsahaFilterSelection?> showUsahaFilterSheet(
  BuildContext context, {
  required String? selectedRegionId,
}) {
  return showFSheet<UsahaFilterSelection>(
    context: context,
    side: FLayout.rtl,
    mainAxisMaxRatio: 0.86,
    useSafeArea: true,
    builder: (sheetContext) => _UsahaFilterSheetBody(
      selectedRegionId: selectedRegionId,
    ),
  );
}

class _UsahaFilterSheetBody extends ConsumerStatefulWidget {
  const _UsahaFilterSheetBody({required this.selectedRegionId});

  final String? selectedRegionId;

  @override
  ConsumerState<_UsahaFilterSheetBody> createState() =>
      _UsahaFilterSheetBodyState();
}

class _UsahaFilterSheetBodyState extends ConsumerState<_UsahaFilterSheetBody> {
  late String? _draftRegionId = widget.selectedRegionId;

  Future<void> _pickKecamatan() async {
    final l10n = AppLocalizations.of(context);
    final regionsAsync = await ref.read(regionsProvider.future);
    final regions = regionsAsync ?? const <Region>[];
    if (!mounted) return;

    // '' = semua kecamatan. Null return dari sheet = batal (tutup tanpa pilih).
    final picked = await showOptionPickerSheet<String>(
      context,
      title: l10n.usahaFormPickDistrict,
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: l10n.usahaFormSearchDistrict,
      items: [
        OptionPickerItem(
          value: '',
          label: l10n.usahaFilterAllKecamatan,
          selected: _draftRegionId == null,
        ),
        for (final r in regions.where((r) => r.type == RegionType.kecamatan))
          OptionPickerItem(
            value: r.id,
            label: r.name,
            selected: r.id == _draftRegionId,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _draftRegionId = picked.isEmpty ? null : picked);
  }

  String _kecamatanSubtitle(AppLocalizations l10n, List<Region> kecamatan) {
    final id = _draftRegionId;
    if (id == null) return l10n.usahaFilterAllKecamatan;
    for (final r in kecamatan) {
      if (r.id == id) return r.name;
    }
    return l10n.usahaFilterAllKecamatan;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kecamatan = ref.watch(regionsKecamatanProvider).value ?? const [];

    return ColoredBox(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.listFilter,
                  size: 18,
                  color: theme.colors.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    l10n.usahaFilterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(FLucideIcons.x),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ],
            ),
          ),
          const Gap(8),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              children: [
                FTileGroup(
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.mapPin, size: 18),
                      title: Text(l10n.usahaFilterKecamatan),
                      subtitle: Text(_kecamatanSubtitle(l10n, kecamatan)),
                      onPress: _pickKecamatan,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: FButton(
                onPress: () => Navigator.of(context).pop(
                  UsahaFilterSelection(regionId: _draftRegionId),
                ),
                child: Text(l10n.usahaFilterApply),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
