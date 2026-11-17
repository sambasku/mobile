import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../../shared/widgets/image_crop_page.dart';
import '../../data/baleho_api.dart';
import '../../domain/baleho_models.dart';
import '../providers/baleho_board_provider.dart';
import '../widgets/baleho_deeplink_picker_sheet.dart';
import '../widgets/baleho_slide_content_sheet.dart';

const _kDayPresets = [7, 14, 30];
const _kMinDays = 1;
const _kMaxDays = 30;

/// Form pesan slot Baleho - compact, childPad FScaffold, awam.
class BalehoBookPage extends ConsumerStatefulWidget {
  const BalehoBookPage({
    super.key,
    required this.selection,
    this.referralUsername,
  });

  final BalehoSelection selection;
  final String? referralUsername;

  @override
  ConsumerState<BalehoBookPage> createState() => _BalehoBookPageState();
}

class _FrameForm {
  _FrameForm();

  /// v1: hanya gambar.
  String mediaType = 'image';
  String actionType = 'in_app';
  final title = TextEditingController();
  final cta = TextEditingController();
  final mediaUrl = TextEditingController();
  final actionPayload = TextEditingController();
  String? uploadedUrl;
  /// Notifier supaya sheet konten tetap rebuild saat upload (drawer return dulu).
  final uploading = ValueNotifier<bool>(false);

  void dispose() {
    uploading.dispose();
    title.dispose();
    cta.dispose();
    mediaUrl.dispose();
    actionPayload.dispose();
  }
}

class _BalehoBookPageState extends ConsumerState<BalehoBookPage> {
  final _frames = <_FrameForm>[_FrameForm()];
  late final TextEditingController _referral;
  late final TextEditingController _daysCtrl;
  var _busy = false;
  var _days = 30;

  @override
  void initState() {
    super.initState();
    _referral = TextEditingController(
      text: widget.referralUsername?.trim() ?? '',
    );
    _daysCtrl = TextEditingController(text: '$_days');
    _daysCtrl.addListener(_syncDaysFromCtrl);
  }

  @override
  void dispose() {
    _daysCtrl.removeListener(_syncDaysFromCtrl);
    _referral.dispose();
    _daysCtrl.dispose();
    for (final f in _frames) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncDaysFromCtrl() {
    _onDaysTextChanged(_daysCtrl.text);
  }

  void _setDays(int value) {
    final next = value.clamp(_kMinDays, _kMaxDays);
    setState(() {
      _days = next;
      final text = '$next';
      if (_daysCtrl.text != text) {
        _daysCtrl.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  void _onDaysTextChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != raw) {
      _daysCtrl.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
    if (digits.isEmpty) {
      setState(() => _days = 0);
      return;
    }
    final parsed = int.tryParse(digits);
    if (parsed == null) return;
    setState(() => _days = parsed);
  }

  String _mapError(AppLocalizations l10n, BalehoApiException e) {
    return switch (e.code) {
      'SLOT_TAKEN' => l10n.balehoErrorSlotTaken,
      'BALEHO_ACTIVE_LIMIT' => l10n.balehoErrorActiveLimit,
      'BALEHO_UPLOAD_FAILED' => l10n.balehoErrorUpload,
      'BALEHO_CREATE_FAILED' => l10n.balehoErrorCreate,
      _ => e.message.isNotEmpty && !e.message.startsWith('BALEHO_')
          ? e.message
          : l10n.balehoErrorCreate,
    };
  }

  String? _validate(AppLocalizations l10n) {
    if (_days < _kMinDays || _days > _kMaxDays) {
      return l10n.balehoValidationDays;
    }
    if (_frames.isEmpty) return l10n.balehoValidationNeedFrame;
    for (final f in _frames) {
      // v1: hanya gambar.
      f.mediaType = 'image';
      final url = (f.uploadedUrl ?? f.mediaUrl.text).trim();
      if (url.isEmpty) return l10n.balehoValidationMediaUrl;
      final payload = f.actionPayload.text.trim();
      if (payload.isEmpty) return l10n.balehoValidationAction;
      if (f.actionType == 'external') {
        final u = Uri.tryParse(payload);
        if (u == null ||
            (u.scheme != 'http' && u.scheme != 'https')) {
          return l10n.balehoValidationExternalUrl;
        }
      }
    }
    return null;
  }

  /// Rasio crop = ukuran slot (sel kotak → w:h). Label disederhanakan (4×2 → 2:1).
  CropAspectRatio get _slotCropAspect {
    final w = widget.selection.w;
    final h = widget.selection.h;
    final g = w.gcd(h);
    return CropAspectRatio(
      label: '${w ~/ g}:${h ~/ g}',
      ratio: w / h,
    );
  }

  bool get _anyUploading => _frames.any((f) => f.uploading.value);

  Future<void> _pickImage(_FrameForm frame) async {
    final l10n = AppLocalizations.of(context);
    showImageSheetDrawer(
      context,
      lockedAspectRatio: _slotCropAspect,
      onPicked: (file) async {
        frame.uploading.value = true;
        if (mounted) setState(() {});
        try {
          final url = await ref.read(balehoApiProvider).uploadImage(file);
          if (!mounted) return;
          frame.uploadedUrl = url;
          frame.mediaUrl.text = url;
          frame.mediaType = 'image';
          frame.uploading.value = false;
          setState(() {});
          showFToast(
            context: context,
            title: Text(l10n.balehoUploadOk),
          );
        } on BalehoApiException catch (e) {
          frame.uploading.value = false;
          if (!mounted) return;
          setState(() {});
          await showAppErrorSheet(context, message: _mapError(l10n, e));
        } catch (_) {
          frame.uploading.value = false;
          if (!mounted) return;
          setState(() {});
          await showAppErrorSheet(
            context,
            message: l10n.balehoErrorUpload,
          );
        }
      },
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final err = _validate(l10n);
    if (err != null) {
      await showAppErrorSheet(context, message: err);
      return;
    }
    setState(() => _busy = true);
    try {
      final drafts = [
        for (final f in _frames)
          BalehoFrameDraft(
            mediaType: f.mediaType,
            mediaUrl: (f.uploadedUrl ?? f.mediaUrl.text).trim().isEmpty
                ? null
                : (f.uploadedUrl ?? f.mediaUrl.text).trim(),
            title: f.title.text.trim().isEmpty ? null : f.title.text.trim(),
            ctaLabel: f.cta.text.trim().isEmpty ? null : f.cta.text.trim(),
            actionType: f.actionType,
            actionPayload: f.actionPayload.text.trim(),
          ),
      ];
      await ref.read(balehoApiProvider).createPlacement(
            col: widget.selection.col,
            row: widget.selection.row,
            w: widget.selection.w,
            h: widget.selection.h,
            frames: drafts,
            referralUsername: _referral.text.trim().isEmpty
                ? null
                : _referral.text.trim(),
            days: _days,
          );
      if (!mounted) return;
      ref.invalidate(balehoBoardProvider(1));
      showFToast(context: context, title: Text(l10n.balehoSubmitOk));
      context.pop(true);
    } on BalehoApiException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: _mapError(l10n, e));
      if (e.code == 'SLOT_TAKEN') {
        ref.invalidate(balehoBoardProvider(1));
      }
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: l10n.balehoErrorCreate);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final sel = widget.selection;

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.balehoBookPageTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: (_busy || _anyUploading) ? null : () => context.pop(),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: (_busy || _anyUploading) ? null : _submit,
            prefix: (_busy || _anyUploading)
                ? const FCircularProgress()
                : null,
            child: Text(
              _anyUploading
                  ? l10n.balehoUploading
                  : _busy
                      ? l10n.balehoSubmitting
                      : l10n.balehoSubmit,
            ),
          ),
        ),
      ),
      // childPad FScaffold sudah horizontal - jangan dobel.
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        children: [
          Text(
            l10n.balehoSlotSummary(
              '${sel.w}x${sel.h}',
              sel.col + 1,
              sel.row + 1,
            ),
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            l10n.balehoTosBody,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _daysCtrl),
            label: Text(l10n.balehoDaysLabel),
            hint: l10n.balehoDaysHint,
            keyboardType: TextInputType.number,
            enabled: !_busy,
          ),
          const Gap(6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final d in _kDayPresets)
                GestureDetector(
                  onTap: _busy ? null : () => _setDays(d),
                  child: FBadge(
                    variant: _days == d
                        ? FBadgeVariant.primary
                        : FBadgeVariant.secondary,
                    child: Text(l10n.balehoDaysChip(d)),
                  ),
                ),
            ],
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _referral),
            label: Text(l10n.balehoReferralLabel),
            hint: l10n.balehoReferralHint,
            enabled: !_busy,
          ),
          const Gap(16),
          Text(
            l10n.balehoContentSection,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          for (var i = 0; i < _frames.length; i++) ...[
            if (i > 0) const Gap(12),
            _FrameEditor(
              index: i,
              frame: _frames[i],
              busy: _busy || _anyUploading,
              onChanged: () => setState(() {}),
              onPickImage: () => _pickImage(_frames[i]),
              onRemove: _frames.length <= 1
                  ? null
                  : () => setState(() {
                        _frames.removeAt(i).dispose();
                      }),
            ),
          ],
          if (_frames.length < 10) ...[
            const Gap(12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: (_busy || _anyUploading)
                  ? null
                  : () => setState(() => _frames.add(_FrameForm())),
              child: Text(l10n.balehoAddFrame),
            ),
          ],
        ],
      ),
    );
  }
}

class _FrameEditor extends StatelessWidget {
  const _FrameEditor({
    required this.index,
    required this.frame,
    required this.busy,
    required this.onChanged,
    required this.onPickImage,
    this.onRemove,
  });

  final int index;
  final _FrameForm frame;
  final bool busy;
  final VoidCallback onChanged;
  final Future<void> Function() onPickImage;
  final VoidCallback? onRemove;

  String get _contentSummary {
    final title = frame.title.text.trim();
    if (title.isNotEmpty) return title;
    final media = (frame.uploadedUrl ?? frame.mediaUrl.text).trim();
    if (media.isNotEmpty) return media;
    final cta = frame.cta.text.trim();
    if (cta.isNotEmpty) return cta;
    return '';
  }

  Future<void> _openContentSheet(BuildContext context) async {
    await showBalehoSlideContentSheet(
      context,
      slideIndex: index + 1,
      mediaType: frame.mediaType,
      onMediaTypeChanged: (t) => frame.mediaType = t,
      title: frame.title,
      cta: frame.cta,
      mediaUrl: frame.mediaUrl,
      busy: busy,
      uploading: frame.uploading,
      onPickImage: onPickImage,
      onChanged: onChanged,
    );
    onChanged();
  }

  Future<void> _pickDeeplink(BuildContext context) async {
    final path = await showBalehoDeeplinkPickerSheet(
      context,
      selectedPath: frame.actionPayload.text,
    );
    if (path == null) return;
    frame.actionPayload.text = path;
    frame.actionPayload.selection = TextSelection.collapsed(
      offset: path.length,
    );
    onChanged();
  }

  Future<void> _setActionType(BuildContext context, String a) async {
    frame.actionType = a;
    onChanged();
    if (a == 'in_app' && !busy) {
      await _pickDeeplink(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final summary = _contentSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.balehoFrameLabel(index + 1),
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onRemove != null)
              FButton(
                variant: FButtonVariant.ghost,
                onPress: busy ? null : onRemove,
                child: Text(l10n.balehoRemoveFrame),
              ),
          ],
        ),
        const Gap(6),
        ValueListenableBuilder<bool>(
          valueListenable: frame.uploading,
          builder: (context, uploading, _) {
            return FTileGroup(
              children: [
                FTile(
                  prefix: Icon(
                    FLucideIcons.panelTop,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  title: Text(l10n.balehoSlideContentCta),
                  subtitle: Text(
                    uploading
                        ? l10n.balehoUploading
                        : summary.isEmpty
                            ? l10n.balehoSlideContentEmpty
                            : summary,
                  ),
                  suffix: uploading
                      ? const FCircularProgress(size: .sm)
                      : const Icon(FLucideIcons.chevronRight, size: 16),
                  onPress: busy || uploading
                      ? null
                      : () => _openContentSheet(context),
                ),
              ],
            );
          },
        ),
        const Gap(10),
        Text(
          l10n.balehoActionKindLabel,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final a in ['in_app', 'external'])
              GestureDetector(
                onTap: busy ? null : () => _setActionType(context, a),
                child: FBadge(
                  variant: frame.actionType == a
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(
                    a == 'in_app'
                        ? l10n.balehoActionInApp
                        : l10n.balehoActionExternal,
                  ),
                ),
              ),
          ],
        ),
        const Gap(8),
        if (frame.actionType == 'in_app') ...[
          FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.link, size: 18),
                title: Text(l10n.balehoDeeplinkPickCta),
                subtitle: Text(
                  frame.actionPayload.text.trim().isEmpty
                      ? l10n.balehoDeeplinkEmpty
                      : frame.actionPayload.text.trim(),
                ),
                suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                onPress: busy ? null : () => _pickDeeplink(context),
              ),
            ],
          ),
          const Gap(8),
        ],
        FTextField(
          control: FTextFieldControl.managed(controller: frame.actionPayload),
          label: Text(
            frame.actionType == 'external'
                ? l10n.balehoActionUrlLabel
                : l10n.balehoActionPathLabel,
          ),
          hint: frame.actionType == 'external'
              ? l10n.balehoActionUrlHint
              : l10n.balehoActionPathHint,
          enabled: !busy,
          maxLines: 4,
        ),
      ],
    );
  }
}
