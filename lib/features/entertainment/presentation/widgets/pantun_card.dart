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
/// Badge pola rima (ABAB/AAAA) diberi tooltip penjelasan supaya istilahnya
/// tidak menggantung tanpa konteks.
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

  /// Konten tambahan di bawah badge rima (mis. tombol hapus balasan).
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
                    for (final line in pantun.lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: theme.typography.body.sm.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(6),
              Row(
                children: [
                  PantunRhymeBadge(scheme: pantun.rhymeScheme),
                  if (onVoteToggle != null) ...[
                    const Gap(10),
                    Flexible(
                      child: PantunVoteBar(
                        pantun: pantun,
                        onToggle: onVoteToggle!,
                      ),
                    ),
                  ],
                  if (footer != null) ...[
                    const Spacer(),
                    footer!,
                  ],
                ],
              ),
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
        border: Border.all(
          color: theme.colors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(8), child: padded),
    );
  }
}

/// Badge pola rima + tooltip penjelasan polanya.
class PantunRhymeBadge extends StatelessWidget {
  const PantunRhymeBadge({super.key, required this.scheme});

  final String scheme;

  static const _explain = {
    'ABAB': 'Baris 1 & 3 berima, baris 2 & 4 berima. Pola pantun klasik.',
    'AAAA': 'Keempat baris berima sama (pantun jenaka/kilat).',
  };

  @override
  Widget build(BuildContext context) {
    final tip = _explain[scheme] ?? 'Pola rima $scheme';
    return FTooltip(
      tipBuilder: (context, _) => Text(tip),
      child: FBadge(variant: FBadgeVariant.outline, child: Text(scheme)),
    );
  }
}
