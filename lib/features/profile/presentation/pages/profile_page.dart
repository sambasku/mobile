import 'package:flutter/widgets.dart';
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

/// Tab PROFILE - identity + menu via FTileGroup.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const roleLabels = <String, String>{
    'root': 'Root',
    'admin': 'Admin',
    'editor': 'Editor',
    'reviewer': 'Reviewer',
    'contributor': 'Kontributor',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);

    return Column(
      children: [
        FHeader(
          title: const Text('Profil'),
          suffixes: [
            if (authStatus.value?.isAuth ?? false)
              const NotificationHeaderAction(),
            const ThemeToggleHeaderAction(),
          ],
        ),
        Expanded(
          child: authStatus.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => const Center(child: FCircularProgress()),
            data: (status) => ListView(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
              children: [
                _IdentityTileGroup(status: status),
                const Gap(14),
                if (status.isAuth) ...[
                  FTileGroup(
                    label: const Text('Saya'),
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
                        subtitle: const Text(
                          'Kata tersimpan untuk dibaca lagi',
                        ),
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
                      FTile(
                        prefix: const Icon(FLucideIcons.flag),
                        title: const Text('Laporkan Masalah'),
                        subtitle: const Text('Kirim saran atau laporkan bug'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/report-bug'),
                      ),
                    ],
                  ),
                  const Gap(14),
                  FTileGroup(
                    label: const Text('Akun'),
                    children: [
                      if (status.role == 'contributor')
                        FTile(
                          prefix: const Icon(FLucideIcons.badgeCheck),
                          title: const Text('Jadi verifikator'),
                          subtitle: const Text(
                            'Ajukan diri untuk meninjau kontribusi',
                          ),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/verifier-application'),
                        ),
                      if (canReviewQueue(status.role)) const _ReviewQueueTile(),
                      FTile(
                        prefix: const Icon(FLucideIcons.userRoundPen),
                        title: const Text('Edit profil'),
                        subtitle: const Text('Ubah nama tampilan dan bio'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/edit-profile'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.link),
                        title: const Text('Akun Terhubung'),
                        subtitle: const Text('Kelola login yang terhubung ke akun'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/linked-accounts'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.keyRound),
                        title: const Text('Ubah Password'),
                        subtitle: const Text('Ganti password akun'),
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
                  const Gap(14),
                ] else
                  FTileGroup(
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.logIn),
                        title: const Text('Masuk / Login'),
                        subtitle: const Text('Masuk untuk berkontribusi kata'),
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
                      FTile(
                        prefix: const Icon(FLucideIcons.flag),
                        title: const Text('Laporkan Masalah'),
                        subtitle: const Text('Kirim saran atau laporkan bug'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/report-bug'),
                      ),
                    ],
                  ),
                const Gap(14),
                FTileGroup(
                  label: const Text('Tampilan'),
                  children: [themeModeTile(ref), paletteTile(ref)],
                ),
                const Gap(14),
                FTileGroup(
                  label: const Text('Tentang'),
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.info),
                      title: const Text('Tentang SambasKu'),
                      subtitle: const Text('Fitur dan versi aplikasi'),
                      suffix: const Icon(FLucideIcons.chevronRight),
                      onPress: () => context.push('/about'),
                    ),
                  ],
                ),
                if (status.isAuth) ...[
                  const Gap(14),
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
      subtitle: Text(pending ? 'Ada usulan yang menunggu' : 'Antrean review kontribusi'),
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
      subtitle: Text(
        unread > 0 ? '$unread belum dibaca' : 'Status usulan yang sudah direview',
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(NotificationRouter.list.path),
    );
  }
}

class _IdentityTileGroup extends StatelessWidget {
  const _IdentityTileGroup({required this.status});

  final AuthStatusState status;

  @override
  Widget build(BuildContext context) {
    final username = status.username?.trim();
    final displayName = status.isAuth
        ? (username?.isNotEmpty == true ? username! : 'Pengguna')
        : 'Belum masuk';
    final roleLabel = status.isAuth && status.role != null
        ? (ProfilePage.roleLabels[status.role!] ?? status.role!)
        : null;
    final subtitle = status.isAuth
        ? 'Lihat profil & ganti foto'
        : 'Masuk untuk berkontribusi kata';

    return FTileGroup(
      children: [
        FTile(
          prefix: _ProfileAvatar(
            name: status.isAuth ? displayName : null,
            imageUrl: status.avatarUrl,
            size: 40,
          ),
          title: Text(displayName),
          subtitle: Text(
            status.isAuth
                ? (roleLabel != null ? '$roleLabel · $subtitle' : subtitle)
                : subtitle,
          ),
          suffix: status.isAuth
              ? const Icon(FLucideIcons.chevronRight)
              : null,
          onPress: status.isAuth && username != null && username.isNotEmpty
              ? () => UserProfileRouter.open(context, username)
              : null,
        ),
      ],
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
