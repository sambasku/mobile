import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';

void main() {
  test('lemma berkutip ditandai, kutip dibuang, sisanya teks biasa', () {
    expect(splitQuotedLemma('Menandai "kumis" sudah pas'), [
      ('Menandai ', false),
      ('kumis', true),
      (' sudah pas', false),
    ]);
    expect(splitQuotedLemma('Membagikan kartu · "lading"'), [
      ('Membagikan kartu · ', false),
      ('lading', true),
    ]);
  });

  test('tanpa kutip atau kutip tak berpasangan = satu teks biasa', () {
    expect(splitQuotedLemma('Menandai diskusi sudah pas'), [
      ('Menandai diskusi sudah pas', false),
    ]);
    expect(splitQuotedLemma('ukuran 5" saja'), [('ukuran 5" saja', false)]);
  });
}
