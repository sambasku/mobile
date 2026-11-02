import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/utils/use_show_back_to_top.dart';

class _Host extends HookWidget {
  const _Host({required this.scroll, required this.onReady});

  final ScrollController scroll;
  final ValueChanged<ValueNotifier<bool>> onReady;

  @override
  Widget build(BuildContext context) {
    onReady(useShowBackToTop(scroll, threshold: 200));
    return ListView.builder(
      controller: scroll,
      itemCount: 80,
      itemBuilder: (_, i) => SizedBox(height: 40, child: Text('$i')),
    );
  }
}

void main() {
  testWidgets('visible hanya setelah pixels melewati threshold', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    late ValueNotifier<bool> visible;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 400,
          child: _Host(scroll: scroll, onReady: (v) => visible = v),
        ),
      ),
    );
    await tester.pump();

    expect(visible.value, isFalse);

    scroll.jumpTo(250);
    await tester.pump();
    expect(visible.value, isTrue);

    scroll.jumpTo(50);
    await tester.pump();
    expect(visible.value, isFalse);
  });
}
