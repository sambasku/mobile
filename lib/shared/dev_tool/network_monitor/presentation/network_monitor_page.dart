import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../dev_tool_inspector.dart';
import '../cache_source_copy.dart';
import '../data/models/network_request_record.dart';
import '../network_monitor_registry.dart';
import 'network_request_detail_page.dart';

class NetworkMonitorInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF1A73E8);

  @override
  String get description => 'Rekam dan inspect request API';

  @override
  IconData get icon => FLucideIcons.wifi;

  @override
  String get name => 'Network Monitor';

  @override
  List<Widget> get appBarActions => [
    IconButton(
      tooltip: 'Clear',
      icon: const Icon(FLucideIcons.trash2),
      onPressed: NetworkMonitorRegistry.clearRecords.call,
    ),
  ];

  @override
  Widget buildPage(BuildContext context) => const NetworkMonitorPage();
}

class NetworkMonitorPage extends StatelessWidget {
  const NetworkMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<NetworkRequestRecord>>(
            stream: NetworkMonitorRegistry.observeRecords(),
            builder: (context, snapshot) {
              final records = snapshot.data ?? const <NetworkRequestRecord>[];

              if (records.isEmpty) {
                return const _EmptyNetworkMonitorState();
              }

              return FTileGroup.builder(
                count: records.length,
                tileBuilder: (context, index) {
                  final record = records[index];

                  return _NetworkRecordTile(
                    record: record,
                    onPress: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            NetworkRequestDetailPage(record: record),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NetworkRecordTile extends StatelessWidget with FTileMixin {
  const _NetworkRecordTile({required this.record, required this.onPress});

  final NetworkRequestRecord record;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final statusText = record.statusCode?.toString() ?? '...';
    final durationText = record.cacheSource != null
        ? 'cache'
        : (record.durationMs == null ? '-' : '${record.durationMs} ms');
    final host = Uri.tryParse(record.url)?.host ?? '';
    final statusColors = _statusColors(theme, record);
    final cacheSource = record.cacheSource;

    return FTile(
      title: Text(
        record.path,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.xs.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Badge(
                label: record.method,
                textColor: theme.colors.primaryForeground,
                backgroundColor: theme.colors.primary,
              ),
              _Badge(
                label: statusText,
                textColor: statusColors.$1,
                backgroundColor: statusColors.$2,
              ),
              if (cacheSource != null)
                _Badge(
                  label: cacheSource,
                  textColor: _cacheBadgeColors(theme, cacheSource).$1,
                  backgroundColor: _cacheBadgeColors(theme, cacheSource).$2,
                  tooltip: cacheSourcePlainExplanation(cacheSource),
                ),
              if (host.isNotEmpty)
                Text(host, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          if (record.errorMessage != null) ...[
            const Gap(4),
            Text(
              record.errorMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colors.destructive),
            ),
          ],
        ],
      ),
      details: Text(durationText),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onPress,
    );
  }

  /// `(text, background)` untuk badge status.
  (Color, Color) _statusColors(FThemeData theme, NetworkRequestRecord record) {
    if (record.statusCode == null) {
      return (theme.colors.mutedForeground, theme.colors.muted);
    }
    if (record.isError || (record.statusCode ?? 0) >= 400) {
      return (
        theme.colors.destructive,
        theme.colors.destructive.withValues(alpha: 0.12),
      );
    }
    // ponytail: Forui tak punya success token; pakai primary tint.
    return (
      theme.colors.primary,
      theme.colors.primary.withValues(alpha: 0.12),
    );
  }
}

(Color, Color) _cacheBadgeColors(FThemeData theme, String source) {
  switch (source) {
    case 'HIT':
      return (
        const Color(0xFF0F766E),
        const Color(0xFF0D9488).withValues(alpha: 0.16),
      );
    case 'STALE':
      return (
        const Color(0xFFB45309),
        const Color(0xFFF59E0B).withValues(alpha: 0.18),
      );
    case 'DEGRADED':
      return (
        theme.colors.destructive,
        theme.colors.destructive.withValues(alpha: 0.12),
      );
    default:
      return (theme.colors.mutedForeground, theme.colors.muted);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.tooltip,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );

    final tip = tooltip;
    if (tip == null || tip.isEmpty) return badge;

    return Tooltip(
      message: tip,
      waitDuration: const Duration(milliseconds: 400),
      showDuration: const Duration(seconds: 6),
      triggerMode: TooltipTriggerMode.tap,
      child: badge,
    );
  }
}

class _EmptyNetworkMonitorState extends StatelessWidget {
  const _EmptyNetworkMonitorState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Belum ada request yang direkam.',
          textAlign: TextAlign.center,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
