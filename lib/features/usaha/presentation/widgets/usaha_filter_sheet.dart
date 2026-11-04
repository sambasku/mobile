import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../explore/domain/entities/region.dart';
import '../../../explore/presentation/providers/regions_providers.dart';

/// Hasil pilihan filter. Null dari [showUsahaFilterSheet] = user tutup tanpa
/// ubah (barrier / tombol X). Instance non-null = terapkan (regionId boleh null
/// = semua kecamatan).
class UsahaFilterSelection {
  const UsahaFilterSelection({this.regionId});

  final String? regionId;
}

/// Drawer kanan: filter listing usaha. Tahap awal = kecamatan saja.
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

class _UsahaFilterSheetBody extends ConsumerWidget {
  const _UsahaFilterSheetBody({required this.selectedRegionId});

  final String? selectedRegionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kecamatanAsync = ref.watch(regionsKecamatanProvider);

    return Material(
      type: MaterialType.transparency,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              l10n.usahaFilterKecamatan,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: kecamatanAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.usahaFilterLoadFailed,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
              data: (kecamatan) {
                final items = <Region?>[null, ...kecamatan];
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final region = items[index];
                    final selected = region == null
                        ? selectedRegionId == null
                        : selectedRegionId == region.id;
                    final label = region == null
                        ? l10n.usahaFilterAllKecamatan
                        : region.name;
                    return Semantics(
                      button: true,
                      selected: selected,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(
                          UsahaFilterSelection(regionId: region?.id),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: theme.typography.body.md.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (selected)
                                Icon(
                                  FLucideIcons.check,
                                  size: 18,
                                  color: theme.colors.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
