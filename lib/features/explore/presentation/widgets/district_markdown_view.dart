import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../shared/widgets/sambasku_markdown.dart';
import '../../data/district_markdown/district_markdown_repository.dart';

/// Widget artikel markdown profil kecamatan: loading skeleton -> artikel ->
/// error state (tetap halaman normal, hanya tanpa konten). Reuse MarkdownBody
/// dari pengumuman (#124) agar tap link & preview gambar identik.
class DistrictMarkdownView extends ConsumerWidget {
  const DistrictMarkdownView({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(districtMarkdownProvider(slug));
    final theme = context.theme;

    return async.when(
      loading: () => _buildSkeleton(theme),
      data: (markdown) {
        if (markdown == null || markdown.trim().isEmpty) {
          return const SizedBox.shrink();
        }
        return SambaskuMarkdown(data: markdown);
      },
      error: (_, _) => const SizedBox.shrink(),
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
          return Column(
            children: [
              FractionallySizedBox(
                widthFactor: i == 2 ? 0.7 : 1.0,
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
}
