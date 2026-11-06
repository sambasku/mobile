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
  String fullName = 'Budi Santoso',
  String phoneDigits = '6281234567890',
  String address = 'Jl. Contoh No. 1, Sambas',
  List<SocialDraft>? social,
  String reason = 'Saya ingin meninjau kata.',
  bool photoUploading = false,
  bool photoFailed = false,
}) {
  return verifierFormErrors(
    fullName: fullName,
    phoneDigits: phoneDigits,
    address: address,
    social: social ?? [_row()],
    reason: reason,
    photoUploading: photoUploading,
    photoFailed: photoFailed,
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

    test('nama lengkap kurang dari 2 karakter', () {
      expect(
        _errors(fullName: 'A'),
        contains('Nama lengkap minimal 2 karakter.'),
      );
    });

    test('nomor HP kosong dan invalid', () {
      expect(_errors(phoneDigits: ''), contains('Nomor HP wajib diisi.'));
      expect(
        _errors(phoneDigits: '628'),
        contains('Nomor HP tidak valid. Contoh: 81234567890.'),
      );
    });

    test('alasan kurang dari 10 karakter', () {
      expect(
        _errors(reason: 'pendek'),
        contains('Alasan minimal 10 karakter.'),
      );
    });

    test('foto diri yang sedang diunggah menahan kirim', () {
      expect(
        _errors(photoUploading: true),
        contains('Tunggu foto diri selesai diunggah.'),
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
