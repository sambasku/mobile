import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/logout_use_case.dart';

/// Usecase wajib unit test (mobile-base-stack Section 10): logout
/// hanyalah delegasi ke repository, hasil Either diteruskan apa adanya.
class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, void> result;
  int calls = 0;

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

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
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> logout() async {
    calls++;
    return result;
  }

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));
}

void main() {
  test(
    'sukses - right(null) diteruskan dan repository dipanggil sekali',
    () async {
      final repo = _FakeRepo(Either.right(null));
      final usecase = LogoutUseCase(repo);

      final result = await usecase();

      expect(repo.calls, 1);
      expect(result.isRight(), true);
    },
  );

  test('gagal - failure diteruskan tanpa diubah', () async {
    final repo = _FakeRepo(
      Either.left(
        const AuthFailure(
          'Token tidak valid',
          errorCode: 'REFRESH_TOKEN_INVALID',
        ),
      ),
    );
    final usecase = LogoutUseCase(repo);

    final result = await usecase();

    final failure = result.getLeft().toNullable();
    expect(failure?.message, 'Token tidak valid');
    expect(failure?.errorCode, 'REFRESH_TOKEN_INVALID');
  });
}
