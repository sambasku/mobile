import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../dev_tool_inspector.dart';
import 'exception_log.dart';

class ExceptionLogInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFFE53E3E);

  @override
  String get description => 'Exception yang tidak tertangkap';

  @override
  IconData get icon => FLucideIcons.circleAlert;

  @override
  String get name => 'Exceptions';

  @override
  List<Widget> get appBarActions => [
    IconButton(
      tooltip: 'Bersihkan',
      icon: const Icon(FLucideIcons.trash2),
      onPressed: ExceptionLog.buffer.clear,
    ),
  ];

  @override
  Widget buildPage(BuildContext context) => const _ExceptionLogPage();
}

class _ExceptionLogPage extends StatelessWidget {
  const _ExceptionLogPage();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ExceptionLogRecord>>(
      valueListenable: ExceptionLog.buffer.records,
      builder: (context, records, _) {
        if (records.isEmpty) {
          return const _EmptyExceptions();
        }
        return FTileGroup.builder(
          count: records.length,
          tileBuilder: (context, index) =>
              _ExceptionTile(record: records[index]),
        );
      },
    );
  }
}

class _ExceptionTile extends StatelessWidget with FTileMixin {
  const _ExceptionTile({required this.record});

  final ExceptionLogRecord record;

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: Text(record.message, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(_subtitle(record)),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ExceptionDetailPage(record: record),
        ),
      ),
    );
  }
}

class _ExceptionDetailPage extends StatelessWidget {
  const _ExceptionDetailPage({required this.record});

  final ExceptionLogRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final text = record.reportText;
    return FScaffold(
      childPad: true,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(FLucideIcons.arrowLeft, size: 24),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Exception',
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    showFToast(
                      context: context,
                      title: const Text('Detail disalin'),
                    );
                  },
                  child: const Icon(FLucideIcons.copy, size: 20),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(text, style: theme.typography.sm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExceptions extends StatelessWidget {
  const _EmptyExceptions();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Text(
        'Belum ada exception',
        style: theme.typography.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

String _subtitle(ExceptionLogRecord record) {
  final local = record.at.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final clock = '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  if (record.count <= 1) return clock;
  return '$clock · ${record.count} kali';
}
