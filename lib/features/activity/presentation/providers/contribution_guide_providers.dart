import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../edit_profile/domain/providers/edit_profile_domain_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';

part 'contribution_guide_providers.g.dart';

/// Key SharedPreferences flag guide tab Kontribusi.
const kContribGuideReadPrefsKey = 'contrib_guide_read_at';

/// Provider prefs ter-inject (test bisa override dengan SharedPreferences.setMockInitialValues).
@Riverpod(keepAlive: true)
Future<SharedPreferences> contributionGuidePrefs(Ref ref) =>
    SharedPreferences.getInstance();

/// Apakah guide swipe tab Kontribusi masih perlu ditampilkan.
///
/// Unread = belum ada flag lokal DAN flag server false. Tamu (belum login)
/// dianggap unread: sheet hanya tips UI, aman tampil.
@Riverpod(keepAlive: true)
Future<bool> contributionGuideUnread(Ref ref) async {
  final prefs = await ref.watch(contributionGuidePrefsProvider.future);
  if (prefs.getString(kContribGuideReadPrefsKey) != null) return false;

  final auth = ref.watch(authStatusProvider).value;
  if (auth == null || !auth.isAuth) return true;

  final profile = await ref.watch(getMyProfileUseCaseProvider).call();
  return profile.fold(
    (failure) => true,
    (profile) => !profile.hasReadContributionGuide,
  );
}

/// Tandai guide sudah dibaca. Prefs lokal dulu (instant), PATCH server
/// fire-and-forget - gagal tidak masalah karena lokal sudah mencegah
/// guide muncul lagi.
Future<void> markContributionGuideRead(WidgetRef ref) async {
  final prefs = await ref.read(contributionGuidePrefsProvider.future);
  await prefs.setString(
    kContribGuideReadPrefsKey,
    DateTime.now().toIso8601String(),
  );
  ref.invalidate(contributionGuideUnreadProvider);

  final auth = ref.read(authStatusProvider).value;
  if (auth == null || !auth.isAuth) return;
  unawaited(
    ref
        .read(updateMyProfileUseCaseProvider)
        .call(hasReadContributionGuide: true),
  );
}
