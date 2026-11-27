import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/explore_page.dart';
import 'package:sambasku_mobile/features/report_bug/presentation/report_bug_page.dart';
import 'package:sambasku_mobile/features/report_bug/report_bug_router.dart';

import '../../helpers/l10n_delegates.dart';

class _GuestAuthStatusNotifier extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async => const AuthStatusState(isAuth: false);
}

void main() {
  testWidgets(
    'ExplorePage menampilkan kartu CTA kritik/saran dan membuka /feedback saat ditekan',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: '/explore',
        routes: [
          GoRoute(
            path: '/explore',
            builder: (_, _) => const FScaffold(
              child: ExplorePage(mapHeroOverride: SizedBox(height: 140)),
            ),
          ),
          GoRoute(
            path: ReportBugRouter.feedback.path,
            name: ReportBugRouter.feedback.name,
            builder: (_, _) =>
                const ReportBugPage(mode: ReportBugMode.feedback),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStatusProvider.overrideWith(_GuestAuthStatusNotifier.new),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: appLocalizationDelegates,
            locale: appTestLocale,
            supportedLocales: appTestSupportedLocales,
            builder: (context, child) => FTheme(
              data: foruiPalettes['zinc']!.light.touch,
              child: FToaster(child: child!),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ctaTitle = find.text('Punya kritik atau saran?');
      await tester.scrollUntilVisible(ctaTitle, 200);
      expect(ctaTitle, findsOneWidget);
      expect(
        find.text(
          'Bantu kami membuat pengalaman menggunakan SambasKu jadi lebih nyaman untukmu!',
        ),
        findsOneWidget,
      );

      await tester.tap(ctaTitle);
      await tester.pumpAndSettle();

      expect(find.text('Kritik & Saran'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Ilustrasi kirim kritik dan saran untuk SambasKu'),
        findsOneWidget,
      );
    },
  );
}
