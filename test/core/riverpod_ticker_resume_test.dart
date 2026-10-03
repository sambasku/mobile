import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resume TickerMode di tengah build overlay tidak boleh setState pada
/// ProviderScope. Bentuk graph-nya sama dengan shell: satu future menonton
/// beberapa future lain yang berbagi dependency (auth).
void main() {
  testWidgets('TickerMode resume over a diamond does not throw', (tester) async {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final seed = NotifierProvider<Seed, int>(Seed.new);
    final shared = Provider<int>((ref) => ref.watch(seed));
    final left = FutureProvider<int>((ref) async => ref.watch(shared) + 1);
    final right = FutureProvider<int>((ref) async => ref.watch(shared) * 2);
    final top = FutureProvider<int>((ref) async {
      final a = await ref.watch(left.future);
      final b = await ref.watch(right.future);
      return a + b;
    });

    Widget app({required bool enabled}) {
      return UncontrolledProviderScope(
        container: container,
        child: TickerMode(
          enabled: enabled,
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(top);
              return const SizedBox();
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(app(enabled: true));
    await tester.pump();
    expect(container.read(top).asData?.value, 1);

    await tester.pumpWidget(app(enabled: false));
    container.read(seed.notifier).bump();
    await tester.pumpWidget(app(enabled: true));
    await tester.pump();

    expect(container.read(top).asData?.value, 4);
  });

  testWidgets('invalidate saat pause terlihat setelah resume', (tester) async {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final counter = NotifierProvider<Counter, int>(Counter.new);

    Widget app({required bool enabled}) {
      return UncontrolledProviderScope(
        container: container,
        child: TickerMode(
          enabled: enabled,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Consumer(
              builder: (context, ref, _) => Text('v${ref.watch(counter)}'),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(app(enabled: true));
    expect(find.text('v0'), findsOneWidget);

    await tester.pumpWidget(app(enabled: false));
    container.read(counter.notifier).bump();
    await tester.pumpWidget(app(enabled: true));
    await tester.pump();
    expect(find.text('v1'), findsOneWidget);
  });

  testWidgets('element di-invalidate saat inaktif refresh saat ditonton lagi', (
    tester,
  ) async {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final counter = NotifierProvider<Counter, int>(Counter.new);

    // Buat element, invalidate saat belum ada listener aktif - fork tidak
    // menjadwalkan refresh untuk element inaktif (invalidateSelf).
    container.read(counter.notifier).bump();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Consumer(
            builder: (context, ref, _) => Text('v${ref.watch(counter)}'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('v1'), findsOneWidget);
  });
}

class Seed extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
