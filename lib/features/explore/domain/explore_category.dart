import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Kategori curated tab Eksplorasi (v1 statis; konten API belakangan).
class ExploreCategory {
  const ExploreCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.comingSoon = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Konten API belum ada - kartu tetap tampil sebagai sasaran app.
  final bool comingSoon;

  static const List<ExploreCategory> all = [
    // Aktif
    ExploreCategory(
      id: 'wilayah',
      title: 'Wilayah',
      subtitle: 'Kecamatan dan desa di Sambas',
      icon: FLucideIcons.signpost,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'wisata',
      title: 'Wisata',
      subtitle: 'Destinasi di Sambas',
      icon: FLucideIcons.mapPinned,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'kuliner',
      title: 'Kuliner',
      subtitle: 'Makanan khas Sambas',
      icon: FLucideIcons.utensilsCrossed,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'usaha',
      title: 'Usaha',
      subtitle: 'UMKM dan jasa lokal',
      icon: FLucideIcons.store,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'acara',
      title: 'Acara',
      subtitle: 'Festival, pameran, dan kegiatan',
      icon: FLucideIcons.calendarDays,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'hiburan',
      title: 'Permainan',
      subtitle: 'Pantun dan permainan Sambas',
      icon: FLucideIcons.tv,
      comingSoon: false,
    ),
    // Segera
    // Gabungan Sejarah + Kisah + Karya + Tradisi + Permainan.
    ExploreCategory(
      id: 'ensiklopedia',
      title: 'Ensiklopedia',
      subtitle: 'Sejarah, kisah, karya, dan tradisi',
      icon: FLucideIcons.bookOpen,
    ),
    ExploreCategory(
      id: 'komunitas',
      title: 'Komunitas',
      subtitle: 'Grup warga dan kegiatan bersama',
      icon: FLucideIcons.users,
    ),
  ];

  static ExploreCategory? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
