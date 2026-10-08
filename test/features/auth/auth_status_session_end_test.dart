import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// #127: sesi mati dari jalur luar AuthStatusNotifier (mis.
/// AuthInterceptor._clearSession saat refresh terminal) harus langsung
/// tercermin di state notifier - tanpa restart app.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clearTokens() dari storage -> notifier state isAuth=false', () async {
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'at',
      'refreshToken': 'rt',
    });
    SharedPreferences.setMockInitialValues({'isAuth': true});
    final storage = AuthTokenStorage();
    await storage.setIsAuth(true);

    final container = ProviderContainer(
      overrides: [authTokenStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    // Seed: notifier hidup dengan sesi login (seperti setelah markLoggedIn).
    await container.read(authStatusProvider.notifier).future;
    expect(
      container.read(authStatusProvider).value?.isAuth ?? false,
      isTrue,
      reason: 'prekondisi: sesi login',
    );

    // Skenario #127: _clearSession interceptor -> clearTokens()
    // -> setIsAuth(false) -> stream. State UI harus ikut false.
    await storage.clearTokens();
    await Future<void>.delayed(Duration.zero); // drain microtask stream.

    expect(
      container.read(authStatusProvider).value?.isAuth ?? true,
      isFalse,
      reason: '#127: stale isAuth=true membuat deck vote 401 '
          '"Token tidak disertakan" yang tak sembuh walau di-refresh',
    );
  });
}
