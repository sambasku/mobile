import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/about/data/datasources/contributors_remote_datasource.dart';
import 'package:sambasku_mobile/features/about/data/datasources/sponsors_remote_datasource.dart';

void main() {
  test('ContributorEntry.fromJson baca sambaskuUsername', () {
    final e = ContributorEntry.fromJson(const {
      'id': 'iamutaki',
      'sambaskuUsername': 'ibnulmutaki',
      'name': 'Ibnul Mutaki',
      'roles': ['developer', 'maintainer'],
      'since': '2019-03-01',
      'note': 'Penggagas',
    });
    expect(e, isNotNull);
    expect(e!.sambaskuUsername, 'ibnulmutaki');
  });

  test('ContributorEntry tanpa field -> null (data lama valid)', () {
    final e = ContributorEntry.fromJson(const {
      'id': 'hanapi',
      'name': 'Hana',
      'roles': ['peneliti'],
      'since': '2020-01-01',
      'note': 'x',
    });
    expect(e, isNotNull);
    expect(e!.sambaskuUsername, isNull);
  });

  test('SponsorEntry.fromJson baca sambaskuUsername / tanpa field', () {
    final withUser = SponsorEntry.fromJson(const {
      'id': '1',
      'sambaskuUsername': 'galang',
      'name': 'Galang Septiadi',
      'since': '2026-09-23',
      'note': 'domain',
    });
    final without = SponsorEntry.fromJson(const {
      'id': '2',
      'name': 'X',
      'since': '2026-01-01',
      'note': 'y',
    });
    expect(withUser!.sambaskuUsername, 'galang');
    expect(without!.sambaskuUsername, isNull);
  });

  test('sambaskuUsername kosong/whitespace -> null (trim)', () {
    final e = ContributorEntry.fromJson(const {
      'id': 'a',
      'sambaskuUsername': '  ',
      'name': 'A',
      'roles': ['r'],
      'since': '2020-01-01',
      'note': 'x',
    });
    expect(e, isNotNull);
    expect(e!.sambaskuUsername, isNull);
  });
}
