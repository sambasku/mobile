import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/verifier_application/domain/entities/verifier_application.dart';

VerifierApplication _app({
  required String status,
  String? adminComment,
}) {
  return VerifierApplication(
    id: '01APP000000000000000000001',
    status: status,
    phone: '81234567890',
    address: 'Jl. Contoh No. 1',
    socialLinks: const [],
    adminComment: adminComment,
    createdAt: '2026-09-27T00:00:00.000Z',
  );
}

void main() {
  group('VerifierApplication rejected copy helpers', () {
    test('needsRevision saat rejected + admin_comment non-kosong', () {
      final app = _app(status: 'rejected', adminComment: '  Lengkapi alamat  ');
      expect(app.needsRevision, isTrue);
      expect(app.isHardRejected, isFalse);
    });

    test('isHardRejected saat rejected tanpa admin_comment', () {
      final app = _app(status: 'rejected');
      expect(app.needsRevision, isFalse);
      expect(app.isHardRejected, isTrue);
    });

    test('isHardRejected saat rejected dengan comment kosong/spasi', () {
      final app = _app(status: 'rejected', adminComment: '   ');
      expect(app.needsRevision, isFalse);
      expect(app.isHardRejected, isTrue);
    });

    test('pending/approved bukan needsRevision maupun hardRejected', () {
      expect(_app(status: 'pending').needsRevision, isFalse);
      expect(_app(status: 'pending').isHardRejected, isFalse);
      expect(_app(status: 'approved').needsRevision, isFalse);
      expect(_app(status: 'approved').isHardRejected, isFalse);
    });
  });
}
