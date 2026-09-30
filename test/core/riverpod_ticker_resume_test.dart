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
}

class Seed extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
