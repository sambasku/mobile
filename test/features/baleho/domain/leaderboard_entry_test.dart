import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/baleho/domain/leaderboard_models.dart';

void main() {
  group('LeaderboardEntry.fromJson', () {
    test('parse format baru (submitted_points, approved_points, verification_points)', () {
      final json = <String, dynamic>{
        'rank': 1,
        'username': 'ahmad',
        'avatar_url': 'https://example.com/a.jpg',
        'submitted_points': 15,
        'approved_points': 6,
        'verification_points': 4,
        'combined': 25,
        'is_verifier': true,
      };

      final entry = LeaderboardEntry.fromJson(json);

      expect(entry.rank, 1);
      expect(entry.username, 'ahmad');
      expect(entry.avatarUrl, 'https://example.com/a.jpg');
      expect(entry.submittedPoints, 15);
      expect(entry.approvedPoints, 6);
      expect(entry.verificationPoints, 4);
      expect(entry.combined, 25);
      expect(entry.isVerifier, isTrue);
      // Backward-compat getters
      expect(entry.contributions, 15);
      expect(entry.verifications, 4);
    });

    test('fallback format lama (contributions, verifications) tanpa error', () {
      final json = <String, dynamic>{
        'rank': 2,
        'username': 'budi',
        'contributions': 8,
        'verifications': 12,
        'combined': 20,
        'is_verifier': false,
      };

      final entry = LeaderboardEntry.fromJson(json);

      expect(entry.rank, 2);
      expect(entry.username, 'budi');
      expect(entry.submittedPoints, 8); // fallback dari contributions
      expect(entry.approvedPoints, 0); // default 0 jika lama
      expect(entry.verificationPoints, 12); // fallback dari verifications
      expect(entry.combined, 20);
      expect(entry.isVerifier, isFalse);
    });

    test('toleran field null / kosong', () {
      final entry = LeaderboardEntry.fromJson(<String, dynamic>{});

      expect(entry.rank, 0);
      expect(entry.username, '');
      expect(entry.avatarUrl, isNull);
      expect(entry.submittedPoints, 0);
      expect(entry.approvedPoints, 0);
      expect(entry.verificationPoints, 0);
      expect(entry.combined, 0);
      expect(entry.isVerifier, isFalse);
    });
  });
}
