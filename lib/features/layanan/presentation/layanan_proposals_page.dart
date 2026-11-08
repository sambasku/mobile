import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import 'layanan_providers.dart';

class LayananProposalsPage extends ConsumerWidget {
  const LayananProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(layananMineProvider);
    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.layananMyProposals),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => Center(child: Text(l10n.layananLoadFailed)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.layananProposalsEmpty));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              FTileGroup(
                children: [
                  for (final item in items)
                    FTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.phones.map((p) => p.phone).join(', ')}\n${_status(l10n, item.status)}${item.revisionNote == null ? '' : '\n${item.revisionNote}'}',
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
    'pending' => l10n.layananStatusPending,
    'needs_revision' => l10n.layananStatusRevision,
    'approved' => l10n.layananStatusApproved,
    'rejected' => l10n.layananStatusRejected,
    _ => status,
  };
}
