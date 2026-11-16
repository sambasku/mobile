import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../karya_providers.dart';

class KaryaProposalsPage extends ConsumerWidget {
  const KaryaProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(karyaMineProvider);
    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.karyaProposalsTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => Center(child: Text(l10n.karyaLoadFailed)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.karyaProposalsEmpty));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              FTileGroup(
                children: [
                  for (final item in items)
                    FTile(
                      title: Text(item.title),
                      subtitle: Text(
                        '${_kindLabel(l10n, item.kind)}\n${_status(l10n, item.status)}${item.revisionNote == null ? '' : '\n${item.revisionNote}'}',
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _status(AppLocalizations l10n, String status) => switch (status) {
        'pending' => l10n.karyaStatusPending,
        'needs_revision' => l10n.karyaStatusRevision,
        'approved' => l10n.karyaStatusApproved,
        'rejected' => l10n.karyaStatusRejected,
        _ => status,
      };

  String _kindLabel(AppLocalizations l10n, String kind) => switch (kind) {
        'new' => l10n.karyaProposalKindNew,
        'edit' => l10n.karyaProposalKindEdit,
        'excerpt' => l10n.karyaProposalKindExcerpt,
        _ => kind,
      };
}