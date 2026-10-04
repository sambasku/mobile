import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/widgets/exclude_semantics_on_exit.dart';

/// Regresi: semantics halaman mati saat exit transition (pop) berjalan.
/// Mencegah assertion "Invisible SemanticsNodes" dari widget slide-out.
void main() {
  Future<void> pushAndPop(WidgetTester tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Text('home')),
      ),
    );

    // Route kedua membungkus konten dengan ExcludeSemanticsOnExit.
    final controller = nav.currentState!;
    controller.push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => const ExcludeSemanticsOnExit(
          child: Scaffold(body: Text('detail')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Selama exit transition, semantics route di-exclude.
    controller.pop();
    await tester.pump(const Duration(milliseconds: 100)); // tengah animasi

    expect(
      find.descendant(
        of: find.byType(ExcludeSemanticsOnExit),
        matching: find.byWidgetPredicate(
          (w) => w is ExcludeSemantics && w.excluding,
        ),
      ),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
  }

  testWidgets('saat pop: ExcludeSemantics aktif', (tester) async {
    await pushAndPop(tester);
  });

  testWidgets('saat idle: ExcludeSemantics tidak aktif', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const ExcludeSemanticsOnExit(
          child: Scaffold(body: Text('home')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(ExcludeSemanticsOnExit),
        matching: find.byWidgetPredicate(
          (w) => w is ExcludeSemantics && !w.excluding,
        ),
      ),
      findsOneWidget,
    );
  });
}
