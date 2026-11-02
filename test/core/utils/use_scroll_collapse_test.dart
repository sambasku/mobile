import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/core/utils/use_scroll_collapse.dart';

/// Widget pembungkus hook (hook wajib dipanggil di build `HookWidget`).
class _CollapseHost extends HookWidget {
  const _CollapseHost({required this.scroll, required this.onReady});

  final ScrollController scroll;
  final ValueChanged<Animation<double>> onReady;

  @override
  Widget build(BuildContext context) {
    onReady(useScrollCollapse(scroll));
    return ListView.builder(
      controller: scroll,
      itemCount: 60,
      itemBuilder: (_, i) => SizedBox(height: 40, child: Text('$i')),
    );
  }
}

/// Regression: scroll balik ke atas dulu memanggil `animateBack(0)` tiap
/// frame → listener collapse notifikasi terus → blok header repaint ulang
/// walau progress tidak berubah (scroll terasa berat).
void main() {
  testWidgets('listener collapse tidak memicu animasi berulang di ujung atas', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    late Animation<double> collapse;

    await tester.pumpWidget(
      MaterialApp(
        home: _CollapseHost(scroll: scroll, onReady: (a) => collapse = a),
      ),
    );
    await tester.pump();

    // Turun melewati jarak collaps, lalu balik ke posisi 0.
    scroll.jumpTo(300);
    await tester.pump();
    expect(collapse.value, 1.0);

    scroll.jumpTo(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(collapse.value, 0.0);

    // Animasi harus sudah selesai: tidak ada frame terjadwal lagi, jadi
    // scroll diam tidak memicu repaint header terus-menerus.
    expect(
      tester.binding.hasScheduledFrame,
      isFalse,
      reason: 'tidak boleh ada animasi collapse yang jalan terus',
    );
  });
}
