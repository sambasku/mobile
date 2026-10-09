import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/network/failover/api_host_resolver.dart';
import 'package:sambasku_mobile/features/profile/presentation/widgets/api_host_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final resolver = ApiHostResolver.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await resolver.setForcedTier(null);
    resolver.configure(
      primaryHost: 'https://api.sambasku.com',
      fallbackHosts: const [
        'https://deno.sambasku.com',
        'https://render.sambasku.com',
      ],
    );
  });

  tearDown(() async {
    await resolver.setForcedTier(null);
  });

  Future<void> pumpTile(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: FScaffold(
              child: Builder(
                builder: (context) => FTileGroup(
                  children: [apiHostTile(context, resolver)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mode otomatis - label "Otomatis"', (tester) async {
    await pumpTile(tester);
    expect(find.text('Server'), findsOneWidget);
    expect(find.text('Otomatis'), findsOneWidget);
  });

  testWidgets('mode terkunci - label menunjukkan host terpilih', (tester) async {
    await resolver.setForcedTier(2);
    await pumpTile(tester);
    expect(find.text('Render'), findsOneWidget);
  });

  testWidgets('tap tile membuka sheet berisi 3 host + Otomatis', (tester) async {
    await pumpTile(tester);
    await tester.tap(find.text('Server'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Server'), findsOneWidget);
    expect(find.text('Cloudflare'), findsOneWidget);
    expect(find.text('Deno Deploy'), findsOneWidget);
    expect(find.text('Render'), findsOneWidget);
    expect(find.text('Uji semua'), findsOneWidget);
  });

  testWidgets('pilih Render di sheet → resolver terkunci ke tier 3', (tester) async {
    await pumpTile(tester);
    await tester.tap(find.text('Server'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Render').last);
    await tester.pumpAndSettle();

    expect(resolver.forcedTierIndex, 2);
    expect(resolver.activeHost, 'https://render.sambasku.com');
  });
}