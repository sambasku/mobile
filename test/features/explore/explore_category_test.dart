import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/explore_category.dart';

void main() {
  test('kategori aktif: wisata + kuliner selalu ada', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon);
    expect(active.map((c) => c.id), containsAll(['wisata', 'kuliner']));
  });

  test('comingSoon: komunitas sudah aktif bersama kategori lainnya', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon).toList();
    final coming = ExploreCategory.all.where((c) => c.comingSoon).toList();
    expect(coming, isEmpty);
    expect(active, ExploreCategory.all);
    expect(active.map((c) => c.id), contains('komunitas'));
  });

  test('posisi kartu aktif tetap konsisten', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon).toList();
    expect(active, isNotEmpty);
    // Anchor urutan = karya sebelum komunitas (komunitas kartu terakhir).
    expect(
      ExploreCategory.byId('komunitas'),
      active.last,
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
    // Pengganti: ensiklopedia + hiburan; karya = musik/film; komunitas = direktori.
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
