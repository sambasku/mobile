import 'dart:async';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Satu pilihan dari GET /api/v1/lemma-definitions/lookup → suggestions[].
class KbbiSuggestion {
  const KbbiSuggestion({
    required this.id,
    required this.lemma,
    required this.homonymIndex,
    required this.senseIndex,
    required this.definition,
    this.wordClassCode,
    this.wordClassLabel,
  });

  final String id;
  final String lemma;
  final int homonymIndex;
  final int senseIndex;
  final String definition;
  final String? wordClassCode;
  final String? wordClassLabel;
}

/// Bottom sheet: cari lemma Indonesia via API kita, pilih satu definisi.
/// Pencarian debounce 400 ms (tanpa tombol Cari). List di-scroll (bisa
/// 100+ sense) - header tetap, body `Expanded` + ListView.builder.
Future<KbbiSuggestion?> showKbbiDefinitionSheet(
  BuildContext context, {
  required Dio dio,
  String initialLemma = '',
}) {
  return showModalBottomSheet<KbbiSuggestion>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _KbbiDefinitionSheetBody(dio: dio, initialLemma: initialLemma);
    },
  );
}

class _KbbiDefinitionSheetBody extends StatefulWidget {
  const _KbbiDefinitionSheetBody({
    required this.dio,
    required this.initialLemma,
  });

  final Dio dio;
  final String initialLemma;

  @override
  State<_KbbiDefinitionSheetBody> createState() =>
      _KbbiDefinitionSheetBodyState();
}

class _KbbiDefinitionSheetBodyState extends State<_KbbiDefinitionSheetBody> {
  static const _debounceMs = 400;

  late final TextEditingController _lemmaCtrl;
  Timer? _debounce;
  int _reqId = 0;
  bool _loading = false;
  String? _error;
  bool _searched = false;
  List<KbbiSuggestion> _items = const [];

  @override
  void initState() {
    super.initState();
    _lemmaCtrl = TextEditingController(text: widget.initialLemma);
    _lemmaCtrl.addListener(_onLemmaChanged);
    if (widget.initialLemma.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSearch());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _lemmaCtrl.removeListener(_onLemmaChanged);
    _lemmaCtrl.dispose();
    super.dispose();
  }

  void _onLemmaChanged() => _scheduleSearch();

  void _scheduleSearch() {
    _debounce?.cancel();
    final q = _lemmaCtrl.text.trim();
    if (q.isEmpty) {
      _reqId++;
      setState(() {
        _loading = false;
        _error = null;
        _searched = false;
        _items = const [];
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      _search,
    );
  }

  Future<void> _search() async {
    final q = _lemmaCtrl.text.trim();
    if (q.isEmpty) return;

    final reqId = ++_reqId;
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });

    try {
      final resp = await widget.dio.get<dynamic>(
        '/api/v1/lemma-definitions/lookup',
        queryParameters: <String, dynamic>{'lemma': q},
      );
      if (!mounted || reqId != _reqId) return;

      final data = resp.data;
      if (data is! Map<String, dynamic>) {
        throw StateError('Response tidak valid');
      }
      if (data['success'] != true) {
        final msg = data['message']?.toString();
        throw StateError(
          (msg != null && msg.isNotEmpty)
              ? msg
              : 'Gagal mengambil definisi KBBI',
        );
      }
      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        throw StateError('Response tidak valid');
      }
      final suggestions = payload['suggestions'];
      final list = <KbbiSuggestion>[];
      if (suggestions is List) {
        for (final raw in suggestions) {
          if (raw is! Map<String, dynamic>) continue;
          final definition = raw['definition']?.toString().trim() ?? '';
          if (definition.isEmpty) continue;
          list.add(
            KbbiSuggestion(
              id: raw['id']?.toString() ?? '',
              lemma: raw['lemma']?.toString() ?? q,
              homonymIndex: (raw['homonym_index'] as num?)?.toInt() ?? 1,
              senseIndex: (raw['sense_index'] as num?)?.toInt() ?? 1,
              definition: definition,
              wordClassCode: raw['word_class_code']?.toString(),
              wordClassLabel: raw['word_class_label']?.toString(),
            ),
          );
        }
      }
      setState(() {
        _items = list;
        _loading = false;
        _error = null;
      });
    } on DioException catch (e) {
      if (!mounted || reqId != _reqId) return;
      final body = e.response?.data;
      String message = 'Gagal mengambil definisi KBBI';
      if (body is Map && body['message'] is String) {
        message = body['message'] as String;
      } else if (e.response?.statusCode == 401) {
        message = 'Sesi berakhir - masuk lagi untuk memakai KBBI';
      }
      setState(() {
        _loading = false;
        _error = message;
        _items = const [];
      });
    } catch (e) {
      if (!mounted || reqId != _reqId) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _items = const [];
      });
    }
  }

  /// Tinggi sheet: ~75% layar, sisakan ruang keyboard + safe area.
  double _sheetHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final target = available * 0.75;
    return target.clamp(280.0, available);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final height = _sheetHeight(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.bookOpen,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Ambil definisi dari KBBI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Ketik kata Indonesia - hasil muncul otomatis. Pilih satu untuk mengisi form.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FTextField(
                control: FTextFieldControl.managed(controller: _lemmaCtrl),
                hint: 'mis. makan, rumah',
                textInputAction: TextInputAction.search,
                // Enter = cari sekarang (skip sisa debounce).
                onSubmit: (_) {
                  _debounce?.cancel();
                  _search();
                },
                suffixBuilder: _loading
                    ? (context, style, _) => Padding(
                        padding: style.clearButtonPadding,
                        child: const FCircularProgress(size: .sm),
                      )
                    : null,
              ),
            ),
            if (_error != null) ...[
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(
                    _error!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            if (_searched && !_loading && _items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  '${_items.length} definisi - gulir untuk melihat semua',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ),
            const Gap(8),
            Expanded(
              child: _loading
                  ? const Center(child: FCircularProgress())
                  : !_searched
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Ketik kata untuk mencari di KBBI',
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : _items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Tidak ditemukan di KBBI',
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _KbbiSuggestionTile(
                          item: item,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KbbiSuggestionTile extends StatelessWidget {
  const _KbbiSuggestionTile({required this.item, required this.onTap});

  final KbbiSuggestion item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final meta = [
      item.lemma,
      'makna ${item.homonymIndex}.${item.senseIndex}',
      if (item.wordClassLabel != null && item.wordClassLabel!.isNotEmpty)
        item.wordClassLabel!,
    ].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.definition,
                      style: theme.typography.body.sm,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
