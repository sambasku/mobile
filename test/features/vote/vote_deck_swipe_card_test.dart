import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_deck_swipe_card.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      home: FTheme(
        data: FThemes.zinc.light.touch,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 240,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('swipe atas melewati ambang memanggil onSwiped skip', (
    tester,
  ) async {
    VoteDeckSwipeDirection? got;

    await tester.pumpWidget(
      wrap(
        VoteDeckSwipeCard(
          itemKey: 'a',
          enabled: true,
          onSwiped: (direction) async {
            got = direction;
            return true;
          },
          child: const SizedBox.expand(
            child: Center(child: Text('kartu')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ambang 28% dari 240 = 67.2; drag -120 melewati ambang.
    await tester.timedDrag(
      find.byType(VoteDeckSwipeCard),
      const Offset(0, -120),
      const Duration(milliseconds: 120),
    );
    await tester.pumpAndSettle();

    expect(got, VoteDeckSwipeDirection.skip);
  });

  testWidgets('drag kanan parsial menampilkan arrowBigUp', (tester) async {
    await tester.pumpWidget(
      wrap(
        VoteDeckSwipeCard(
          itemKey: 'b',
          enabled: true,
          onSwiped: (_) async => true,
          child: const SizedBox.expand(
            child: Center(child: Text('kartu')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(FLucideIcons.arrowBigUp), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VoteDeckSwipeCard)),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(find.byIcon(FLucideIcons.arrowBigUp), findsOneWidget);
    expect(find.byIcon(FLucideIcons.arrowBigDown), findsNothing);
    expect(find.byIcon(FLucideIcons.check), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('drag kiri parsial menampilkan arrowBigDown', (tester) async {
    await tester.pumpWidget(
      wrap(
        VoteDeckSwipeCard(
          itemKey: 'c',
          enabled: true,
          onSwiped: (_) async => true,
          child: const SizedBox.expand(
            child: Center(child: Text('kartu')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VoteDeckSwipeCard)),
    );
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();

    expect(find.byIcon(FLucideIcons.arrowBigDown), findsOneWidget);
    expect(find.byIcon(FLucideIcons.arrowBigUp), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
