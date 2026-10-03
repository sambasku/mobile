import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/utils/parse_mentions.dart';

void main() {
  group('parseMentionCandidates', () {
    test('ambil token setelah @ di akhir teks sebelum kursor', () {
      expect(parseMentionCandidates('hai @bu'), ['bu']);
      expect(parseMentionCandidates('hai @budi dan @siti'), ['budi', 'siti']);
    });

    test('tolak token tanpa @, <2 char, >30 char, dan username anonim', () {
      expect(parseMentionCandidates('hai @b'), isEmpty); // min 2
      expect(parseMentionCandidates('@${'a' * 31}'), isEmpty); // max 30
      expect(parseMentionCandidates('email@contoh.com'), isEmpty); // bukan token mention
      expect(parseMentionCandidates('@anonim'), isEmpty); // system user
    });

    test('dedupe case-insensitive, tampil sesuai ketikan', () {
      expect(parseMentionCandidates('@Budi @budi'), ['Budi']);
    });

    test('hanya token sebelum kursor', () {
      expect(parseMentionCandidates('hai @budi dan @s', cursor: 9), ['budi']);
      expect(parseMentionCandidates('hai @budi dan @sa', cursor: 17), ['sa']);
      // token 1 char (< min 2) tidak jadi kandidat
      expect(parseMentionCandidates('hai @budi dan @s', cursor: 16), isEmpty);
    });
  });

  group('insertMention', () {
    test('ganti token @jus dengan @username + spasi, kursor setelah spasi', () {
      final result = insertMention('halo @jus di sini', 9, 'budi');
      expect(result.text, 'halo @budi di sini');
      expect(result.cursor, 11);
    });

    test('spasi selalu ditambah di ujung mention di akhir kalimat', () {
      final result = insertMention('halo @jus', 9, 'budi');
      expect(result.text, 'halo @budi ');
      expect(result.cursor, 11);
    });
  });
}
