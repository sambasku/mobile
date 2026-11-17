import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/explore_category.dart';

void main() {
  test('kategori aktif: wisata + kuliner selalu ada', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon);
    expect(active.map((c) => c.id), containsAll(['wisata', 'kuliner']));
  });

  test('comingSoon: komunitas satu-satunya stub di grid', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon).toList();
    final coming = ExploreCategory.all.where((c) => c.comingSoon).toList();
    expect(coming.map((c) => c.id), ['komunitas']);
    expect(active + coming, ExploreCategory.all);
    expect(active, isNotEmpty);
  });

  test('toggle segera hadir tidak menggeser posisi kartu aktif', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon).toList();
    final soon = ExploreCategory.all.where((c) => c.comingSoon).toList();
    final withSoon = [...active, ...soon];

    // Kartu aktif menempati prefix yang identik sebelum & sesudah toggle.
    expect(
      withSoon.take(active.length).map((c) => c.id),
      active.map((c) => c.id),
    );
    // Anchor urutan = kartu aktif TERAKHIR (karya, setelah layanan).
    expect(
      withSoon.indexOf(ExploreCategory.byId('karya')!),
      active.length - 1,
    );
    expect(
      ExploreCategory.all.indexWhere((c) => c.id == 'acara') <
          ExploreCategory.all.indexWhere((c) => c.id == 'hiburan'),
      isTrue,
    );
    expect(
      ExploreCategory.all.indexWhere((c) => c.id == 'hiburan') <
          ExploreCategory.all.indexWhere((c) => c.id == 'ensiklopedia'),
      isTrue,
    );
    expect(
      ExploreCategory.all.indexWhere((c) => c.id == 'ensiklopedia') <
          ExploreCategory.all.indexWhere((c) => c.id == 'layanan'),
      isTrue,
    );
    expect(
      ExploreCategory.all.indexWhere((c) => c.id == 'layanan') <
          ExploreCategory.all.indexWhere((c) => c.id == 'karya'),
      isTrue,
    );
  });

  test('kategori lama digabung/dihapus: hanya id baru yang boleh ada', () {
    final ids = ExploreCategory.all.map((c) => c.id).toSet();
    // Dihapus: sejarah, kisah, tradisi, permainan, pendidikan.
    expect(
      ids.containsAll([
        'sejarah',
        'kisah',
        'tradisi',
        'permainan',
        'pendidikan',
      ]),
      isFalse,
    );
    // Pengganti: ensiklopedia + hiburan; karya = musik/film; komunitas = stub.
    expect(
      ids.containsAll(['ensiklopedia', 'hiburan', 'karya', 'komunitas']),
      isTrue,
    );
  });

  test('cover karya ada di assets explore_covers', () {
    final karya = ExploreCategory.byId('karya');
    expect(karya, isNotNull);
    expect(karya!.coverAsset, 'assets/images/explore_covers/karya.webp');
    expect(karya.comingSoon, isFalse);
  });
}
