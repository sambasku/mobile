import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_detail_providers.dart';
import 'package:sambasku_mobile/features/suggest_edit/presentation/pages/suggest_edit_page.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../helpers/l10n_delegates.dart';

const _wordId = '01SUGGESTBACKTESTAAAAAAAAA';

WordDetail _detail() => const WordDetail(
  id: _wordId,
  lemma: 'apam',
  languageId: 'lang-1',
  wordType: 'word',
  status: 'published',
  isVerified: true,
  isCorrected: false,
  meanings: [],
  images: [],
);

class _FakeAuthStatus extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async =>
      const AuthStatusState(isAuth: true, username: 'tester', role: 'contributor');
}

void main() {
  testWidgets(
    '#264: back dari form kategori kembali ke listing, bukan keluar',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: Text('halaman awal')),
          ),
          GoRoute(
            path: '/suggest-edit/:wordId',
            builder: (_, state) => SuggestEditPage(
              wordId: state.pathParameters['wordId']!,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStatusProvider.overrideWith(_FakeAuthStatus.new),
            wordDetailProvider(_wordId).overrideWith((ref) async => _detail()),
          ],
          child: MaterialApp.router(
            theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
            localizationsDelegates: appLocalizationDelegates,
            supportedLocales: appTestSupportedLocales,
            locale: appTestLocale,
            routerConfig: router,
            builder: (context, child) => FTheme(
              data: foruiPalettes['zinc']!.light.touch,
              child: FToaster(child: child!),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.push('/suggest-edit/$_wordId');
      await tester.pumpAndSettle();

      expect(find.text('Apa yang ingin diubah?'), findsOneWidget);
      expect(find.text('halaman awal'), findsNothing);

      // Tambah foto selalu tersedia (tidak butuh makna/gambar existing).
      await tester.tap(find.text('Tambah foto'));
      await tester.pumpAndSettle();

      expect(find.text('Ketuk untuk ganti jenis usulan'), findsOneWidget);
      expect(find.text('Apa yang ingin diubah?'), findsNothing);

      await tester.tap(find.byType(FHeaderAction).first);
      await tester.pumpAndSettle();

      expect(find.text('Apa yang ingin diubah?'), findsOneWidget);
      expect(find.text('halaman awal'), findsNothing);

      await tester.tap(find.byType(FHeaderAction).first);
      await tester.pumpAndSettle();

      expect(find.text('halaman awal'), findsOneWidget);
    },
  );
}
