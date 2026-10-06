import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Alasan penolakan umum. Chip mengirim teks label sebagai comment API.
/// Dipakai deck review (`review_session_page`) dan approve-in-place
/// dari detail kata (`word_detail_page`) - satu sumber kebenaran.
const kRejectReasons = <String>[
  'Kurang akurat',
  'Ejaan atau penulisan salah',
  'Duplikat entri yang sudah ada',
  'Tidak relevan',
  'Media (gambar/audio) tidak sesuai',
  'Konten tidak pantas',
  'Informasi kurang lengkap',
  'Lainnya',
];

/// Tampilkan sheet pemilih alasan penolakan. Kembalikan teks alasan, atau
/// `null` bila user membatalkan.
Future<String?> showRejectReasonSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => const _RejectReasonSheet(),
  );
}

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _controller = TextEditingController();
  String? _selected;

  bool get _isOther => _selected == 'Lainnya';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) return;
    if (_isOther) {
      final text = _controller.text.trim();
      if (text.isEmpty) return;
      Navigator.pop(context, text);
      return;
    }
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    final bottom = media.viewInsets.bottom;
    final canSubmit =
        _selected != null && (!_isOther || _controller.text.trim().isNotEmpty);
    // Chip + field "Lainnya" + keyboard mudah melebihi tinggi layar.
    final maxHeight = (media.size.height - bottom) * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const Gap(16),
              Text(
                'Tolak usulan',
                style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              const Gap(4),
              Text(
                'Pilih alasan agar kontributor tahu apa yang perlu diperbaiki.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final reason in kRejectReasons)
                    GestureDetector(
                      onTap: () => setState(() => _selected = reason),
                      child: FBadge(
                        variant: _selected == reason
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(reason),
                      ),
                    ),
                ],
              ),
              if (_isOther) ...[
                const Gap(16),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _controller,
                    onChange: (_) => setState(() {}),
                  ),
                  label: const Text('Alasan penolakan'),
                  hint: 'Jelaskan alasan penolakan',
                  maxLines: 4,
                  autofocus: true,
                ),
              ],
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.destructive,
                      onPress: canSubmit ? _submit : null,
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}