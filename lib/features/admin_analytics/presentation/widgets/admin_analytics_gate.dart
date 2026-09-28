import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/admin_access.dart';
import '../pages/admin_analytics_forbidden_page.dart';

/// Penjaga rute /admin/analytics. Peran dicek di klien.
class AdminAnalyticsGate extends ConsumerWidget {
  const AdminAnalyticsGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);
    return auth.when(
      loading: () =>
          const FScaffold(child: Center(child: FCircularProgress())),
      error: (_, _) => const AdminAnalyticsForbiddenPage(),
      data: (status) => canAccessAdminAnalytics(status.role)
          ? child
          : const AdminAnalyticsForbiddenPage(),
    );
  }
}
