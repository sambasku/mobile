import 'dart:async';

import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart'
    show PopScope, Tooltip, showModalBottomSheet;

import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/record_thread_audio_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/pantun_api.dart';
import '../../data/pantun_draft_store.dart';
import '../../domain/pantun_compose_args.dart';
import '../../domain/pantun_models.dart';
import '../../domain/rhyme_check.dart';
import '../providers/pantun_providers.dart';

/// Durasi bacaan pantun (parity API `PANTUN_AUDIO_MIN/MAX_MS` = 7500-60000).
const _pantunAudioMinMs = 7500;
const _pantunAudioMaxSec = 60;

enum _ComposeMode { text, voice }

/// Buat pantun: mode teks (4 baris + rima) atau mode suara (rekaman saja).
///
/// Balasan: [parentId] = induk API; [quoteId] = cuplikan + key draf lokal.
class PantunComposePage extends HookConsumerWidget {
  const PantunComposePage({
    super.key,
    this.parentId,
    this.quoteId = PantunComposeArgs.quoteRoot,
    this.args,
    this.draftStore,
  });

  /// Null = pantun pembuka; berisi = balasan ke pantun pembuka itu.
  final String? parentId;

  /// `'root'` atau id balasan yang di-tap sebagai cuplikan.
  final String quoteId;

  /// Extra navigasi (lines/author). Boleh null jika deep-link query saja.
  final PantunComposeArgs? args;

  /// Override untuk test; produksi pakai [PantunDraftStore] default.
  final PantunDraftStore? draftStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controllers = List.generate(4, (_) => useTextEditingController());
    final focusNodes = List.generate(4, (_) => useFocusNode());
    final submitting = useState(false);
    final draftReady = useState(false);
    final hasDraftContent = useState(false);
    final draftSavedAt = useState<DateTime?>(null);
    final attachedAudio = useState<RecordedThreadAudio?>(null);
    final composeMode = useState(_ComposeMode.text);
    final store = useMemoized(() => draftStore ?? PantunDraftStore());
    final debounce = useRef<Timer?>(null);
    final skipPersist = useRef(false);
    final staleToastShown = useRef(false);
    final allowPop = useState(false);

    final effectiveParent = parentId ?? args?.parentId;
    final requestedQuote = () {
      if (effectiveParent == null || effectiveParent.isEmpty) {
        return PantunComposeArgs.quoteRoot;
      }
      final fromQuery = quoteId.trim();
      if (fromQuery.isNotEmpty) return fromQuery;
      return args?.normalizedQuoteId ?? PantunComposeArgs.quoteRoot;
    }();
    final resolvedQuote = useState(requestedQuote);

    String? quoteForStore() =>
        effectiveParent == null ? null : resolvedQuote.value;

    Future<void> persistNow() async {
      if (skipPersist.value || !draftReady.value) return;
      debounce.value?.cancel();
      debounce.value = null;
      final lines = controllers.map((c) => c.text).toList(growable: false);
      await store.save(
        lines: lines,
        parentId: effectiveParent,
        quoteId: quoteForStore(),
      );
      if (!context.mounted) return;
      final any = lines.any((l) => l.trim().isNotEmpty);
      hasDraftContent.value = any;
      draftSavedAt.value = any ? DateTime.now() : null;
    }

    Future<void> leave() async {
      await persistNow();
      if (context.mounted) context.pop();
    }

    useEffect(() {
      unawaited(
        AnalyticsService.instance.logPantunComposeOpen(
          isReply: effectiveParent != null,
        ),
      );
      return null;
    }, const []);

    // Restore draf sekali saat open (pakai requested quote dulu).
    useEffect(() {
      var cancelled = false;
      unawaited(() async {
        final draft = await store.load(
          parentId: effectiveParent,
          quoteId: effectiveParent == null ? null : requestedQuote,
        );
        if (cancelled || !context.mounted) return;
        if (draft != null && draft.hasContent) {
          for (var i = 0; i < 4; i++) {
            controllers[i].text = draft.lines[i];
          }
          hasDraftContent.value = true;
          draftSavedAt.value = draft.updatedAt.toLocal();
        }
        draftReady.value = true;
      }());
      return () {
        cancelled = true;
        // Flush terakhir saat dispose (back sistem / route pop) bila timer
        // debounce belum sempat jalan. Controllers masih hidup di cleanup hooks.
        debounce.value?.cancel();
        debounce.value = null;
        if (!skipPersist.value && draftReady.value) {
          unawaited(
            store.save(
              lines: controllers.map((c) => c.text).toList(growable: false),
              parentId: effectiveParent,
              quoteId: effectiveParent == null ? null : resolvedQuote.value,
            ),
          );
        }
      };
    }, [effectiveParent, requestedQuote]);

    // Debounce persist + update indikator.
    useEffect(() {
      void onChanged() {
        final any = controllers.any((c) => c.text.trim().isNotEmpty);
        hasDraftContent.value = any;
        if (!any) draftSavedAt.value = null;
        if (!draftReady.value || skipPersist.value) return;
        debounce.value?.cancel();
        debounce.value = Timer(const Duration(milliseconds: 400), () {
          unawaited(persistNow());
        });
      }

      for (final c in controllers) {
        c.addListener(onChanged);
      }
      return () {
        for (final c in controllers) {
          c.removeListener(onChanged);
        }
      };
    }, [draftReady.value, effectiveParent, resolvedQuote.value]);

    // Quote reply hilang → toast + fallback induk + pindah key draf.
    final detailAsync = effectiveParent == null
        ? null
        : ref.watch(pantunDetailProvider(effectiveParent));
    useEffect(() {
      if (effectiveParent == null) return null;
      if (requestedQuote == PantunComposeArgs.quoteRoot) return null;
      if (staleToastShown.value) return null;
      final detail = detailAsync?.asData?.value;
      if (detail == null) return null;
      final exists = detail.replies.any((r) => r.id == requestedQuote);
      if (exists) return null;
      staleToastShown.value = true;
      resolvedQuote.value = PantunComposeArgs.quoteRoot;
      unawaited(
        store.clear(parentId: effectiveParent, quoteId: requestedQuote),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showFToast(
          context: context,
          title: Text(l10n.pantunComposeQuoteMissing),
        );
      });
      return null;
    }, [detailAsync?.asData?.value, requestedQuote, effectiveParent]);

    final tick = useState(0);
    for (final c in controllers) {
      useEffect(() {
        void listener() => tick.value++;
        c.addListener(listener);
        return () => c.removeListener(listener);
      }, [c]);
    }
    final lines = controllers.map((c) => c.text.trim()).toList();
    final allFilled = lines.every((l) => l.isNotEmpty);
    final scheme = allFilled ? pickRhymeScheme(lines) : null;
    final check = scheme == null
        ? (allFilled ? detectRhyme(lines, 'ABAB') : null)
        : detectRhyme(lines, scheme);
    final isVoice = composeMode.value == _ComposeMode.voice;
    final canSubmit = !submitting.value &&
        (isVoice ? attachedAudio.value != null : scheme != null);

    void selectMode(_ComposeMode next) {
      if (composeMode.value == next) return;
      if (next == _ComposeMode.text) {
        final prev = attachedAudio.value;
        attachedAudio.value = null;
        if (prev != null) {
          unawaited(prev.file.delete().catchError((_) => prev.file));
        }
      }
      composeMode.value = next;
    }

    final hints = [
      l10n.pantunComposeLine1Hint,
      l10n.pantunComposeLine2Hint,
      l10n.pantunComposeLine3Hint,
      l10n.pantunComposeLine4Hint,
    ];

    final quotePreview = _resolveQuotePreview(
      ref,
      parentId: effectiveParent,
      quoteId: resolvedQuote.value,
      args: args,
      preferLiveDetail: staleToastShown.value,
    );

    Future<void> discardDraft() async {
      final ok = await _confirmDiscardDraft(context, l10n);
      if (!ok || !context.mounted) return;
      skipPersist.value = true;
      debounce.value?.cancel();
      await store.clear(
        parentId: effectiveParent,
        quoteId: quoteForStore(),
      );
      for (final c in controllers) {
        c.clear();
      }
      hasDraftContent.value = false;
      draftSavedAt.value = null;
      skipPersist.value = false;
    }

    return PopScope(
      canPop: allowPop.value,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await leave();
      },
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: Text(
            effectiveParent == null ? l10n.pantunWrite : l10n.pantunReply,
          ),
          prefixes: [
            FHeaderAction.back(onPress: leave),
          ],
          suffixes: [
            if (hasDraftContent.value)
              Tooltip(
                message: l10n.pantunComposeDiscardDraft,
                child: FHeaderAction(
                  icon: const Icon(FLucideIcons.trash),
                  onPress: discardDraft,
                ),
              ),
          ],
        ),
        footer: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child:             FButton(
              onPress: canSubmit
                  ? () => _submit(
                      context,
                      ref,
                      lines,
                      scheme,
                      submitting,
                      mode: composeMode.value,
                      audio: attachedAudio.value,
                      store: store,
                      parentId: effectiveParent,
                      quoteId: resolvedQuote.value,
                      onBeforeClear: () {
                        skipPersist.value = true;
                        debounce.value?.cancel();
                      },
                      onAllowPop: () => allowPop.value = true,
                    )
                  : null,
              prefix: submitting.value ? const FCircularProgress() : null,
              child: Text(
                submitting.value ? l10n.pantunSending : l10n.pantunSend,
              ),
            ),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (effectiveParent != null && quotePreview != null) ...[
              _QuotePreviewCard(preview: quotePreview),
              const Gap(16),
            ],
            _ComposeModePicker(
              mode: composeMode.value,
              enabled: !submitting.value,
              onSelect: selectMode,
            ),
            const Gap(16),
            if (!isVoice) ...[
              for (var i = 0; i < 4; i++) ...[
                FTextField(
                  control: FTextFieldControl.managed(controller: controllers[i]),
                  focusNode: focusNodes[i],
                  hint: hints[i],
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: i < 3
                      ? TextInputAction.next
                      : TextInputAction.done,
                ),
                const Gap(12),
              ],
              if (hasDraftContent.value && draftSavedAt.value != null) ...[
                Text(
                  l10n.pantunComposeDraftSaved,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                const Gap(8),
              ],
              _RhymeStatus(check: check, allFilled: allFilled, scheme: scheme),
            ] else ...[
              _PantunAudioAttachRow(
                attached: attachedAudio.value,
                busy: submitting.value,
                onRecord: () async {
                  final recorded = await showRecordThreadAudioSheet(
                    context,
                    title: l10n.pantunRecordAudioTitle,
                    subtitle: l10n.pantunRecordAudioSubtitle,
                    submitLabel: l10n.pantunRecordAudio,
                    minMilliseconds: _pantunAudioMinMs,
                    maxSeconds: _pantunAudioMaxSec,
                  );
                  if (recorded != null && context.mounted) {
                    attachedAudio.value = recorded;
                  }
                },
                onRemove: () {
                  final prev = attachedAudio.value;
                  attachedAudio.value = null;
                  if (prev != null) {
                    unawaited(prev.file.delete().catchError((_) => prev.file));
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    List<String> lines,
    String? scheme,
    ValueNotifier<bool> submitting, {
    required _ComposeMode mode,
    required RecordedThreadAudio? audio,
    required PantunDraftStore store,
    required String? parentId,
    required String quoteId,
    required VoidCallback onBeforeClear,
    required VoidCallback onAllowPop,
  }) async {
    final l10n = AppLocalizations.of(context);
    final auth = await ref.read(authStatusProvider.future);
    if (!auth.isAuth) {
      if (context.mounted) {
        await showAppErrorSheet(
          context,
          message: parentId == null
              ? l10n.pantunWriteLoginRequired
              : l10n.pantunReplyLoginRequired,
        );
      }
      return;
    }
    submitting.value = true;
    try {
      final api = ref.read(pantunApiProvider);
      final Pantun row;
      if (mode == _ComposeMode.voice) {
        // canSubmit sudah jamin audio ada; guard lokal untuk type safety.
        final clip = audio!;
        row = parentId == null
            ? await api.createWithAudio(
                lines: const <String>[],
                rhymeScheme: null,
                audioFile: clip.file,
                durationMs: clip.durationMs,
              )
            : await api.createReplyWithAudio(
                parentId: parentId,
                lines: const <String>[],
                rhymeScheme: null,
                audioFile: clip.file,
                durationMs: clip.durationMs,
              );
      } else if (parentId == null) {
        row = await api.create(lines: lines, rhymeScheme: scheme);
      } else {
        row = await api.createReply(
          parentId: parentId,
          lines: lines,
          rhymeScheme: scheme,
        );
      }
      unawaited(
        AnalyticsService.instance.logPantunSubmit(isReply: parentId != null),
      );
      onBeforeClear();
      await store.clear(
        parentId: parentId,
        quoteId: parentId == null ? null : quoteId,
      );
      if (context.mounted) {
        ref.invalidate(pantunFeedProvider);
        // Detail: caller append+scroll; jangan invalidate di sini agar
        // balasan baru tidak hilang sebelum scroll.
        onAllowPop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.pop(row);
        });
      }
    } on PantunFailure catch (e) {
      if (context.mounted) await showAppErrorSheet(context, message: e.message);
    } catch (_) {
      if (context.mounted) {
        await showAppErrorSheet(context, message: l10n.pantunSendFailed);
      }
    } finally {
      submitting.value = false;
    }
  }
}

class _QuotePreview {
  const _QuotePreview({required this.authorLabel, required this.lines});

  final String authorLabel;
  final List<String> lines;
}

_QuotePreview? _resolveQuotePreview(
  WidgetRef ref, {
  required String? parentId,
  required String quoteId,
  required PantunComposeArgs? args,
  bool preferLiveDetail = false,
}) {
  if (parentId == null || parentId.isEmpty) return null;

  final detail = ref.watch(pantunDetailProvider(parentId)).asData?.value;

  if (detail != null) {
    final Pantun target;
    if (quoteId == PantunComposeArgs.quoteRoot || quoteId == parentId) {
      target = detail.pantun;
    } else {
      Pantun? match;
      for (final reply in detail.replies) {
        if (reply.id == quoteId) {
          match = reply;
          break;
        }
      }
      target = match ?? detail.pantun;
    }
    return _QuotePreview(
      authorLabel: displayPublicAccountLabel(
        displayName: target.displayName,
        username: target.username,
      ),
      lines: target.lines,
    );
  }

  if (preferLiveDetail) return null;

  final fromArgsLines = args?.quoteLines;
  final fromArgsAuthor = args?.quoteAuthorLabel?.trim() ?? '';
  if (fromArgsLines != null && fromArgsLines.isNotEmpty) {
    return _QuotePreview(
      authorLabel: fromArgsAuthor,
      lines: fromArgsLines.take(4).toList(growable: false),
    );
  }
  return null;
}

Future<bool> _confirmDiscardDraft(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: MediaQuery.of(sheetContext).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.pantunComposeDiscardDraftTitle),
                subtitle: Text(l10n.pantunComposeDiscardDraftBody),
              ),
              FTile(
                title: const SizedBox.shrink(),
                suffix: FButton(
                  variant: FButtonVariant.destructive,
                  onPress: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.pantunComposeDiscardDraftConfirm),
                ),
              ),
              FTile(
                title: const SizedBox.shrink(),
                suffix: FButton(
                  onPress: () => Navigator.of(sheetContext).pop(false),
                  child: Text(l10n.pantunCancel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result == true;
}

class _QuotePreviewCard extends StatelessWidget {
  const _QuotePreviewCard({required this.preview});

  final _QuotePreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final title = preview.authorLabel.trim().isEmpty
        ? l10n.pantunComposeReplying
        : l10n.pantunComposeReplyingAuthor(preview.authorLabel);
    final shown = preview.lines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
            if (shown.isNotEmpty) ...[
              const Gap(8),
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const Gap(2),
                Text(
                  shown[i],
                  style: theme.typography.body.sm.copyWith(
                    fontStyle: i < 2 ? FontStyle.italic : FontStyle.normal,
                    color: i < 2
                        ? theme.colors.mutedForeground
                        : theme.colors.foreground,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RhymeStatus extends StatelessWidget {
  const _RhymeStatus({
    required this.check,
    required this.allFilled,
    this.scheme,
  });

  final RhymeCheckResult? check;
  final bool allFilled;
  final String? scheme;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    if (!allFilled) {
      return Text(
        l10n.pantunComposeIncomplete,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }
    return switch (check) {
      RhymeOk(:final warning) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FBadge(
            variant: FBadgeVariant.primary,
            child: Text(
              scheme == null
                  ? l10n.pantunComposeRhymeOk
                  : l10n.pantunComposeRhymeOkScheme(scheme!),
            ),
          ),
          if (warning != null) ...[
            const Gap(6),
            Text(
              warning,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.primary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      RhymeMismatch(:final pairs) => FBadge(
        variant: FBadgeVariant.destructive,
        child: Text(
          pairs
              .map((p) => l10n.pantunComposeRhymeMismatchPair(p.$1, p.$2))
              .join('; '),
        ),
      ),
      RhymeLastWordUndetected(:final lineIndex) => FBadge(
        variant: FBadgeVariant.destructive,
        child: Text(
          l10n.pantunComposeRhymeLastWordUndetected(lineIndex + 1),
        ),
      ),
      null => const SizedBox.shrink(),
    };
  }
}

class _ComposeModePicker extends StatelessWidget {
  const _ComposeModePicker({
    required this.mode,
    required this.enabled,
    required this.onSelect,
  });

  final _ComposeMode mode;
  final bool enabled;
  final ValueChanged<_ComposeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return FTileGroup(
      children: [
        FTile(
          title: Text(l10n.pantunComposeModeText),
          subtitle: Text(l10n.pantunComposeTextHint),
          prefix: Icon(
            FLucideIcons.penLine,
            color: mode == _ComposeMode.text
                ? theme.colors.primary
                : theme.colors.mutedForeground,
          ),
          suffix: mode == _ComposeMode.text
              ? Icon(FLucideIcons.check, color: theme.colors.primary)
              : null,
          onPress: enabled ? () => onSelect(_ComposeMode.text) : null,
        ),
        FTile(
          title: Text(l10n.pantunComposeModeVoice),
          subtitle: Text(l10n.pantunComposeVoiceHint),
          prefix: Icon(
            FLucideIcons.mic,
            color: mode == _ComposeMode.voice
                ? theme.colors.primary
                : theme.colors.mutedForeground,
          ),
          suffix: mode == _ComposeMode.voice
              ? Icon(FLucideIcons.check, color: theme.colors.primary)
              : null,
          onPress: enabled ? () => onSelect(_ComposeMode.voice) : null,
        ),
      ],
    );
  }
}

class _PantunAudioAttachRow extends StatelessWidget {
  const _PantunAudioAttachRow({
    required this.attached,
    required this.busy,
    required this.onRecord,
    required this.onRemove,
  });

  final RecordedThreadAudio? attached;
  final bool busy;
  final VoidCallback onRecord;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    if (attached == null) {
      return FButton(
        variant: FButtonVariant.outline,
        onPress: busy ? null : onRecord,
        prefix: const Icon(FLucideIcons.mic, size: 16),
        child: Text(l10n.pantunRecordAudio),
      );
    }
    final seconds = (attached!.durationMs / 1000).round();
    return FTileGroup(
      children: [
        FTile(
          title: Text(l10n.pantunRecordAudioAttached(seconds)),
          prefix: Icon(FLucideIcons.audioLines, color: theme.colors.primary),
          suffix: FButton(
            variant: FButtonVariant.ghost,
            onPress: busy ? null : onRemove,
            child: Text(l10n.pantunRecordAudioRemove),
          ),
        ),
      ],
    );
  }
}
