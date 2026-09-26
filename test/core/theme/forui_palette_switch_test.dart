import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palette_controller.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/data/providers/auth_data_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, void>> logout() async => Either.right(null);

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async =>
      Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai'));
}

/// Harness meniru struktur App asli: watch provider → MaterialApp.theme
/// + FTheme di builder. Verifikasi tap palet → state & tema berubah instan.
class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette =
        foruiPalettes[ref.watch(foruiPaletteControllerProvider)] ??
        foruiPalettes[defaultPalette]!;

    return MaterialApp(
      theme: palette.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) => FTheme(
        data: palette.light.touch,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const ProfilePage(),
    );
  }
}

void main() {
  testWidgets('pilih palet Merah → provider & MaterialApp.theme berubah', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const {});
    FlutterSecureStorage.setMockInitialValues(const {});
    await ForuiPaletteController.preload();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const _Harness(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final zincPrimary = FThemes.zinc.light.touch
        .toApproximateMaterialTheme()
        .colorScheme
        .primary;

    // Warna Tema tile mungkin di bawah fold (viewport test 800x600)
    await tester.scrollUntilVisible(
      find.text('Warna Tema'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Warna Tema'));
    // Jangan pumpAndSettle: FTappable/popover bisa menyisakan ticker.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Merah'), findsOneWidget);
    await tester.tap(find.text('Merah'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1) state provider berubah
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfilePage)),
    );
    expect(container.read(foruiPaletteControllerProvider), 'red');

    // 2) MaterialApp dibangun ulang dengan tema merah
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final redPrimary = FThemes.red.light.touch
        .toApproximateMaterialTheme()
        .colorScheme
        .primary;
    expect(materialApp.theme!.colorScheme.primary, redPrimary);
    expect(materialApp.theme!.colorScheme.primary, isNot(zincPrimary));

    // 3) persist
    expect(
      await SharedPreferences.getInstance().then((p) => p.getString('foruiPalette')),
      'red',
    );
  });
}
