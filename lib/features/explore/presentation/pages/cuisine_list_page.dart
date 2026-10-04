import 'package:flutter/material.dart';
import 'dart:async';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/cuisine.dart';
import '../providers/cuisine_providers.dart';

/// Daftar cuisine dari `cuisines.json` (CDN). Data soft-fail:
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
    ref.invalidate(cuisineProvider);
    await ref.read(cuisineProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cuisineAsync = ref.watch(cuisineProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Cuisine'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: cuisineAsync.when(
        loading: () => const _SkeletonList(),
        error: (_, _) => _ErrorBody(onRetry: _reload),
        data: (items) {
          if (items == null) return _ErrorBody(onRetry: _reload);
          if (items.isEmpty) return const _EmptyBody();
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? items
              : items
                    .where((k) => k.name.toLowerCase().contains(q))
                    .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: _onSearchChanged,
                ),
                hint: 'Cari cuisine...',
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
                      'Belum ada cuisine yang cocok.',
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
                    itemBuilder: (context, i) =>
                        _CuisineCard(cuisine: filtered[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CuisineCard extends StatelessWidget {
  const _CuisineCard({required this.cuisine});

  static const _thumbSize = 88.0;

  final Cuisine cuisine;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = cuisine.cover;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push('/explore/cuisine/${cuisine.slug}'),
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
                            FLucideIcons.utensilsCrossed,
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
                      cuisine.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      cuisine.region,
                      style: theme.typography.xs.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colors.primary,
                      ),
                    ),
                    Text(
                      cuisine.description,
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
                onPressed: () => showFToast(
                  context: context,
                  title: const Text('Bookmark cuisine belum bisa dipakai'),
                  description: const Text(
                    'Kami sedang berusaha membuatnya jadi lebih baik.',
                  ),
                ),
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

/// Skeleton kartu cuisine - bentuk mirip konten asli supaya transisi
/// loading → konten/gagal tidak "loncat".
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
                width: _CuisineCard._thumbSize,
                height: _CuisineCard._thumbSize,
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
            Icon(
              FLucideIcons.utensilsCrossed,
              size: 48,
              color: theme.colors.primary,
            ),
            const Gap(16),
            Text(
              'Belum ada cuisine',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Text(
              'Konten cuisine khas Sambas sedang disiapkan. Balik lagi nanti ya.',
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
