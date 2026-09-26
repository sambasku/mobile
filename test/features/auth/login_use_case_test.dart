import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/login_use_case.dart';

/// Usecase wajib unit test (mobile-base-stack Section 10):
/// trim email + teruskan hasil Either apa adanya.
class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, AuthSession> result;
  String? receivedEmail;

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    return result;
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  const session = AuthSession(
    userId: '01U',
    username: 'budi',
    role: 'contributor',
  );

  test('sukses - email di-trim sebelum kirim', () async {
    final repo = _FakeRepo(Either.right(session));
    final usecase = LoginUseCase(repo);

    final result = await usecase(
      const LoginParams(email: '  budi@test.com  ', password: 'Password123'),
    );

    expect(repo.receivedEmail, 'budi@test.com');
    expect(result.getRight().toNullable()?.username, 'budi');
  });

  test('gagal - failure diteruskan tanpa diubah', () async {
    final repo = _FakeRepo(
      Either.left(
        const AuthFailure(
          'Email atau password salah',
          errorCode: 'INVALID_CREDENTIALS',
        ),
      ),
    );
    final usecase = LoginUseCase(repo);

    final result = await usecase(
      const LoginParams(email: 'budi@test.com', password: 'salah'),
    );

    final failure = result.getLeft().toNullable();
    expect(failure?.message, 'Email atau password salah');
    expect(failure?.errorCode, 'INVALID_CREDENTIALS');
  });
}
