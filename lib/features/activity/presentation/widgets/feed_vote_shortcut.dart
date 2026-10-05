import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';

/// Shortcut vote inline di baris feed kind=vote (target kata).
///
/// Bungkus [VoteButtons] + [voteControllerProvider]: counts/myVote dimuat
/// per kata, toggle memakai jalur yang sama dengan detail (toast failure,
/// analytics vote_cast dari VoteController). Tamu: toast + push /login,
/// pola `_WordVoteBar._vote`.
class FeedVoteShortcut extends ConsumerWidget {
  const FeedVoteShortcut({super.key, required this.wordId});

  final String wordId;

  Future<void> _vote(
    BuildContext context,
    WidgetRef ref,
    VoteTarget target,
    int value,
  ) async {
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
        .read(voteControllerProvider(target).notifier)
        .toggle(value);
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = VoteTarget(type: 'word', id: wordId);
    final async = ref.watch(voteControllerProvider(target));

    return async.when(
      loading: () => const Skeletonizer(
        enabled: true,
        child: VoteButtonsSkeleton(compact: true),
      ),
      // Error muat: tanpa shortcut, CTA baris tetap navigasi.
      error: (_, _) => const SizedBox.shrink(),
      data: (view) => VoteButtons(
        upvotes: view.upvotes,
        downvotes: view.downvotes,
        myVote: view.myVote,
        compact: true,
        onVote: (value) => _vote(context, ref, target, value),
      ),
    );
  }
}
