import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../domain/entities/event_contribution.dart';

part 'event_proposals_provider.g.dart';

@riverpod
EventContributionApi eventContributionApi(Ref ref) =>
    EventContributionApi(ref.watch(dioProvider));

/// Daftar usulan acara milik user yang login.
///
/// Guest = state kosong (bukan error). Notifier, bukan setState, supaya
/// halaman bisa invalidate dari mana saja (mis. setelah notifikasi).
@Riverpod(keepAlive: true)
class EventProposalsController extends _$EventProposalsController {
  @override
  Future<List<EventContribution>> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const [];
    return ref.watch(eventContributionApiProvider).mine();
  }

  /// Batalkan usulan yang masih menunggu, lalu muat ulang.
  Future<void> cancel(String id) async {
    await ref.read(eventContributionApiProvider).cancel(id);
    ref.invalidateSelf();
  }
}
