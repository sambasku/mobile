import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../l10n/app_localizations.dart';

/// Kategori curated tab Eksplorasi (v1 statis; konten API belakangan).
///
/// [title] dan [subtitle] sengaja TIDAK disimpan di sini - label tinggal di
/// ARB lewat [titleOf] / [subtitleOf] supaya domain bebas bahasa.
class ExploreCategory {
  const ExploreCategory({
    required this.id,
    required this.icon,
    this.comingSoon = true,
  });

  final String id;
  final IconData icon;

  /// Konten API belum ada - kartu tetap tampil sebagai sasaran app.
  final bool comingSoon;

  /// Cover WebP di `assets/images/explore_covers/` (null = tanpa ilustrasi).
  String? get coverAsset => switch (id) {
    'wilayah' => 'assets/images/explore_covers/wilayah.webp',
    'wisata' => 'assets/images/explore_covers/wisata.webp',
    'kuliner' => 'assets/images/explore_covers/kuliner.webp',
    'usaha' => 'assets/images/explore_covers/usaha.webp',
    'acara' => 'assets/images/explore_covers/acara.webp',
    'hiburan' => 'assets/images/explore_covers/permainan.webp',
    'ensiklopedia' => 'assets/images/explore_covers/ensiklopedia.webp',
    'layanan' => 'assets/images/explore_covers/layanan.webp',
    _ => null,
  };

  /// Judul kategori sesuai bahasa aktif.
  String titleOf(AppLocalizations l10n) => switch (id) {
    'wilayah' => l10n.exploreCategoryWilayah,
    'wisata' => l10n.exploreCategoryWisata,
    'kuliner' => l10n.exploreCategoryKuliner,
    'usaha' => l10n.usahaTitle,
    'layanan' => l10n.exploreCategoryLayanan,
    'acara' => l10n.exploreCategoryAcara,
    'hiburan' => l10n.exploreCategoryPermainan,
    'ensiklopedia' => l10n.exploreCategoryEnsiklopedia,
    'komunitas' => l10n.exploreCategoryKomunitas,
    _ => id,
  };

  /// Subjudul kategori sesuai bahasa aktif.
  String subtitleOf(AppLocalizations l10n) => switch (id) {
    'wilayah' => l10n.exploreCategoryWilayahSubtitle,
    'wisata' => l10n.exploreCategoryWisataSubtitle,
    'kuliner' => l10n.exploreCategoryKulinerSubtitle,
    'usaha' => l10n.exploreCategoryUsahaSubtitle,
    'layanan' => l10n.exploreCategoryLayananSubtitle,
    'acara' => l10n.exploreCategoryAcaraSubtitle,
    'hiburan' => l10n.exploreCategoryPermainanSubtitle,
    'ensiklopedia' => l10n.exploreCategoryEnsiklopediaSubtitle,
    'komunitas' => l10n.exploreCategoryKomunitasSubtitle,
    _ => '',
  };

  static const List<ExploreCategory> all = [
    // Aktif
    ExploreCategory(
      id: 'wilayah',
      icon: FLucideIcons.signpost,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'wisata',
      icon: FLucideIcons.mapPinned,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'kuliner',
      icon: FLucideIcons.utensilsCrossed,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'usaha',
      icon: FLucideIcons.store,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'acara',
      icon: FLucideIcons.calendarDays,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'hiburan',
      icon: FLucideIcons.tv,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'ensiklopedia',
      icon: FLucideIcons.bookOpen,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'layanan',
      icon: FLucideIcons.phone,
      comingSoon: false,
    ),
    // Segera
    // Gabungan Sejarah + Kisah + Karya + Tradisi + Permainan.
    ExploreCategory(id: 'komunitas', icon: FLucideIcons.users),
  ];

  static ExploreCategory? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
