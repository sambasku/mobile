import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_swipe_card.dart';

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
              height: 600,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> dragCard(
    WidgetTester tester, {
    required double dx,
  }) async {
    final card = find.byType(ReviewSwipeCard);
    await tester.timedDrag(
      card,
      Offset(dx, 0),
      const Duration(milliseconds: 120),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('swipe kanan melewati ambang memanggil onSwiped approve', (
    tester,
  ) async {
    ReviewSwipeDirection? got;

    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
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

    // Ambang 28% dari 400 = 112; drag 200 melewati ambang.
    await dragCard(tester, dx: 200);

    expect(got, ReviewSwipeDirection.approve);
  });

  testWidgets('swipe kiri melewati ambang memanggil onSwiped reject', (
    tester,
  ) async {
    ReviewSwipeDirection? got;

    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
          itemKey: 'b',
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

    await dragCard(tester, dx: -200);

    expect(got, ReviewSwipeDirection.reject);
  });

  testWidgets('swipe atas melewati ambang memanggil onSwiped skip', (
    tester,
  ) async {
    ReviewSwipeDirection? got;

    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
          itemKey: 'up',
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

    // Ambang 28% dari tinggi 600 = 168; drag naik 240 melewati ambang.
    final card = find.byType(ReviewSwipeCard);
    await tester.timedDrag(
      card,
      const Offset(0, -240),
      const Duration(milliseconds: 120),
    );
    await tester.pumpAndSettle();

    expect(got, ReviewSwipeDirection.skip);
  });

  testWidgets('batal (onSwiped false) mengembalikan kartu ke tengah', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
          itemKey: 'c',
          enabled: true,
          onSwiped: (_) async => false,
          child: const SizedBox.expand(
            child: Center(child: Text('kartu')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = tester.getCenter(find.text('kartu'));
    await dragCard(tester, dx: -200);
    final after = tester.getCenter(find.text('kartu'));
    expect((after.dx - before.dx).abs(), lessThan(2));
  });

  testWidgets('disabled tidak memanggil onSwiped', (tester) async {
    var called = false;

    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
          itemKey: 'd',
          enabled: false,
          onSwiped: (_) async {
            called = true;
            return true;
          },
          child: const SizedBox.expand(
            child: Center(child: Text('kartu')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await dragCard(tester, dx: 200);

    expect(called, isFalse);
  });

  testWidgets('drag kanan parsial menampilkan check (setujui)', (tester) async {
    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
          itemKey: 'e',
          enabled: true,
          onSwiped: (_) async => true,
          child: const SizedBox.expand(
            child: Center(child: Text('kartu')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(FLucideIcons.check), findsNothing);
    expect(find.byIcon(FLucideIcons.x), findsNothing);

    // Drag di bawah ambang (112) supaya tidak commit; tahan di tengah path.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ReviewSwipeCard)),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.byIcon(FLucideIcons.x), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('drag kiri parsial menampilkan x (tolak)', (tester) async {
    await tester.pumpWidget(
      wrap(
        ReviewSwipeCard(
          itemKey: 'f',
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
      tester.getCenter(find.byType(ReviewSwipeCard)),
    );
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();

    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    expect(find.byIcon(FLucideIcons.check), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
