import 'package:material_ui/material_ui.dart' show Colors, InkWell, Material;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/widgets/public_account_name.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../domain/pantun_models.dart';
import 'pantun_vote_bar.dart';

/// Kartu pantun bergaya thread (konsisten dengan [ThreadMessageRow] di
/// Ruang Diskusi): avatar + nama ✓ + handle + tanggal, isi 4 baris, footer.
///
/// Bait dibagi dua kelompok visual: baris 1-2 (pembayang) redup, baris 3-4
/// (isi) tegas - pembeda struktur tanpa perlu badge pola rima.
class PantunCard extends StatelessWidget {
  const PantunCard({
    super.key,
    required this.pantun,
    this.onTap,
    this.footer,
    this.onUsernameTap,
    this.onVoteToggle,
    this.highlighted = false,
  });

  final Pantun pantun;
  final VoidCallback? onTap;

  /// Konten tambahan di bawah baris vote (mis. aksi hapus).
  final Widget? footer;
  final VoidCallback? onUsernameTap;

  /// Non-null = tampilkan bar vote. Caller menyediakan toggle dari
  /// controller feed/detail; null = kartu tanpa vote (skeleton/preview).
  final Future<String?> Function(Pantun pantun, int value)? onVoteToggle;

  /// Latar lembut untuk balasan yang dituju deep-link (`?reply=`).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = displayPublicAccountLabel(
      displayName: pantun.displayName,
      username: pantun.username,
    );
    final showHandle =
        pantun.username != null &&
        pantun.username != label &&
        pantun.username!.isNotEmpty;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(name: label, imageUrl: pantun.avatarUrl, size: 28),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: PublicAccountName(
                      label: label,
                      isVerifier: pantun.isVerifier,
                      onTap: onUsernameTap,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: onUsernameTap == null
                            ? theme.colors.foreground
                            : theme.colors.primary,
                      ),
                    ),
                  ),
                  const Gap(6),
                  Text(
                    formatRelativeAgo(pantun.createdAt),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              // Handle @username di baris sendiri di bawah nama.
              if (showHandle) ...[
                const Gap(2),
                Text(
                  '@${pantun.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
              const Gap(6),
              // Bait diberi aksen garis kiri supaya beda dari meta header,
              // tapi tetap satu blok padat (bukan 4 kartu terpisah).
              Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colors.primary.withValues(alpha: 0.35),
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < pantun.lines.length; i++) ...[
                      // Jeda antar kelompok: pembayang (1-2) vs isi (3-4).
                      if (i == 2) const Gap(6),
                      Text(
                        pantun.lines[i],
                        style: theme.typography.body.sm.copyWith(
                          height: 1.5,
                          color: i < 2
                              ? theme.colors.mutedForeground
                              : theme.colors.foreground,
                          fontWeight: i < 2 ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Vote/Tindakan di baris sendiri: tanpa kompetisi lebar,
              // jadi panah balasan tidak menyusut (FittedBox di VoteButtons).
              if (onVoteToggle != null || footer != null) const Gap(6),
              if (onVoteToggle != null)
                PantunVoteBar(pantun: pantun, onToggle: onVoteToggle!),
              if (footer != null) ...[
                if (onVoteToggle != null) const Gap(2),
                Align(alignment: Alignment.centerRight, child: footer!),
              ],
            ],
          ),
        ),
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: onTap == null
          ? content
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: content,
            ),
    );
    if (!highlighted) return padded;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(padding: const EdgeInsets.all(8), child: padded),
    );
  }
}

/// Aksi footer milik penulis/pelapor (satu widget, dua permukaan).
/// Hapus = [FLucideIcons.trash], Laporkan = [FLucideIcons.flag].
class PantunActionRow extends StatelessWidget {
  const PantunActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Footer hapus untuk penulis sendiri.
  factory PantunActionRow.delete({
    Key? key,
    required VoidCallback onDelete,
    String label = 'Hapus',
  }) =>
      PantunActionRow(
        key: key,
        icon: FLucideIcons.trash,
        label: label,
        onTap: onDelete,
      );

  /// Footer laporkan untuk pantun/balasan orang lain.
  factory PantunActionRow.report({
    Key? key,
    required VoidCallback onReport,
    String label = 'Laporkan',
  }) =>
      PantunActionRow(
        key: key,
        icon: FLucideIcons.flag,
        label: label,
        onTap: onReport,
      );

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: theme.colors.mutedForeground),
                const Gap(4),
                Text(
                  label,
                  style: theme.typography.body.sm.copyWith(
                    fontSize: 11,
                    color: theme.colors.mutedForeground,
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
