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
    ExploreCategory(
      id: 'wisata-kuliner',
      title: 'Wisata & Kuliner',
      subtitle: 'Destinasi dan makanan khas Sambas',
      icon: FLucideIcons.utensilsCrossed,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'bisnis-jasa',
      title: 'Bisnis & Jasa',
      subtitle: 'UMKM dan jasa lokal',
      icon: FLucideIcons.store,
    ),
    ExploreCategory(
      id: 'event-acara',
      title: 'Event & Acara',
      subtitle: 'Festival, pameran, dan kegiatan',
      icon: FLucideIcons.calendarDays,
    ),
    ExploreCategory(
      id: 'kabar-berita',
      title: 'Kabar & Berita',
      subtitle: 'Update dan kabar daerah',
      icon: FLucideIcons.newspaper,
    ),
    ExploreCategory(
      id: 'bahasa-budaya',
      title: 'Bahasa & Budaya',
      subtitle: 'Ungkapan, pantun, dan kamus hidup',
      icon: FLucideIcons.bookOpen,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'sejarah-tokoh',
      title: 'Sejarah & Tokoh',
      subtitle: 'Narasi identitas dan tokoh Sambas',
      icon: FLucideIcons.landmark,
    ),
    ExploreCategory(
      id: 'seni-kerajinan',
      title: 'Seni & Kerajinan',
      subtitle: 'Anyaman, songket, dan kesenian',
      icon: FLucideIcons.palette,
    ),
    ExploreCategory(
      id: 'tradisi-adat',
      title: 'Tradisi & Adat',
      subtitle: 'Upacara dan kalender budaya',
      icon: FLucideIcons.sparkles,
    ),
    ExploreCategory(
      id: 'peta-akses',
      title: 'Peta & Akses',
      subtitle: 'Cara ke lokasi dan transportasi',
      icon: FLucideIcons.map,
      comingSoon: false,
    ),
    ExploreCategory(
      id: 'komunitas',
      title: 'Komunitas & Relawan',
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
