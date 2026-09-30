import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/reset_password_use_case.dart';

class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, String> result;
  String? receivedToken;
  String? receivedEmail;
  String? receivedCode;
  String? receivedPassword;

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async {
    receivedToken = token;
    receivedEmail = email;
    receivedCode = code;
    receivedPassword = newPassword;
    return result;
  }

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));


  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, void>> logout() async =>
      throw UnimplementedError();

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async =>
      throw UnimplementedError();

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async => throw UnimplementedError();
}

void main() {
  group('extractResetToken', () {
    test('ambil token dari query tautan https', () {
      expect(
        extractResetToken(
          'https://sambasku.iamutaki.com/reset-password?token=abc123',
        ),
        'abc123',
      );
    });

    test('ambil token dari deep link aplikasi', () {
      expect(
        extractResetToken('sambasku://app/reset-password?token=xyz'),
        'xyz',
      );
    });

    test('token mentah di-trim', () {
      expect(extractResetToken('  raw-token  '), 'raw-token');
    });
  });

  test('sukses - token dari tautan diekstrak sebelum kirim', () async {
    final repo = _FakeRepo(Either.right('Password berhasil direset'));
    final usecase = ResetPasswordUseCase(repo);

    final result = await usecase(
      const ResetPasswordParams(
        token: 'sambasku://app/reset-password?token=tok1',
        newPassword: 'Password123',
      ),
    );

    expect(repo.receivedToken, 'tok1');
    expect(repo.receivedPassword, 'Password123');
    expect(result.getRight().toNullable(), 'Password berhasil direset');
  });

  test('sukses - jalur aplikasi email+kode 6 karakter', () async {
    final repo = _FakeRepo(Either.right('Password berhasil direset'));
    final usecase = ResetPasswordUseCase(repo);

    await usecase(
      const ResetPasswordParams(
        email: '  budi@test.com  ',
        code: 'a4k-9m2',
        newPassword: 'Password123',
      ),
    );

    expect(repo.receivedEmail, 'budi@test.com');
    expect(repo.receivedCode, 'A4K9M2');
    expect(repo.receivedToken, isNull);
  });

  test('gagal - RESET_TOKEN_INVALID diteruskan', () async {
    final repo = _FakeRepo(
      Either.left(
        const AuthFailure(
          'Token reset tidak valid atau kadaluarsa',
          errorCode: 'RESET_TOKEN_INVALID',
        ),
      ),
    );
    final usecase = ResetPasswordUseCase(repo);

    final result = await usecase(
      const ResetPasswordParams(token: 'expired', newPassword: 'Password123'),
    );
    expect(result.getLeft().toNullable()?.errorCode, 'RESET_TOKEN_INVALID');
  });
}
