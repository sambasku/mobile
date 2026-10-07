import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/entities/feed_activity_item.dart';
import 'activity_kind_avatar.dart';

/// Satu baris feed "Aktivitas terbaru" (home + profil publik).
class ActivityFeedTile extends StatelessWidget {
  const ActivityFeedTile({super.key, required this.item, this.showCta = true});

  final FeedActivityItem item;

  /// false = sembunyikan label CTA + chevron di kanan (mis. profil sendiri,
  /// aksi ke karya sendiri tidak relevan). Tap baris tetap navigasi.
  final bool showCta;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final actorLabel = item.actor == null
        ? 'Warga'
        : displayPublicAccountLabel(
            displayName: item.actor!.displayName,
            username: item.actor!.username,
          );
    final canOpenProfile = isLinkablePublicUsername(item.actor?.username);
    final dateLabel = formatRelativeCompact(DateTime.tryParse(item.createdAt));
    final kindLabel = _friendlyKindLabel(item.kind);
    final subtitle = item.subtitle?.trim();
    final contextMeta = [
      ?kindLabel,
      if (subtitle != null && subtitle.isNotEmpty) subtitle,
    ].join(' · ');
    final path = _navigatePath(item);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canOpenProfile
              ? () => UserProfileRouter.open(context, item.actor!.username!)
              : null,
          child: ActivityKindAvatar(
            kind: item.kind,
            imageUrl: item.actor?.avatarUrl,
            name: actorLabel,
            size: 40,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canOpenProfile
                      ? () => UserProfileRouter.open(
                            context,
                            item.actor!.username!,
                          )
                      : null,
                  child: Text(
                    actorLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: canOpenProfile
                          ? theme.colors.primary
                          : theme.colors.foreground,
                    ),
                  ),
                ),
                if (canOpenProfile)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => UserProfileRouter.open(
                      context,
                      item.actor!.username!,
                    ),
                    child: Text(
                      '@${item.actor!.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ),
              ],
            ),
          ),
                  if (dateLabel.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      dateLabel,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(4),
              Text.rich(
                TextSpan(
                  children: [
                    // Komentar/diskusi = teks bebas user; kutipannya bukan lemma.
                    for (final (text, lemma) in switch (item.kind) {
                      FeedActivityKind.comment ||
                      FeedActivityKind.discussion => [(item.body, false)],
                      _ => splitQuotedLemma(item.body),
                    })
                      TextSpan(
                        text: text,
                        style: lemma
                            ? const TextStyle(fontWeight: FontWeight.w700)
                            : null,
                      ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  height: 1.35,
                  color: theme.colors.foreground,
                ),
              ),
              if (contextMeta.isNotEmpty || path != null) ...[
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contextMeta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.25,
                        ),
                      ),
                    ),
                    // CTA hanya label; tap ditangani InkWell baris (tujuan sama).
                    // Sengaja muted: fokus visual tetap di lemma, bukan CTA.
                    if (showCta && path != null) ...[
                      const Gap(8),
                      Text(
                        _ctaLabel(item.kind),
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: path == null
            ? null
            : () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.push(path);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: content,
        ),
      ),
    );
  }

  /// Label singkat non-teknis di meta (bukan entity_type mentah).
  static String? _friendlyKindLabel(FeedActivityKind kind) {
    return switch (kind) {
      FeedActivityKind.word => 'Kata',
      FeedActivityKind.comment => 'Komentar',
      FeedActivityKind.vote => 'Penilaian',
      FeedActivityKind.discussion => 'Diskusi',
      FeedActivityKind.wordImage => 'Foto',
      FeedActivityKind.wordAudio => 'Suara',
      FeedActivityKind.pronunciation => 'Cara baca',
      FeedActivityKind.example => 'Contoh',
      FeedActivityKind.searchMiss => 'Kata tidak ditemukan',
      FeedActivityKind.welcome => 'Bergabung',
      FeedActivityKind.cardShare => 'Bagikan',
      FeedActivityKind.suggestion => 'Usulan',
      FeedActivityKind.contribution => 'Usulan kata baru',
      FeedActivityKind.verification => 'Verifikasi',
    };
  }

  static String _ctaLabel(FeedActivityKind kind) {
    return switch (kind) {
      FeedActivityKind.vote => 'Ikut menilai',
      FeedActivityKind.word => 'Lihat arti',
      FeedActivityKind.comment => 'Balas',
      FeedActivityKind.discussion => 'Ikut diskusi',
      FeedActivityKind.wordImage => 'Lihat foto',
      FeedActivityKind.wordAudio => 'Dengarkan',
      FeedActivityKind.pronunciation => 'Lihat cara baca',
      FeedActivityKind.example => 'Lihat contoh',
      FeedActivityKind.searchMiss => 'Bantu isi',
      FeedActivityKind.welcome => 'Lihat profil',
      FeedActivityKind.cardShare => 'Lihat kartu',
      FeedActivityKind.suggestion => 'Lihat usulan',
      FeedActivityKind.contribution => 'Lihat kata',
      FeedActivityKind.verification => 'Lihat kata',
    };
  }

  String? _navigatePath(FeedActivityItem item) {
    final target = item.target;
    if (target == null) return null;
    switch (target.type) {
      case 'word':
        return DictionaryRouter.detail.path.replaceFirst(':id', target.id);
      case 'discussion':
        return DiscussionRouter.detailPath(target.id);
      case 'user':
        final username = item.actor?.username?.trim();
        if (username == null ||
            username.isEmpty ||
            !isLinkablePublicUsername(username)) {
          return null;
        }
        return UserProfileRouter.profile.path.replaceFirst(
          ':username',
          Uri.encodeComponent(username),
        );
      case 'search_miss':
        final term = _searchMissTerm(item);
        final q = Uri(
          queryParameters: <String, String>{
            if (term != null && term.isNotEmpty) 'lemma': term,
            'miss_id': target.id,
          },
        ).query;
        return '${ContributionRouter.contribute.path}?$q';
      default:
        return null;
    }
  }

  String? _searchMissTerm(FeedActivityItem item) {
    // Baru: Mencari "term" - belum ada...
    // Lama: mencari term tapi tidak terdapat...
    final body = item.body;
    final quoted = RegExp(r'Mencari "([^"]+)"').firstMatch(body);
    if (quoted != null) return quoted.group(1)?.trim();
    const prefix = 'mencari ';
    const suffix = ' tapi tidak terdapat';
    if (!body.startsWith(prefix) || !body.contains(suffix)) return null;
    return body.substring(prefix.length, body.indexOf(suffix)).trim();
  }
}
