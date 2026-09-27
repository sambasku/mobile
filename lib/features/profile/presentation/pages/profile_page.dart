import 'dart:async';

import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../auth/presentation/models/auth_status_state.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../notification/notification_router.dart';
import '../../../review/domain/review_access.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../widgets/appearance_tiles.dart';
import '../widgets/notification_header_action.dart';

/// Tab PROFILE - identitas di atas, lalu menu terkelompok (aktivitas / akun / preferensi).
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  static const roleLabels = <String, String>{
    'root': 'Root',
    'admin': 'Admin',
    'editor': 'Editor',
    'reviewer': 'Reviewer',
    'contributor': 'Kontributor',
  };

  static const _sectionGap = Gap(16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);
    final isAuth = authStatus.value?.isAuth ?? false;
    final userId = authStatus.value?.userId;

    // Prefs bisa stale setelah migrate username (hyphen → underscore).
    // Sync saat tab Profil tampil, bukan hanya saat tap kartu identitas.
    useEffect(() {
      if (!isAuth) return null;
      unawaited(
        ref.read(authStatusProvider.notifier).ensureUsernameForProfile(),
      );
      return null;
    }, [isAuth, userId]);

    Future<void> refreshIdentity() async {
      if (!isAuth) return;
      await ref.read(authStatusProvider.notifier).ensureUsernameForProfile();
    }

    return Column(
      children: [
        FHeader(
          title: const Text('Profil'),
          suffixes: [
            if (isAuth) const NotificationHeaderAction(),
            const ThemeToggleHeaderAction(),
          ],
        ),
        Expanded(
          child: authStatus.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => const Center(child: FCircularProgress()),
            data: (status) => RefreshIndicator(
              onRefresh: refreshIdentity,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 40),
                children: [
                  _IdentityCard(status: status),
                  _sectionGap,
                  if (status.isAuth) ...[
                    FTileGroup(
                      label: const Text('Aktivitas'),
                      children: [
                        const _NotificationTile(),
                        FTile(
                          prefix: const Icon(FLucideIcons.filePenLine),
                          title: const Text('Kontribusi Saya'),
                          subtitle: const Text('Riwayat & status usulan kata'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/contributions'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.bookmark),
                          title: const Text('Bookmark'),
                          subtitle: const Text('Kata tersimpan'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/bookmarks'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.arrowBigUp),
                          title: const Text('Vote'),
                          subtitle: const Text('Kata yang pernah kamu vote'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/votes'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.messageSquare),
                          title: const Text('Komentar'),
                          subtitle: const Text('Komentar & status moderasi'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/comments'),
                        ),
                      ],
                    ),
                    _sectionGap,
                    FTileGroup(
                      label: const Text('Akun'),
                      children: [
                        FTile(
                          prefix: const Icon(FLucideIcons.userRoundPen),
                          title: const Text('Edit profil'),
                          subtitle: const Text('Nama tampilan dan bio'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/edit-profile'),
                        ),
                        if (status.role == 'contributor')
                          FTile(
                            prefix: const Icon(FLucideIcons.badgeCheck),
                            title: const Text('Jadi verifikator'),
                            subtitle: const Text(
                              'Ajukan diri untuk meninjau kontribusi',
                            ),
                            suffix: const Icon(FLucideIcons.chevronRight),
                            onPress: () =>
                                context.push('/verifier-application'),
                          ),
                        if (canReviewQueue(status.role))
                          const _ReviewQueueTile(),
                        FTile(
                          prefix: const Icon(FLucideIcons.link),
                          title: const Text('Akun Terhubung'),
                          subtitle: const Text('Google, GitHub, dan lainnya'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/linked-accounts'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.keyRound),
                          title: const Text('Ubah Password'),
                          subtitle: const Text('Ganti kata sandi akun'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/change-password'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.userRoundX),
                          title: const Text('Hapus akun'),
                          subtitle: const Text('Hapus akun dan data pribadi'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/delete-account'),
                        ),
                      ],
                    ),
                    _sectionGap,
                  ] else ...[
                    FTileGroup(
                      label: const Text('Masuk'),
                      children: [
                        FTile(
                          prefix: const Icon(FLucideIcons.logIn),
                          title: const Text('Masuk / Login'),
                          subtitle: const Text(
                            'Bookmark, vote, dan usul sebagai diri sendiri',
                          ),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.go('/login'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.userRoundPlus),
                          title: const Text('Daftar'),
                          subtitle: const Text('Buat akun kontributor baru'),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.go('/register'),
                        ),
                      ],
                    ),
                    _sectionGap,
                  ],
                  FTileGroup(
                    label: const Text('Tampilan'),
                    children: [themeModeTile(ref), paletteTile(ref)],
                  ),
                  _sectionGap,
                  FTileGroup(
                    label: const Text('Bantuan'),
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.info),
                        title: const Text('Tentang SambasKu'),
                        subtitle: const Text('Fitur dan versi aplikasi'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/about'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.flag),
                        title: const Text('Laporkan Masalah'),
                        subtitle: const Text('Kirim saran atau laporkan bug'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/report-bug'),
                      ),
                    ],
                  ),
                  if (status.isAuth) ...[
                    _sectionGap,
                    FTileGroup(
                      children: [
                        FTile(
                          variant: .destructive,
                          prefix: status.isLoggingOut
                              ? const FCircularProgress()
                              : const Icon(FLucideIcons.logOut),
                          title: Text(
                            status.isLoggingOut ? 'Keluar...' : 'Keluar',
                          ),
                          subtitle: status.isLoggingOut
                              ? null
                              : const Text('Akhiri sesi di perangkat ini'),
                          enabled: !status.isLoggingOut,
                          onPress: status.isLoggingOut
                              ? null
                              : () async {
                                  await ref
                                      .read(authStatusProvider.notifier)
                                      .logout();
                                  if (!context.mounted) return;
                                  context.go('/login');
                                },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewQueueTile extends ConsumerWidget with FTileMixin {
  const _ReviewQueueTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(reviewQueueHasPendingProvider).value ?? false;
    return FTile(
      prefix: const Icon(FLucideIcons.shieldCheck),
      title: const Text('Tinjau usulan'),
      subtitle: pending
          ? const Text('Ada usulan yang menunggu')
          : const Text('Antrian kontribusi untuk ditinjau'),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pending)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
          const Icon(FLucideIcons.chevronRight),
        ],
      ),
      onPress: () => context.push('/review'),
    );
  }
}

class _NotificationTile extends ConsumerWidget with FTileMixin {
  const _NotificationTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(unreadNotificationCountControllerProvider).value ?? 0;
    return FTile(
      prefix: const Icon(FLucideIcons.bell),
      title: const Text('Notifikasi'),
      subtitle: unread > 0
          ? Text('$unread belum dibaca')
          : const Text('Kotak masuk pemberitahuan'),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(NotificationRouter.list.path),
    );
  }
}

/// Kartu identitas di atas menu: nama, handle, peran - bukan baris menu biasa.
class _IdentityCard extends ConsumerWidget {
  const _IdentityCard({required this.status});

  final AuthStatusState status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final username = status.username?.trim();
    final rawDisplay = status.displayName?.trim();
    final displayName = status.isAuth
        ? (rawDisplay?.isNotEmpty == true
              ? rawDisplay!
              : (username?.isNotEmpty == true ? username! : 'Pengguna'))
        : 'Tamu';
    final roleLabel = status.isAuth && status.role != null
        ? (ProfilePage.roleLabels[status.role!] ?? status.role!)
        : null;
    final handle = username != null && username.isNotEmpty ? '@$username' : null;

    Future<void> openPublicProfile() async {
      final resolved = await ref
          .read(authStatusProvider.notifier)
          .ensureUsernameForProfile();
      if (!context.mounted) return;
      if (resolved == null || resolved.isEmpty) return;
      UserProfileRouter.open(context, resolved);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: status.isAuth ? openPublicProfile : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ProfileAvatar(
                      name: status.isAuth ? displayName : null,
                      imageUrl: status.avatarUrl,
                      size: 56,
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.typography.lg.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          if (status.isAuth) ...[
                            if (handle != null) ...[
                              const Gap(2),
                              Text(
                                handle,
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                            if (roleLabel != null) ...[
                              const Gap(6),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: theme.colors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  child: Text(
                                    roleLabel,
                                    style: theme.typography.xs.copyWith(
                                      color: theme.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            const Gap(4),
                            Text(
                              'Belum masuk',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'Cari kata tanpa akun. Masuk untuk menyimpan aktivitas.',
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.mutedForeground,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (status.isAuth)
                      Icon(
                        FLucideIcons.chevronRight,
                        color: theme.colors.mutedForeground,
                      ),
                  ],
                ),
              ),
              if (status.isAuth) ...[
                const Gap(14),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: openPublicProfile,
                        child: const Text('Lihat profil'),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => context.push('/edit-profile'),
                        child: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, this.imageUrl, this.size = 40});

  final String? name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final display = displayImageUrl(imageUrl, width: 256) ?? imageUrl;
    if (display != null && display.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          display,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            if (imageUrl != null &&
                imageUrl!.isNotEmpty &&
                imageUrl != display) {
              return Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _InitialsOrIcon(name: name, size: size),
              );
            }
            return _InitialsOrIcon(name: name, size: size);
          },
        ),
      );
    }
    return _InitialsOrIcon(name: name, size: size);
  }
}

class _InitialsOrIcon extends StatelessWidget {
  const _InitialsOrIcon({required this.name, required this.size});

  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final initials = _initials(name);

    return FAvatar.raw(
      size: size,
      style: .delta(
        backgroundColor: initials != null
            ? theme.colors.primary.withValues(alpha: 0.12)
            : theme.colors.muted,
      ),
      child: initials != null
          ? Text(
              initials,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.primary,
                height: 1,
              ),
            )
          : Icon(
              FLucideIcons.userRound,
              size: size * 0.42,
              color: theme.colors.mutedForeground,
            ),
    );
  }

  static String? _initials(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final word = parts.first;
    if (word.length >= 2) return word.substring(0, 2).toUpperCase();
    return word.toUpperCase();
  }
}
