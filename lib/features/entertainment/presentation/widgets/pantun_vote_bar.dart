import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/pantun_models.dart';

/// Bar vote pantun/balasan: guard login + toast error, state dari pemanggil.
///
/// Caller menyediakan [onToggle] (controller feed/detail) supaya widget ini
/// tidak perlu tahu sumber data -- satu tempat guard, dua permukaan.
class PantunVoteBar extends ConsumerWidget {
  const PantunVoteBar({
    super.key,
    required this.pantun,
    required this.onToggle,
  });

  final Pantun pantun;

  /// Toggle vote; return pesan error (null = sukses).
  final Future<String?> Function(Pantun pantun, int value) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VoteButtons(
      upvotes: pantun.upvotes,
      downvotes: pantun.downvotes,
      myVote: pantun.myVote,
      compact: true,
      onVote: (value) => _vote(context, ref, value),
    );
  }

  Future<void> _vote(BuildContext context, WidgetRef ref, int value) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).pantunVoteLoginRequired),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }

    final error = await onToggle(pantun, value);
    if (error != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(error),
        variant: FToastVariant.destructive,
      );
    }
  }
}
