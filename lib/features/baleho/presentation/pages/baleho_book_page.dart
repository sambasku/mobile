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

/// Satu slide child: hanya media. Judul/CTA/aksi di parent form.
class _FrameForm {
  _FrameForm();

  String mediaType = 'image';
  final mediaUrl = TextEditingController();
  String? uploadedUrl;
  /// Notifier supaya sheet konten tetap rebuild saat upload (drawer return dulu).
  final uploading = ValueNotifier<bool>(false);

  void dispose() {
    uploading.dispose();
    mediaUrl.dispose();
  }
}

class _BalehoBookPageState extends ConsumerState<BalehoBookPage> {
  final _frames = <_FrameForm>[_FrameForm()];
  /// Parent copy: dipakai semua slide di sheet + wire API.
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _cta = TextEditingController();
  final _actionPayload = TextEditingController();
  var _actionType = 'in_app';
  String? _entityType;
  String? _entityId;
  late final TextEditingController _referral;
  late final TextEditingController _daysCtrl;
  var _busy = false;
  var _days = 30;
  String? _reactivateCreativeId;
  String? _reactivateLabel;
  List<BalehoCreativeSummary>? _creatives;

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
    _title.dispose();
    _body.dispose();
    _cta.dispose();
    _actionPayload.dispose();
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
      'BALEHO_FINGERPRINT_DUP' => l10n.balehoErrorFingerprintDup,
      'BALEHO_UPLOAD_FAILED' => l10n.balehoErrorUpload,
      'BALEHO_CREATE_FAILED' => l10n.balehoErrorCreate,
      'RATE_LIMITED' => l10n.balehoErrorRateLimited,
      _ => e.message.isNotEmpty && !e.message.startsWith('BALEHO_')
          ? e.message
          : l10n.balehoErrorCreate,
    };
  }

  Future<void> _loadCreatives() async {
    try {
      final list = await ref.read(balehoApiProvider).listMyCreatives();
      if (!mounted) return;
      setState(() => _creatives = list);
    } catch (_) {
      if (!mounted) return;
      setState(() => _creatives = const []);
    }
  }

  Future<void> _pickReactivate() async {
    final l10n = AppLocalizations.of(context);
    if (_creatives == null) await _loadCreatives();
    if (!mounted) return;
    final items = _creatives ?? const <BalehoCreativeSummary>[];
    if (items.isEmpty) {
      await showAppErrorSheet(context, message: l10n.balehoReactivateEmpty);
      return;
    }
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTileGroup(
                  children: [
                    FTile(
                      title: Text(l10n.balehoReactivateTitle),
                      subtitle: Text(l10n.balehoReactivateSubtitle),
                    ),
                    for (final c in items)
                      FTile(
                        title: Text(
                          (c.title?.trim().isNotEmpty ?? false)
                              ? c.title!.trim()
                              : l10n.balehoReactivateUntitled,
                        ),
                        subtitle: Text(
                          c.lastReferralUsername == null ||
                                  c.lastReferralUsername!.isEmpty
                              ? c.id
                              : l10n.balehoReactivateRefHint(
                                  c.lastReferralUsername!,
                                ),
                        ),
                        onPress: () => Navigator.pop(ctx, c.id),
                      ),
                    FTile(
                      title: Text(l10n.balehoReactivateClear),
                      onPress: () => Navigator.pop(ctx, ''),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    if (choice.isEmpty) {
      setState(() {
        _reactivateCreativeId = null;
        _reactivateLabel = null;
      });
      return;
    }
    final picked = items.where((c) => c.id == choice).firstOrNull;
    setState(() {
      _reactivateCreativeId = choice;
      _reactivateLabel = (picked?.title?.trim().isNotEmpty ?? false)
          ? picked!.title!.trim()
          : l10n.balehoReactivateUntitled;
      if (picked?.lastReferralUsername != null &&
          picked!.lastReferralUsername!.isNotEmpty) {
        _referral.text = picked.lastReferralUsername!;
      }
    });
  }

  String? _validate(AppLocalizations l10n) {
    if (_days < _kMinDays || _days > _kMaxDays) {
      return l10n.balehoValidationDays;
    }
    // Reaktivasi: konten dari creative lama - skip validasi frame.
    if (_reactivateCreativeId != null && _reactivateCreativeId!.isNotEmpty) {
      return null;
    }
    if (_frames.isEmpty) return l10n.balehoValidationNeedFrame;
    final payload = _actionPayload.text.trim();
    if (payload.isEmpty) return l10n.balehoValidationAction;
    if (_actionType == 'external') {
      final u = Uri.tryParse(payload);
      if (u == null || (u.scheme != 'http' && u.scheme != 'https')) {
        return l10n.balehoValidationExternalUrl;
      }
    }
    for (final f in _frames) {
      f.mediaType = 'image';
      final url = (f.uploadedUrl ?? f.mediaUrl.text).trim();
      if (url.isEmpty) return l10n.balehoValidationMediaUrl;
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
    if (_busy || _anyUploading) return;
    final l10n = AppLocalizations.of(context);
    final err = _validate(l10n);
    if (err != null) {
      await showAppErrorSheet(context, message: err);
      return;
    }
    setState(() => _busy = true);
    try {
      final title = _title.text.trim();
      final body = _body.text.trim();
      final cta = _cta.text.trim();
      final payload = _actionPayload.text.trim();
      // Parent copy di-stamp ke tiap frame (wire API per-frame); sheet &
      // aksi baca frame pertama sebagai parent.
      final drafts = [
        for (final f in _frames)
          BalehoFrameDraft(
            mediaType: f.mediaType,
            mediaUrl: (f.uploadedUrl ?? f.mediaUrl.text).trim().isEmpty
                ? null
                : (f.uploadedUrl ?? f.mediaUrl.text).trim(),
            title: title.isEmpty ? null : title,
            body: body.isEmpty ? null : body,
            ctaLabel: cta.isEmpty ? null : cta,
            actionType: _actionType,
            actionPayload: payload,
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
            creativeId: _reactivateCreativeId,
            entityType: _entityType,
            entityId: _entityId,
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
            enabled: !_busy && _reactivateCreativeId == null,
          ),
          const Gap(12),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.refreshCw,
                  size: 18,
                  color: theme.colors.primary,
                ),
                title: Text(l10n.balehoReactivateCta),
                subtitle: Text(
                  _reactivateLabel ?? l10n.balehoReactivateHint,
                ),
                suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                onPress: _busy ? null : _pickReactivate,
              ),
            ],
          ),
          const Gap(16),
          Text(
            l10n.balehoContentSection,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          if (_reactivateCreativeId != null) ...[
            Text(
              l10n.balehoReactivateUsingOld,
              softWrap: true,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground.withValues(alpha: 0.75),
              ),
            ),
            const Gap(8),
          ],
          if (_reactivateCreativeId == null) ...[
            // Parent: judul + body + teks tombol + aksi (satu untuk semua slide).
            FTextField(
              control: FTextFieldControl.managed(controller: _title),
              label: Text(l10n.balehoTitleLabel),
              enabled: !_busy,
              maxLines: 2,
            ),
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _body),
              label: Text(l10n.balehoBodyLabel),
              description: Text(l10n.balehoBodyHint),
              enabled: !_busy,
              maxLines: 4,
              maxLength: 320,
            ),
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _cta),
              label: Text(l10n.balehoCtaLabel),
              enabled: !_busy,
              maxLines: 1,
              maxLength: 40,
            ),
            const Gap(12),
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
                    onTap: _busy
                        ? null
                        : () => _setParentActionType(context, a),
                    child: FBadge(
                      variant: _actionType == a
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
            if (_actionType == 'in_app') ...[
              FTileGroup(
                children: [
                  FTile(
                    prefix: const Icon(FLucideIcons.link, size: 18),
                    title: Text(l10n.balehoDeeplinkPickCta),
                    subtitle: Text(
                      _actionPayload.text.trim().isEmpty
                          ? l10n.balehoDeeplinkEmpty
                          : _actionPayload.text.trim(),
                    ),
                    suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                    onPress: _busy ? null : () => _pickParentDeeplink(context),
                  ),
                ],
              ),
              const Gap(8),
            ],
            FTextField(
              control: FTextFieldControl.managed(controller: _actionPayload),
              label: Text(
                _actionType == 'external'
                    ? l10n.balehoActionUrlLabel
                    : l10n.balehoActionPathLabel,
              ),
              hint: _actionType == 'external'
                  ? l10n.balehoActionUrlHint
                  : l10n.balehoActionPathHint,
              enabled: !_busy,
              maxLines: 4,
            ),
            const Gap(16),
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
        ],
      ),
    );
  }

  Future<void> _pickParentDeeplink(BuildContext context) async {
    final pick = await showBalehoDeeplinkPickerSheet(
      context,
      selectedPath: _actionPayload.text,
    );
    if (pick == null) return;
    setState(() {
      _actionPayload.text = pick.path;
      _actionPayload.selection = TextSelection.collapsed(
        offset: pick.path.length,
      );
      _entityType = pick.entityType;
      _entityId = pick.entityId;
    });
  }

  Future<void> _setParentActionType(BuildContext context, String a) async {
    setState(() => _actionType = a);
    if (a == 'in_app' && !_busy) {
      await _pickParentDeeplink(context);
    }
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

  String get _mediaSummary {
    final media = (frame.uploadedUrl ?? frame.mediaUrl.text).trim();
    return media;
  }

  Future<void> _openContentSheet(BuildContext context) async {
    await showBalehoSlideContentSheet(
      context,
      slideIndex: index + 1,
      mediaType: frame.mediaType,
      onMediaTypeChanged: (t) => frame.mediaType = t,
      mediaUrl: frame.mediaUrl,
      busy: busy,
      uploading: frame.uploading,
      onPickImage: onPickImage,
      onChanged: onChanged,
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final summary = _mediaSummary;

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
                    FLucideIcons.image,
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
      ],
    );
  }
}
