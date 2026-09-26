import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/forgot_password_use_case.dart';

class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, String> result;
  String? receivedEmail;

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async {
    receivedEmail = email;
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
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async => throw UnimplementedError();
}

void main() {
  test('sukses - email di-trim sebelum kirim', () async {
    final repo = _FakeRepo(
      Either.right('Jika email terdaftar, kode reset telah dikirim'),
    );
    final usecase = ForgotPasswordUseCase(repo);

    final result = await usecase('  budi@test.com  ');

    expect(repo.receivedEmail, 'budi@test.com');
    expect(
      result.getRight().toNullable(),
      'Jika email terdaftar, kode reset telah dikirim',
    );
  });

  test('gagal - failure diteruskan tanpa diubah', () async {
    final repo = _FakeRepo(
      Either.left(
        const AuthFailure(
          'Terlalu banyak percobaan',
          errorCode: 'RATE_LIMITED',
        ),
      ),
    );
    final usecase = ForgotPasswordUseCase(repo);

    final result = await usecase('budi@test.com');
    final failure = result.getLeft().toNullable();
    expect(failure?.errorCode, 'RATE_LIMITED');
  });
}
