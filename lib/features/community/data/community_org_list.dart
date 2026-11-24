import '../domain/community_org.dart';

/// Top 2 selalu tampil di atas listing (default, tak ikut filter/search).
/// Detail tiap item akan dirinci menyusul.
const communityTopList = [
  CommunityOrg(
    id: 'top-tim',
    name: 'Tim Kami',
    category: 'lain',
    description: 'Tim pengelola SambasKu.',
    isVerified: true,
  ),
  CommunityOrg(
    id: 'top-sponsor',
    name: 'Sponsor Kami',
    category: 'lain',
    description: 'Para sponsor yang mendukung SambasKu.',
    isVerified: true,
  ),
];

/// Data mock komunitas. TODO(data): ganti dengan data nyata.
const communityOrgList = [
  CommunityOrg(
    id: 'c1',
    name: 'Komunitas Seni 1',
    category: 'seni',
    description:
        'Sanggar seni tari tradisional Saman dan Zapin di Desa Robayan, '
        'Kecamatan Sambas. Rutin latihan setiap malam Jumat.',
    location: 'Kec. Sambas',
    contactUrl: 'https://wa.me/6281234567890?utm_source=sambasku.com&utm_medium=referral',
    isVerified: true,
  ),
  CommunityOrg(
    id: 'c2',
    name: 'Komunitas Bahasa 1',
    category: 'bahasa',
    description:
        'Komunitas pelestari bahasa Melayu Sambas. Menggagas '
        'kamus dan kegiatan literasi warga.',
    location: 'Kab. Sambas',
    contactUrl: 'https://chat.whatsapp.com/sambasku?utm_source=sambasku.com&utm_medium=referral',
    isVerified: true,
  ),
  CommunityOrg(
    id: 'c3',
    name: 'Komunitas Sejarah',
    category: 'lain',
    description:
        'Komunitas peneliti dan dokumentasi sejarah Kabupaten Sambas, '
        'termasuk Kesultanan Sambas.',
    location: 'Kec. Sambas',
    isVerified: false,
  ),
  CommunityOrg(
    id: 'c4',
    name: 'Komunitas Pemuda',
    category: 'lain',
    description:
        'Wadah komunikasi dan kolaborasi pemuda untuk '
        'kegiatan sosial dan pembangunan daerah.',
    location: 'Kab. Sambas',
    isVerified: false,
  ),
  CommunityOrg(
    id: 'c5',
    name: 'Kelompok Bermain 1',
    category: 'pendidikan',
    description:
        'PAUD bermain dengan pendekatan bahasa ibunda dan '
        'budaya lokal untuk anak usia 3-6 tahun.',
    location: 'Kec. Tebas',
    isVerified: false,
  ),
  CommunityOrg(
    id: 'c6',
    name: 'Koperasi 1',
    category: 'ukm',
    description:
        'Koperasi primer untuk pelaku UMKM dan masyarakat '
        'Kabupaten Sambas.',
    location: 'Kec. Sambas',
    contactUrl: 'https://wa.me/6289876543210?utm_source=sambasku.com&utm_medium=referral',
    isVerified: false,
  ),
  CommunityOrg(
    id: 'c7',
    name: 'Kelompok Tani 1',
    category: 'ukm',
    description:
        'Gabungan poktan untuk pertanian dan edukasi '
        'budidaya pertanian berkelanjutan.',
    location: 'Kec. Pemangkat',
    isVerified: false,
  ),
  CommunityOrg(
    id: 'c8',
    name: 'Komunitas Fotografi',
    category: 'seni',
    description:
        'Komunitas fotografer lokal yang mendokumentasikan '
        'kehidupan dan keindahan Sambas.',
    location: 'Kab. Sambas',
    contactUrl: 'https://instagram.com/sambasku?utm_source=sambasku.com&utm_medium=referral',
    isVerified: true,
  ),

  // Simulasi grid panjang (proto) - hapus saat data nyata masuk.
  CommunityOrg(
    id: 's1',
    name: 'Komunitas Seni 2',
    category: 'seni',
    description: 'Sanggar musik dan orkes Melayu Sambas.',
    location: 'Kec. Sambas',
  ),
  CommunityOrg(
    id: 's2',
    name: 'Komunitas Film',
    category: 'seni',
    description: 'Kelompok dokumenter dan film pendek Paloh.',
    location: 'Kec. Paloh',
  ),
  CommunityOrg(
    id: 's3',
    name: 'Paduan Suara 1',
    category: 'seni',
    description: 'Paduan suara lintas gereja Kabupaten Sambas.',
    location: 'Kec. Sambas',
  ),
  CommunityOrg(
    id: 'b1',
    name: 'Komunitas Bahasa 2',
    category: 'bahasa',
    description: 'Kelas daring bahasa Melayu Sambas gratis.',
    location: 'Kab. Sambas',
  ),
  CommunityOrg(
    id: 'b2',
    name: 'Klub Baca 1',
    category: 'bahasa',
    description: 'Klub baca dan tukar buku warga.',
    location: 'Kec. Sambas',
  ),
  CommunityOrg(
    id: 'b3',
    name: 'Komunitas Penerjemah',
    category: 'bahasa',
    description: 'Relawan terjemah konten budaya Sambas.',
    location: 'Kab. Sambas',
  ),
  CommunityOrg(
    id: 'p1',
    name: 'Bimbel 1',
    category: 'pendidikan',
    description: 'Bimbingan belajar gratis untuk pelajar.',
    location: 'Kec. Sebalo',
  ),
  CommunityOrg(
    id: 'p2',
    name: 'Perpustakaan Komunitas',
    category: 'pendidikan',
    description: 'Perpustakaan kecil kelola warga Tebas.',
    location: 'Kec. Tebas',
  ),
  CommunityOrg(
    id: 'p3',
    name: 'Kursus Komputer 1',
    category: 'pendidikan',
    description: 'Kursus digital literasi pemuda Pemangkat.',
    location: 'Kec. Pemangkat',
  ),
  CommunityOrg(
    id: 'u1',
    name: 'UMKM Kuliner 1',
    category: 'ukm',
    description: 'Wadah UMKM kuliner khas Sambas.',
    location: 'Kec. Sambas',
  ),
  CommunityOrg(
    id: 'u2',
    name: 'Pengrajin Tenun 1',
    category: 'ukm',
    description: 'Kelompok pengrajin kain tenun tradisional.',
    location: 'Kec. Teluk Keramat',
  ),
  CommunityOrg(
    id: 'u3',
    name: 'Kelompok Nelayan 1',
    category: 'ukm',
    description: 'Kelompok nelayan dan pengolahan hasil laut.',
    location: 'Kec. Selakau',
  ),
  CommunityOrg(
    id: 'l1',
    name: 'Relawan Bencana',
    category: 'lain',
    description: 'Relawan siaga bencana dan sosial.',
    location: 'Kab. Sambas',
  ),
  CommunityOrg(
    id: 'l2',
    name: 'Komunitas Pecinta Alam',
    category: 'lain',
    description: 'Komunitas pendaki dan pecinta alam.',
    location: 'Kab. Sambas',
  ),
  CommunityOrg(
    id: 'l3',
    name: 'Karang Taruna 1',
    category: 'lain',
    description: 'Karang taruna lintas desa.',
    location: 'Kec. Sambas',
  ),
];

/// Kategori filter untuk halaman komunitas.
enum CommunityCategory {
  semua,
  seni,
  bahasa,
  pendidikan,
  ukm,
  lain;

  String get id => switch (this) {
    semua => 'semua',
    seni => 'seni',
    bahasa => 'bahasa',
    pendidikan => 'pendidikan',
    ukm => 'ukm',
    lain => 'lain',
  };

  static CommunityCategory fromId(String id) => switch (id) {
    'seni' => seni,
    'bahasa' => bahasa,
    'pendidikan' => pendidikan,
    'ukm' => ukm,
    'lain' => lain,
    _ => semua,
  };
}

/// Filter daftar komunitas berdasarkan kategori.
List<CommunityOrg> filterCommunities(
  List<CommunityOrg> all,
  CommunityCategory category,
) {
  if (category == CommunityCategory.semua) return all;
  return all.where((c) => c.category == category.id).toList();
}
