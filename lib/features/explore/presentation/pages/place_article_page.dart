import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../data/place_markdown/place_markdown_repository.dart';
import '../providers/places_providers.dart';
import '../../../../shared/widgets/sambasku_markdown.dart';

/// Halaman reader artikel markdown wisata. Header: nama tempat, back.
/// Isi: markdown dirender utuh (reuse `sambasku_markdown.dart`).
class PlaceArticlePage extends ConsumerWidget {
  const PlaceArticlePage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(placeMarkdownProvider(slug));
    final theme = context.theme;
    final placesAsync = ref.watch(placesProvider);
    final place =
        placesAsync.value?.where((p) => p.slug == slug).firstOrNull;

    return FScaffold(
      header: FHeader.nested(
        title: Text(place?.name ?? slug),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      childPad: false,
      child: async.when(
        loading: () => _buildSkeleton(theme),
        data: (markdown) => (markdown == null || markdown.trim().isEmpty)
            ? _EmptyArticle(slug: slug)
            // MarkdownBody tidak scrollable - tanpa ini artikel panjang
            // overflow RenderFlex (region page pakai pola sama via ListView).
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SambaskuMarkdown(data: markdown),
              ),
        error: (_, _) => _EmptyArticle(slug: slug),
      ),
    );
  }

  /// Skeleton loading (sama dengan pengumuman): judul + 3 baris teks.
  Widget _buildSkeleton(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 150,
          decoration: BoxDecoration(
            color: theme.colors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Gap(12),
        ...List.generate(3, (i) {
          final width = i == 2 ? 0.7 : 1.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: width,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go('/explore');
}

/// Artikel tidak tersedia / gagal dimuat. Jangan blank page (#168) -
/// kasih konteks + jalan keluar (kembali ke detail, coba lagi).
class _EmptyArticle extends ConsumerWidget {
  const _EmptyArticle({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FLucideIcons.fileQuestionMark, size: 40),
            const Gap(12),
            Text(
              'Artikel belum tersedia atau gagal dimuat.',
              textAlign: TextAlign.center,
              style: context.theme.typography.sm,
            ),
            const Gap(16),
            FButton(
              onPress: () => ref.invalidate(placeMarkdownProvider(slug)),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
