import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../providers/regions_providers.dart';

/// Detail kecamatan/desa: kontennya belum ada, ditampilkan sebagai halaman
/// "Segera hadir" agar user sudah mengenal fungsi CTA-nya sejak sekarang.
class RegionDetailPage extends ConsumerStatefulWidget {
  const RegionDetailPage.kecamatan({super.key, required this.slug})
    : isKecamatan = true;

  const RegionDetailPage.desa({super.key, required this.slug})
    : isKecamatan = false;

  /// Kecamatan: slug id `regions.json`. Desa: kode BPS (id).
  final String slug;

  final bool isKecamatan;

  @override
  ConsumerState<RegionDetailPage> createState() => _RegionDetailPageState();
}

class _RegionDetailPageState extends ConsumerState<RegionDetailPage> {
  @override
  void initState() {
    super.initState();
    // Log sekali saat halaman tampil (analitik wajib per halaman baru).
    Future<void>.microtask(() {
      if (!mounted) return;
      final a = AnalyticsService.instance;
      unawaited(
        widget.isKecamatan
            ? a.logWilayahKecDetailOpen(slug: widget.slug)
            : a.logWilayahDesaDetailOpen(slug: widget.slug),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final regions = ref.watch(regionsProvider).value ?? const [];
    final isKec = widget.isKecamatan;

    // Slug kecamatan = id; slug desa = kode BPS (id-nya mengandung "/").
    final region = isKec
        ? regions.where((r) => r.id == widget.slug).firstOrNull
        : regions.where((r) => r.code == widget.slug).firstOrNull;
    final name = region?.name ?? widget.slug;

    final desaCount = regions.where((r) => r.parentId == widget.slug).length;

    return FScaffold(
      header: FHeader.nested(title: Text(name)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isKec ? FLucideIcons.signpost : FLucideIcons.mapPin,
                size: 48,
                color: theme.colors.primary,
              ),
              const Gap(16),
              FBadge(
                variant: FBadgeVariant.outline,
                child: const Text('Segera hadir'),
              ),
              const Gap(12),
              Text(
                isKec ? 'Kecamatan $name' : 'Desa $name',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (isKec && desaCount > 0) ...[
                const Gap(4),
                Text(
                  '$desaCount desa',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              const Gap(12),
              Text(
                isKec
                    ? 'Profil kecamatan ini sedang kami siapkan. Nanti kamu bisa lihat info lengkapnya di sini ya.'
                    : 'Profil desa ini sedang kami siapkan. Nanti kamu bisa lihat info lengkapnya di sini ya.',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
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
