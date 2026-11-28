import 'dart:io';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import 'meme_text_renderer.dart';

/// Hasil editor: teks sudah di-trim, plus warna teks dan border.
typedef MemeText = ({
  String top,
  String bottom,
  MemeColor textColor,
  MemeColor borderColor,
});

/// Bottom sheet untuk mengisi teks meme, warna teks, dan warna border.
/// Mengembalikan [MemeText] saat "Pakai teks", null saat ditutup.
Future<MemeText?> showMemeTextEditorSheet(
  BuildContext context, {
  required File baseFile,
  required MemeText initial,
}) {
  return showModalBottomSheet<MemeText>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _MemeTextEditorBody(baseFile: baseFile, initial: initial),
  );
}

class _MemeTextEditorBody extends StatefulWidget {
  const _MemeTextEditorBody({required this.baseFile, required this.initial});

  final File baseFile;
  final MemeText initial;

  @override
  State<_MemeTextEditorBody> createState() => _MemeTextEditorBodyState();
}

class _MemeTextEditorBodyState extends State<_MemeTextEditorBody> {
  static const _kMaxTextLength = 60;
  static const _kPreviewSize = 200.0;
  static const _kSwatchSize = 36.0;
  static const _kOutlineOffset = 1.5;

  late final TextEditingController _topCtrl;
  late final TextEditingController _bottomCtrl;
  late MemeColor _textColor;
  late MemeColor _borderColor;

  @override
  void initState() {
    super.initState();
    _topCtrl = TextEditingController(text: widget.initial.top)
      ..addListener(_onChanged);
    _bottomCtrl = TextEditingController(text: widget.initial.bottom)
      ..addListener(_onChanged);
    _textColor = widget.initial.textColor;
    _borderColor = widget.initial.borderColor;
  }

  @override
  void dispose() {
    _topCtrl.dispose();
    _bottomCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _apply() {
    Navigator.of(context).pop<MemeText>((
      top: _topCtrl.text.trim(),
      bottom: _bottomCtrl.text.trim(),
      textColor: _textColor,
      borderColor: _borderColor,
    ));
  }

  String _colorName(AppLocalizations l10n, MemeColor color) => switch (color) {
    MemeColor.white => l10n.stickerMemeColorWhite,
    MemeColor.black => l10n.stickerMemeColorBlack,
    MemeColor.yellow => l10n.stickerMemeColorYellow,
    MemeColor.red => l10n.stickerMemeColorRed,
    MemeColor.blue => l10n.stickerMemeColorBlue,
  };

  /// Border dibuat dari bayangan 8 arah, supaya preview mendekati hasil render.
  List<Shadow> _outlineShadows() {
    const o = _kOutlineOffset;
    final color = _borderColor.value;
    return [
      Shadow(color: color, offset: const Offset(-o, 0)),
      Shadow(color: color, offset: const Offset(o, 0)),
      Shadow(color: color, offset: const Offset(0, -o)),
      Shadow(color: color, offset: const Offset(0, o)),
      Shadow(color: color, offset: const Offset(-o, -o)),
      Shadow(color: color, offset: const Offset(o, -o)),
      Shadow(color: color, offset: const Offset(-o, o)),
      Shadow(color: color, offset: const Offset(o, o)),
    ];
  }

  Widget _previewLabel(String text, {required bool atTop}) {
    return Positioned(
      left: 0,
      right: 0,
      top: atTop ? 8 : null,
      bottom: atTop ? null : 8,
      child: Text(
        text.trim().toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kMemeFontFamily,
          fontSize: 26,
          height: 1.0,
          color: _textColor.value,
          shadows: _outlineShadows(),
        ),
      ),
    );
  }

  Widget _colorRow({
    required AppLocalizations l10n,
    required String label,
    required MemeColor selected,
    required ValueChanged<MemeColor> onSelect,
  }) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(6),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            for (final color in MemeColor.values)
              Semantics(
                button: true,
                selected: color == selected,
                label: _colorName(l10n, color),
                child: GestureDetector(
                  onTap: () => onSelect(color),
                  child: Container(
                    width: _kSwatchSize,
                    height: _kSwatchSize,
                    decoration: BoxDecoration(
                      color: color.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == selected
                            ? theme.colors.primary
                            : theme.colors.border,
                        width: color == selected ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.stickerMemeEditorTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: _kPreviewSize,
                  height: _kPreviewSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(widget.baseFile, fit: BoxFit.cover),
                      _previewLabel(_topCtrl.text, atTop: true),
                      _previewLabel(_bottomCtrl.text, atTop: false),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(12),
            FTextField(
              control: FTextFieldControl.managed(controller: _topCtrl),
              label: Text(l10n.stickerMemeTopLabel),
              hint: l10n.stickerMemeInputHint,
              maxLength: _kMaxTextLength,
            ),
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _bottomCtrl),
              label: Text(l10n.stickerMemeBottomLabel),
              hint: l10n.stickerMemeInputHint,
              maxLength: _kMaxTextLength,
            ),
            const Gap(12),
            _colorRow(
              l10n: l10n,
              label: l10n.stickerMemeTextColorLabel,
              selected: _textColor,
              onSelect: (c) => setState(() => _textColor = c),
            ),
            const Gap(12),
            _colorRow(
              l10n: l10n,
              label: l10n.stickerMemeBorderColorLabel,
              selected: _borderColor,
              onSelect: (c) => setState(() => _borderColor = c),
            ),
            const Gap(16),
            FButton(
              onPress: _apply,
              child: Text(l10n.stickerMemeApply),
            ),
          ],
        ),
      ),
    );
  }
}
