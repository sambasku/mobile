import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_policy.dart';
import '../../../core/cache/cache_providers.dart';
import '../../../core/cache/response_cache_store.dart';
import '../../../core/utils/format_datetime.dart';
import '../dev_tool_inspector.dart';

/// Explorer box Hive L1 (`response_cache_index` / `response_cache_body`).
class ResponseCacheInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF0D9488);

  @override
  String get description => 'Hive L1: key, TTL age, body, wipe';

  @override
  IconData get icon => FLucideIcons.hardDrive;

  @override
  String get name => 'Response Cache';

  @override
  Widget buildPage(BuildContext context) => const _ResponseCachePage();
}

class _ResponseCachePage extends StatefulWidget {
  const _ResponseCachePage();

  @override
  State<_ResponseCachePage> createState() => _ResponseCachePageState();
}

class _ResponseCachePageState extends State<_ResponseCachePage> {
  final ResponseCacheStore _store = responseCacheStoreSingleton;
  late final TextEditingController _filterCtrl;
  late final FTextFieldControl _filterControl;

  List<CacheEntryMeta> _entries = const [];
  String _query = '';
  CacheScope? _scopeFilter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _filterCtrl = TextEditingController();
    _filterControl = FTextFieldControl.managed(
      controller: _filterCtrl,
      onChange: (value) {
        final next = value.text;
        if (next == _query) return;
        setState(() => _query = next);
      },
    );
    _reload();
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _loading = true;
      _entries = _store.listMeta();
      _loading = false;
    });
  }

  List<CacheEntryMeta> get _filtered {
    final q = _query.trim().toLowerCase();
    return _entries.where((e) {
      if (_scopeFilter != null && e.scope != _scopeFilter) return false;
      if (q.isEmpty) return true;
      return e.key.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  Future<void> _wipeAll() async {
    final ok = await _confirm(
      title: 'Wipe seluruh L1?',
      body: 'Semua entry response cache akan dihapus.',
    );
    if (!ok) return;
    await _store.wipeAll();
    _reload();
  }

  Future<void> _wipeScope(CacheScope scope) async {
    final ok = await _confirm(
      title: 'Wipe scope ${scope.name}?',
      body: 'Hanya entry dengan scope ${scope.name}.',
    );
    if (!ok) return;
    await _store.wipeScope(scope);
    _reload();
  }

  Future<void> _deleteKey(String key) async {
    await _store.delete(key);
    _reload();
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final result = await showFDialog<bool>(
      context: context,
      builder: (dialogContext, style, animation) => FDialog(
        style: style,
        animation: animation,
        title: Text(title),
        body: Text(body),
        actions: [
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FButton(
            onPress: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _openDetail(CacheEntryMeta meta) {
    final entry = _store.peek(meta.key);
    if (entry == null) {
      showFToast(
        context: context,
        variant: FToastVariant.destructive,
        icon: const Icon(FLucideIcons.triangleAlert, size: 16),
        title: const Text('Entry hilang / corrupt'),
      );
      _reload();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ResponseCacheDetailPage(
          entry: entry,
          onDelete: () async {
            await _deleteKey(entry.key);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (_loading) {
      return const Center(child: FCircularProgress.loader());
    }

    final filtered = _filtered;
    final total = _store.totalBytes;
    final budget = CachePolicy.maxBudgetBytes;
    final pct = budget == 0 ? 0.0 : (total / budget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.sm,
                    semanticsLabel: 'Refresh',
                    onPress: _reload,
                    child: const Icon(FLucideIcons.refreshCw),
                  ),
                  const Gap(4),
                  FPopoverMenu.tiles(
                    menuAnchor: Alignment.topLeft,
                    childAnchor: Alignment.bottomLeft,
                    menuBuilder: (context, controller, menu) => [
                      FTileGroup(
                        children: [
                          FTile(
                            title: const Text('Wipe all'),
                            onPress: _entries.isEmpty
                                ? null
                                : () async {
                                    await controller.hide();
                                    await _wipeAll();
                                  },
                          ),
                          FTile(
                            title: const Text('Wipe user'),
                            onPress: () async {
                              await controller.hide();
                              await _wipeScope(CacheScope.user);
                            },
                          ),
                          FTile(
                            title: const Text('Wipe public'),
                            onPress: () async {
                              await controller.hide();
                              await _wipeScope(CacheScope.public);
                            },
                          ),
                        ],
                      ),
                    ],
                    builder: (context, controller, child) => FButton.icon(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.sm,
                      semanticsLabel: 'Wipe',
                      onPress: controller.toggle,
                      child: const Icon(FLucideIcons.trash2),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      '${_store.entryCount} · ${_formatBytes(total)} / '
                      '${_formatBytes(budget)}',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Gap(6),
              FDeterminateProgress(value: pct),
              const Gap(8),
              FTextField(
                control: _filterControl,
                size: FTextFieldSizeVariant.sm,
                hint: 'Filter key…',
              ),
              const Gap(8),
              Row(
                children: [
                  for (final opt in <(CacheScope?, String)>[
                    (null, 'Semua'),
                    (CacheScope.public, 'public'),
                    (CacheScope.user, 'user'),
                  ]) ...[
                    if (opt != (null, 'Semua')) const Gap(6),
                    FButton(
                      variant: _scopeFilter == opt.$1
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      size: FButtonSizeVariant.xs,
                      onPress: () => setState(() => _scopeFilter = opt.$1),
                      child: Text(opt.$2),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'Kosong',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FTileGroup.builder(
                    count: filtered.length,
                    tileBuilder: (context, index) {
                      final meta = filtered[index];
                      return _CacheTile(
                        meta: meta,
                        onPress: () => _openDetail(meta),
                        onDelete: () => _deleteKey(meta.key),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _CacheTile extends StatelessWidget with FTileMixin {
  const _CacheTile({
    required this.meta,
    required this.onPress,
    required this.onDelete,
  });

  final CacheEntryMeta meta;
  final VoidCallback onPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final age = DateTime.now().toUtc().difference(meta.cachedAt);
    final guessed = _guessCacheClass(meta.key);
    final freshness = guessed == null
        ? null
        : CachePolicy.freshness(
            CacheEntry(
              key: meta.key,
              body: '',
              cachedAt: meta.cachedAt,
              lastAccess: meta.lastAccess,
              sizeBytes: meta.sizeBytes,
              scope: meta.scope,
              schemaVersion: meta.schemaVersion,
            ),
            guessed,
          );

    return FTile(
      title: Text(meta.key, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${meta.scope.name} · ${_formatBytes(meta.sizeBytes)} · '
        '${_formatAge(age)}'
        '${freshness != null ? ' · ${freshness.name}' : ''}'
        ' · ${formatDateTime(meta.cachedAt)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.xs.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
      suffix: FButton.icon(
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        semanticsLabel: 'Hapus',
        onPress: onDelete,
        child: Icon(
          FLucideIcons.trash2,
          color: theme.colors.destructive,
        ),
      ),
      onPress: onPress,
    );
  }
}

class _ResponseCacheDetailPage extends StatelessWidget {
  const _ResponseCacheDetailPage({
    required this.entry,
    required this.onDelete,
  });

  final CacheEntry entry;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final pretty = _prettyBody(entry.body);
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: 'Kembali',
                  onPress: () => Navigator.of(context).pop(),
                  child: const Icon(FLucideIcons.arrowLeft),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Cache entry',
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: 'Salin body',
                  onPress: () {
                    Clipboard.setData(ClipboardData(text: pretty));
                    showFToast(
                      context: context,
                      variant: FToastVariant.primary,
                      icon: const Icon(FLucideIcons.copy, size: 16),
                      title: const Text('Body disalin'),
                    );
                  },
                  child: const Icon(FLucideIcons.copy),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: 'Hapus',
                  onPress: () async => onDelete(),
                  child: Icon(
                    FLucideIcons.trash2,
                    color: theme.colors.destructive,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              entry.key,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            const Gap(2),
            Text(
              '${entry.scope.name} · ${_formatBytes(entry.sizeBytes)} · '
              'schema ${entry.schemaVersion} · '
              '${formatDateTime(entry.cachedAt)}',
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(12),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  pretty,
                  style: theme.typography.sm.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: theme.colors.foreground,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

CacheClass? _guessCacheClass(String key) {
  final k = key.toLowerCase();
  if (k.contains('/languages') ||
      k.contains('/dialects') ||
      k.contains('/word-classes')) {
    return CacheClass.referenceStatic;
  }
  if (k.contains('/words/today')) return CacheClass.wordOfDay;
  if (k.contains('/words/latest')) return CacheClass.feedList;
  if (k.contains('/words/search')) return CacheClass.search;
  if (k.contains('/discussions')) return CacheClass.socialPublic;
  if (k.contains('/words/')) return CacheClass.dictionaryDetail;
  return null;
}

String _prettyBody(String body) {
  try {
    final decoded = jsonDecode(body);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return body;
  }
}

String _formatBytes(int n) {
  if (n < 1024) return '$n B';
  if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
  return '${(n / (1024 * 1024)).toStringAsFixed(2)} MB';
}

String _formatAge(Duration age) {
  if (age.isNegative) return '0s';
  if (age.inDays >= 1) return '${age.inDays}d';
  if (age.inHours >= 1) return '${age.inHours}h';
  if (age.inMinutes >= 1) return '${age.inMinutes}m';
  return '${age.inSeconds}s';
}
