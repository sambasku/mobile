import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../edit_profile/domain/providers/edit_profile_domain_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';

part 'contribution_guide_providers.g.dart';

/// Key SharedPreferences flag guide tamu (pra-per-user, dipakai bersama).
const kContribGuideReadPrefsKey = 'contrib_guide_read_at';

/// Prefiks flag per-user: `contrib_guide_read_at:<userId>`.
///
/// ponytail: per-user, bukan hapus-flag-saat-login - dua akun yang bolak-balik
/// login di HP yang sama tidak saling menimpa "sudah baca". Server flag
/// `has_read_contribution_guide` tetap sumber kebenaran lintas device.
const kContribGuideReadPrefsKeyPrefix = 'contrib_guide_read_at:';

/// Provider prefs ter-inject (test bisa override dengan SharedPreferences.setMockInitialValues).
@Riverpod(keepAlive: true)
Future<SharedPreferences> contributionGuidePrefs(Ref ref) =>
    SharedPreferences.getInstance();

/// Apakah guide swipe tab Kontribusi masih perlu ditampilkan.
///
/// Unread = belum ada flag lokal (per-user / tamu) DAN flag server false.
/// Tamu (belum login) dianggap unread: sheet hanya tips UI, aman tampil.
@Riverpod(keepAlive: true)
Future<bool> contributionGuideUnread(Ref ref) async {
  final prefs = await ref.watch(contributionGuidePrefsProvider.future);
  final auth = ref.watch(authStatusProvider).value;

  if (auth == null || !auth.isAuth) {
    // Tamu: cek key legacy
    final legacyVal = prefs.getString(kContribGuideReadPrefsKey);
    if (legacyVal != null) return false;
    return true;
  }

  // Login: cek key per-user
  final userKey = '$kContribGuideReadPrefsKeyPrefix${auth.userId}';
  final userVal = prefs.getString(userKey);
  if (userVal != null) return false;

  // Tidak ada key per-user -> cek server
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
  final auth = ref.read(authStatusProvider).value;
  final localKey = auth != null && auth.isAuth
      ? '$kContribGuideReadPrefsKeyPrefix${auth.userId}'
      : kContribGuideReadPrefsKey;
  await prefs.setString(localKey, DateTime.now().toIso8601String());
  ref.invalidate(contributionGuideUnreadProvider);

  if (auth == null || !auth.isAuth) return;
  unawaited(
    ref
        .read(updateMyProfileUseCaseProvider)
        .call(hasReadContributionGuide: true),
  );
}
