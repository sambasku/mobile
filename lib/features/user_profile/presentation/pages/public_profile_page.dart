import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../../shared/utils/photo_pick_constants.dart';
import '../../../../shared/widgets/profile_stat_inline.dart';
import '../../../../shared/widgets/small_button.dart';
import '../../../activity/presentation/providers/activity_feed_providers.dart';
import '../../../activity/presentation/widgets/activity_feed_tile.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../profile/data/avatar_upload_service.dart';
import '../../../profile/presentation/crop_profile_photo.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../../domain/public_activity_mapper.dart';
import '../providers/user_profile_providers.dart';

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
      childPad: true,
      header: FHeader.nested(
        title: Text(
          _appBarTitle(
            async: async,
            isOwnProfile: isOwnProfile,
            sessionDisplayName: me?.displayName,
            initialDisplayName: initialDisplayName,
          ),
        ),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.hasError
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
              loading: () => const Center(child: FCircularProgress()),
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
    );
  }
}

/// Judul app bar: display name dari server, lalu sesi auth, lalu hint navigasi.
/// Jangan pakai handle route sebagai judul.
String _appBarTitle({
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

  return 'Profil';
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
    final canPreviewAvatar =
        !isOwnProfile && avatarSrc != null && avatarSrc.trim().isNotEmpty;
    final uploadingAvatar = useState(false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button:
                    (isOwnProfile && !uploadingAvatar.value) ||
                    canPreviewAvatar,
                label: isOwnProfile
                    ? 'Ganti foto profil'
                    : canPreviewAvatar
                    ? 'Lihat foto profil'
                    : 'Foto profil',
                child: GestureDetector(
                  onTap: isOwnProfile && !uploadingAvatar.value
                      ? () =>
                            _pickAndUploadAvatar(context, ref, uploadingAvatar)
                      : canPreviewAvatar
                      ? () => showImagePreview(context, urls: [avatarSrc])
                      : null,
                  child: _Avatar(
                    name: profile.displayName,
                    imageUrl: avatarSrc,
                    size: 56,
                    showEditBadge: isOwnProfile,
                    uploading: uploadingAvatar.value,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (profile.displayName != profile.username) ...[
                      const Gap(1),
                      Text(
                        '@${profile.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                    if (profile.bio != null &&
                        profile.bio!.trim().isNotEmpty) ...[
                      const Gap(6),
                      Text(
                        profile.bio!,
                        style: theme.typography.sm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isOwnProfile) ...[
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SmallButton(
                    label: 'Edit',
                    onPress: () => context.push('/edit-profile'),
                  ),
                ),
              ],
            ],
          ),
          const Gap(10),
          ProfileStatRow(
            contributions: profile.contributionsApproved,
            verifications: profile.verificationsDone,
            comments: profile.commentsPublished,
          ),
          const Gap(6),
          ProfileMetaRow(joinedLabel: joined, isVerifier: profile.isVerifier),
          const Gap(16),
          Text(
            'Aktivitas terbaru',
            style: theme.typography.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          activityAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: FCircularProgress()),
            ),
            error: (err, _) => Column(
              children: [
                FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(
                    err is UserProfileFailure
                        ? err.message
                        : 'Gagal memuat aktivitas',
                  ),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: onRetryActivity,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Belum ada aktivitas publik.',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final item in items)
                    ActivityFeedTile(
                      item: mapPublicActivityToFeed(item, profile),
                      // Aksi/CTA ke karya sendiri tidak relevan di profil sendiri.
                      showCta: !isOwnProfile,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
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
            title: const Text('Gagal membuka pemotong foto'),
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
                title: const Text('Foto profil diperbarui'),
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.showEditBadge = false,
    this.uploading = false,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final bool showEditBadge;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    if (uploading) {
      return Skeletonizer(enabled: true, child: Bone.circle(size: size));
    }

    final theme = context.theme;
    final display = displayImageUrl(imageUrl, width: 256) ?? imageUrl;
    final Widget face;
    if (display != null && display.isNotEmpty) {
      face = ClipOval(
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
                    _InitialsAvatar(name: name, size: size, theme: theme),
              );
            }
            return _InitialsAvatar(name: name, size: size, theme: theme);
          },
        ),
      );
    } else {
      face = _InitialsAvatar(name: name, size: size, theme: theme);
    }

    if (!showEditBadge) return face;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: theme.colors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colors.background, width: 2),
            ),
            child: Icon(
              FLucideIcons.camera,
              size: 13,
              color: theme.colors.primaryForeground,
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.size, this.theme});

  final String name;
  final double size;
  final FThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final t = theme ?? context.theme;
    final initials = _initials(name);
    return FAvatar.raw(
      size: size,
      style: .delta(backgroundColor: t.colors.primary.withValues(alpha: 0.12)),
      child: Text(
        initials,
        style: t.typography.md.copyWith(
          fontWeight: FontWeight.w700,
          color: t.colors.primary,
          height: 1,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final word = parts.first;
    if (word.length >= 2) return word.substring(0, 2).toUpperCase();
    return word.toUpperCase();
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
        padding: const EdgeInsets.symmetric(vertical: 24),
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
                  ? 'Pengguna tidak ditemukan'
                  : 'Gagal memuat profil',
              style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
            Text(
              failure.message,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
