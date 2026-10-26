import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';

/// Badge status operasional. `unknown` tidak ditampilkan (tidak ada info).
FBadge? usahaOperationalBadge(UsahaOperationalStatus status) {
  final (variant, label) = switch (status) {
    UsahaOperationalStatus.open => (FBadgeVariant.primary, 'Buka'),
    UsahaOperationalStatus.temporarilyClosed => (
      FBadgeVariant.secondary,
      'Tutup sementara',
    ),
    UsahaOperationalStatus.permanentlyClosed => (
      FBadgeVariant.destructive,
      'Tutup permanen',
    ),
    UsahaOperationalStatus.unknown => (FBadgeVariant.outline, ''),
  };
  if (label.isEmpty) return null;
  return FBadge(variant: variant, child: Text(label));
}

/// Baris meta tile: kategori · desa · jenis.
String usahaMetaLine(Usaha usaha) {
  final parts = <String>[
    if (usaha.category != null) usaha.category!.name,
    if (usaha.village != null) usaha.village!.name else if (usaha.addressText != null)
      usaha.addressText!,
  ];
  return parts.join(' · ');
}

/// Format harga katalog. Teks bebas apa adanya - kosong = belum dicantumkan.
String usahaPriceLabel(UsahaItem item) {
  final price = item.priceText?.trim();
  return price == null || price.isEmpty ? 'Harga belum dicantumkan' : price;
}

/// Kartu usaha di grid 3 kolom: foto 1:1 + nama - seragam dengan kartu
/// wisata/kuliner. Meta (kategori, desa) & status buka ada di halaman detail.
class UsahaCard extends StatelessWidget {
  const UsahaCard({super.key, required this.usaha});

  final Usaha usaha;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = usaha.coverUrl;
    final titleStyle = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    final titleHeight = (titleStyle.fontSize ?? 12) * 1.25 * 2;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(UsahaRouter.detailPath(usaha.slug)),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cover == null || cover.isEmpty
                    ? ColoredBox(
                        color: theme.colors.muted,
                        child: Icon(
                          FLucideIcons.store,
                          size: 28,
                          color: theme.colors.mutedForeground,
                        ),
                      )
                    : CachedNetworkImageWithFallback(
                        imageUrl: displayImageUrl(cover, width: 360) ?? cover,
                        fallbackUrl: cover,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const Gap(6),
            SizedBox(
              height: titleHeight,
              child: Text(
                usaha.name,
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

/// Tile ringkas usaha - dipakai di section "Usaha di sekitar" halaman lain.
class UsahaMiniTile extends StatelessWidget {
  const UsahaMiniTile({super.key, required this.usaha, this.onTap});

  final Usaha usaha;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FTile(
      prefix: Icon(FLucideIcons.store, color: theme.colors.primary),
      title: Text(
        usaha.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        usahaMetaLine(usaha),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: usahaOperationalBadge(usaha.operationalStatus),
      onPress: onTap ?? () => context.push(UsahaRouter.detailPath(usaha.slug)),
    );
  }
}
