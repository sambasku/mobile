import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/presentation/providers/chat_unread_provider.dart';
import '../../../contribution/contribution_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../search_miss/search_miss_router.dart';
import '../../../vote/periksa_kata_router.dart';
import '../../dictionary_router.dart';
import '../providers/word_list_providers.dart';

/// Satu baris tile aksi, dipakai Home DAN tab Kontribusi (tombol identik):
/// Cari / A-Z / Tambah Kata / Ruang Diskusi / Kata Belum Ada / Periksa Kata.
/// Scroll horizontal; kotak ikon 1:1; label di bawahnya.
class ActionChipsRow extends ConsumerWidget {
  const ActionChipsRow({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 0),
    this.from = 'home',
  });

  /// Gutter kiri-kanan. Home: 12 (carousel full-bleed). Tab Kontribusi: zero
  /// karena shell sudah memberi padding 12.
  final EdgeInsets padding;

  /// Sumber analytics `contribute_start` (`home` / `kontribusi`).
  final String from;

  /// Lebar kotak ikon (= tinggi, rasio 1:1). Sama dengan lebar kolom,
  /// supaya jarak antar kotak = separator 8px (pola chip Kontribusi).
  static const double _tileSize = 48;

  /// Slot label di bawah kotak (2 baris kecil).
  static const double _labelSlot = 28;

  /// Tinggi total baris (kotak + gap + label).
  static const double height = _tileSize + 6 + _labelSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(chatUnreadProvider);
    final items = <_ActionChip>[
      _ActionChip(
        icon: FLucideIcons.search,
        label: l10n.dictSearchChip,
        semanticsLabel: l10n.dictSearchHint,
        onPress: () {
          // #296: jangan bawa query keepAlive / riwayat disk ke field baru.
          ref.read(wordListProvider.notifier).clearSearchSession();
          context.push('${DictionaryRouter.list.path}?focus=1');
        },
      ),
      _ActionChip(
        icon: FLucideIcons.aLargeSmall,
        label: l10n.dictAZ,
        onPress: () => context.push(
          DictionaryRouter.letter.path.replaceFirst(':letter', 'a'),
        ),
      ),
      _ActionChip(
        icon: FLucideIcons.plus,
        label: l10n.dictProposeChip,
        semanticsLabel: l10n.dictProposeWord,
        onPress: () {
          AnalyticsService.instance.log(
            AnalyticsEvents.contributeStart,
            params: {'from': from},
          );
          context.push(ContributionRouter.contribute.path);
        },
      ),
      _ActionChip(
        icon: FLucideIcons.messagesSquare,
        label: l10n.dictDiscussionChip,
        semanticsLabel: unread.personal > 0
            ? l10n.dictDiscussionMentionSemantics(unread.personal)
            : unread.total > 0
            ? l10n.dictDiscussionUnreadSemantics
            : l10n.dictDiscussionSubtitle,
        badgeCount: unread.personal,
        showDot: unread.personal == 0 && unread.total > 0,
        onPress: () {
          // Tap = tandai terbaca; pesan baru berikutnya memunculkan badge lagi.
          unawaited(ref.read(chatUnreadProvider.notifier).markAsRead());
          context.push(DiscussionRouter.chat.path);
        },
      ),
      _ActionChip(
        icon: FLucideIcons.searchX,
        label: l10n.feedContributeSearchMiss,
        onPress: () => context.push(SearchMissRouter.list.path),
      ),
      _ActionChip(
        icon: FLucideIcons.clipboardCheck,
        label: l10n.feedContributePeriksaKata,
        onPress: () => context.push(PeriksaKataRouter.check.path),
      ),
    ];

    return SizedBox(
      height: height,
      child: ListView.separated(
        key: const ValueKey('action_chips_row'),
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) => _ActionTile(item: items[i]),
      ),
    );
  }
}

class _ActionChip {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPress,
    this.semanticsLabel,
    this.badgeCount = 0,
    this.showDot = false,
  });

  final IconData icon;
  final String label;
  final String? semanticsLabel;
  final VoidCallback onPress;

  /// Angka merah (reply/mention ke saya). 0 = tidak tampil.
  final int badgeCount;

  /// Titik kecil (pesan umum baru); diabaikan bila [badgeCount] > 0.
  final bool showDot;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.item});

  final _ActionChip item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = ActionChipsRow._tileSize;
    return Semantics(
      button: true,
      label: item.semanticsLabel ?? item.label,
      child: FTappable(
        onPress: item.onPress,
        // Lebar = ukuran kotak: jarak antar kotak = separator saja (8px).
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            size: 18,
                            color: theme.colors.foreground,
                          ),
                        ),
                      ),
                    ),
                    // Di dalam batas kotak: ListView horizontal memotong overflow.
                    if (item.badgeCount > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: _UnreadPill(
                          key: const ValueKey('home_chip_badge_count'),
                          count: item.badgeCount,
                        ),
                      )
                    else if (item.showDot)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: DecoratedBox(
                          key: const ValueKey('home_chip_badge_dot'),
                          decoration: BoxDecoration(
                            color: theme.colors.destructive,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 8, height: 8),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.xs.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: theme.colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pil angka merah kecil (maks `99+`) di pojok kotak chip.
class _UnreadPill extends StatelessWidget {
  const _UnreadPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.destructive,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Center(
            widthFactor: 1,
            child: Text(
              count > 99 ? '99+' : '$count',
              style: theme.typography.body.xs.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1,
                color: theme.colors.destructiveForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
