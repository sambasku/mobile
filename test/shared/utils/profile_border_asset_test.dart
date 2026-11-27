import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:sambasku_mobile/shared/utils/profile_border_asset.dart';

void main() {
  test('profileBorderUrlIsLottie mendeteksi .lottie dan .json', () {
    expect(
      profileBorderUrlIsLottie('https://cdn.example.com/wreath.lottie'),
      isTrue,
    );
    expect(
      profileBorderUrlIsLottie('https://cdn.example.com/wreath.json?v=1'),
      isTrue,
    );
    expect(
      profileBorderUrlIsLottie('https://cdn.example.com/border.webp'),
      isFalse,
    );
  });

  testWidgets('.lottie dirender via LottieBuilder (canvas Flutter)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ProfileBorderAssetLayer(
          url: 'https://cdn.example.com/wreath.lottie',
          assetKind: ProfileBorderAssetKind.lottie,
        ),
      ),
    );

    final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
    expect(lottie.animate, isTrue);
    expect(lottie.repeat, isTrue);
  });

  testWidgets('URL .lottie tetap pakai Lottie walau assetKind image', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ProfileBorderAssetLayer(
          url: 'https://cdn.example.com/wreath.lottie',
          assetKind: ProfileBorderAssetKind.image,
        ),
      ),
    );

    expect(find.byType(LottieBuilder), findsOneWidget);
  });

  testWidgets('disableAnimations menahan animasi tanpa menyembunyikan frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ProfileBorderAssetLayer(
            url: 'https://cdn.example.com/wreath.lottie',
            assetKind: ProfileBorderAssetKind.lottie,
          ),
        ),
      ),
    );

    final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
    expect(lottie.animate, isFalse);
    expect(lottie.repeat, isFalse);
  });
}
