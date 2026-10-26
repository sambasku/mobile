import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/utils/display_image_url.dart';
import 'avatar_border_overlay.dart';
import 'profile_stat_inline.dart';
import 'public_account_name.dart';
import 'user_avatar.dart';

/// Varian header identitas profil.
///
/// - [hero]: avatar besar + konten center (tab Profil). Bingkai achievement
///   butuh avatar besar supaya cincinnya terbaca.
/// - [compact]: avatar sedang + konten rata kiri (profil publik).
enum ProfileHeaderVariant { hero, compact }

/// Header identitas bersama untuk tab Profil dan Profil Publik.
///
/// Satu sumber kebenaran untuk cover, avatar + bingkai, nama, handle, bio,
/// stat 5 angka, dan meta "Bergabung". Dipakai dua halaman supaya perbaikan
/// visual tidak perlu dikerjakan dua kali.
///
/// Param sengaja primitif (tanpa entitas domain) agar halaman tamu, profil
/// sendiri, dan profil orang lain bisa memakai widget yang sama.
class ProfileIdentityHeader extends StatelessWidget {
  const ProfileIdentityHeader({
    super.key,
    required this.variant,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.borderUrl,
    this.bio,
    this.isVerifier = false,
    this.stats,
    this.joinedLabel,
    this.actions = const [],
    this.coverUrl,
    this.onAvatarTap,
    this.footer,
  });

  final ProfileHeaderVariant variant;
  final String displayName;

  /// Handle tanpa `@`. Null/kosong = baris handle tidak dirender.
  final String? username;
  final String? avatarUrl;

  /// URL aset bingkai profil aktif (achievement `profile_border`).
  final String? borderUrl;
  final String? bio;
  final bool isVerifier;

  /// Null = blok stat disembunyikan (tamu / profil belum termuat).
  final ProfileStatGrid? stats;
  final String? joinedLabel;

  /// Tombol di bawah identitas (mis. `Edit` di profil sendiri).
  final List<Widget> actions;

  /// Cover profil. Null = placeholder gradien dari warna primer tema.
  // ponytail: cover masih slot tampilan; sambungkan ke kolom cover_url saat
  // fitur custom cover tersedia.
  final String? coverUrl;
  final VoidCallback? onAvatarTap;

  /// Konten tambahan di bawah identitas (mis. ringkasan lencana).
  final Widget? footer;

  bool get _isHero => variant == ProfileHeaderVariant.hero;

  double get _avatarSize => _isHero ? 104 : 72;
  double get _coverHeight => _isHero ? 96 : 72;
  // AvatarBorderOverlay menggambar cincin di dalam kotak frame yang lebih
  // besar dari fotonya; tinggi art harus ikut frame supaya cincin tidak
  // terpotong tepi atas cover.
  double get _avatarExtent => AvatarBorderOverlay.extent(_avatarSize);
  double get _artHeight => _coverHeight + _avatarExtent / 2;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final handle = username?.trim();
    final bioText = bio?.trim();
    final verticalAlign = _isHero
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = _isHero ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cover + avatar menumpuk: avatar separuh keluar dari cover.
        SizedBox(
          height: _artHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _coverHeight,
                child: _ProfileCover(url: coverUrl),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: _isHero
                      ? Alignment.bottomCenter
                      : Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: _isHero ? 0 : 16),
                    child: Semantics(
                      button: onAvatarTap != null,
                      label: 'Foto profil $displayName',
                      child: GestureDetector(
                        onTap: onAvatarTap,
                        child: AvatarBorderOverlay(
                          size: _avatarSize,
                          borderUrl: borderUrl,
                          child: UserAvatar(
                            name: displayName,
                            imageUrl: avatarUrl,
                            size: _avatarSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(_isHero ? 16 : 16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: verticalAlign,
            children: [
              PublicAccountName(
                label: displayName,
                isVerifier: isVerifier,
                badgeSize: 16,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              if (handle != null && handle.isNotEmpty) ...[
                const Gap(1),
                Text(
                  '@$handle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: textAlign,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              if (bioText != null && bioText.isNotEmpty) ...[
                const Gap(6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    bioText,
                    textAlign: textAlign,
                    maxLines: _isHero ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm,
                  ),
                ),
              ],
              if (stats != null) ...[
                const Gap(10),
                stats!,
              ],
              if (joinedLabel != null && joinedLabel!.trim().isNotEmpty) ...[
                const Gap(6),
                ProfileMetaRow(joinedLabel: joinedLabel!),
              ],
              if (actions.isNotEmpty) ...[
                const Gap(10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: _isHero ? WrapAlignment.center : WrapAlignment.start,
                  children: actions,
                ),
              ],
              if (footer != null) ...[
                const Gap(12),
                footer!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Cover profil: foto bila [url] ada, selain itu gradien primer tema.
class _ProfileCover extends StatelessWidget {
  const _ProfileCover({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colors.primary.withValues(alpha: 0.22),
            theme.colors.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
    );

    final raw = url?.trim();
    if (raw == null || raw.isEmpty) return fallback;
    final display = displayImageUrl(raw, width: 1080) ?? raw;
    return ClipRect(
      child: Image.network(
        display,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // Cover gagal load = gradien, bukan kotak rusak.
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

/// Placeholder skeleton header identitas (pola `mobile-base-stack.md` 5c).
///
/// Merender header asli berisi teks placeholder di dalam [Skeletonizer], jadi
/// struktur dan tinggi mengikuti varian - transisi skeleton -> data tidak
/// melompat - tanpa menduplikasi layout.
class ProfileIdentityHeaderSkeleton extends StatelessWidget {
  const ProfileIdentityHeaderSkeleton({
    super.key,
    this.variant = ProfileHeaderVariant.compact,
  });

  final ProfileHeaderVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // Tanpa `Theme.of`: pohon Forui tidak selalu punya ancestor Material.
    final isDark = theme.colors.background.computeLuminance() < 0.5;
    final muted = theme.colors.muted;

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: ProfileIdentityHeader(
        variant: variant,
        displayName: 'Nama pengguna',
        username: 'username',
        stats: const ProfileStatGrid(
          words: 0,
          corrections: 0,
          verifications: 0,
          comments: 0,
          contributions: 0,
        ),
      ),
    );
  }
}
