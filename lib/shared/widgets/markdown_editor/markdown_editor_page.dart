import 'dart:io';

import 'package:flutter/material.dart'
    show
        InputBorder,
        InputDecoration,
        Material,
        MaterialType,
        TextAlignVertical,
        TextField,
        TextInputAction,
        TextInputType;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' show showModalBottomSheet;

import '../../../l10n/app_localizations.dart';
import '../../utils/image_sheet_drawer.dart';
import '../sambasku_markdown.dart';
import 'markdown_syntax.dart';
import 'markdown_toolbar.dart';

/// Callback unggah gambar; kembalikan URL HTTPS publik.
typedef MarkdownImageUpload = Future<String> Function(File file);

/// Builder pratinjau Markdown (default: [SambaskuMarkdown]).
typedef MarkdownPreviewBuilder =
    Widget Function(BuildContext context, String md);

/// Halaman editor Markdown full-screen: toolbar format, sisip gambar, preview.
///
/// Isolasi fitur: tidak mengimpor encyclopedia. Upload lewat [uploadImage];
/// selesai → `Navigator.pop(context, markdown)`.
class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({
    super.key,
    this.initialMarkdown = '',
    this.uploadImage,
    this.previewBuilder,
    this.title,
  });

  final String initialMarkdown;
  final MarkdownImageUpload? uploadImage;
  final MarkdownPreviewBuilder? previewBuilder;
  final String? title;

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final UndoHistoryController _undoController = UndoHistoryController();

  /// Seleksi terakhir sebelum pointer turun di toolbar (hindari hilang saat tap).
  TextSelection? _preservedSelection;

  bool _previewing = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMarkdown);
    _undoController.addListener(_onUndoStateChanged);
  }

  void _onUndoStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _undoController.removeListener(_onUndoStateChanged);
    _undoController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _done() {
    Navigator.of(context).pop(_controller.text);
  }

  void _preserveSelection() {
    final selection = _controller.selection;
    if (selection.isValid) {
      _preservedSelection = selection;
    }
  }

  void _restoreSelectionIfNeeded() {
    final saved = _preservedSelection;
    if (saved == null || !saved.isValid) return;
    final textLen = _controller.text.length;
    final start = saved.start.clamp(0, textLen);
    final end = saved.end.clamp(0, textLen);
    _controller.selection = TextSelection(baseOffset: start, extentOffset: end);
  }

  void _ensureFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  /// Jalankan aksi format dengan seleksi yang diawetkan dari pointer-down.
  void _runFormat(VoidCallback action) {
    _restoreSelectionIfNeeded();
    _ensureFocus();
    action();
    _preservedSelection = _controller.selection;
  }

  void _onUndo() {
    _ensureFocus();
    _undoController.undo();
  }

  void _onRedo() {
    _ensureFocus();
    _undoController.redo();
  }

  void _onBold() {
    _runFormat(
      () => MarkdownSyntax.wrap(_controller, left: '**', right: '**'),
    );
  }

  void _onItalic() {
    _runFormat(
      () => MarkdownSyntax.wrap(_controller, left: '_', right: '_'),
    );
  }

  void _onHeading() {
    _runFormat(() => MarkdownSyntax.insertHeadingLine(_controller));
  }

  void _onList() {
    _runFormat(() => MarkdownSyntax.insertBulletLine(_controller));
  }

  Future<void> _onLink() async {
    _preserveSelection();
    final selected = _selectedText();
    final draft = await showModalBottomSheet<_MdLinkDraft>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => _LinkSheet(initialLabel: selected),
    );
    if (draft == null || !mounted) return;
    _runFormat(
      () => MarkdownSyntax.insertLink(
        _controller,
        label: draft.label,
        url: draft.url,
      ),
    );
  }

  String _selectedText() {
    final value = _controller.value;
    final selection = _preservedSelection ?? value.selection;
    if (!selection.isValid || selection.isCollapsed) return '';
    final text = value.text;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);
    return text.substring(start, end);
  }

  Future<void> _onImage() async {
    final upload = widget.uploadImage;
    if (upload == null || _uploading) return;
    final l10n = AppLocalizations.of(context);
    _preserveSelection();

    showImageSheetDrawer(
      context,
      filePicker: false,
      mediaExplorerPicker: false,
      onPicked: (file) async {
        if (!mounted) return;
        setState(() => _uploading = true);
        try {
          final url = await upload(file);
          if (!mounted) return;
          _runFormat(
            () => MarkdownSyntax.insertImage(
              _controller,
              url: url,
              alt: l10n.mdEditorImageAlt,
            ),
          );
        } catch (_) {
          if (!mounted) return;
          showFToast(
            context: context,
            title: Text(l10n.mdEditorUploadFailed),
          );
        } finally {
          if (mounted) setState(() => _uploading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final md = _controller.text;
    final previewBuilder =
        widget.previewBuilder ??
        (BuildContext ctx, String data) => SambaskuMarkdown(data: data);
    final undoValue = _undoController.value;

    return FScaffold(
      header: FHeader.nested(
        title: Text(widget.title ?? l10n.mdEditorTitle),
        prefixes: [
          FHeaderAction.back(onPress: _done),
        ],
        suffixes: [
          FHeaderAction(
            icon: Icon(
              _previewing ? FLucideIcons.pencil : FLucideIcons.eye,
            ),
            onPress: _uploading
                ? null
                : () => setState(() => _previewing = !_previewing),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _uploading ? null : _done,
            prefix: _uploading ? const FCircularProgress() : null,
            child: Text(l10n.mdEditorDone),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _previewing
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: md.trim().isEmpty
                        ? Text(
                            l10n.mdEditorEmptyPreview,
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          )
                        : previewBuilder(context, md),
                  )
                // TextField Material butuh ancestor Material di pohon Forui.
                : Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      undoController: _undoController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.foreground,
                        height: 1.45,
                      ),
                      cursorColor: theme.colors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: l10n.mdEditorHint,
                        hintStyle: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
          ),
          MarkdownToolbar(
            previewing: _previewing,
            uploading: _uploading,
            canUndo: undoValue.canUndo,
            canRedo: undoValue.canRedo,
            imageEnabled: widget.uploadImage != null,
            onPreserveSelection: _preserveSelection,
            onUndo: _onUndo,
            onRedo: _onRedo,
            onBold: _onBold,
            onItalic: _onItalic,
            onHeading: _onHeading,
            onList: _onList,
            onLink: _onLink,
            onImage: _onImage,
            onTogglePreview: () =>
                setState(() => _previewing = !_previewing),
          ),
        ],
      ),
    );
  }
}

class _MdLinkDraft {
  const _MdLinkDraft({required this.label, required this.url});

  final String label;
  final String url;
}

class _LinkSheet extends StatefulWidget {
  const _LinkSheet({required this.initialLabel});

  final String initialLabel;

  @override
  State<_LinkSheet> createState() => _LinkSheetState();
}

class _LinkSheetState extends State<_LinkSheet> {
  late final TextEditingController _label;
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.initialLabel.trim());
    _url = TextEditingController();
  }

  @override
  void dispose() {
    _label.dispose();
    _url.dispose();
    super.dispose();
  }

  void _submit() {
    final url = _url.text.trim();
    if (!MarkdownSyntax.isHttpsUrl(url)) return;
    Navigator.pop(
      context,
      _MdLinkDraft(label: _label.text, url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final url = _url.text.trim();
    final showInvalid = url.isNotEmpty && !MarkdownSyntax.isHttpsUrl(url);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.mdEditorLinkSheetTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              FTextField(
                control: FTextFieldControl.managed(controller: _label),
                label: Text(l10n.mdEditorLinkLabel),
                hint: l10n.mdEditorLinkLabelHint,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              FTextField(
                control: FTextFieldControl.managed(
                  controller: _url,
                  onChange: (_) => setState(() {}),
                ),
                label: Text(l10n.mdEditorLinkUrl),
                hint: l10n.mdEditorLinkUrlHint,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                autofocus: true,
                autocorrect: false,
                error: showInvalid ? Text(l10n.mdEditorLinkInvalid) : null,
                onSubmit: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              FButton(
                onPress: MarkdownSyntax.isHttpsUrl(url) ? _submit : null,
                child: Text(l10n.mdEditorLinkInsert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
