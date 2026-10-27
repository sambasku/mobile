import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/pantun_api.dart';
import '../../domain/pantun_models.dart';

/// Alasan laporan pantun. `reason_code` mengikuti kontrak API
/// (`pantun_reports.reason_code`).
List<(String, String)> _reasons(AppLocalizations l10n) => [
  ('inappropriate', l10n.reportPantunInappropriate),
  ('sexual', l10n.reportPantunSexual),
  ('harassment', l10n.reportPantunHarassment),
  ('hate_speech', l10n.reportPantunHateSpeech),
  ('spam', l10n.reportPantunSpam),
  ('other', l10n.reportPantunOther),
];

/// Bottom sheet lapor pantun/balasan. true = laporan terkirim.
Future<bool> showPantunReportSheet(
  BuildContext context, {
  required String targetType,
  required String targetId,
}) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        _PantunReportSheet(targetType: targetType, targetId: targetId),
  );
  return sent ?? false;
}

/// Alur lapor dari UI: tamu diarahkan login, lalu sheet, lalu toast sukses.
Future<void> reportPantunFromUi(
  BuildContext context,
  WidgetRef ref, {
  required String targetType,
  required String targetId,
}) async {
  final auth = await ref.read(authStatusProvider.future);
  if (!auth.isAuth) {
    if (!context.mounted) return;
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).reportPantunLoginFirst),
    );
    await context.push('/login');
    return;
  }
  if (!context.mounted) return;

  final sent = await showPantunReportSheet(
    context,
    targetType: targetType,
    targetId: targetId,
  );
  if (!sent || !context.mounted) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).reportPantunSent),
    variant: FToastVariant.primary,
  );
}

class _PantunReportSheet extends ConsumerStatefulWidget {
  const _PantunReportSheet({
    required this.targetType,
    required this.targetId,
  });

  final String targetType;
  final String targetId;

  @override
  ConsumerState<_PantunReportSheet> createState() => _PantunReportSheetState();
}

class _PantunReportSheetState extends ConsumerState<_PantunReportSheet> {
  String _reason = 'inappropriate';
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final note = _note.text.trim();
    if (_reason == 'other' && note.isEmpty) {
      showFToast(context: context, title: Text(l10n.reportNoteRequiredToast));
      return;
    }

    setState(() => _sending = true);
    try {
      await ref.read(pantunApiProvider).report(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reasonCode: _reason,
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PantunFailure catch (error) {
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
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final noteRequired = _reason == 'other';

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.reportPantunTitle,
            style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(4),
          Text(
            l10n.reportPantunSubtitle,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final reason in _reasons(l10n))
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
              hintText: noteRequired
                  ? l10n.reportNoteLabelRequired
                  : l10n.reportNoteLabelOptional,
            ),
          ),
          const Gap(8),
          FButton(
            onPress: _sending ? null : _submit,
            child: Text(
              _sending ? l10n.reportSubmitting : l10n.reportSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
