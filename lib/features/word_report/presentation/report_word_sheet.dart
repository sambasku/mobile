import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../data/word_report_providers.dart';
import '../data/word_report_repository.dart';

const _reasons = <(String, String)>[
  ('not_sambas', 'Bukan kosakata Sambas'),
  ('inaccurate', 'Arti atau ejaan salah'),
  ('duplicate', 'Duplikat entri lain'),
  ('inappropriate', 'Tidak pantas'),
  ('spam', 'Spam'),
  ('other', 'Lainnya'),
];

/// Alasan khusus pelaporan gambar. Ditampilkan ketika [imageId] diisi.
/// `reason_code` tetap `violent_image` (kontrak API); pilihan user
/// ditambahkan ke note supaya verifikator tahu keluhannya.
const _imageReasons = <(String, String)>[
  ('kekerasan', 'Foto berisi kekerasan'),
  ('seksual', 'Foto berisi konten seksual'),
  ('tidak_pantas', 'Foto tidak pantas'),
];

Future<bool> showReportWordSheet(
  BuildContext context,
  String wordId, {

  /// Saat diisi, sheet menampilkan alasan khusus gambar (mis. kekerasan).
  String? imageId,
}) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) =>
        _ReportWordSheet(wordId: wordId, imageId: imageId),
  );
  return sent ?? false;
}

class _ReportWordSheet extends ConsumerStatefulWidget {
  const _ReportWordSheet({required this.wordId, this.imageId});

  final String wordId;

  /// Saat diisi, laporan merujuk ke gambar tertentu.
  final String? imageId;

  @override
  ConsumerState<_ReportWordSheet> createState() => _ReportWordSheetState();
}

class _ReportWordSheetState extends ConsumerState<_ReportWordSheet> {
  late String _reason;
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Saat imageId ada, mulai dari alasan kekerasan gambar.
    _reason = widget.imageId != null ? 'kekerasan' : 'inappropriate';
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _noteRequired => _reason == 'other' || _reason == 'duplicate';

  Future<void> _submit() async {
    final note = _note.text.trim();
    if (_noteRequired && note.isEmpty) {
      showFToast(
        context: context,
        title: const Text('Catatan wajib diisi untuk alasan ini'),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      // Laporan foto: keluhan chip ditambahkan ke catatan; reason_code yang
      // dikirim tetap violent_image sesuai kontrak API.
      final isImage = widget.imageId != null;
      final chipNote = isImage
          ? _imageReasons.firstWhere((r) => r.$1 == _reason).$2
          : null;
      await ref
          .read(wordReportRepositoryProvider)
          .submit(
            wordId: widget.wordId,
            reasonCode: isImage ? 'violent_image' : _reason,
            note: chipNote == null
                ? note
                : note.isEmpty
                ? chipNote
                : '$chipNote. Catatan: $note',
            imageId: widget.imageId,
          );
      if (!mounted) return;
      AnalyticsService.instance.log(
        AnalyticsEvents.reportWordSubmit,
        params: {'word_id': widget.wordId},
      );
      Navigator.of(context).pop(true);
    } on WordReportFailure catch (error) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(error.message),
        variant: FToastVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.imageId != null ? 'Laporkan foto' : 'Laporkan entri',
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(4),
          Text(
            widget.imageId != null
                ? 'Laporkan foto ini ke tim Sambasku untuk ditinjau.'
                : 'Untuk entri yang tidak layak tayang. Perbaikan isi tetap lewat Usulkan perubahan.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final reason
                  in widget.imageId != null ? _imageReasons : _reasons)
                GestureDetector(
                  onTap: _sending
                      ? null
                      : () => setState(() => _reason = reason.$1),
                  child: FBadge(
                    variant: _reason == reason.$1
                        ? FBadgeVariant.primary
                        : FBadgeVariant.secondary,
                    child: Text(reason.$2),
                  ),
                ),
            ],
          ),
          const Gap(12),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: _noteRequired ? 'Catatan wajib' : 'Catatan (opsional)',
            ),
          ),
          const Gap(8),
          FButton(
            onPress: _sending ? null : _submit,
            child: Text(_sending ? 'Mengirim...' : 'Kirim laporan'),
          ),
        ],
      ),
    );
  }
}
