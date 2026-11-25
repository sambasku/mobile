import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/word_approved_badge_icon.dart';
import '../../dictionary_router.dart';
import '../../domain/entities/word_summary.dart';
import '../dictionary_labels.dart';
import '../providers/lemma_merge_selection_provider.dart';

typedef LemmaMergeSubtitleBuilder = String? Function(
  BuildContext context,
  WordSummary item,
);

class LemmaMergeWordTile extends ConsumerWidget {
  const LemmaMergeWordTile({
    super.key,
    required this.item,
    required this.subtitleBuilder,
  });

  final WordSummary item;
  final LemmaMergeSubtitleBuilder subtitleBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sel = ref.watch(lemmaMergeSelectionProvider);
    final notifier = ref.read(lemmaMergeSelectionProvider.notifier);
    final subtitle = subtitleBuilder(context, item);
    final selected = sel.selected.containsKey(item.id);

    Widget suffix;
    if (sel.active) {
      suffix = FCheckbox(
        value: selected,
        onChange: (_) => notifier.toggle(item),
      );
    } else {
      suffix = item.isVerified
          ? const WordApprovedBadgeIcon()
          : const PendingReviewBadgeIcon();
    }

    return Semantics(
      label: l10n.lemmaMergeHoldHint(item.lemma),
      child: GestureDetector(
        onLongPress: () {
          if (!sel.active) {
            notifier.startWith(item);
          } else {
            notifier.toggle(item);
          }
        },
        child: FTile(
          title: Text(item.lemma),
          subtitle: subtitle != null ? Text(subtitle) : null,
          suffix: suffix,
          onPress: () {
            if (sel.active) {
              notifier.toggle(item);
              return;
            }
            FocusManager.instance.primaryFocus?.unfocus();
            context.push(DictionaryRouter.detail.path.replaceFirst(':id', item.id));
          },
        ),
      ),
    );
  }
}

String? defaultWordTileSubtitle(BuildContext context, WordSummary item) {
  final gloss = item.sense?.trim();
  if (gloss != null && gloss.isNotEmpty) return gloss;
  if (item.wordType != 'word') {
    return wordSummaryTypeLabel(item, AppLocalizations.of(context));
  }
  return null;
}