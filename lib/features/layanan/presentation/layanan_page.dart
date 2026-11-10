import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/providers/auth_status_providers.dart';
import '../../explore/domain/entities/region.dart';
import '../../explore/explore_router.dart';
import '../../explore/presentation/providers/regions_providers.dart';
import '../domain/layanan.dart';
import '../layanan_router.dart';
import 'layanan_logo.dart';
import 'layanan_providers.dart';
import 'widgets/layanan_filter_sheet.dart';

/// Ukuran cover list - sama dengan ensiklopedia.
const _kCoverSize = 64.0;

class LayananPage extends ConsumerStatefulWidget {
  const LayananPage({super.key});

  @override
  ConsumerState<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends ConsumerState<LayananPage> {
  String? _regionId;
  String? _category;

  LayananBrowseQuery get _query => LayananBrowseQuery(
        regionId: _regionId,
        category: _category,
      );

  Future<void> _openFilter() async {
    final selection = await showLayananFilterSheet(
      context,
      selectedRegionId: _regionId,
    );
    if (!mounted || selection == null) return;
    setState(() => _regionId = selection.regionId);
  }

  void _clearRegionFilter() {
    setState(() => _regionId = null);
  }

  Future<void> _propose() async {
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      context.push('/login');
      return;
    }
    context.push(LayananRouter.contributePath(regionId: _regionId));
  }

  Future<void> _reload() async {
    ref.invalidate(layananBrowseProvider(_query));
    await ref.read(layananBrowseProvider(_query).future);
  }

  String? _regionName(List<Region> kecamatan) {
    final id = _regionId;
    if (id == null) return null;
    for (final r in kecamatan) {
      if (r.id == id) return r.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kecamatan = ref.watch(regionsKecamatanProvider).value ?? const [];
    final listAsync = ref.watch(layananBrowseProvider(_query));
    final regionName = _regionName(kecamatan);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.layananTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(ExploreRouter.hub.path),
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: Icon(
              FLucideIcons.listFilter,
              color: _regionId != null ? theme.colors.primary : null,
            ),
            onPress: _openFilter,
          ),
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: _propose,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_regionId != null && regionName != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FBadge(
                  variant: FBadgeVariant.secondary,
                  child: Text(l10n.usahaFilterRegionChip(regionName)),
                ),
                GestureDetector(
                  onTap: _clearRegionFilter,
                  child: Text(
                    l10n.usahaFilterClear,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
          ],
          _CategoryBar(
            selected: _category,
            onSelect: (value) => setState(() => _category = value),
          ),
          const Gap(8),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (_, _) => Center(child: Text(l10n.layananLoadFailed)),
              data: (items) {
                final visible = switch (_category) {
                  'ambulance' => items.where((e) => e.isAmbulance).toList(),
                  'fire' => items.where((e) => !e.isAmbulance).toList(),
                  _ => items,
                };
                if (visible.isEmpty) {
                  return _EmptyBody(
                    hasFilter: _regionId != null || _category != null,
                    onPropose: _propose,
                    onRefresh: _reload,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, i) => _LayananListTile(
                      item: visible[i],
                      showCategory: _category == null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris list pola ensiklopedia: cover 64 + judul/subtitle + chevron.
class _LayananListTile extends StatelessWidget {
  const _LayananListTile({
    required this.item,
    required this.showCategory,
  });

  final LayananEntry item;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final subtitle = _subtitle(l10n);

    return FTappable(
      onPress: () => context.push(LayananRouter.detailPath(item.slug)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LayananLogo(
              logoUrl: item.logoUrl,
              isAmbulance: item.isAmbulance,
              size: _kCoverSize,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(8),
            Icon(
              FLucideIcons.chevronRight,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  /// Alamat/kecamatan; saat filter Semua, sisip kategori di depan.
  String? _subtitle(AppLocalizations l10n) {
    final address = (item.addressText ?? '').trim();
    final region = (item.regionName ?? '').trim();
    final place = address.isNotEmpty
        ? address
        : (region.isNotEmpty ? region : null);
    if (!showCategory) return place;
    final category =
        item.isAmbulance ? l10n.layananAmbulance : l10n.layananFire;
    if (place == null) return category;
    return '$category · $place';
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            label: l10n.usahaFilterAll,
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          const Gap(6),
          _chip(
            label: l10n.layananAmbulance,
            active: selected == 'ambulance',
            onTap: () => onSelect('ambulance'),
          ),
          const Gap(6),
          _chip(
            label: l10n.layananFire,
            active: selected == 'fire',
            onTap: () => onSelect('fire'),
          ),
        ],
      ),
    );
  }

  Widget _chip({
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

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.hasFilter,
    required this.onPropose,
    required this.onRefresh,
  });

  final bool hasFilter;
  final VoidCallback onPropose;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Gap(48),
          Center(
            child: Icon(
              FLucideIcons.phone,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(10),
          Text(
            hasFilter ? l10n.layananEmptyFilter : l10n.layananEmpty,
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            hasFilter ? l10n.layananEmptyFilterHint : l10n.layananEmptyHint,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          Center(
            child: FButton(
              variant: FButtonVariant.outline,
              onPress: onPropose,
              child: Text(l10n.layananPropose),
            ),
          ),
        ],
      ),
    );
  }
}
