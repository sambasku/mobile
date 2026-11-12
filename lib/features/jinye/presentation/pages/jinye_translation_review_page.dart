import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';

/// Antrian usulan terjemahan Jinye untuk verifikator.
class JinyeTranslationReviewPage extends ConsumerStatefulWidget {
  const JinyeTranslationReviewPage({super.key});

  @override
  ConsumerState<JinyeTranslationReviewPage> createState() =>
      _JinyeTranslationReviewPageState();
}

class _JinyeTranslationReviewPageState
    extends ConsumerState<JinyeTranslationReviewPage> {
  String _status = 'pending';
  String? _busyId;

  Future<void> _resolve(JinyeTranslation row, String action) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busyId = row.id);
    try {
      await ref.read(jinyeRepositoryProvider).resolveTranslation(
            translationId: row.id,
            action: action,
          );
      if (!mounted) return;
      ref.invalidate(jinyeTranslationQueueProvider(_status));
      ref.invalidate(jinyeTranslationsProvider(row.reffId));
      showFToast(
        context: context,
        title: Text(
          action == 'approve'
              ? l10n.jinyeTranslateResolveApproved
              : l10n.jinyeTranslateResolveRejected,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : null;
      await showAppErrorSheet(
        context,
        message: msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeTranslateResolveFailed,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: l10n.jinyeTranslateResolveFailed,
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(jinyeTranslationQueueProvider(_status));

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.jinyeTranslateReviewTitle),
        prefixes: [
          FHeaderAction.back(onPress: () => context.pop()),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final s in const ['pending', 'accepted', 'rejected'])
                  FButton(
                    variant: _status == s
                        ? FButtonVariant.primary
                        : FButtonVariant.outline,
                    onPress: () => setState(() => _status = s),
                    child: Text(switch (s) {
                      'pending' => l10n.jinyeTranslateStatusPending,
                      'accepted' => l10n.jinyeTranslateStatusAccepted,
                      _ => l10n.jinyeTranslateStatusRejected,
                    }),
                  ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.jinyeTranslateReviewLoadFailed),
                ),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.jinyeTranslateReviewEmpty,
                        style: theme.typography.body.md.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Gap(8),
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    final busy = _busyId == row.id;
                    final source = row.sourceBody.trim();
                    return FTileGroup(
                      children: [
                        FTile(
                          title: Text(
                            source.isEmpty
                                ? l10n.jinyeTranslateReviewSourceId(row.reffId)
                                : source,
                          ),
                          subtitle: Text(l10n.jinyeTranslateReviewSourceLabel),
                          onPress: () =>
                              context.push(JinyeRouter.detailPath(row.reffId)),
                        ),
                        FTile(
                          title: Text(row.body),
                          subtitle: Text(l10n.jinyeTranslateReviewBodyLabel),
                          onPress: () =>
                              context.push(JinyeRouter.detailPath(row.reffId)),
                        ),
                        if (row.isPending) ...[
                          FTile(
                            title: Text(l10n.jinyeTranslateApproveAction),
                            suffix: busy
                                ? const FCircularProgress()
                                : null,
                            onPress: busy
                                ? null
                                : () => _resolve(row, 'approve'),
                          ),
                          FTile(
                            title: Text(l10n.jinyeTranslateRejectAction),
                            onPress: busy
                                ? null
                                : () => _resolve(row, 'reject'),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
