import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/shared/widgets/word_image_view.dart';

WordImage _pending() => const WordImage(
  id: 'img-1',
  url: 'https://placehold.co/600x400',
  isPrimary: true,
  isVerified: false,
);

Future<void> _pump(WidgetTester tester, Brightness brightness) async {
  await tester.pumpWidget(
    Material(
      child: Theme(
        data: ThemeData(brightness: brightness),
        child: FTheme(
          data: brightness == Brightness.dark
              ? FThemes.zinc.dark.touch
              : FThemes.zinc.light.touch,
          child: SizedBox(
            width: 320,
            height: 200,
            child: WordImageView(image: _pending(), revealed: false),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('pending review: gif terpasang sesuai tema', (tester) async {
    await _pump(tester, Brightness.light);
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/gif/pending_review_light.gif',
    );

    await _pump(tester, Brightness.dark);
    final dark = tester.widget<Image>(find.byType(Image));
    expect(
      (dark.image as AssetImage).assetName,
      'assets/gif/pending_review_dark.gif',
    );
  });
}
