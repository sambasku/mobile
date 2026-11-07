import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/utils/pronunciation_format.dart';

void main() {
  group('pronunciationRaw', () {
    test('strips edge slashes and trims', () {
      expect(pronunciationRaw(' /sa.dap/ '), 'sa.dap');
      expect(pronunciationRaw('//sa.dap//'), 'sa.dap');
      expect(pronunciationRaw('sa.dap'), 'sa.dap');
      expect(pronunciationRaw(''), '');
      expect(pronunciationRaw(null), '');
    });
  });

  group('pronunciationDisplay', () {
    test('wraps raw with slashes', () {
      expect(pronunciationDisplay('sa.dap'), '/sa.dap/');
      expect(pronunciationDisplay('/sa.dap/'), '/sa.dap/');
      expect(pronunciationDisplay(''), '');
    });
  });

  group('pronunciationsDisplayLine', () {
    test('joins multiple values', () {
      expect(
        pronunciationsDisplayLine(['sa.dap', '/ma.kan/']),
        '/sa.dap/ · /ma.kan/',
      );
      expect(pronunciationsDisplayLine(['', '  ']), '');
    });
  });
}
