import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/place.dart';
import '../../explore_router.dart';
import '../place_ui.dart';
import '../providers/places_providers.dart';

/// Filter list satu baris: type wisata + Kuliner sebagai satu chip.
enum _Filter { semua, alam, budaya, pantai, sejarah, belanja, kuliner }

const _filterLabels = {
  _Filter.semua: 'Semua',
  _Filter.alam: 'Alam',
  _Filter.budaya: 'Budaya',
  _Filter.pantai: 'Pantai',
  _Filter.sejarah: 'Sejarah',
  _Filter.belanja: 'Belanja',
  _Filter.kuliner: 'Kuliner',
};

/// Daftar Place (Wisata & Kuliner). Data CDN soft-fail: gagal = tombol coba lagi.
class PlaceListPage extends ConsumerStatefulWidget {
  const PlaceListPage({super.key});

  @override
  ConsumerState<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends ConsumerState<PlaceListPage> {
  _Filter _filter = _Filter.semua;
  String _query = '';

  Future<void> _reload() async {
    ref.invalidate(placesProvider);
    await ref.read(placesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final placesAsync = ref.watch(placesProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Wisata & Kuliner'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: placesAsync.when(
        loading: () => const _SkeletonList(),
        error: (_, _) => _ErrorBody(onRetry: _reload),
        data: (places) {
          if (places == null) return _ErrorBody(onRetry: _reload);
          if (places.isEmpty) return const _EmptyBody();
          final filtered = _applyFilter(places);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: (value) => setState(() => _query = value.text),
                ),
                hint: 'Cari destinasi...',
                textInputAction: TextInputAction.search,
                clearable: (value) => value.text.isNotEmpty,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              const Gap(12),
              _FilterBar(
                selected: _filter,
                onSelect: (f) => setState(() => _filter = f),
              ),
              const Gap(4),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Belum ada destinasi yang cocok.',
                      textAlign: TextAlign.center,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _PlaceCard(place: filtered[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ponytail: filter lokal per ketikan tanpa debounce, aman selama katalog
  // puluhan item. Kalau search pindah ke API atau ribuan item, tambah
  // debounce ~300ms (pola `_debounce` di kbbi_definition_sheet.dart).
  List<Place> _applyFilter(List<Place> places) {
    final q = _query.trim().toLowerCase();
    return places.where((p) {
      if (q.isNotEmpty && !p.name.toLowerCase().contains(q)) return false;
      switch (_filter) {
        case _Filter.semua:
          return true;
        case _Filter.kuliner:
          return p.category == PlaceCategory.kuliner;
        default:
          return p.category == PlaceCategory.wisata &&
              p.type?.name == _filter.name;
      }
    }).toList();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final _Filter selected;
  final ValueChanged<_Filter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _Filter.values) ...[
            if (f != _Filter.semua) const Gap(6),
            GestureDetector(
              onTap: () => onSelect(f),
              child: FBadge(
                variant: selected == f
                    ? FBadgeVariant.primary
                    : FBadgeVariant.secondary,
                child: Text(_filterLabels[f]!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  static const _thumbSize = 88.0;

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = place.cover;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(
          ExploreRouter.place.path.replaceFirst(':slug', place.slug),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: _thumbSize,
                  child: cover == null
                      ? ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            place.category == PlaceCategory.kuliner
                                ? FLucideIcons.utensilsCrossed
                                : FLucideIcons.landmark,
                            size: 32,
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      : CachedNetworkImageWithFallback(
                          imageUrl:
                              displayImageUrl(cover.url, width: 240) ??
                              cover.url,
                          fallbackUrl: cover.url,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      placeLabel(place),
                      style: theme.typography.xs.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colors.primary,
                      ),
                    ),
                    Text(
                      place.shortDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Bookmark',
                onPressed: () => showPlaceBookmarkSoon(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  FLucideIcons.bookmark,
                  size: 20,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FAlert(
              title: Text('Gagal memuat'),
              subtitle: Text('Periksa koneksi internetmu lalu coba lagi ya.'),
            ),
            const Gap(16),
            FButton(onPress: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

/// Skeleton kartu Place saat loading - bentuknya mirip konten asli supaya
/// transisi loading → konten/gagal tidak "loncat".
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(
                width: _PlaceCard._thumbSize,
                height: _PlaceCard._thumbSize,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(width: 160, height: 16),
                    Gap(6),
                    Bone(width: 64, height: 14),
                    Gap(6),
                    Bone(width: 200, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FLucideIcons.compass, size: 48, color: theme.colors.primary),
            const Gap(16),
            Text(
              'Belum ada destinasi',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Text(
              'Konten wisata dan kuliner sedang disiapkan. Balik lagi nanti ya.',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
