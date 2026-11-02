import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import '../../../l10n/app_localizations.dart';

/// Pilih warna polos (HSV + hex). Opaque, tanpa eyedropper.
Future<Color?> showShareSolidColorSheet(
  BuildContext context, {
  required Color initial,
}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _ShareSolidColorSheet(initial: initial),
  );
}

class _ShareSolidColorSheet extends StatefulWidget {
  const _ShareSolidColorSheet({required this.initial});

  final Color initial;

  @override
  State<_ShareSolidColorSheet> createState() => _ShareSolidColorSheetState();
}

class _ShareSolidColorSheetState extends State<_ShareSolidColorSheet> {
  late HSVColor _hsv;
  late TextEditingController _hex;
  final _hexFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial.withValues(alpha: 1));
    _hex = TextEditingController(text: _hexOf(_hsv.toColor()));
    _hexFocus.addListener(_onHexFocus);
  }

  @override
  void dispose() {
    _hexFocus.removeListener(_onHexFocus);
    _hexFocus.dispose();
    _hex.dispose();
    super.dispose();
  }

  void _onHexFocus() {
    if (!_hexFocus.hasFocus) _applyHexField();
  }

  void _setHsv(HSVColor next) {
    setState(() => _hsv = next);
    if (!_hexFocus.hasFocus) {
      _hex.value = TextEditingValue(
        text: _hexOf(next.toColor()),
        selection: TextSelection.collapsed(offset: 7),
      );
    }
  }

  void _applyHexField() {
    final parsed = _colorFromHex(_hex.text);
    if (parsed == null) {
      _hex.value = TextEditingValue(
        text: _hexOf(_hsv.toColor()),
        selection: TextSelection.collapsed(offset: 7),
      );
      return;
    }
    _setHsv(HSVColor.fromColor(parsed));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final color = _hsv.toColor();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const Gap(16),
          Text(AppLocalizations.of(context).shareSolidColorTitle, style: theme.typography.body.lg),
          const Gap(12),
          SizedBox(
            height: 160,
            child: _SatValBox(
              hsv: _hsv,
              onChanged: _setHsv,
            ),
          ),
          const Gap(16),
          _HueSlider(
            hue: _hsv.hue,
            onChanged: (h) => _setHsv(_hsv.withHue(h)),
          ),
          const Gap(16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colors.border),
                ),
              ),
              const Gap(12),
              Expanded(
                child: TextField(
                  controller: _hex,
                  focusNode: _hexFocus,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Hex',
                    hintText: '#1C1917',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _applyHexField(),
                ),
              ),
            ],
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).shareCancel),
                ),
              ),
              const Gap(12),
              Expanded(
                child: FButton(
                  onPress: () => Navigator.of(context).pop(color),
                  child: Text(AppLocalizations.of(context).shareApply),
                ),
              ),
            ],
          ),
          const Gap(4),
        ],
      ),
    );
  }
}

class _SatValBox extends StatelessWidget {
  const _SatValBox({required this.hsv, required this.onChanged});

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  void _fromLocal(Offset local, Size size) {
    final s = (local.dx / size.width).clamp(0.0, 1.0);
    final v = (1 - local.dy / size.height).clamp(0.0, 1.0);
    onChanged(hsv.withSaturation(s).withValue(v));
  }

  @override
  Widget build(BuildContext context) {
    final hueColor = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanDown: (d) => _fromLocal(d.localPosition, size),
          onPanUpdate: (d) => _fromLocal(d.localPosition, size),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.white, hueColor],
              ),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                ),
              ),
              child: CustomPaint(
                painter: _SatValThumbPainter(
                  saturation: hsv.saturation,
                  value: hsv.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SatValThumbPainter extends CustomPainter {
  const _SatValThumbPainter({required this.saturation, required this.value});

  final double saturation;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(saturation * size.width, (1 - value) * size.height);
    canvas.drawCircle(c, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black54,
    );
  }

  @override
  bool shouldRepaint(_SatValThumbPainter old) =>
      old.saturation != saturation || old.value != value;
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hue, required this.onChanged});

  final double hue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 12,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        trackShape: const _HueTrackShape(),
      ),
      child: Slider(
        value: hue.clamp(0, 359.99),
        min: 0,
        max: 359.99,
        onChanged: onChanged,
      ),
    );
  }
}

class _HueTrackShape extends SliderTrackShape {
  const _HueTrackShape();

  static const _hues = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final h = sliderTheme.trackHeight ?? 12;
    return Rect.fromLTWH(
      offset.dx + 10,
      offset.dy + (parentBox.size.height - h) / 2,
      parentBox.size.width - 20,
      h,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    context.canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(colors: _hues).createShader(rect),
    );
  }
}

String _hexOf(Color color) {
  final n = color.toARGB32() & 0xFFFFFF;
  return '#${n.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color? _colorFromHex(String raw) {
  final t = raw.trim().replaceFirst('#', '');
  if (t.length != 6) return null;
  final v = int.tryParse(t, radix: 16);
  if (v == null) return null;
  return Color(0xFF000000 | v);
}
