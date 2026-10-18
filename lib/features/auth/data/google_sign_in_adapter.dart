import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/env.dart';
import '../../../flavors.dart';
import '../domain/ports/google_sign_in_port.dart';

class GoogleSignInAdapter implements GoogleSignInPort {
  bool _initialized = false;

  /// Cancel < 800ms biasanya bukan user batal, tapi token issuance ditolak
  /// (mis. package/SHA-1 tidak cocok dengan OAuth client). Log membedakan
  /// kasus lapangan tanpa menebak.
  static const _instantCancelMs = 800;

  @override
  Future<String?> authenticate() async {
    final serverClientId = Env.googleWebClientId?.trim();
    if (serverClientId == null || serverClientId.isEmpty) {
      throw StateError(
        'Masuk dengan Google belum siap di perangkat ini. Coba lagi nanti.',
      );
    }

    final sw = Stopwatch()..start();
    try {
      if (!_initialized) {
        await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
        _initialized = true;
      }

      var account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'openid', 'profile'],
      );
      var idToken = account.authentication.idToken;

      // ponytail: credential cache bisa kasih idToken null (dikenal di
      // google_sign_in 7.x); 1x authenticate() ulang cukup menutup itu.
      // Kalau masih sering, upgrade ke authorizationClient().
      if (idToken == null || idToken.trim().isEmpty) {
        developer.log(
          'idToken null setelah authenticate - retry sekali',
          name: 'auth.google',
        );
        account = await GoogleSignIn.instance.authenticate(
          scopeHint: const ['email', 'openid', 'profile'],
        );
        idToken = account.authentication.idToken;
      }

      if (idToken == null || idToken.trim().isEmpty) {
        sw.stop();
        throw StateError('Tidak bisa masuk dengan Google. Coba lagi.');
      }
      return idToken;
    } on GoogleSignInException catch (error, stack) {
      _log('GoogleSignInException code=${error.code}', error, stack);

      // User dismiss / batal / interrupt → null (toast "dibatalkan" di UI).
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        final elapsed = sw.elapsedMilliseconds;
        developer.log(
          elapsed < _instantCancelMs
              ? 'cancel instan ${elapsed}ms - indikasi config (package/SHA), '
                  'bukan user batal'
              : 'cancel oleh user setelah ${elapsed}ms',
          name: 'auth.google',
        );
        return null;
      }

      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        final packageName = F.isStaging
            ? 'com.iamutaki.sambasku.staging'
            : 'com.iamutaki.sambasku';
        _log(
          'clientConfigurationError - di GCP (project Web client yang sama) '
          'daftarkan OAuth Android: package $packageName + SHA-1 keystore '
          'yang menandatangani build (upload JKS lokal / Play App Signing)',
          error,
          stack,
        );
        throw StateError(
          'Masuk dengan Google belum siap di perangkat ini. Coba lagi nanti.',
        );
      }

      throw StateError('Tidak bisa masuk dengan Google. Coba lagi.');
    } catch (error, stack) {
      _log('authenticate gagal', error, stack);
      rethrow;
    }
  }

  void _log(String message, Object error, StackTrace stack) {
    debugPrint('[auth.google] $message');
    developer.log(
      message,
      name: 'auth.google',
      error: error,
      stackTrace: stack,
    );
  }
}
