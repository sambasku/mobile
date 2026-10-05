import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/services/in_app_review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Service guard kReleaseMode - di test selalu false, jadi maybePrompt()
  /// tidak pernah menyentuh prefs. Logika keputusan (due/cooldown) di-decode
  /// manual di sini untuk menjaga kontrak format tersimpan.
  test('decode: format count saja', () {
    final state = InAppReviewService.decodeForTest('7');
    expect(state?.$1, 7);
    expect(state?.$2, isNull);
  });

  test('decode: format count|lastPromptMs', () {
    final ms = DateTime(2026, 10, 1).millisecondsSinceEpoch;
    final state = InAppReviewService.decodeForTest('7|$ms');
    expect(state?.$1, 7);
    expect(state?.$2, DateTime(2026, 10, 1));
  });

  test('decode: format rusak -> null', () {
    expect(InAppReviewService.decodeForTest('abc'), isNull);
  });

  test('maybePrompt: release guard - debug tidak menulis prefs', () async {
    SharedPreferences.setMockInitialValues({});
    await InAppReviewService.maybePrompt();
    final prefs = await SharedPreferences.getInstance();
    // kReleaseMode false di test -> tidak ada tulisan apapun.
    expect(prefs.getString('review_prompt_state'), isNull);
  });

  test('konstanta: prompt pertama di count 3, repeat 10, cooldown 30 hari', () {
    expect(InAppReviewService.firstPromptAtForTest, 3);
    expect(InAppReviewService.repeatEveryForTest, 10);
    expect(InAppReviewService.cooldownForTest?.inDays, 30);
  });
}
