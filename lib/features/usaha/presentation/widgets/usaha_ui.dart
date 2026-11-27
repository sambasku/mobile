import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../usaha_labels.dart';

/// Titik usaha di Google Maps; rute diurus aplikasi Maps.
/// Prefer mapsUrl HTTPS; fallback lat,lng.
Uri? usahaGoogleMapsUri(Usaha usaha) {
  if (usaha.mapsUrl != null) {
    final uri = Uri.tryParse(usaha.mapsUrl!);
    if (uri != null && uri.isScheme('https')) return uri;
  }
  if (usaha.hasCoordinates) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${usaha.lat},${usaha.lng}',
    });
  }
  return null;
}

bool usahaCanOpenMaps(Usaha usaha) => usahaGoogleMapsUri(usaha) != null;

/// Toast bila usaha belum punya koordinat untuk peta internal.
void showUsahaNoCoordinates(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showFToast(
    context: context,
    title: Text(l10n.usahaNoCoordinatesTitle),
    description: Text(l10n.usahaNoCoordinatesBody),
  );
}

/// Badge status operasional. `unknown` tidak ditampilkan (tidak ada info).
FBadge? usahaOperationalBadge(
  AppLocalizations l10n,
  UsahaOperationalStatus status,
) {
  if (status == UsahaOperationalStatus.unknown) return null;
  final variant = switch (status) {
    UsahaOperationalStatus.open => FBadgeVariant.primary,
    UsahaOperationalStatus.temporarilyClosed => FBadgeVariant.secondary,
    UsahaOperationalStatus.permanentlyClosed => FBadgeVariant.destructive,
    UsahaOperationalStatus.unknown => FBadgeVariant.outline,
  };
  return FBadge(
    variant: variant,
    child: Text(usahaOperationalLabel(l10n, status)),
  );
}

String? _sponsorTierLabel(AppLocalizations l10n, String tier) {
  return switch (tier) {
    'perak' => l10n.usahaSponsorTierPerak,
    'emas' => l10n.usahaSponsorTierEmas,
    'intan' => l10n.usahaSponsorTierIntan,
    'mustika' => l10n.usahaSponsorTierMustika,
    _ => null,
  };
}

/// Listing: lencana "Sponsor" bila ada sponsor_tier.
FBadge? usahaSponsorListBadge(AppLocalizations l10n, String? tier) {
  if (tier == null || tier.isEmpty) return null;
  return FBadge(
    variant: FBadgeVariant.primary,
    style: const FBadgeStyleDelta.delta(
      labelTextStyle: TextStyleDelta.delta(fontSize: 10, height: 1.2),
      padding: EdgeInsetsGeometryDelta.value(
        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    ),
    child: Text(l10n.usahaSponsorBadge),
  );
}

/// Detail: "Sponsor Mustika" (+ warna primary).
FBadge? usahaSponsorDetailBadge(AppLocalizations l10n, String? tier) {
  if (tier == null || tier.isEmpty) return null;
  final label = _sponsorTierLabel(l10n, tier);
  return FBadge(
    variant: FBadgeVariant.primary,
    child: Text(
      label == null
          ? l10n.usahaSponsorBadge
          : l10n.usahaSponsorBadgeTier(label),
    ),
  );
}

/// Baris meta tile: kategori · desa · kecamatan.
String usahaMetaLine(Usaha usaha) {
  final parts = <String>[
    if (usaha.category != null) usaha.category!.name,
    if (usaha.village != null) usaha.village!.name,
    if (usaha.region != null) usaha.region!.name,
    if (usaha.village == null &&
        usaha.region == null &&
        usaha.addressText != null)
      usaha.addressText!,
  ];
  return parts.join(' · ');
}

/// Format harga katalog. Teks bebas apa adanya - kosong = belum dicantumkan.
String usahaPriceLabel(AppLocalizations l10n, UsahaItem item) {
  final price = item.priceText?.trim();
  return price == null || price.isEmpty ? l10n.usahaPriceUnlisted : price;
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
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
                            imageUrl:
                                displayImageUrl(cover, width: 360) ?? cover,
                            fallbackUrl: cover,
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (usahaSponsorListBadge(
                        AppLocalizations.of(context),
                        usaha.sponsorTier,
                      )
                      case final sponsorBadge?)
                    Positioned(top: 6, left: 6, child: sponsorBadge),
                ],
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
    final l10n = AppLocalizations.of(context);
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
      suffix: usahaOperationalBadge(l10n, usaha.operationalStatus),
      onPress: onTap ?? () => context.push(UsahaRouter.detailPath(usaha.slug)),
    );
  }
}
