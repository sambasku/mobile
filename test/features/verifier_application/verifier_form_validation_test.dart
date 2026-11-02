import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/verifier_application/presentation/pages/verifier_application_page.dart';

SocialDraft _row({
  String? platform = 'instagram',
  String username = 'namaku',
  String? screenshotUrl = 'https://cdn.test/a.jpg',
  String? screenshotFileId = 'file-1',
  bool uploading = false,
  bool error = false,
}) {
  return SocialDraft(
    platform: platform,
    username: username,
    screenshotUrl: screenshotUrl,
    screenshotFileId: screenshotFileId,
    uploading: uploading,
    error: error,
  );
}

List<String> _errors({
  String phoneDigits = '6281234567890',
  String address = 'Jl. Contoh No. 1, Sambas',
  List<SocialDraft>? social,
}) {
  return verifierFormErrors(
    phoneDigits: phoneDigits,
    address: address,
    social: social ?? [_row()],
  );
}

void main() {
  group('verifierFormErrors', () {
    test('form lengkap tidak menghasilkan error', () {
      expect(_errors(), isEmpty);
    });

    test('baris ke-2 tanpa platform ditolak dengan pesan jelas (#195)', () {
      final errors = _errors(social: [_row(), _row(platform: null)]);
      expect(errors, contains('Pilih platform untuk akun ke-2.'));
    });

    test('baris pertama tanpa platform memakai label akun pertama', () {
      final errors = _errors(
        social: [_row(platform: null, username: '', screenshotUrl: null)],
      );
      expect(errors, contains('Pilih platform untuk akun pertama.'));
    });

    test('daftar akun kosong ditolak', () {
      expect(
        _errors(social: []),
        contains('Tambahkan minimal satu akun media sosial.'),
      );
    });

    test('nomor HP kosong dan invalid', () {
      expect(_errors(phoneDigits: ''), contains('Nomor HP wajib diisi.'));
      expect(
        _errors(phoneDigits: '628'),
        contains('Nomor HP tidak valid. Contoh: 81234567890.'),
      );
    });

    test('alamat kurang dari 10 karakter', () {
      expect(
        _errors(address: 'Jl. A'),
        contains('Alamat minimal 10 karakter.'),
      );
    });

    test('username kurang dari 2 karakter', () {
      final errors = _errors(social: [_row(username: ' @ ')]);
      expect(
        errors,
        contains('Nama atau username akun pertama minimal 2 karakter.'),
      );
    });

    test('screenshot belum ada, sedang upload, dan gagal upload', () {
      expect(
        _errors(social: [_row(screenshotUrl: null, screenshotFileId: null)]),
        contains('Unggah screenshot profil akun pertama.'),
      );
      expect(
        _errors(social: [_row(uploading: true)]),
        contains('Tunggu screenshot akun pertama selesai diunggah.'),
      );
      expect(
        _errors(social: [_row(error: true)]),
        contains('Screenshot akun pertama gagal diunggah. Coba lagi.'),
      );
    });
  });
}
