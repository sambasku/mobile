import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart'
    show RefreshIndicator, showModalBottomSheet;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../../shared/utils/photo_pick_constants.dart';
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../../shared/widgets/profile_leveling_chip.dart';
import '../../../../shared/widgets/profile_stat_inline.dart';
import '../../../../shared/widgets/small_button.dart';
import '../../../achievement/presentation/providers/achievement_providers.dart';
import '../../../achievement/presentation/widgets/border_picker_sheet.dart';
import '../../../achievement/presentation/widgets/profile_achievement_tabs.dart';
import '../../../activity/presentation/providers/activity_feed_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../profile/data/avatar_upload_service.dart';
import '../../../profile/presentation/crop_profile_photo.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/profile_activity_section.dart';

/// Halaman profil publik - GET /api/v1/users/:username (+ activity).
/// Avatar bisa diganti hanya jika username = user yang sedang login.
class PublicProfilePage extends HookConsumerWidget {
  const PublicProfilePage({
    super.key,
    required this.username,
    this.initialDisplayName,
  });

  final String username;

  /// Nama dari layar sebelumnya / sesi - tampil di app bar sebelum fetch selesai.
  final String? initialDisplayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(username));
    final activityAsync = ref.watch(publicActivityProvider(username));
    final me = ref.watch(authStatusProvider).value;
    final isOwnProfile =
        me?.isAuth == true &&
        me?.username != null &&
        me!.username!.toLowerCase() == username.toLowerCase();

    // Handle lama (mis. hyphen) di route → sync sesi lalu ganti ke handle baru.
    useEffect(() {
      if (!async.hasError || me?.isAuth != true) return null;
      unawaited(() async {
        final fresh = await ref
            .read(authStatusProvider.notifier)
            .ensureUsernameForProfile();
        if (!context.mounted) return;
        if (fresh == null || fresh.isEmpty) return;
        if (fresh.toLowerCase() == username.toLowerCase()) return;
        context.replace('/users/${Uri.encodeComponent(fresh)}');
      }());
      return null;
    }, [async.hasError, username, me?.isAuth]);

    // Profil sendiri: sync sesi hanya jika beda dari yang sudah di state
    // (hindari rebuild IndexedStack saat animasi back).
    useEffect(
      () {
        final profile = async.asData?.value;
        if (profile == null || !isOwnProfile) return null;
        final session = me;
        final sameUsername =
            session.username?.toLowerCase() == profile.username.toLowerCase();
        final sameDisplay =
            (session.displayName ?? '') == (profile.displayName);
        final sameAvatar =
            (session.avatarUrl ?? '') == (profile.avatarUrl ?? '');
        if (sameUsername && sameDisplay && sameAvatar) return null;
        unawaited(
          ref
              .read(authStatusProvider.notifier)
              .applySessionIdentity(
                username: profile.username,
                displayName: profile.displayName,
                avatarUrl: profile.avatarUrl,
              ),
        );
        return null;
      },
      [
        async.asData?.value.username,
        async.asData?.value.displayName,
        async.asData?.value.avatarUrl,
        isOwnProfile,
      ],
    );

    Future<void> refresh() async {
      ref.invalidate(publicProfileProvider(username));
      ref.invalidate(publicActivityProvider(username));
      if (me?.isAuth == true) {
        await ref.read(authStatusProvider.notifier).ensureUsernameForProfile();
      }
      await ref.read(publicProfileProvider(username).future);
    }

    return FScaffold(
      // childPad: false - gutter horizontal dipasang manual per sliver supaya
      // baris chip kategori bisa full-bleed seperti feed beranda (#193).
      // FScaffold.childPad membungkus SELURUH scroll view, jadi chip ikut
      // terpasung 12px dari tepi + garis bawahnya tidak sampai ke tepi layar.
      childPad: false,
      // Tanpa header: cover full-bleed sampai belakang status bar, tombol
      // back melayang di atasnya (ProfileHeroShell).
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => context.pop(),
        backLabel: AppLocalizations.of(context).commonBack,
        coverHeight: ProfileIdentityHeader.coverHeightOf(
          ProfileHeaderVariant.compact,
        ),
        title: _appBarTitle(
          l10n: AppLocalizations.of(context),
          async: async,
          isOwnProfile: isOwnProfile,
          sessionDisplayName: me?.displayName,
          initialDisplayName: initialDisplayName,
        ),
        scrollView: async.hasError
            ? _ErrorState(
                failure: async.error is UserProfileFailure
                    ? async.error! as UserProfileFailure
                    : UserProfileFailure(async.error.toString()),
                onRetry: () {
                  ref.invalidate(publicProfileProvider(username));
                  ref.invalidate(publicActivityProvider(username));
                },
              )
            : async.when(
                loading: () => const _PublicProfileLoadingBody(),
                error: (_, _) => const SizedBox.shrink(),
                data: (profile) => _ProfileBody(
                  profile: profile,
                  isOwnProfile: isOwnProfile,
                  activityAsync: activityAsync,
                  onRefresh: refresh,
                  onRetryActivity: () =>
                      ref.invalidate(publicActivityProvider(username)),
                ),
              ),
      ),
    );
  }
}

/// Judul app bar: display name dari server, lalu sesi auth, lalu hint navigasi.
/// Jangan pakai handle route sebagai judul.
String _appBarTitle({
  required AppLocalizations l10n,
  required AsyncValue<PublicProfile> async,
  required bool isOwnProfile,
  required String? sessionDisplayName,
  required String? initialDisplayName,
}) {
  final fromServer = async.asData?.value.displayName.trim();
  if (fromServer != null && fromServer.isNotEmpty) return fromServer;

  if (isOwnProfile) {
    final fromSession = sessionDisplayName?.trim();
    if (fromSession != null && fromSession.isNotEmpty) return fromSession;
  }

  final fromRoute = initialDisplayName?.trim();
  if (fromRoute != null && fromRoute.isNotEmpty) return fromRoute;

  return l10n.profileViewTitle;
}

class _ProfileBody extends HookConsumerWidget {
  const _ProfileBody({
    required this.profile,
    required this.isOwnProfile,
    required this.activityAsync,
    required this.onRefresh,
    required this.onRetryActivity,
  });

  final PublicProfile profile;
  final bool isOwnProfile;
  final AsyncValue<List<PublicActivityItem>> activityAsync;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetryActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final joined = formatDateTimeIso(profile.joinedAt);
    // Prefer avatar dari sesi setelah upload lokal (sebelum invalidate selesai).
    final sessionAvatar = isOwnProfile
        ? ref.watch(authStatusProvider).value?.avatarUrl
        : null;
    final avatarSrc = sessionAvatar ?? profile.avatarUrl;
    // Bingkai profil: profil sendiri baca live dari /me/achievements supaya
    // langsung berubah setelah pilih bingkai; profil orang lain pakai wire
    // active_border_url dari profil publik.
    final myBorder = isOwnProfile
        ? ref.watch(myActiveBorderProvider).asData?.value
        : null;
    final borderUrl = isOwnProfile
        ? myBorder?.imageUrl
        : profile.activeBorderUrl;
    final canPreviewAvatar =
        !isOwnProfile && avatarSrc != null && avatarSrc.trim().isNotEmpty;
    final uploadingAvatar = useState(false);
    final activityFilter = useState(ProfileActivityFilter.all);
    // Chip pinned berhenti di bawah bar melayang (status bar + bar aksi),
    // bukan menempel ke tepi atas layar.
    final barOffset =
        MediaQuery.paddingOf(context).top + ProfileHeroShell.barHeight;

    return RefreshIndicator(
      onRefresh: onRefresh,
      // Spinner mulai di bawah bar melayang, bukan di baliknya.
      displacement: barOffset + 8,
      // Sliver (bukan ListView): baris chip kategori bisa PIN di bawah bar
      // melayang - pola sama dengan feed beranda (#193).
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            // Header identitas full-bleed (cover selebar layar); gutter
            // horizontal dipasang di dalam widget header.
            padding: EdgeInsets.zero,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header identitas bersama dengan tab Profil: beda varian
                  // (compact), struktur dan ritme sama.
                  ProfileIdentityHeader(
                    variant: ProfileHeaderVariant.compact,
                    displayName: profile.displayName,
                    username: profile.username,
                    avatarUrl: avatarSrc,
                    borderUrl: borderUrl,
                    bio: profile.bio,
                    isVerifier: profile.isVerifier,
                    leveling: profile.leveling == null
                        ? null
                        : ProfileLevelingChip(leveling: profile.leveling!),
                    stats: ProfileStatRow(
                      words: profile.wordsApproved,
                      corrections: profile.correctionsApproved,
                    ),
                    joinedLabel: joined,
                    onAvatarTap: isOwnProfile && !uploadingAvatar.value
                        ? () =>
                              _showAvatarActions(context, ref, uploadingAvatar)
                        : canPreviewAvatar
                        ? () => showImagePreview(context, urls: [avatarSrc])
                        : null,
                    actions: [
                      if (isOwnProfile)
                        SmallButton(
                          label: AppLocalizations.of(context).profileEditAction,
                          onPress: () => context.push('/edit-profile'),
                        ),
                    ],
                    footer: ProfileAchievementTabs(
                      username: isOwnProfile ? null : profile.username,
                      showTitle: true,
                    ),
                  ),
                  const Gap(12),
                ],
              ),
            ),
          ),
        // Chip kategori menempel di bawah bar melayang saat scroll.
        SliverPersistentHeader(
          pinned: true,
          delegate: ProfileActivityChipsHeader(
            topOffset: barOffset,
            // body.sm + w700: sama dengan heading feed beranda; jangan
            // body.md (line height 24) - titleHeight default 18 memotong teks.
            title: Text(
              AppLocalizations.of(context).profileActivityRecent,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: ProfileActivityChips(
              selected: activityFilter.value,
              onChanged: (next) {
                if (next == activityFilter.value) return;
                HapticFeedback.selectionClick();
                activityFilter.value = next;
              },
            ),
          ),
        ),
        SliverPadding(
          // Gutter horizontal manual (childPad false) + jarak bawah.
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
          sliver: SliverToBoxAdapter(
            child: ProfileActivityList(
              username: profile.username,
              profile: profile,
              filter: activityFilter.value,
              activityAsync: activityAsync,
              onRetry: onRetryActivity,
              showCta: !isOwnProfile,
            ),
          ),
        ),
        ],
      ),
    );
  }

  /// Bottom sheet tap avatar sendiri: ganti foto atau ubah bingkai.
  Future<void> _showAvatarActions(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> uploadingAvatar,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  prefix: const Icon(FLucideIcons.camera),
                  title: Text(
                    AppLocalizations.of(sheetContext).profileChangePhoto,
                  ),
                  onPress: () => Navigator.of(sheetContext).pop('photo'),
                ),
                FTile(
                  prefix: const Icon(FLucideIcons.frame),
                  title: Text(
                    AppLocalizations.of(sheetContext).profileChangeFrame,
                  ),
                  onPress: () => Navigator.of(sheetContext).pop('border'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == 'photo') {
      await _pickAndUploadAvatar(context, ref, uploadingAvatar);
    } else if (action == 'border') {
      await showBorderPickerSheet(context);
    }
  }

  Future<void> _pickAndUploadAvatar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> uploadingAvatar,
  ) async {
    showImageSheetDrawer(
      context,
      filePicker: false,
      maxWidth: kAvatarPickMaxWidth,
      maxHeight: kAvatarPickMaxHeight,
      imageQuality: kPhotoPickQuality,
      onPicked: (file) async {
        // Sheet sumber ditutup dulu supaya activity crop tidak bentrok.
        await Future<void>.delayed(Duration.zero);
        if (!context.mounted) return;
        final File? cropped;
        try {
          cropped = await cropProfilePhoto(context, file.path);
        } catch (_) {
          if (!context.mounted) return;
          showFToast(
            context: context,
            title: Text(
              AppLocalizations.of(context).profilePhotoPickerFailed,
            ),
          );
          return;
        }
        if (cropped == null || !context.mounted) return;
        uploadingAvatar.value = true;
        try {
          final result = await AvatarUploadService(
            ref.read(dioProvider),
          ).upload(cropped);
          if (!context.mounted) return;
          await result.match(
            (err) async {
              showFToast(context: context, title: Text(err));
            },
            (url) async {
              await ref.read(authStatusProvider.notifier).setAvatarUrl(url);
              ref.invalidate(publicProfileProvider(profile.username));
              await ref
                  .read(responseCacheStoreProvider)
                  .deleteByPrefix('GET|/api/v1/activity');
              ref.invalidate(activityFeedProvider);
              if (!context.mounted) return;
              showFToast(
                context: context,
                title: Text(
                  AppLocalizations.of(context).profilePhotoUpdated,
                ),
              );
            },
          );
        } finally {
          if (context.mounted) uploadingAvatar.value = false;
        }
      },
    );
  }
}

/// Loading penuh: header + lencana + chip + feed - semua Skeletonizer,
/// bukan spinner. Tinggi mendekati isi asli supaya scroll tidak loncat.
class _PublicProfileLoadingBody extends StatelessWidget {
  const _PublicProfileLoadingBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final barOffset =
        MediaQuery.paddingOf(context).top + ProfileHeroShell.barHeight;

    return IgnorePointer(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ProfileIdentityHeaderSkeleton(
                  footer: _BadgeGridSkeleton(),
                ),
                const Gap(12),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: ProfileActivityChipsHeader(
              topOffset: barOffset,
              title: Text(
                l10n.profileActivityRecent,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: ProfileActivityChips(
                selected: ProfileActivityFilter.all,
                onChanged: (_) {},
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 32),
            sliver: SliverToBoxAdapter(
              child: ProfileActivityListSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bone 3 kolom di dalam [ProfileIdentityHeaderSkeleton] (sudah Skeletonizer).
class _BadgeGridSkeleton extends StatelessWidget {
  const _BadgeGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Bone.text(
          words: 1,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = (constraints.maxWidth - 24) / 3;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < 3; i++)
                  SizedBox(
                    width: cellWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colors.border),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AspectRatio(aspectRatio: 1, child: Bone.square()),
                          Gap(4),
                          Bone.text(words: 2),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure, required this.onRetry});

  final UserProfileFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        // Gutter horizontal manual (childPad false di FScaffold).
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              failure.isNotFound
                  ? FLucideIcons.searchX
                  : FLucideIcons.circleAlert,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              failure.isNotFound
                  ? AppLocalizations.of(context).profileUserNotFound
                  : AppLocalizations.of(context).profileLoadFailed,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
            Text(
              failure.message,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onRetry,
              child: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
