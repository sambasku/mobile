import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'change_history_timeline.dart';

/// Halaman penuh timeline riwayat perubahan satu data eksplorasi (wisata,
/// kuliner, dst). [path] = endpoint `.../change-history`.
class EntityChangeHistoryPage extends StatelessWidget {
  const EntityChangeHistoryPage({
    super.key,
    required this.path,
    this.fallbackLocation = '/explore',
  });

  final String path;

  /// Tujuan back saat tidak ada stack (deep link).
  final String fallbackLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.historyTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go(fallbackLocation),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          ChangeHistoryTimeline(
            path: path,
            notFoundTitle: l10n.historyEntityNotFound,
            emptyHint: l10n.historyEmptyHintEntity,
          ),
        ],
      ),
    );
  }
}
