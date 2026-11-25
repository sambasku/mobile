import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/karya/data/karya_api.dart';

void main() {
  test('karyaPayloadWire menyertakan cover_url bila diisi', () {
    final wire = karyaPayloadWire(
      title: 'Lagu Tes',
      kind: 'music',
      credits: const [
        {'role': 'vocal', 'name_text': 'Penyanyi'},
      ],
      coverUrl: 'https://cdn.example.com/assets/karyas/abc.jpg',
    );
    expect(
      wire['cover_url'],
      'https://cdn.example.com/assets/karyas/abc.jpg',
    );
  });

  test('karyaPayloadWire menghilangkan cover_url kosong', () {
    final wire = karyaPayloadWire(
      title: 'Film Tes',
      kind: 'film',
      credits: const [
        {'role': 'other', 'name_text': 'Studio'},
      ],
      coverUrl: '',
    );
    expect(wire.containsKey('cover_url'), isFalse);
  });

  test('karyaPayloadWire menyertakan access_links trailer', () {
    final wire = karyaPayloadWire(
      title: 'Film Tes',
      kind: 'film',
      credits: const [
        {'role': 'other', 'name_text': 'Studio'},
      ],
      accessLinks: const [
        {
          'kind': 'trailer',
          'label': 'Trailer',
          'url': 'https://youtube.com/watch?v=abc',
          'is_primary': false,
        },
      ],
    );
    final links = wire['access_links'] as List<dynamic>;
    expect(links, hasLength(1));
    expect(links.first['kind'], 'trailer');
  });
}
