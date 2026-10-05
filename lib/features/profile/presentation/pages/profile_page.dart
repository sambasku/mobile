import 'dart:async';

import 'package:flutter/material.dart'
    show InkWell, Material, MaterialType, RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../auth/presentation/models/auth_status_state.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../notification/notification_router.dart';
import '../../../admin_analytics/admin_analytics_router.dart';
import '../../../admin_analytics/domain/admin_access.dart';
import '../../../review/domain/review_access.dart';
import '../../../review/presentation/providers/review_suggestions_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/utils/use_scroll_collapse.dart';
import '../../../../shared/widgets/profile_stat_inline.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../widgets/appearance_tiles.dart';
import '../widgets/notification_header_action.dart';

/// Tab PROFILE - identitas di app bar + menu sectioned (FTileGroup).
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  static const _sectionGap = Gap(8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);
    final isAuth = authStatus.value?.isAuth ?? false;
    final scroll = useScrollController();
    // Future dibuat sekali: PackageInfo.fromPlatform panggil method channel.
    final versionFuture = useMemoized(PackageInfo.fromPlatform);
    // Animation, bukan double: ListView menu tidak rebuild tiap frame scroll.
    // Yang rebuild hanya title header + blok stat (AnimatedBuilder).
    final collapse = useScrollCollapse(scroll);

    // Sync handle sekali saat tab Profil aktif - jangan tiap rebuild auth.
    useEffect(() {
      if (!isAuth) return null;
      unawaited(
        ref.read(authStatusProvider.notifier).ensureUsernameForProfile(),
      );
      return null;
    }, [isAuth]);

    Future<void> refreshIdentity() async {
      if (!isAuth) return;
      await ref.read(authStatusProvider.notifier).ensureUsernameForProfile();
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: collapse,
          builder: (context, _) => FHeader(
            title: _ProfileHeaderTitle(
              status: authStatus.value,
              collapse: collapse,
            ),
          ),
        ),
        Expanded(
          child: authStatus.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => const Center(child: FCircularProgress()),
            data: (status) => RefreshIndicator(
              onRefresh: refreshIdentity,
              child: ListView(
                controller: scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                children: [
                  if (status.isAuth) ...[
                    FTileGroup(
                      label: const Text('Aktivitas saya'),
                      children: [
                        const _NotificationTile(),
                        FTile(
                          prefix: const Icon(
                            FLucideIcons.filePenLine,
                            size: 18,
                          ),
                          title: const Text('Kontribusi Saya'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/contributions'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.bookmark, size: 18),
                          title: const Text('Bookmark'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/bookmarks'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.arrowBigUp, size: 18),
                          title: const Text('Vote'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/votes'),
                        ),
                        FTile(
                          prefix: const Icon(
                            FLucideIcons.messageSquare,
                            size: 18,
                          ),
                          title: const Text('Komentar'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/comments'),
                        ),
                      ],
                    ),
                    _sectionGap,
                    if (status.role == 'contributor' ||
                        canAccessReviewHome(status.role) ||
                        canAccessAdminAnalytics(status.role)) ...[
                      FTileGroup(
                        label: const Text('Peran'),
                        children: [
                          if (status.role == 'contributor')
                            FTile(
                              prefix: const Icon(
                                FLucideIcons.badgeCheck,
                                size: 18,
                              ),
                              title: const Text('Jadi verifikator'),
                              suffix: const Icon(
                                FLucideIcons.chevronRight,
                                size: 16,
                              ),
                              onPress: () =>
                                  context.push('/verifier-application'),
                            ),
                          if (canAccessReviewHome(status.role))
                            const _ReviewQueueTile(),
                          if (canAccessAdminAnalytics(status.role))
                            FTile(
                              prefix: const Icon(
                                FLucideIcons.chartColumn,
                                size: 18,
                              ),
                              title: const Text('Analitik'),
                              suffix: const Icon(
                                FLucideIcons.chevronRight,
                                size: 16,
                              ),
                              onPress: () =>
                                  context.push(AdminAnalyticsRouter.home.path),
                            ),
                        ],
                      ),
                      _sectionGap,
                    ],
                    FTileGroup(
                      label: const Text('Akun'),
                      children: [
                        FTile(
                          prefix: const Icon(FLucideIcons.link, size: 18),
                          title: const Text('Akun Terhubung'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/linked-accounts'),
                        ),
                        FTile(
                          prefix: const Icon(FLucideIcons.keyRound, size: 18),
                          title: const Text('Ubah Password'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/change-password'),
                        ),
                      ],
                    ),
                    _sectionGap,
                  ] else ...[
                    FTileGroup(
                      children: [
                        FTile(
                          prefix: const Icon(FLucideIcons.logIn, size: 18),
                          title: const Text('Masuk / Login'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.go('/login'),
                        ),
                        FTile(
                          prefix: const Icon(
                            FLucideIcons.userRoundPlus,
                            size: 18,
                          ),
                          title: const Text('Daftar'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.go('/register'),
                        ),
                      ],
                    ),
                    _sectionGap,
                  ],
                  FTileGroup(
                    label: const Text('Tampilan & bantuan'),
                    children: [
                      themeModeTile(ref),
                      paletteTile(ref),
                      fontScaleTile(ref),
                      FTile(
                        prefix: const Icon(FLucideIcons.info, size: 18),
                        title: const Text('Tentang SambasKu'),
                        suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                        onPress: () => context.push('/about'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.flag, size: 18),
                        title: const Text('Laporkan Masalah'),
                        suffix: const Icon(FLucideIcons.chevronRight, size: 16),
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
                          prefix: const Icon(FLucideIcons.userRoundX),
                          title: const Text('Hapus akun'),
                          suffix: const Icon(
                            FLucideIcons.chevronRight,
                            size: 16,
                          ),
                          onPress: () => context.push('/delete-account'),
                        ),
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
                  const Gap(16),
                  // Label versi paling bawah. Gagal load = label hilang.
                  FutureBuilder<PackageInfo>(
                    future: versionFuture,
                    builder: (context, snapshot) {
                      final info = snapshot.data;
                      if (info == null) return const SizedBox.shrink();
                      return Center(
                        child: Text(
                          'v${info.version}(${info.buildNumber})',
                          style: context.theme.typography.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
      prefix: const Icon(FLucideIcons.bell, size: 18),
      title: const Text('Notifikasi'),
      subtitle: unread > 0 ? Text('$unread belum dibaca') : null,
      suffix: const Icon(FLucideIcons.chevronRight, size: 16),
      onPress: () => context.push(NotificationRouter.list.path),
    );
  }
}

class _ReviewQueueTile extends ConsumerWidget with FTileMixin {
  const _ReviewQueueTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(reviewHubHasPendingProvider).value ?? false;
    return FTile(
      prefix: const Icon(FLucideIcons.shieldCheck, size: 18),
      title: const Text('Area Verifikator'),
      subtitle: pending ? const Text('Ada usulan yang menunggu') : null,
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
          const Icon(FLucideIcons.chevronRight, size: 16),
        ],
      ),
      onPress: () => context.push('/review'),
    );
  }
}

/// Header kaya ala Threads: avatar + nama + handle + bio + stat + meta.
/// Tap seluruh blok membuka profil publik. Slot FHeader.title.
class _ProfileHeaderTitle extends ConsumerWidget {
  const _ProfileHeaderTitle({required this.status, required this.collapse});

  final AuthStatusState? status;

  /// 0 = blok stat terbuka, 1 = tertutup (dari [useScrollCollapse]).
  final Animation<double> collapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final isAuth = status?.isAuth ?? false;
    final username = status?.username?.trim();
    final rawDisplay = status?.displayName?.trim();
    final displayName = isAuth
        ? (rawDisplay?.isNotEmpty == true
              ? rawDisplay!
              : (username?.isNotEmpty == true ? username! : 'Pengguna'))
        : 'Belum masuk';

    // Detail profil publik (bio, stat, bergabung). Tamu tidak watch.
    final usernameLower = username?.toLowerCase();
    final profileAsync =
        isAuth && usernameLower != null && usernameLower.isNotEmpty
        ? ref.watch(publicProfileProvider(usernameLower))
        : null;
    final profile = profileAsync?.asData?.value;
    final loadingProfile =
        profile == null && (profileAsync?.isLoading ?? false);

    Future<void> openPublicProfile() async {
      // Baca state terbaru saat tap - jangan andalkan closure yang bisa stale.
      final latest = ref.read(authStatusProvider).value;
      final titleHint = latest?.displayName?.trim();
      var handle = latest?.username?.trim();
      if (handle == null || handle.isEmpty) {
        handle = await ref
            .read(authStatusProvider.notifier)
            .ensureUsernameForProfile();
      }
      if (!context.mounted) return;
      if (handle == null || handle.isEmpty) {
        showFToast(
          context: context,
          title: const Text('Profil belum siap, coba lagi'),
        );
        return;
      }
      UserProfileRouter.open(
        context,
        handle,
        displayName: (titleHint != null && titleHint.isNotEmpty)
            ? titleHint
            : null,
      );
    }

    // Label semantik + hint agar tap-header diketahui pengguna screen reader.
    return Semantics(
      button: true,
      enabled: isAuth,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isAuth ? openPublicProfile : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      name: isAuth ? displayName : null,
                      imageUrl: status?.avatarUrl,
                      size: 56,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.lg.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          if (isAuth &&
                              username != null &&
                              username.isNotEmpty) ...[
                            const Gap(1),
                            Text(
                              '@$username',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                          if (profile?.bio?.trim().isNotEmpty == true) ...[
                            const Gap(4),
                            Text(
                              profile!.bio!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.sm,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isAuth) ...[
                      const Gap(8),
                      // FHeader memusatkan suffix secara vertikal terhadap
                      // title yang tinggi; taruh di sini agar tetap di atas.
                      FHeaderData(
                        actionStyle: theme.headerStyles.resolve({
                          FHeaderVariant.root,
                          context.platformVariant,
                        }).actionStyle,
                        child: const NotificationHeaderAction(),
                      ),
                    ],
                  ],
                ),
                if (profile != null || loadingProfile)
                  // Collaps ikut scroll, sama seperti blok search di Home.
                  // Rebuild dibatasi ke blok stat saja (AnimatedBuilder).
                  AnimatedBuilder(
                    animation: collapse,
                    builder: (context, child) {
                      final t = collapse.value;
                      return Align(
                        alignment: Alignment.topLeft,
                        heightFactor: 1 - t,
                        child: ClipRect(
                          child: Opacity(
                            opacity: (1 - t * 1.4).clamp(0.0, 1.0),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Skeletonizer(
                        enabled: loadingProfile,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfileStatRow(
                              contributions:
                                  profile?.contributionsApproved ?? 0,
                              verifications: profile?.verificationsDone ?? 0,
                              comments: profile?.commentsPublished ?? 0,
                            ),
                            const Gap(4),
                            ProfileMetaRow(
                              joinedLabel: profile == null
                                  ? '1 Januari 2026'
                                  : formatDateTimeIso(profile.joinedAt),
                              isVerifier: profile?.isVerifier ?? false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
