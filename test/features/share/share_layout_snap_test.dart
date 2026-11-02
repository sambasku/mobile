import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/share/domain/share_models.dart';
import 'package:sambasku_mobile/features/share/presentation/widgets/share_layout_edit_layer.dart';
import 'package:sambasku_mobile/features/share/presentation/widgets/share_layout_snap.dart';

void main() {
  const threshold = 30.0;

  test('jauh dari target: delta tidak diubah', () {
    final result = snapAxis(
      center: 0,
      target: 100,
      delta: 10,
      threshold: threshold,
      stuck: false,
      accum: 0,
    );
    expect(result.delta, 10);
    expect(result.stuck, isFalse);
    expect(result.accum, 0);
  });

  test('masuk zona tengah: menempel dan sisa geseran dihitung', () {
    final result = snapAxis(
      center: 100,
      target: 0,
      delta: -80,
      threshold: threshold,
      stuck: false,
      accum: 0,
    );
    expect(result.delta, -100);
    expect(result.stuck, isTrue);
    expect(result.accum, 20);
  });

  test('sudah menempel: geseran kecil menahan di target', () {
    final result = snapAxis(
      center: 0,
      target: 0,
      delta: 8,
      threshold: threshold,
      stuck: true,
      accum: 10,
    );
    expect(result.delta, 0);
    expect(result.stuck, isTrue);
    expect(result.accum, 18);
  });

  test('menempel lalu lepas: elemen menyusul akumulasi jari', () {
    final result = snapAxis(
      center: 0,
      target: 0,
      delta: 16,
      threshold: threshold,
      stuck: true,
      accum: 20,
    );
    expect(result.delta, 36);
    expect(result.stuck, isFalse);
    expect(result.accum, 0);
  });

  test('arah berlawanan mengurangi akumulasi', () {
    final result = snapAxis(
      center: 0,
      target: 0,
      delta: -12,
      threshold: threshold,
      stuck: true,
      accum: 20,
    );
    expect(result.stuck, isTrue);
    expect(result.accum, 8);
    expect(result.delta, 0);
  });

  testWidgets('ketukan di teks memilih teks, area kosong memilih gambar', (
    tester,
  ) async {
    ShareTextElementId? selected;
    var mediaTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ShareLayoutEditLayer(
            width: 400,
            height: 400,
            selected: null,
            mediaSelected: false,
            mediaAlignment: Offset.zero,
            onSelectElement: (id) => selected = id,
            onSelectMedia: () => mediaTaps++,
            cardBuilder: (hitKeyFor) {
              return Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: Color(0xFF111111)),
                  ),
                  Positioned(
                    left: 140,
                    top: 160,
                    child: SizedBox(
                      key: hitKeyFor(ShareTextElementId.lemma),
                      width: 120,
                      height: 48,
                      child: const ColoredBox(
                        color: Color(0xFFFFFFFF),
                        child: Text('Lemma'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Lemma'));
    expect(selected, ShareTextElementId.lemma);
    expect(mediaTaps, 0);

    final origin = tester.getTopLeft(find.byType(ShareLayoutEditLayer));
    await tester.tapAt(origin + const Offset(12, 12));
    expect(mediaTaps, 1);
    expect(selected, ShareTextElementId.lemma);
  });

  testWidgets('gambar di tengah menampilkan garis vertikal dan horizontal', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShareLayoutEditLayer(
          width: 300,
          height: 300,
          selected: null,
          mediaSelected: true,
          mediaAlignment: Offset.zero,
          cardBuilder: _emptyCard,
        ),
      ),
    );
    await tester.pump();

    final painter = _guidePainter(tester);
    expect(painter.showVertical, isTrue);
    expect(painter.showHorizontal, isTrue);
  });

  testWidgets('gambar tidak di tengah tidak menampilkan garis', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShareLayoutEditLayer(
          width: 300,
          height: 300,
          selected: null,
          mediaSelected: true,
          mediaAlignment: Offset(0.4, 0),
          cardBuilder: _emptyCard,
        ),
      ),
    );
    await tester.pump();

    final painter = _guidePainter(tester);
    expect(painter.showVertical, isFalse);
    expect(painter.showHorizontal, isTrue);
  });
}

Widget _emptyCard(ShareCardHitKeyFor hitKeyFor) {
  return const SizedBox.expand();
}

ShareCenterGuidePainter _guidePainter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(ShareLayoutEditLayer),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as ShareCenterGuidePainter;
}
