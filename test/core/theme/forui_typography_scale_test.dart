import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

void main() {
  test('app touch typography is denser than Forui stock', () {
    final colors = foruiPalettes['zinc']!.light.touch.colors;
    final stock = FTypography.inherit(colors: colors, touch: true);
    final app = foruiPalettes['zinc']!.light.touch.typography;

    expect(app.body.md.fontSize, closeTo(
      (stock.body.md.fontSize ?? 0) * kForuiTypographyScale,
      0.01,
    ));
    expect(app.body.md.fontSize! < stock.body.md.fontSize!, isTrue);
  });
}
