import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/device_registration_holder.dart';
import '../../../edit_profile/domain/providers/edit_profile_domain_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../models/auth_status_state.dart';

part 'auth_status_providers.g.dart';

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
///
/// keepAlive: sesi tidak boleh autoDispose saat pindah /login → / (gap
/// antar listener sempat cancel rebuild + sisakan cache isAuth:false).
@Riverpod(keepAlive: true)
class AuthStatusNotifier extends _$AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async {
    final storage = ref.watch(authTokenStorageProvider);
    final isAuth = await storage.getIsAuth();
    final user = await storage.getSessionUser();
    var state = AuthStatusState(
      isAuth: isAuth,
      username: user.username,
      displayName: user.displayName,
      role: user.role,
      userId: user.userId,
      avatarUrl: user.avatarUrl,
    );

    // Setelah migrate username→handle, prefs bisa masih simpan nama lama.
    // Sync dari GET /users/me supaya navigasi profil tidak 404.
    if (isAuth) {
      state = await _syncIdentityFromServer(state) ?? state;
    }
    return state;
  }

  /// Dipanggil langsung setelah login sukses (token sudah di storage).
  /// Hindari invalidate auth: reload async masih bawa previous isAuth:false
  /// → form KBBI/gambar sempat mengira user masih tamu.
  void markLoggedIn(AuthSession session) {
    state = AsyncData(
      AuthStatusState(
        isAuth: true,
        username: session.username,
        displayName: session.displayName,
        role: session.role,
        userId: session.userId,
        avatarUrl: session.avatarUrl,
      ),
    );
    // Sama seperti logout: list keepAlive watch authStatus, cukup rebuild.
  }

  /// Timpa username/display_name/avatar dari server (atau JWT) ke prefs + state.
  Future<void> applySessionIdentity({
    required String username,
    String? displayName,
    String? avatarUrl,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;

    final current = state.value ?? const AuthStatusState();
    final storage = ref.read(authTokenStorageProvider);
    final user = await storage.getSessionUser();
    final nextDisplay =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : user.displayName;
    final nextAvatar =
        avatarUrl != null
            ? (avatarUrl.isNotEmpty ? avatarUrl : null)
            : user.avatarUrl;

    await storage.saveSessionUser(
      username: trimmed,
      displayName: nextDisplay,
      role: user.role ?? current.role,
      userId: user.userId ?? current.userId,
      avatarUrl: nextAvatar,
    );

    state = AsyncData(
      current.copyWith(
        isAuth: true,
        username: trimmed,
        displayName: nextDisplay,
        clearDisplayName: nextDisplay == null,
        avatarUrl: nextAvatar,
        clearAvatarUrl: nextAvatar == null,
      ),
    );
  }

  /// Update display name setelah edit profil tanpa reload storage penuh.
  Future<void> setDisplayName(String? displayName) async {
    final current = state.value ?? const AuthStatusState();
    final storage = ref.read(authTokenStorageProvider);
    final user = await storage.getSessionUser();
    final next =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : null;
    final username = (user.username ?? current.username)?.trim();
    if (username != null && username.isNotEmpty) {
      await storage.saveSessionUser(
        username: username,
        displayName: next,
        role: user.role,
        userId: user.userId,
        avatarUrl: user.avatarUrl,
      );
    }
    state = AsyncData(
      current.copyWith(clearDisplayName: true).copyWith(displayName: next),
    );
  }

  /// Update avatar setelah upload/hapus tanpa reload storage penuh.
  Future<void> setAvatarUrl(String? avatarUrl) async {
    final current = state.value ?? const AuthStatusState();
    final storage = ref.read(authTokenStorageProvider);
    final user = await storage.getSessionUser();
    final next = (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : null;
    final username = (user.username ?? current.username)?.trim();
    if (username != null && username.isNotEmpty) {
      await storage.saveSessionUser(
        username: username,
        displayName: user.displayName,
        role: user.role,
        userId: user.userId,
        avatarUrl: next,
      );
    }
    state = AsyncData(
      current.copyWith(clearAvatarUrl: true).copyWith(avatarUrl: next),
    );
  }

  Future<AuthStatusState?> _syncIdentityFromServer(AuthStatusState current) async {
    try {
      final result = await ref.read(getMyProfileUseCaseProvider).call();
      return await result.match(
        (_) async => null,
        (profile) async {
          final storage = ref.read(authTokenStorageProvider);
          final user = await storage.getSessionUser();
          await storage.saveSessionUser(
            username: profile.username,
            displayName: profile.displayName,
            role: user.role ?? current.role,
            userId: user.userId ?? current.userId,
            avatarUrl: profile.avatarUrl ?? user.avatarUrl,
          );
          return current.copyWith(
            username: profile.username,
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl ?? user.avatarUrl,
          );
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Paksa sync identitas dari server (dipakai sebelum buka profil publik).
  Future<String?> ensureUsernameForProfile() async {
    final current = state.value;
    if (current == null || !current.isAuth) return null;

    final synced = await _syncIdentityFromServer(current);
    if (synced != null) {
      state = AsyncData(synced);
      return synced.username?.trim();
    }
    return current.username?.trim();
  }

  Future<void> logout() async {
    final current = state.value ?? const AuthStatusState();
    state = AsyncData(current.copyWith(isLoggingOut: true));

    // Detach FCM dulu (butuh access token masih valid). Jika access sudah
    // expired, PATCH /device/revoke dapat 401 - AuthInterceptor skip refresh
    // untuk path itu supaya tidak infinite loop.
    await DeviceRegistrationHolder.instance?.revokeBestEffort();

    await ref.read(authLogoutUseCaseProvider).call();

    state = const AsyncData(AuthStatusState(isAuth: false));
    AnalyticsService.instance.log(AnalyticsEvents.authLogout);
    // Jangan invalidate bookmark/kontribusi/notifikasi: mereka sudah
    // `watch` authStatus. Invalidate saat rebuild → circular Riverpod 3.
  }
}
