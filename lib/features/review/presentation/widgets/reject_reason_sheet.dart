import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Alasan penolakan umum. Chip mengirim teks label sebagai comment API.
/// Dipakai deck review (`review_session_page`) dan approve-in-place
/// dari detail kata (`word_detail_page`) - satu sumber kebenaran.
List<String> rejectReasons(AppLocalizations l10n) => [
  l10n.reviewRejectReasonInaccurate,
  l10n.reviewRejectReasonSpelling,
  l10n.reviewRejectReasonDuplicate,
  l10n.reviewRejectReasonIrrelevant,
  l10n.reviewRejectReasonMedia,
  l10n.reviewRejectReasonInappropriate,
  l10n.reviewRejectReasonIncomplete,
  l10n.reviewRejectReasonOther,
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

  bool _isOther(AppLocalizations l10n) =>
      _selected == l10n.reviewRejectReasonOther;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) return;
    if (_isOther(AppLocalizations.of(context))) {
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
    final isOther = _isOther(AppLocalizations.of(context));
    final canSubmit =
        _selected != null && (!isOther || _controller.text.trim().isNotEmpty);
    // Chip + field alasan Lainnya + keyboard mudah melebihi tinggi layar.
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
                AppLocalizations.of(context).reviewRejectSheetTitle,
                style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              const Gap(4),
              Text(
                AppLocalizations.of(context).reviewRejectSheetBody,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final reason in rejectReasons(AppLocalizations.of(context)))
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
              if (isOther) ...[
                const Gap(16),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _controller,
                    onChange: (_) => setState(() {}),
                  ),
                  label: Text(AppLocalizations.of(context).reviewRejectReasonLabel),
                  hint: AppLocalizations.of(context).reviewRejectReasonHint,
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
                      child: Text(AppLocalizations.of(context).commonCancel),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.destructive,
                      onPress: canSubmit ? _submit : null,
                      child: Text(AppLocalizations.of(context).commonReject),
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