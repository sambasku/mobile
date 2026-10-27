import 'dart:async';

import 'package:material_ui/material_ui.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/models/auth_status_state.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../linked_accounts/presentation/providers/linked_accounts_providers.dart';
import '../../../notification/notification_router.dart';
import '../../../admin_analytics/admin_analytics_router.dart';
import '../../../admin_analytics/domain/admin_access.dart';
import '../../../review/domain/review_access.dart';
import '../../../review/presentation/providers/review_suggestions_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../settings/settings_router.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../achievement/presentation/providers/achievement_providers.dart';
import '../../../achievement/presentation/widgets/profile_achievement_tabs.dart';
import '../../../../core/network/failover/api_host_resolver.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../../shared/widgets/profile_stat_inline.dart';
import '../widgets/allow_notification_shortcut.dart';
import '../widgets/api_host_tile.dart';
import '../widgets/notification_header_action.dart';

/// Tab PROFILE - header identitas (avatar besar + cover) di atas menu
/// sectioned (FTileGroup). Header identitas dipakai bersama dengan
/// halaman profil publik ([ProfileIdentityHeader]).
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  static const _sectionGap = Gap(8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);
    final links = ref.watch(linkedAccountsProvider);
    final isAuth = authStatus.value?.isAuth ?? false;
    final l10n = AppLocalizations.of(context);
    final scroll = useScrollController();
    // Future dibuat sekali: PackageInfo.fromPlatform panggil method channel.
    final versionFuture = useMemoized(PackageInfo.fromPlatform);
    final allowNotif = useAllowNotificationShortcut();

    // Sync handle sekali saat tab Profil aktif - jangan tiap rebuild auth.
    useEffect(() {
      if (!isAuth) return null;
      unawaited(
        ref.read(authStatusProvider.notifier).ensureUsernameForProfile(),
      );
      return null;
    }, [isAuth]);

    Future<void> refreshAll() async {
      if (!isAuth) return;
      final username = ref.read(authStatusProvider).value?.username?.trim();
      await ref.read(authStatusProvider.notifier).ensureUsernameForProfile();
      ref.invalidate(linkedAccountsProvider);
      ref.invalidate(myAchievementsProvider());
      ref.invalidate(myActiveBorderProvider);
      if (username != null && username.isNotEmpty) {
        ref.invalidate(publicProfileProvider(username.toLowerCase()));
      }
      await ref.read(authStatusProvider.notifier).ensureUsernameForProfile();
    }

    return Column(
      children: [
        // Judul dikosongkan: nama sudah tampil besar di header identitas tepat
        // di bawahnya, jadi mengulangnya di app bar terasa dobel.
        FHeader(
          title: const SizedBox.shrink(),
          suffixes: [
            if (isAuth) ...[
              FHeaderData(
                actionStyle: context.theme.headerStyles.resolve({
                  FHeaderVariant.root,
                  context.platformVariant,
                }).actionStyle,
                child: const NotificationHeaderAction(),
              ),
              FHeaderAction(
                icon: const Icon(FLucideIcons.pencil, size: 18),
                onPress: () => context.push('/edit-profile'),
                semanticsLabel: l10n.profileEditSemantics,
              ),
            ],
          ],
        ),
        Expanded(
          child: authStatus.when(
            loading: () => const ProfileIdentityHeaderSkeleton(
              variant: ProfileHeaderVariant.hero,
            ),
            error: (_, _) => const ProfileIdentityHeaderSkeleton(
              variant: ProfileHeaderVariant.hero,
            ),
            data: (state) => RefreshIndicator(
              onRefresh: refreshAll,
              // SingleChildScrollView, bukan ListView: halaman ini isinya
              // pendek dan statis. Di ListView lazy, header identitas
              // di-dispose saat keluar cacheExtent - provider autoDispose
              // (profil, lencana, bingkai) ikut mati dan fetch API terulang
              // tiap balik scroll. Kolom + scroll view = semua anak tetap
              // mounted, nol refetch.
              child: SingleChildScrollView(
                controller: scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _IdentitySection(status: state),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      child: Column(
                        children: [
                          if (state.isAuth) ...[
                            FTileGroup(
                              label: Text(l10n.profileGroupActivity),
                              children: [
                                const _NotificationTile(),
                                _navTile(
                                  context,
                                  icon: FLucideIcons.filePenLine,
                                  title: l10n.profileMyContributions,
                                  path: '/contributions',
                                ),
                                _navTile(
                                  context,
                                  icon: FLucideIcons.bookmark,
                                  title: l10n.profileBookmarks,
                                  path: '/bookmarks',
                                ),
                                _navTile(
                                  context,
                                  icon: FLucideIcons.arrowBigUp,
                                  title: l10n.profileVotes,
                                  path: '/votes',
                                ),
                                _navTile(
                                  context,
                                  icon: FLucideIcons.messageSquare,
                                  title: l10n.profileComments,
                                  path: '/comments',
                                ),
                              ],
                            ),
                            _sectionGap,
                            if (state.role == 'contributor' ||
                                canAccessReviewHome(state.role) ||
                                canAccessAdminAnalytics(state.role)) ...[
                              FTileGroup(
                                label: Text(l10n.profileGroupRole),
                                children: [
                                  if (state.role == 'contributor')
                                    _navTile(
                                      context,
                                      icon: FLucideIcons.badgeCheck,
                                      title: l10n.profileBecomeVerifier,
                                      path: '/verifier-application',
                                    ),
                                  if (canAccessReviewHome(state.role))
                                    const _ReviewQueueTile(),
                                  if (canAccessAdminAnalytics(state.role))
                                    _navTile(
                                      context,
                                      icon: FLucideIcons.chartColumn,
                                      title: l10n.profileAnalytics,
                                      path: AdminAnalyticsRouter.home.path,
                                    ),
                                ],
                              ),
                              _sectionGap,
                            ],
                            FTileGroup(
                              label: Text(l10n.profileGroupAccount),
                              children: [
                                _navTile(
                                  context,
                                  icon: FLucideIcons.link,
                                  title: l10n.profileLinkedAccounts,
                                  path: '/linked-accounts',
                                ),
                                _navTile(
                                  context,
                                  icon: FLucideIcons.keyRound,
                                  title:
                                      links.isLoading ||
                                          links.hasPassword ||
                                          links.errorMessage != null
                                      ? l10n.profileChangePassword
                                      : l10n.profileCreatePassword,
                                  path:
                                      links.isLoading ||
                                          links.hasPassword ||
                                          links.errorMessage != null
                                      ? '/change-password'
                                      : '/set-password',
                                ),
                              ],
                            ),
                            _sectionGap,
                          ] else ...[
                            FTileGroup(
                              children: [
                                _navTile(
                                  context,
                                  icon: FLucideIcons.logIn,
                                  title: l10n.profileLogin,
                                  path: '/login',
                                  go: true,
                                ),
                                _navTile(
                                  context,
                                  icon: FLucideIcons.userRoundPlus,
                                  title: l10n.profileRegister,
                                  path: '/register',
                                ),
                              ],
                            ),
                            _sectionGap,
                          ],
                              FTileGroup(
                                children: [
                                  apiHostTile(context, ApiHostResolver.instance),
                                ],
                              ),
                              _sectionGap,
                              FTileGroup(
                                label: Text(l10n.profileGroupHelp),
                                children: [
                                  if (allowNotif.visible)
                                    FTile(
                                      prefix: const Icon(
                                        FLucideIcons.bell,
                                        size: 18,
                                      ),
                                      title: Text(l10n.profileAllowNotif),
                                      subtitle: Text(
                                        l10n.profileAllowNotifSubtitle,
                                      ),
                                      enabled: !allowNotif.busy,
                                      suffix: allowNotif.busy
                                          ? const FCircularProgress(size: .sm)
                                          : _chevron,
                                      onPress: allowNotif.busy
                                          ? null
                                          : () => allowNotif.onPress(context),
                                    ),
                                  _navTile(
                                    context,
                                    icon: FLucideIcons.settings,
                                    title: l10n.profileSettingsTile,
                                    subtitle: l10n.profileSettingsSubtitle,
                                    path: SettingsRouter.root.path,
                                  ),
                                ],
                              ),
                          if (state.isAuth) ...[
                            _sectionGap,
                            FTileGroup(
                              label: Text(l10n.profileGroupLogout),
                              children: [
                                FTile(
                                  variant: .destructive,
                                  prefix: const Icon(FLucideIcons.userRoundX),
                                  title: Text(l10n.profileDeleteAccount),
                                  suffix: _chevron,
                                  onPress: () =>
                                      context.push('/delete-account'),
                                ),
                                FTile(
                                  variant: .destructive,
                                  prefix: state.isLoggingOut
                                      ? const FCircularProgress(size: .sm)
                                      : const Icon(FLucideIcons.logOut),
                                  title: Text(
                                    state.isLoggingOut ? l10n.profileLoggingOut : l10n.profileLogout,
                                  ),
                                  enabled: !state.isLoggingOut,
                                  onPress: state.isLoggingOut
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
                          _VersionLabel(future: versionFuture),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _displayNameOf(AuthStatusState? status, String fallback) {
    final display = status?.displayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    final handle = status?.username?.trim();
    if (handle != null && handle.isNotEmpty) return handle;
    return fallback;
  }
}

/// Satu baris menu ber-chevron. Menggantikan 12 salinan FTile + ikon yang
/// sebelumnya ditulis manual di halaman ini.
FTile _navTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  required String path,
  bool go = false,
}) {
  return FTile(
    prefix: Icon(icon, size: 18),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    suffix: _chevron,
    onPress: () => go ? context.go(path) : context.push(path),
  );
}

const Widget _chevron = Icon(FLucideIcons.chevronRight, size: 16);

/// Header identitas tab Profil: avatar besar + cover + stat ringkas.
class _IdentitySection extends ConsumerWidget {
  const _IdentitySection({required this.status});

  final AuthStatusState status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAuth = status.isAuth;
    final username = status.username?.trim();
    // Detail profil publik (bio, stat, bergabung). Tamu tidak watch.
    final usernameLower = username?.toLowerCase();
    final profileAsync =
        isAuth && usernameLower != null && usernameLower.isNotEmpty
        ? ref.watch(publicProfileProvider(usernameLower))
        : null;
    final profile = profileAsync?.asData?.value;

    final border = ref.watch(myActiveBorderProvider).asData?.value?.imageUrl;
    // Tamu: label ajakan masuk tampil di header, bukan username kosong.
    final displayName = isAuth
        ? ProfilePage._displayNameOf(status, l10n.profileDefaultName)
        : l10n.profileGuestName;

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
          title: Text(l10n.profileNotReadyToast),
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

    return Column(
      children: [
        ProfileIdentityHeader(
          variant: ProfileHeaderVariant.hero,
          displayName: displayName,
          username: isAuth ? username : null,
          avatarUrl: status.avatarUrl,
          borderUrl: isAuth ? border : null,
          bio: profile?.bio,
          isVerifier:
              profile?.isVerifier ?? (isAuth && isVerifierRole(status.role)),
          stats: profile == null
              ? null
              : ProfileStatRow(
                  words: profile.wordsApproved,
                  corrections: profile.correctionsApproved,
                ),
          joinedLabel: profile == null
              ? null
              : formatDateTimeIso(profile.joinedAt),
          onAvatarTap: isAuth ? openPublicProfile : null,
          actions: [
            if (isAuth)
              FButton(
                size: .xs,
                variant: FButtonVariant.outline,
                mainAxisSize: MainAxisSize.min,
                prefix: const Icon(FLucideIcons.externalLink, size: 14),
                onPress: openPublicProfile,
                child: Text(l10n.profileViewPublic),
              ),
          ],
          footer: isAuth ? const ProfileAchievementTabs() : null,
        ),
      ],
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel({required this.future});

  final Future<PackageInfo> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: future,
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Center(
          child: Text(
            'v${info.version}(${info.buildNumber})',
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends ConsumerWidget with FTileMixin {
  const _NotificationTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread =
        ref.watch(unreadNotificationCountControllerProvider).value ?? 0;
    return FTile(
      prefix: const Icon(FLucideIcons.bell, size: 18),
      title: Text(l10n.profileNotifications),
      subtitle: unread > 0 ? Text('$unread ${l10n.profileUnreadSuffix}') : null,
      suffix: _chevron,
      onPress: () => context.push(NotificationRouter.list.path),
    );
  }
}

class _ReviewQueueTile extends ConsumerWidget with FTileMixin {
  const _ReviewQueueTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(reviewHubHasPendingProvider).value ?? false;
    return FTile(
      prefix: const Icon(FLucideIcons.shieldCheck, size: 18),
      title: Text(l10n.profileReviewArea),
      subtitle: pending ? Text(l10n.profileReviewPending) : null,
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
          _chevron,
        ],
      ),
      onPress: () => context.push('/review'),
    );
  }
}
