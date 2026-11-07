import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/usaha/domain/entities/usaha.dart';
import 'package:sambasku_mobile/features/usaha/presentation/pages/usaha_list_page.dart';
import 'package:sambasku_mobile/features/usaha/presentation/providers/usaha_browse_providers.dart';
import 'package:sambasku_mobile/features/usaha/presentation/providers/usaha_providers.dart';

import '../../helpers/l10n_delegates.dart';

const _usaha = Usaha(
  id: 'u1',
  slug: 'warung-mak-jam',
  name: 'Warung Mak Jam',
  kind: UsahaKind.product,
  publishStatus: UsahaPublishStatus.published,
  operationalStatus: UsahaOperationalStatus.open,
);

class _StaticBrowse extends UsahaBrowse {
  _StaticBrowse(super.query);

  @override
  Future<UsahaBrowseState> build() async =>
      const UsahaBrowseState(items: [_usaha]);
}

class _RefreshBrowse extends UsahaBrowse {
  _RefreshBrowse(super.query, this.onReload, this.gate);

  final void Function() onReload;
  final Future<void> gate;

  @override
  Future<UsahaBrowseState> build() async =>
      const UsahaBrowseState(items: [_usaha]);

  @override
  Future<void> reload({bool keepItems = false}) async {
    onReload();
    await gate;
  }
}

void main() {
  testWidgets('pull-to-refresh memuat ulang halaman pertama', (tester) async {
    var refreshCalls = 0;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usahaCategoriesProvider.overrideWith((ref) async => const []),
          usahaBrowseProvider.overrideWith2(
            (query) => _RefreshBrowse(
              query,
              () => refreshCalls++,
              refreshCompleter.future,
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          locale: appTestLocale,
          supportedLocales: appTestSupportedLocales,
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(child: UsahaListPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Warung Mak Jam'), findsOneWidget);
    expect(refreshCalls, 0, reason: 'refresh tidak dipanggil sebelum pull');

    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(refreshCalls, 1, reason: 'pull-to-refresh memuat ulang halaman');
    expect(find.byType(RefreshIndicator), findsOneWidget);
    refreshCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.text('Warung Mak Jam'), findsOneWidget);
  });

  testWidgets('reload keepItems tidak unmount grid', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usahaCategoriesProvider.overrideWith((ref) async => const []),
          usahaBrowseProvider.overrideWith2((query) => _StaticBrowse(query)),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          locale: appTestLocale,
          supportedLocales: appTestSupportedLocales,
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: const FToaster(child: UsahaListPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
