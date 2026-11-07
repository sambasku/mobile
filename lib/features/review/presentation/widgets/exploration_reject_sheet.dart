import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/exploration_proposal.dart';
import '../../domain/exploration_reject_reasons.dart';

class ExplorationRejectResult {
  const ExplorationRejectResult({
    required this.reasonCode,
    this.reasonText,
  });

  final String reasonCode;
  final String? reasonText;
}

Future<ExplorationRejectResult?> showExplorationRejectSheet(
  BuildContext context, {
  required ExplorationReviewDomain domain,
}) {
  return showModalBottomSheet<ExplorationRejectResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _ExplorationRejectSheet(domain: domain),
  );
}

class _ExplorationRejectSheet extends StatefulWidget {
  const _ExplorationRejectSheet({required this.domain});

  final ExplorationReviewDomain domain;

  @override
  State<_ExplorationRejectSheet> createState() =>
      _ExplorationRejectSheetState();
}

class _ExplorationRejectSheetState extends State<_ExplorationRejectSheet> {
  final _controller = TextEditingController();
  String? _selectedCode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final code = _selectedCode;
    if (code == null) return;
    final isOther = code == 'other';
    final text = _controller.text.trim();
    if (isOther && text.length < 3) return;
    Navigator.pop(
      context,
      ExplorationRejectResult(
        reasonCode: code,
        reasonText: isOther || text.isNotEmpty ? text : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final bottom = media.viewInsets.bottom;
    final reasons = explorationRejectReasons(widget.domain, l10n);
    final isOther = _selectedCode == 'other';
    final canSubmit = _selectedCode != null &&
        (!isOther || _controller.text.trim().length >= 3);
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
                l10n.reviewExploreRejectSheetTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                l10n.reviewExploreRejectSheetBody,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final reason in reasons)
                    GestureDetector(
                      onTap: () => setState(() => _selectedCode = reason.code),
                      child: FBadge(
                        variant: _selectedCode == reason.code
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(reason.label),
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
                  label: Text(l10n.reviewExploreRejectOtherNoteLabel),
                  hint: l10n.reviewExploreRejectOtherNoteHint,
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
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.destructive,
                      onPress: canSubmit ? () => _submit(l10n) : null,
                      child: Text(l10n.commonReject),
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
