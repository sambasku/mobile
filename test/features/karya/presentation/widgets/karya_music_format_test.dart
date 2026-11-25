import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/karya/domain/karya.dart';
import 'package:sambasku_mobile/features/karya/presentation/widgets/karya_music_format.dart';

void main() {
  group('formatKaryaMusicDuration', () {
    test('125000 ms becomes 2:05', () {
      expect(formatKaryaMusicDuration(125000), '2:05');
    });

    test('pads single-digit seconds', () {
      expect(formatKaryaMusicDuration(61000), '1:01');
    });

    test('zero becomes 0:00', () {
      expect(formatKaryaMusicDuration(0), '0:00');
    });
  });

  group('karyaPrimaryArtistName', () {
    test('prefers vocal credit', () {
      final name = karyaPrimaryArtistName(const [
        KaryaCredit(role: 'producer', nameText: 'Prod'),
        KaryaCredit(role: 'vocal', nameText: 'Penyanyi'),
      ]);
      expect(name, 'Penyanyi');
    });

    test('falls back to first named credit', () {
      final name = karyaPrimaryArtistName(const [
        KaryaCredit(role: 'composer', nameText: 'Komposer'),
      ]);
      expect(name, 'Komposer');
    });

    test('returns null when empty', () {
      expect(karyaPrimaryArtistName(const []), isNull);
    });
  });


  group('KaryaEntry.isMusic branch', () {
    test('music kind is music, film is not', () {
      final music = KaryaEntry(
        id: '1',
        slug: 'a',
        title: 'A',
        kind: 'music',
        sambasConnections: const [],
        accessLinks: const [],
        credits: const [],
        excerpts: const [],
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final film = KaryaEntry(
        id: '2',
        slug: 'b',
        title: 'B',
        kind: 'film',
        sambasConnections: const [],
        accessLinks: const [],
        credits: const [],
        excerpts: const [],
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      expect(music.isMusic, isTrue);
      expect(film.isMusic, isFalse);
    });
  });
}
