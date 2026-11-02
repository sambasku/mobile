import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/explore/domain/explore_category.dart';

void main() {
  test('kategori aktif: wisata + kuliner selalu ada', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon);
    expect(active.map((c) => c.id), containsAll(['wisata', 'kuliner']));
  });

  test('comingSoon mayoritas: filter memang mengurangi jumlah kartu', () {
    final active = ExploreCategory.all.where((c) => !c.comingSoon).length;
    final coming = ExploreCategory.all.where((c) => c.comingSoon).length;
    expect(active, lessThan(ExploreCategory.all.length));
    expect(active + coming, ExploreCategory.all.length);
    // Kesan pertama tab: kartu aktif dominan tampil, stub tersembunyi.
    expect(active, greaterThanOrEqualTo(2));
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
    // Anchor urutan = kartu aktif TERAKHIR (permainan, setelah acara).
    expect(withSoon.indexOf(ExploreCategory.byId('hiburan')!), active.length - 1);
    expect(
      ExploreCategory.all.indexWhere((c) => c.id == 'acara') <
          ExploreCategory.all.indexWhere((c) => c.id == 'hiburan'),
      isTrue,
    );
  });

  test('kategori lama digabung/dihapus: hanya id baru yang boleh ada', () {
    final ids = ExploreCategory.all.map((c) => c.id).toSet();
    // Dihapus: sejarah, kisah, karya, tradisi, permainan, pendidikan.
    expect(
      ids.containsAll(['sejarah', 'kisah', 'karya', 'tradisi', 'permainan', 'pendidikan']),
      isFalse,
    );
    // Pengganti: ensiklopedia (gabungan 5 kategori budaya) + hiburan.
    expect(ids.containsAll(['ensiklopedia', 'hiburan']), isTrue);
  });
}
