import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/karya/domain/karya.dart';
import 'package:sambasku_mobile/features/karya/presentation/widgets/karya_film_format.dart';

void main() {
  group('karyaFilmRuntimeMinutes', () {
    test('keeps positive minutes', () {
      expect(karyaFilmRuntimeMinutes(95), 95);
    });

    test('null and non-positive become null', () {
      expect(karyaFilmRuntimeMinutes(null), isNull);
      expect(karyaFilmRuntimeMinutes(0), isNull);
      expect(karyaFilmRuntimeMinutes(-3), isNull);
    });
  });

  group('karyaPrimaryDirectorName', () {
    test('prefers director credit', () {
      final name = karyaPrimaryDirectorName(const [
        KaryaCredit(role: 'cast', nameText: 'Pemeran'),
        KaryaCredit(role: 'director', nameText: 'Sutradara'),
      ]);
      expect(name, 'Sutradara');
    });

    test('falls back to first named credit', () {
      expect(
        karyaPrimaryDirectorName(const [
          KaryaCredit(role: 'cast', nameText: 'Pemeran'),
        ]),
        'Pemeran',
      );
    });
  });

  group('KaryaEntry.isFilm branch', () {
    test('film kind is film, music is not', () {
      final film = KaryaEntry(
        id: '1',
        slug: 'f',
        title: 'F',
        kind: 'film',
        sambasConnections: const [],
        accessLinks: const [],
        credits: const [],
        excerpts: const [],
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final music = KaryaEntry(
        id: '2',
        slug: 'm',
        title: 'M',
        kind: 'music',
        sambasConnections: const [],
        accessLinks: const [],
        credits: const [],
        excerpts: const [],
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      expect(film.isFilm, isTrue);
      expect(film.isMusic, isFalse);
      expect(music.isFilm, isFalse);
    });
  });
}
