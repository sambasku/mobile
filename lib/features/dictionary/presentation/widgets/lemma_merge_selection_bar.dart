import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/lemma_merge_remote.dart';
import '../providers/lemma_merge_selection_provider.dart';
import 'lemma_merge_submit_sheet.dart';

class LemmaMergeSelectionBar extends ConsumerWidget {
  const LemmaMergeSelectionBar({super.key});

  bool _isVerifier(String? role) =>
      role == 'admin' || role == 'root' || role == 'reviewer';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sel = ref.watch(lemmaMergeSelectionProvider);
    if (!sel.active) return const SizedBox.shrink();

    final count = sel.selected.length;
    final canContinue = count >= 2;

    return SafeArea(
      top: false,
      child: Material(
        elevation: 4,
        color: context.theme.colors.background,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              FButton(
                variant: FButtonVariant.outline,
                onPress: () {
                  ref.read(lemmaMergeSelectionProvider.notifier).cancel();
                },
                child: Text(l10n.lemmaMergeCancel),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.lemmaMergeSelectedCount(count),
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.sm,
                ),
              ),
              FButton(
                onPress: !canContinue
                    ? null
                    : () async {
                        final auth = ref.read(authStatusProvider).asData?.value;
                        if (auth == null || !auth.isAuth) {
                          await showAppErrorSheet(
                            context,
                            message: l10n.lemmaMergeNeedLogin,
                          );
                          return;
                        }
                        final items = sel.selected.values.toList();
                        final sheet = await showLemmaMergeSubmitSheet(
                          context,
                          items: items,
                          requireReason: !_isVerifier(auth.role),
                        );
                        if (sheet == null || !context.mounted) return;
                        final mergeIds = items
                            .map((w) => w.id)
                            .where((id) => id != sheet.keepWordId)
                            .toList();
                        try {
                          final remote = LemmaMergeRemote(ref.read(dioProvider));
                          final result = await remote.create(
                            keepWordId: sheet.keepWordId,
                            mergeWordIds: mergeIds,
                            reasonText: sheet.reasonText,
                          );
                          if (!context.mounted) return;
                          ref.read(lemmaMergeSelectionProvider.notifier).cancel();
                          showFToast(
                            context: context,
                            title: Text(result.message),
                          );
                        } on DioException catch (e) {
                          if (!context.mounted) return;
                          final data = e.response?.data;
                          final msg = data is Map ? data['message'] as String? : null;
                          await showAppErrorSheet(
                            context,
                            message: msg ?? l10n.lemmaDatasetUpdateFailed,
                          );
                        }
                      },
                child: Text(l10n.lemmaMergeContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}