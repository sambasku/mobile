import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/register_use_case.dart';

const _consents = [
  (documentType: 'terms', documentVersion: '2026-09-26'),
  (documentType: 'privacy', documentVersion: '2026-09-26'),
];

class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, void> result;
  String? receivedName;
  String? receivedEmail;
  String? receivedPhone;

  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async {
    receivedName = name;
    receivedEmail = email;
    receivedPhone = phone;
    return result;
  }

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
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
  test('sukses - name/email di-trim, phone diteruskan', () async {
    final repo = _FakeRepo(Either.right(null));
    final usecase = RegisterUseCase(repo);

    final result = await usecase(
      const RegisterParams(
        name: '  Budi  ',
        email: '  budi@test.com  ',
        phoneNationalDigits: '81234567890',
        password: 'Password123',
        confirmPassword: 'Password123',
        consents: _consents,
      ),
    );

    expect(repo.receivedName, 'Budi');
    expect(repo.receivedEmail, 'budi@test.com');
    expect(repo.receivedPhone, '81234567890');
    expect(result.isRight(), isTrue);
  });

  test('gagal - failure diteruskan', () async {
    final repo = _FakeRepo(
      Either.left(
        const AuthFailure(
          'Email sudah terdaftar',
          errorCode: 'EMAIL_ALREADY_EXISTS',
        ),
      ),
    );
    final usecase = RegisterUseCase(repo);

    final result = await usecase(
      const RegisterParams(
        name: 'Budi',
        email: 'budi@test.com',
        password: 'Password123',
        confirmPassword: 'Password123',
        consents: _consents,
      ),
    );

    final failure = result.getLeft().toNullable();
    expect(failure?.errorCode, 'EMAIL_ALREADY_EXISTS');
  });
}
