import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/dev_tool/dev_tool_overlay.dart';

void main() {
  test('mati di build non-debug (profile/release), berapa pun flavor', () {
    expect(devToolsEnabledFor(debug: false, hideDevChrome: false), isFalse);
  });

  test('hidup di debug', () {
    expect(devToolsEnabledFor(debug: true, hideDevChrome: false), isTrue);
  });

  test('SCREENSHOT_MODE selalu matikan', () {
    expect(devToolsEnabledFor(debug: true, hideDevChrome: true), isFalse);
    expect(devToolsEnabledFor(debug: false, hideDevChrome: true), isFalse);
  });
}
