import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/ports/google_sign_in_port.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/login_with_google_use_case.dart';

class _ThrowingSignIn implements GoogleSignInPort {
  @override
  Future<String?> authenticate() async {
    throw StateError('SHA-1 tidak cocok dengan client Android');
  }
}

class _FakeSignIn implements GoogleSignInPort {
  _FakeSignIn(this.token);

  final String? token;
  var calls = 0;

  @override
  Future<String?> authenticate() async {
    calls++;
    return token;
  }
}

/// Picker hilang saat app di-background: future tidak pernah complete.
class _HangingSignIn implements GoogleSignInPort {
  @override
  Future<String?> authenticate() => Completer<String?>().future;
}

class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);

  final Either<AuthFailure, AuthSession> result;
  String? receivedToken;
  var loginWithGoogleCalls = 0;

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
    List<({String documentType, String documentVersion})>? consents,
  }) async {
    loginWithGoogleCalls++;
    receivedToken = idToken;
    return result;
  }

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
    List<({String documentType, String documentVersion})>? consents,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
    List<({String documentType, String documentVersion})>? consents,
  }) async => Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
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

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async => throw UnimplementedError();

  @override
  Future<Either<AuthFailure, void>> logout() async =>
      throw UnimplementedError();
}

AuthSession get _session => AuthSession(
  userId: 'u1',
  username: 'user1',
  displayName: 'User Satu',
  role: 'user',
  avatarUrl: null,
);

void main() {
  test('sukses: token diteruskan ke repo', () async {
    final repo = _FakeRepo(Either.right(_session));
    final signIn = _FakeSignIn('id-token-google');
    final usecase = LoginWithGoogleUseCase(repo, signIn);

    final result = await usecase();

    expect(signIn.calls, 1);
    expect(repo.receivedToken, 'id-token-google');
    expect(result.getRight().toNullable()?.username, 'user1');
  });

  test('409 EMAIL_ALREADY_EXISTS diteruskan apa adanya', () async {
    final repo = _FakeRepo(
      Either.left(
        const AuthFailure(
          'Email sudah dipakai.',
          errorCode: 'EMAIL_ALREADY_EXISTS',
        ),
      ),
    );
    final usecase = LoginWithGoogleUseCase(repo, _FakeSignIn('id-token'));

    final result = await usecase();

    expect(result.getLeft().toNullable()?.errorCode, 'EMAIL_ALREADY_EXISTS');
  });

  test(
    'batal SDK → AuthFailure GOOGLE_SIGN_IN_CANCELED, tidak panggil API',
    () async {
      final repo = _FakeRepo(Either.right(_session));
      final usecase = LoginWithGoogleUseCase(repo, _FakeSignIn(null));

      final result = await usecase();

      expect(repo.loginWithGoogleCalls, 0);
      final failure = result.getLeft().toNullable();
      expect(failure?.errorCode, AuthFailure.googleSignInCanceled);
      expect(failure?.message, 'Masuk dibatalkan.');
      expect(failure?.isSocialSignInCanceled, isTrue);
    },
  );

  test('idToken kosong → AuthFailure generik, tidak panggil API', () async {
    final repo = _FakeRepo(Either.right(_session));
    final usecase = LoginWithGoogleUseCase(repo, _FakeSignIn(' '));

    final result = await usecase();

    expect(repo.loginWithGoogleCalls, 0);
    expect(
      result.getLeft().toNullable()?.message,
      'Tidak bisa masuk dengan Google.',
    );
  });

  test('exception SDK → AuthFailure pesan singkat, tanpa detail SHA', () async {
    final repo = _FakeRepo(Either.right(_session));
    final usecase = LoginWithGoogleUseCase(repo, _ThrowingSignIn());

    final result = await usecase();

    expect(repo.loginWithGoogleCalls, 0);
    final message = result.getLeft().toNullable()?.message ?? '';
    expect(message, isNot(contains('SHA-1')));
    expect(message, 'Tidak bisa masuk dengan Google. Coba lagi.');
  });

  test('authenticate menggantung (picker hilang di background) → '
      'timeout membebaskan dengan batal, bukan hang selamanya', () async {
    final repo = _FakeRepo(Either.right(_session));
    final usecase = LoginWithGoogleUseCase(
      repo,
      _HangingSignIn(),
      authTimeout: const Duration(milliseconds: 100),
    );

    final result = await usecase().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TestFailure('use case hang selamanya'),
    );

    final failure = result.getLeft().toNullable();
    expect(failure?.errorCode, AuthFailure.googleSignInCanceled);
    expect(failure?.isSocialSignInCanceled, isTrue);
    expect(repo.loginWithGoogleCalls, 0);
  });
}
