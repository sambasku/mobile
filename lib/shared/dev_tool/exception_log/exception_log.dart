import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/app_router.dart';

/// Satu exception yang tidak tertangkap, atau beberapa duplikat beruntun.
class ExceptionLogRecord {
  const ExceptionLogRecord({
    required this.at,
    required this.message,
    required this.stack,
    this.count = 1,
  });

  final DateTime at;
  final String message;
  final String stack;
  final int count;

  ExceptionLogRecord copyWith({DateTime? at, int? count}) {
    return ExceptionLogRecord(
      at: at ?? this.at,
      message: message,
      stack: stack,
      count: count ?? this.count,
    );
  }

  /// Teks untuk salin / bagikan ke tim developer.
  String get reportText {
    final body = stack.isEmpty ? message : '$message\n\n$stack';
    if (count <= 1) return body;
    return '$body\n($count kali)';
  }
}

/// Ring buffer in-memory. Terbaru di index 0.
class ExceptionLogBuffer {
  ExceptionLogBuffer({
    this.capacity = 50,
    this.dedupeWindow = const Duration(seconds: 2),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final int capacity;

  /// ponytail: jendela dihitung dari kejadian terakhir, supaya overflow tiap
  /// frame jadi satu baris. Upgrade: hash stack dan buang overflow framework.
  final Duration dedupeWindow;

  final DateTime Function() _clock;

  final ValueNotifier<List<ExceptionLogRecord>> records = ValueNotifier(
    const [],
  );

  void add(Object error, StackTrace? stack) {
    final message = error.toString();
    final stackText = stack?.toString() ?? '';
    final now = _clock();
    final current = records.value;
    if (current.isNotEmpty) {
      final head = current.first;
      final gap = now.difference(head.at);
      if (head.message == message && !gap.isNegative && gap <= dedupeWindow) {
        records.value = [
          head.copyWith(at: now, count: head.count + 1),
          ...current.skip(1),
        ];
        return;
      }
    }
    final next = [
      ExceptionLogRecord(at: now, message: message, stack: stackText),
      ...current,
    ];
    records.value = next.length > capacity ? next.sublist(0, capacity) : next;
  }

  void clear() {
    if (records.value.isEmpty) return;
    records.value = const [];
  }
}

/// Buffer bersama inspector dan hook. Hanya diisi saat hook terpasang.
abstract final class ExceptionLog {
  static final buffer = ExceptionLogBuffer();
}

bool _installed = false;
bool _sheetOpen = false;
bool _pumpScheduled = false;
int _sheetWaitFrames = 0;
Object? _pendingError;
String _pendingStack = '';

/// ponytail: berhenti menunggu navigator setelah ~2 detik. Record tetap di log.
/// Upgrade: dengarkan [AppRouter.rootNavigatorKey] sampai overlay terpasang.
const _maxSheetWaitFrames = 120;

/// Pasang hook exception. Panggil sekali setelah flavor di-set, hanya staging.
void installStagingExceptionLog() {
  if (_installed) return;
  _installed = true;

  final previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    (previous ?? FlutterError.presentError)(details);
    _capture(details.exception, details.stack);
  };

  final previousPlatform = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _capture(error, stack);
    final handled = previousPlatform?.call(error, stack) ?? false;
    if (!handled) {
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    }
    return true;
  };
}

void _capture(Object error, StackTrace? stack) {
  ExceptionLog.buffer.add(error, stack);
  if (_sheetOpen) return;
  _pendingError = error;
  _pendingStack = stack?.toString() ?? '';
  _sheetWaitFrames = 0;
  _pumpSheet();
}

void _pumpSheet() {
  if (_pumpScheduled || _sheetOpen || _pendingError == null) return;
  _pumpScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pumpScheduled = false;
    if (_sheetOpen || _pendingError == null) return;
    final context = AppRouter.rootNavigatorKey.currentState?.overlay?.context;
    if (context == null || !context.mounted) {
      _sheetWaitFrames++;
      if (_sheetWaitFrames < _maxSheetWaitFrames) _pumpSheet();
      return;
    }
    final message = _pendingError.toString();
    final stack = _pendingStack;
    _pendingError = null;
    _pendingStack = '';
    _sheetOpen = true;
    _showExceptionSheet(context, message: message, stack: stack).whenComplete(
      () {
        _sheetOpen = false;
      },
    );
  });
}

const _genericMessage =
    'Aplikasi menemukan masalah. Detail bisa dikirim ke tim developer.';

Future<void> _showExceptionSheet(
  BuildContext context, {
  required String message,
  required String stack,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _ExceptionSheet(message: message, stack: stack);
    },
  );
}

class _ExceptionSheet extends StatefulWidget {
  const _ExceptionSheet({required this.message, required this.stack});

  final String message;
  final String stack;

  @override
  State<_ExceptionSheet> createState() => _ExceptionSheetState();
}

class _ExceptionSheetState extends State<_ExceptionSheet> {
  bool _showDetail = false;

  String get _report {
    if (widget.stack.isEmpty) return widget.message;
    return '${widget.message}\n\n${widget.stack}';
  }

  Future<void> _share(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 1, 1);
    await SharePlus.instance.share(
      ShareParams(text: _report, sharePositionOrigin: origin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Terjadi kesalahan',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                _genericMessage,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (_showDetail) ...[
                const Gap(12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _report,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ],
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => setState(() => _showDetail = !_showDetail),
                child: Text(
                  _showDetail ? 'Sembunyikan detail' : 'Lihat detail',
                ),
              ),
              const Gap(8),
              Builder(
                builder: (buttonContext) {
                  return FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => _share(buttonContext),
                    child: const Text('Bagikan'),
                  );
                },
              ),
              const Gap(8),
              FButton(
                onPress: () => Navigator.of(context).pop(),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
