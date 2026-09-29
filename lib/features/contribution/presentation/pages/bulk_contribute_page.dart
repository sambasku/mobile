import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_contributions/presentation/providers/my_contributions_providers.dart';
import '../models/bulk_submit_word_state.dart';
import '../providers/bulk_submit_word_providers.dart';

class BulkContributePage extends ConsumerStatefulWidget {
  const BulkContributePage({super.key});

  @override
  ConsumerState<BulkContributePage> createState() => _BulkContributePageState();
}

class _RowControllers {
  _RowControllers({String lemma = '', String translation = ''})
    : lemmaCtrl = TextEditingController(text: lemma),
      translationCtrl = TextEditingController(text: translation);

  final TextEditingController lemmaCtrl;
  final TextEditingController translationCtrl;

  void dispose() {
    lemmaCtrl.dispose();
    translationCtrl.dispose();
  }
}

class _BulkContributePageState extends ConsumerState<BulkContributePage> {
  final Map<String, _RowControllers> _ctrls = {};
  final Set<String> _listening = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final guest = !(ref.read(authStatusProvider).value?.isAuth ?? false);
      AnalyticsService.instance.log(
        AnalyticsEvents.contributeStart,
        params: {'guest': guest ? 1 : 0, 'from': 'bulk'},
      );
      _syncControllers(ref.read(bulkSubmitWordProvider).rows);
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _ctrls.clear();
    _listening.clear();
    super.dispose();
  }

  void _syncControllers(List<BulkContributeRow> rows) {
    final ids = rows.map((r) => r.id).toSet();
    var changed = false;
    for (final id in _ctrls.keys.toList(growable: false)) {
      if (ids.contains(id)) continue;
      _ctrls.remove(id)?.dispose();
      _listening.remove(id);
      changed = true;
    }
    for (final row in rows) {
      final existing = _ctrls[row.id];
      if (existing == null) {
        final created = _RowControllers(
          lemma: row.lemma,
          translation: row.translation,
        );
        _ctrls[row.id] = created;
        _attachListeners(row.id, created);
        changed = true;
        continue;
      }
      if (!_listening.contains(row.id)) {
        _attachListeners(row.id, existing);
      }
    }
    if (changed && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _attachListeners(String id, _RowControllers c) {
    if (_listening.contains(id)) return;
    _listening.add(id);
    void onEdit() {
      if (!mounted) return;
      final notifier = ref.read(bulkSubmitWordProvider.notifier);
      final row = ref
          .read(bulkSubmitWordProvider)
          .rows
          .where((r) => r.id == id)
          .firstOrNull;
      if (row == null || !row.isEditable) return;
      notifier.updateRow(
        id,
        lemma: c.lemmaCtrl.text,
        translation: c.translationCtrl.text,
      );
    }

    c.lemmaCtrl.addListener(onEdit);
    c.translationCtrl.addListener(onEdit);
  }

  Future<void> _submit() async {
    final languages =
        ref.read(_bulkLanguagesProvider).value ?? const <_BulkOption>[];
    final wordClasses =
        ref.read(_bulkWordClassesProvider).value ?? const <_BulkOption>[];
    final languageId =
        languages.where((e) => e.code.toUpperCase() == 'SBS').firstOrNull?.id ??
        '';
    final translationLanguageId =
        languages.where((e) => e.code.toUpperCase() == 'IDN').firstOrNull?.id ??
        '';
    final wordClassId =
        wordClasses
            .where((e) => e.code.toLowerCase() == 'umum')
            .firstOrNull
            ?.id ??
        wordClasses.firstOrNull?.id ??
        '';

    String? dialectId;
    if (languageId.isNotEmpty) {
      final dialects = ref.read(_bulkDialectsProvider(languageId)).value;
      dialectId =
          dialects?.where((e) => e.isDefault).firstOrNull?.id ??
          dialects
              ?.where((e) => e.code.toLowerCase() == 'umum')
              .firstOrNull
              ?.id;
    }

    await ref
        .read(bulkSubmitWordProvider.notifier)
        .submitPending(
          languageId: languageId,
          translationLanguageId: translationLanguageId,
          wordClassId: wordClassId,
          dialectId: dialectId,
        );
  }

  Future<void> _showBatchResultDialog(BulkSubmitWordState state) async {
    final sent = state.sentCount;
    final failed = state.failedCount;
    final allOk = state.allSendableSucceeded && failed == 0;

    final title = allOk ? 'Usulan terkirim' : 'Sebagian terkirim';
    final body = allOk
        ? (sent == 1
              ? '1 kata berhasil dikirim.'
              : '$sent kata berhasil dikirim.')
        : '$sent terkirim, $failed gagal. Perbaiki baris yang gagal lalu kirim ulang.';

    final choice = await showFDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext, style, animation) => FDialog(
        style: style,
        animation: animation,
        direction: Axis.vertical,
        title: Text(title),
        body: Text(body),
        actions: [
          if (allOk) ...[
            FButton(
              onPress: () => Navigator.of(dialogContext).pop('list'),
              child: const Text('Lihat usulan'),
            ),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop('back'),
              child: const Text('Kembali'),
            ),
          ] else ...[
            FButton(
              onPress: () => Navigator.of(dialogContext).pop('stay'),
              child: const Text('Perbaiki'),
            ),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop('list'),
              child: const Text('Lihat usulan'),
            ),
          ],
        ],
      ),
    );

    if (!mounted) return;
    ref.read(bulkSubmitWordProvider.notifier).clearBatchFinished();

    switch (choice) {
      case 'list':
        ref.invalidate(myContributionsListControllerProvider);
        context.pushReplacement('/contributions');
      case 'back':
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/contribute');
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = ref.watch(bulkSubmitWordProvider);
    final notifier = ref.read(bulkSubmitWordProvider.notifier);
    final isAuth = ref.watch(authStatusProvider).value?.isAuth ?? false;

    ref.listen<List<BulkContributeRow>>(
      bulkSubmitWordProvider.select((s) => s.rows),
      (_, rows) {
        _syncControllers(rows);
      },
    );

    ref.listen<String?>(bulkSubmitWordProvider.select((s) => s.errorMessage), (
      _,
      next,
    ) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) notifier.clearError();
      });
    });

    ref.listen<bool>(bulkSubmitWordProvider.select((s) => s.batchFinished), (
      prev,
      next,
    ) {
      if (next != true || prev == true) return;
      if (!context.mounted) return;
      final latest = ref.read(bulkSubmitWordProvider);
      _showBatchResultDialog(latest);
    });

    // Prefetch dialek setelah bahasa SBS diketahui.
    final languagesAsync = ref.watch(_bulkLanguagesProvider);
    final sambasId = languagesAsync.value
        ?.where((e) => e.code.toUpperCase() == 'SBS')
        .firstOrNull
        ?.id;
    if (sambasId != null) {
      ref.watch(_bulkDialectsProvider(sambasId));
    }
    ref.watch(_bulkWordClassesProvider);

    final sendingNow = state.rows.any(
      (r) => r.status == BulkRowSubmitStatus.sending,
    );
    final progressCurrent = state.isSubmitting
        ? (state.progressDone + (sendingNow ? 1 : 0)).clamp(
            0,
            state.progressTotal,
          )
        : state.progressDone;
    final footerLabel = state.isSubmitting
        ? 'Mengirim $progressCurrent/${state.progressTotal}...'
        : (state.isRetryMode
              ? 'Kirim ulang yang belum terkirim'
              : 'Kirim semua');

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Usulkan banyak'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/contribute'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: state.isSubmitting || !state.hasPendingSendable
                ? null
                : _submit,
            prefix: state.isSubmitting ? const FCircularProgress() : null,
            child: Text(footerLabel),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        children: [
          Text(
            isAuth
                ? 'Tiap kata langsung tayang dengan label Menunggu pengecekan.'
                : 'Dikirim sebagai tamu. Kata belum tayang sampai tim memeriksa.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(4),
          Text(
            'Maksimal ${BulkSubmitWordState.maxRows} kata. Isi kata Sambas dan terjemahan Indonesia.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(10),
          _BulkTable(
            rows: state.rows,
            ctrls: _ctrls,
            isSubmitting: state.isSubmitting,
            onRemove: notifier.removeRow,
          ),
          const Gap(10),
          if (state.rows.length < BulkSubmitWordState.maxRows)
            FButton(
              variant: FButtonVariant.outline,
              onPress: state.isSubmitting ? null : notifier.addRow,
              prefix: const Icon(FLucideIcons.plus),
              child: const Text('Tambah baris'),
            )
          else
            Text(
              'Maksimal ${BulkSubmitWordState.maxRows} baris per sesi.',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }
}

const _bulkActionWidth = 36.0;

class _BulkTable extends StatelessWidget {
  const _BulkTable({
    required this.rows,
    required this.ctrls,
    required this.isSubmitting,
    required this.onRemove,
  });

  final List<BulkContributeRow> rows;
  final Map<String, _RowControllers> ctrls;
  final bool isSubmitting;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final border = theme.colors.border;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BulkTableHeader(borderColor: border),
            for (var i = 0; i < rows.length; i++)
              _BulkTableRow(
                index: i,
                row: rows[i],
                ctrls: ctrls[rows[i].id],
                cellStyle: _bulkCellStyle(theme.colors.primary),
                borderColor: border,
                canRemove:
                    rows.length > 1 && rows[i].canRemove && !isSubmitting,
                onRemove: () => onRemove(rows[i].id),
              ),
          ],
        ),
      ),
    );
  }
}

class _BulkTableHeader extends StatelessWidget {
  const _BulkTableHeader({required this.borderColor});

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style = theme.typography.xs.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colors.mutedForeground,
    );
    final divider = Border(left: BorderSide(color: borderColor));

    return ColoredBox(
      color: theme.colors.secondary,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('Sambas', style: style),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(border: divider),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text('Indonesia', style: style),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(border: divider),
            child: const SizedBox(width: _bulkActionWidth, height: 32),
          ),
        ],
      ),
    );
  }
}

class _BulkTableRow extends StatelessWidget {
  const _BulkTableRow({
    required this.index,
    required this.row,
    required this.ctrls,
    required this.cellStyle,
    required this.borderColor,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final BulkContributeRow row;
  final _RowControllers? ctrls;
  final FTextFieldStyleDelta cellStyle;
  final Color borderColor;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final locked = !row.isEditable || row.status == BulkRowSubmitStatus.sending;
    final n = index + 1;
    final error = row.errorMessage?.trim();
    final failed = row.status == BulkRowSubmitStatus.failed;
    final divider = Border(left: BorderSide(color: borderColor));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: failed ? theme.colors.error.withValues(alpha: 0.06) : null,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _cell(
                  controller: ctrls?.lemmaCtrl,
                  hint: index == 0 ? 'ngupi' : null,
                  semanticsLabel: 'Kata Sambas baris $n',
                  locked: locked,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(border: divider),
                  child: _cell(
                    controller: ctrls?.translationCtrl,
                    hint: index == 0 ? 'minum kopi' : null,
                    semanticsLabel: 'Terjemahan Indonesia baris $n',
                    locked: locked,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(border: divider),
                child: SizedBox(
                  width: _bulkActionWidth,
                  height: 40,
                  child: Center(child: _action(theme)),
                ),
              ),
            ],
          ),
          if (error != null && error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                error,
                style: theme.typography.xs.copyWith(color: theme.colors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell({
    required TextEditingController? controller,
    required String? hint,
    required String semanticsLabel,
    required bool locked,
    required TextInputAction textInputAction,
  }) {
    if (controller == null) return const SizedBox(height: 40);
    return Semantics(
      label: semanticsLabel,
      child: FTextField(
        control: FTextFieldControl.managed(controller: controller),
        size: FTextFieldSizeVariant.sm,
        style: cellStyle,
        hint: hint,
        enabled: !locked,
        readOnly: locked,
        textInputAction: textInputAction,
      ),
    );
  }

  Widget _action(FThemeData theme) {
    final failed = row.status == BulkRowSubmitStatus.failed;
    switch (row.status) {
      case BulkRowSubmitStatus.sending:
        return Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colors.primary,
            ),
          ),
        );
      case BulkRowSubmitStatus.sent:
        return Icon(
          FLucideIcons.circleCheck,
          size: 16,
          color: theme.colors.primary,
          semanticLabel: 'Terkirim',
        );
      case BulkRowSubmitStatus.idle:
      case BulkRowSubmitStatus.failed:
        if (!canRemove) return const SizedBox.shrink();
        return FButton.icon(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          onPress: onRemove,
          child: Icon(
            FLucideIcons.trash2,
            size: 16,
            color: failed ? theme.colors.error : theme.colors.mutedForeground,
            semanticLabel: 'Hapus baris ${index + 1}',
          ),
        );
    }
  }
}

FTextFieldStyleDelta _bulkCellStyle(Color focusColor) {
  return FTextFieldStyleDelta.delta(
    border: FVariantsValueDelta.delta([
      FVariantValueDeltaOperation.all(InputBorder.none),
      FVariantValueDeltaOperation.exact(
        {FTextFieldVariant.focused},
        UnderlineInputBorder(
          borderSide: BorderSide(color: focusColor, width: 2),
        ),
      ),
    ]),
    color: FVariantsValueDelta.delta([
      FVariantValueDeltaOperation.all(const Color(0x00000000)),
    ]),
    contentPadding: EdgeInsetsGeometryDelta.value(
      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
  );
}

class _BulkOption {
  const _BulkOption({
    required this.id,
    required this.name,
    required this.code,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String code;
  final bool isDefault;
}

final _bulkLanguagesProvider = FutureProvider<List<_BulkOption>>((ref) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(
    method: 'GET',
    path: '/api/v1/languages',
    query: const {'is_active': 'true'},
  );
  final data = await cache.getOrFetch(
    key: key,
    cacheClass: CacheClass.referenceStatic,
    fetch: () async {
      final resp = await dio.get<dynamic>('/api/v1/languages?is_active=true');
      final body = resp.data;
      if (body is! Map) {
        throw StateError('Envelope languages tidak valid');
      }
      return Map<String, dynamic>.from(body);
    },
  );
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map>()
      .map(
        (e) => _BulkOption(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

final _bulkWordClassesProvider = FutureProvider<List<_BulkOption>>((ref) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(method: 'GET', path: '/api/v1/word-classes');
  final data = await cache.getOrFetch(
    key: key,
    cacheClass: CacheClass.referenceStatic,
    fetch: () async {
      final resp = await dio.get<dynamic>('/api/v1/word-classes');
      final body = resp.data;
      if (body is! Map) {
        throw StateError('Envelope word-classes tidak valid');
      }
      return Map<String, dynamic>.from(body);
    },
  );
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map>()
      .map(
        (e) => _BulkOption(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

final _bulkDialectsProvider = FutureProvider.family<List<_BulkOption>, String>((
  ref,
  languageId,
) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final query = <String, dynamic>{'language_id': languageId};
  final key = buildCacheKey(
    method: 'GET',
    path: '/api/v1/dialects',
    query: query,
  );
  final data = await cache.getOrFetch(
    key: key,
    cacheClass: CacheClass.referenceStatic,
    fetch: () async {
      final resp = await dio.get<dynamic>(
        '/api/v1/dialects',
        queryParameters: query,
      );
      final body = resp.data;
      if (body is! Map) {
        throw StateError('Envelope dialects tidak valid');
      }
      return Map<String, dynamic>.from(body);
    },
  );
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map>()
      .map(
        (e) => _BulkOption(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
          isDefault: e['is_default'] == true,
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});
