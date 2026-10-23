import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../providers/meaning_vote_providers.dart';
import 'vote_buttons.dart';

/// Tombol vote untuk satu baris makna (upvote/downvote + jumlah).
///
/// State diambil dari [MeaningVotesController] (batch per kata, bukan
/// per makna) supaya N makna = 2 request, bukan 2×N.
class MeaningVoteRow extends ConsumerWidget {
  const MeaningVoteRow({super.key, required this.meaningId});

  final String meaningId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meaningVotesControllerProvider);

    return VoteButtons(
      upvotes: state.upvotesOf(meaningId),
      downvotes: state.downvotesOf(meaningId),
      myVote: state.myVoteOf(meaningId),
      compact: true,
      onVote: (value) => _vote(context, ref, value),
    );
  }

  Future<void> _vote(BuildContext context, WidgetRef ref, int value) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk memberi vote'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(meaningVotesControllerProvider.notifier)
        .toggle(meaningId, value);
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }
}
