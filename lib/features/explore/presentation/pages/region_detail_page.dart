import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../event/presentation/providers/event_providers.dart';
import '../../../event/presentation/widgets/event_ui.dart';
import '../providers/regions_providers.dart';
import '../widgets/district_markdown_view.dart';

/// Detail kecamatan/desa. Kecamatan: artikel markdown dari CDN (#123)
/// dirender di atas info wilayah. Desa: masih "Segera hadir".
class RegionDetailPage extends ConsumerStatefulWidget {
  const RegionDetailPage.kecamatan({super.key, required this.slug})
    : isKecamatan = true;

  const RegionDetailPage.desa({super.key, required this.slug})
    : isKecamatan = false;

  /// Kecamatan: slug id katalog wilayah. Desa: kode BPS (id).
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
    final l10n = AppLocalizations.of(context);
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
      // childPad false: sama pola artikel wisata (#168) - padding hanya di
      // ListView supaya markdown/tabel tidak kena gutter dobel (12+16).
      childPad: false,
      // ListView agar artikel panjang bisa di-scroll.
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (isKec) ...[
            // Artikel markdown kecamatan: skeleton saat loading, kosong
            // bila tidak tersedia (soft-fail, halaman tetap normal).
            DistrictMarkdownView(slug: widget.slug),
            const Gap(24),
          ],
          if (!isKec) ...[
            Icon(FLucideIcons.mapPin, size: 48, color: theme.colors.primary),
            const Gap(16),
            FBadge(
              variant: FBadgeVariant.outline,
              child: Text(l10n.exploreComingSoon),
            ),
            const Gap(12),
          ],
          Text(
            isKec ? l10n.regionKecamatanTitle(name) : l10n.regionDesaTitle(name),
            style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w700),
          ),
          if (isKec && desaCount > 0) ...[
            const Gap(4),
            Text(
              l10n.regionVillageCount('$desaCount'),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
if (!isKec) ...[
          const Gap(12),
          Text(
            l10n.regionDesaComingSoon,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
        // Agenda desa (hanya desa): acara dengan village_id = desa ini.
        // Slug wilayah (id katalog publik) diterima API sebagai village_id.
        if (!isKec && region != null)
          buildEventMiniList(
            context,
            ref.watch(eventsForVillageProvider(region.id)).value ?? const [],
            title: l10n.regionAgendaDesa(name),
          ) ??
          const SizedBox.shrink(),
      ],
      ),
    );
  }
}
