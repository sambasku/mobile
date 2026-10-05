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
    // Segera
    ExploreCategory(
      id: 'usaha',
      title: 'Usaha',
      subtitle: 'UMKM dan jasa lokal',
      icon: FLucideIcons.store,
    ),
    ExploreCategory(
      id: 'acara',
      title: 'Acara',
      subtitle: 'Festival, pameran, dan kegiatan',
      icon: FLucideIcons.calendarDays,
    ),
    ExploreCategory(
      id: 'sejarah',
      title: 'Sejarah',
      subtitle: 'Narasi identitas dan tokoh Sambas',
      icon: FLucideIcons.landmark,
    ),
    ExploreCategory(
      id: 'kisah',
      title: 'Kisah',
      subtitle: 'Folklor dan kisah rakyat',
      icon: FLucideIcons.bookOpen,
    ),
    ExploreCategory(
      id: 'karya',
      title: 'Karya',
      subtitle: 'Anyaman, songket, dan kesenian',
      icon: FLucideIcons.palette,
    ),
    ExploreCategory(
      id: 'tradisi',
      title: 'Tradisi',
      subtitle: 'Upacara dan kalender budaya',
      icon: FLucideIcons.sparkles,
    ),
    ExploreCategory(
      id: 'permainan',
      title: 'Permainan',
      subtitle: 'Mainan tradisional anak',
      icon: FLucideIcons.puzzle,
    ),
    ExploreCategory(
      id: 'pendidikan',
      title: 'Pendidikan',
      subtitle: 'Bahan ajar untuk murid',
      icon: FLucideIcons.graduationCap,
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
