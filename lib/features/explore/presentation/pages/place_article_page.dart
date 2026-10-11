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
    final place = placesAsync.value?.where((p) => p.slug == slug).firstOrNull;

    return FScaffold(
      header: FHeader.nested(
        title: Text(place?.name ?? slug),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      child: async.when(
        loading: () => _buildSkeleton(theme),
        data: (markdown) {
          if (markdown == null || markdown.trim().isEmpty) {
            return const SizedBox.shrink();
          }
          return SambaskuMarkdown(data: markdown);
        },
        error: (_, _) => const SizedBox.shrink(),
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
          return Column(
            children: [
              FractionallySizedBox(
                widthFactor: width,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (i < 2) const Gap(8),
            ],
          );
        }),
      ],
    );
  }

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.go('/explore');
}