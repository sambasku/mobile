import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../../shared/utils/photo_pick_constants.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../profile/data/avatar_upload_service.dart';
import '../../../profile/presentation/crop_profile_photo.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../providers/user_profile_providers.dart';

/// Halaman profil publik - GET /api/v1/users/:username (+ activity).
/// Avatar bisa diganti hanya jika username = user yang sedang login.
class PublicProfilePage extends HookConsumerWidget {
  const PublicProfilePage({super.key, required this.username});

  final String username;

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

    // Profil sendiri: pastikan prefs/session ikut username + display_name server.
    useEffect(() {
      final profile = async.asData?.value;
      if (profile == null || !isOwnProfile) return null;
      unawaited(
        ref.read(authStatusProvider.notifier).applySessionIdentity(
              username: profile.username,
              displayName: profile.displayName,
              avatarUrl: profile.avatarUrl,
            ),
      );
      return null;
    }, [
      async.asData?.value.username,
      async.asData?.value.displayName,
      isOwnProfile,
    ]);

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
          async.maybeWhen(
            data: (profile) => profile.displayName,
            orElse: () => username,
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

class _ProfileBody extends ConsumerWidget {
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
    final roleLabel = ProfilePage.roleLabels[profile.role] ?? profile.role;
    final joined = formatDateTimeIso(profile.joinedAt);
    // Prefer avatar dari sesi setelah upload lokal (sebelum invalidate selesai).
    final sessionAvatar = isOwnProfile
        ? ref.watch(authStatusProvider).value?.avatarUrl
        : null;
    final avatarSrc = sessionAvatar ?? profile.avatarUrl;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
        children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              button: isOwnProfile,
              label: isOwnProfile ? 'Ganti foto profil' : 'Foto profil',
              child: GestureDetector(
                onTap: isOwnProfile
                    ? () => _pickAndUploadAvatar(context, ref)
                    : null,
                child: _Avatar(
                  name: profile.displayName,
                  imageUrl: avatarSrc,
                  size: 80,
                  showEditBadge: isOwnProfile,
                ),
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (profile.displayName != profile.username) ...[
                    const Gap(2),
                    Text(
                      '@${profile.username}',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                  if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      profile.bio!,
                      style: theme.typography.sm,
                    ),
                  ],
                  const Gap(4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        roleLabel,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      if (profile.isVerifier)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const VerifiedBadgeIcon(size: 14),
                            const Gap(4),
                            Text(
                              'Verifikator',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (joined.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      'Bergabung $joined',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (isOwnProfile) ...[
          const Gap(16),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => context.push('/edit-profile'),
            child: const Text('Edit profil'),
          ),
        ],
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                label: 'Kontribusi',
                value: '${profile.contributionsApproved}',
              ),
            ),
            const Gap(8),
            Expanded(
              child: _StatChip(
                label: 'Verifikasi',
                value: '${profile.verificationsDone}',
              ),
            ),
            const Gap(8),
            Expanded(
              child: _StatChip(
                label: 'Komentar',
                value: '${profile.commentsPublished}',
              ),
            ),
          ],
        ),
        const Gap(24),
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
            return FTileGroup(
              children: [
                for (final item in items)
                  FTile(
                    title: Text(item.summary),
                    subtitle: Text(
                      [
                        _kindLabel(item.kind),
                        if (item.lemma != null && item.lemma!.isNotEmpty)
                          item.lemma!,
                        formatDateTimeIso(item.occurredAt),
                      ].where((s) => s.isNotEmpty).join(' · '),
                    ),
                    suffix: item.wordId != null
                        ? const Icon(FLucideIcons.chevronRight)
                        : null,
                    onPress: item.wordId == null
                        ? null
                        : () {
                            context.push(
                              DictionaryRouter.detail.path.replaceFirst(
                                ':id',
                                item.wordId!,
                              ),
                            );
                          },
                  ),
              ],
            );
          },
        ),
      ],
      ),
    );
  }

  static String _kindLabel(String kind) => switch (kind) {
    'contribution' => 'Kontribusi',
    'comment' => 'Komentar',
    'verification' => 'Verifikasi',
    _ => kind,
  };

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
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
        final result =
            await AvatarUploadService(ref.read(dioProvider)).upload(cropped);
        if (!context.mounted) return;
        await result.match(
          (err) async {
            showFToast(context: context, title: Text(err));
          },
          (url) async {
            await ref.read(authStatusProvider.notifier).setAvatarUrl(url);
            ref.invalidate(publicProfileProvider(profile.username));
            if (!context.mounted) return;
            showFToast(
              context: context,
              title: const Text('Foto profil diperbarui'),
            );
          },
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(2),
          Text(
            label,
            style: theme.typography.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.showEditBadge = false,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
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
      style: .delta(
        backgroundColor: t.colors.primary.withValues(alpha: 0.12),
      ),
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
