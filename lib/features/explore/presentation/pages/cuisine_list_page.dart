import 'package:material_ui/material_ui.dart';
import 'dart:async';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/exclude_semantics_on_exit.dart';
import '../../domain/entities/cuisine.dart';
import '../../explore_router.dart';
import '../providers/cuisine_providers.dart';

/// Grid 3 kolom: foto kotak 1:1, nama selalu 2 baris - seragam dengan
/// halaman wisata (`place_list_page.dart`).
const _cuisineGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: 12,
  crossAxisSpacing: 8,
  childAspectRatio: 0.7,
);

/// Daftar kuliner dari API `/api/v1/culinary/cuisines`. Data soft-fail:
/// gagal = tombol coba lagi.
class CuisineListPage extends ConsumerStatefulWidget {
  const CuisineListPage({super.key});

  @override
  ConsumerState<CuisineListPage> createState() => _CuisineListPageState();
}

class _CuisineListPageState extends ConsumerState<CuisineListPage> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(TextEditingValue value) {
    final text = value.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = text);
    });
  }

  Future<void> _reload() async {
    await ref.read(cuisineRefreshProvider.future);
    ref.invalidate(cuisineProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cuisineAsync = ref.watch(cuisineProvider);

    return ExcludeSemanticsOnExit(
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: const Text('Kuliner'),
          prefixes: [
            FHeaderAction.back(
              onPress: () =>
                  context.canPop() ? context.pop() : context.go('/explore'),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.store),
              onPress: () => context.push(ExploreRouter.cuisinePlaces.path),
              semanticsLabel: 'Tempat kuliner',
            ),
            FHeaderAction(
              icon: const Icon(FLucideIcons.plus),
              onPress: () =>
                  context.push(ExploreRouter.cuisineContribute.path),
              semanticsLabel: 'Usulkan kuliner',
            ),
          ],
        ),
        child: cuisineAsync.when(
          loading: () => const _SkeletonGrid(),
          error: (_, _) => _ErrorBody(onRetry: _reload),
          data: (items) {
            if (items == null) return _ErrorBody(onRetry: _reload);
            if (items.isEmpty) return const _EmptyBody();
            final q = _query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? items
                : items.where((k) => k.name.toLowerCase().contains(q)).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTextField(
                  control: FTextFieldControl.managed(
                    onChange: _onSearchChanged,
                  ),
                  hint: 'Cari kuliner...',
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
                if (filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Belum ada kuliner yang cocok.',
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _reload,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        gridDelegate: _cuisineGridDelegate,
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _CuisineGridTile(cuisine: filtered[i]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Tile grid kuliner - bentuk sama dengan `_PlaceGridTile` di wisata.
class _CuisineGridTile extends StatelessWidget {
  const _CuisineGridTile({required this.cuisine});

  final Cuisine cuisine;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = cuisine.cover;
    final titleStyle = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    final titleHeight = (titleStyle.fontSize ?? 12) * 1.25 * 2;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push('/explore/cuisine/${cuisine.slug}'),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cover == null
                    ? ColoredBox(
                        color: theme.colors.muted,
                        child: Icon(
                          FLucideIcons.utensilsCrossed,
                          size: 28,
                          color: theme.colors.mutedForeground,
                        ),
                      )
                    : CachedNetworkImageWithFallback(
                        imageUrl:
                            displayImageUrl(cover.url, width: 360) ??
                            cover.url,
                        fallbackUrl: cover.url,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const Gap(6),
            SizedBox(
              height: titleHeight,
              child: Text(
                cuisine.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ],
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
              subtitle: Text(
                'Gagal terhubung ke server. Coba lagi dalam beberapa saat.',
              ),
            ),
            const Gap(16),
            FButton(onPress: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

/// Skeleton grid kuliner - bentuk mirip konten asli supaya transisi
/// loading → konten/gagal tidak "loncat".
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

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
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: _cuisineGridDelegate,
        itemCount: 9,
        itemBuilder: (_, _) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Bone(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Gap(6),
            Bone(width: double.infinity, height: 12),
            Gap(4),
            Bone(width: 72, height: 12),
          ],
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
            Icon(
              FLucideIcons.utensilsCrossed,
              size: 48,
              color: theme.colors.primary,
            ),
            const Gap(16),
            Text(
              'Belum ada kuliner',
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Text(
              'Konten kuliner khas Sambas sedang disiapkan. Balik lagi nanti ya.',
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
