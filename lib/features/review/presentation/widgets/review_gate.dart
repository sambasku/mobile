import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/review_access.dart';
import '../pages/review_forbidden_page.dart';

enum ReviewGateMode {
  /// Hub: kontribusi dan/atau diskusi.
  home,
  /// Antrean kontribusi kata (tanpa editor).
  contribution,
  /// Moderasi Ruang Diskusi (termasuk editor).
  discussion,
}

/// Penjaga rute /review. Peran dicek di klien; API tetap sumber kebenaran.
class ReviewGate extends ConsumerWidget {
  const ReviewGate({
    super.key,
    required this.child,
    this.mode = ReviewGateMode.home,
  });

  final Widget child;
  final ReviewGateMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);
    return auth.when(
      loading: () => const FScaffold(child: Center(child: FCircularProgress())),
      error: (_, _) => const ReviewForbiddenPage(),
      data: (status) {
        final ok = switch (mode) {
          ReviewGateMode.home => canAccessReviewHome(status.role),
          ReviewGateMode.contribution => canReviewQueue(status.role),
          ReviewGateMode.discussion => canModerateDiscussions(status.role),
        };
        return ok ? child : const ReviewForbiddenPage();
      },
    );
  }
}
