import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../activity/presentation/widgets/activity_feed_tile.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../../domain/public_activity_mapper.dart';
import '../providers/user_profile_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Kategori chips aktivitas profil publik, selaras feed beranda (#193):
/// Semua | Perbaikan | Komentar. "Penilaian" tidak ada di feed utama.
///
/// `wire` = query `kind` API; null = mode merge (tanpa filter).
enum ProfileActivityFilter {
  all(null),
  correction('contribution'),
  comment('comment');

  const ProfileActivityFilter(this.kind);

  final String? kind;
}

/// Label chip filter. Domain hanya menyimpan nilai wire.
String profileActivityFilterLabel(
  AppLocalizations l10n,
  ProfileActivityFilter filter,
) => switch (filter) {
  ProfileActivityFilter.all => l10n.profileActivityFilterAll,
  ProfileActivityFilter.correction => l10n.profileActivityFilterCorrection,
  ProfileActivityFilter.comment => l10n.profileActivityFilterComment,
};

/// Baris chip kategori. Dipakai di delegate pinned dan di test.
class ProfileActivityChips extends StatelessWidget {
  const ProfileActivityChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ProfileActivityFilter selected;
  final ValueChanged<ProfileActivityFilter> onChanged;

  /// Tinggi baris chip (dipakai delegate pinned).
  static const double height = 36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        key: const ValueKey('profile_activity_chips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
        itemCount: ProfileActivityFilter.values.length,
        separatorBuilder: (_, _) => const Gap(6),
        itemBuilder: (context, i) {
          final filter = ProfileActivityFilter.values[i];
          return FButton(
            size: .xs,
            variant: filter == selected
                ? FButtonVariant.primary
                : FButtonVariant.outline,
            mainAxisSize: MainAxisSize.min,
            onPress: () => onChanged(filter),
            child: Text(
            profileActivityFilterLabel(AppLocalizations.of(context), filter),
          ),
          );
        },
      ),
    );
  }
}

/// Delegate pinned: chip kategori menempel di bawah bar melayang.
/// Latar opaque wajib - tanpa itu item feed tembus di belakang chip.
class ProfileActivityChipsHeader extends SliverPersistentHeaderDelegate {
  ProfileActivityChipsHeader({required this.child, this.topOffset = 0});

  final Widget child;

  /// Tinggi bar melayang di atas chip (status bar + bar aksi). Chip berhenti
  /// di bawahnya, tidak menabrak status bar.
  final double topOffset;

  static const double _bottomGap = 8;

  @override
  double get minExtent => topOffset + ProfileActivityChips.height + _bottomGap;

  @override
  double get maxExtent => topOffset + ProfileActivityChips.height + _bottomGap;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: overlapsContent
              ? [
                  BoxShadow(
                    color: theme.colors.foreground.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ruang untuk bar melayang: chip berhenti di bawahnya.
            SizedBox(height: topOffset),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colors.border, width: 0.5),
                ),
              ),
              child: child,
            ),
            const SizedBox(height: _bottomGap),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(ProfileActivityChipsHeader oldDelegate) =>
      oldDelegate.child != child || oldDelegate.topOffset != topOffset;
}

/// Isi feed aktivitas sesuai filter terpilih.
///
/// - "Semua": [activityAsync] (mode merge, tanpa pagination).
/// - Kategori lain: [publicActivityByKindProvider]; skeleton saat pertama
///   dimuat (chips tetap aktif - pelajaran bug #193).
class ProfileActivityList extends ConsumerWidget {
  const ProfileActivityList({
    super.key,
    required this.username,
    required this.profile,
    required this.filter,
    required this.activityAsync,
    required this.onRetry,
    required this.showCta,
  });

  final String username;
  final PublicProfile profile;
  final ProfileActivityFilter filter;
  final AsyncValue<List<PublicActivityItem>> activityAsync;
  final VoidCallback onRetry;
  final bool showCta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (filter == ProfileActivityFilter.all) {
      return activityAsync.when(
        loading: () => const _CenteredLoader(),
        error: (err, _) => _ErrorBox(
          message: err is UserProfileFailure
              ? err.message
              : l10n.profileActivityLoadFailed,
          onRetry: onRetry,
        ),
        data: (items) => _ActivityList(
          items: items,
          profile: profile,
          showCta: showCta,
          emptyLabel: l10n.profileActivityEmpty,
        ),
      );
    }

    final kind = filter.kind!;
    return ref
        .watch(publicActivityByKindProvider(username, kind))
        .when(
          loading: () => const _CenteredLoader(),
          error: (err, _) => _ErrorBox(
            message: err is UserProfileFailure
                ? err.message
                : l10n.profileActivityLoadFailed,
            onRetry: () =>
                ref.invalidate(publicActivityByKindProvider(username, kind)),
          ),
          data: (state) => _ActivityList(
            items: state.items,
            profile: profile,
            showCta: showCta,
            emptyLabel: l10n.profileActivityEmptyFiltered(
              profileActivityFilterLabel(l10n, filter).toLowerCase(),
            ),
          ),
        );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({
    required this.items,
    required this.profile,
    required this.showCta,
    required this.emptyLabel,
  });

  final List<PublicActivityItem> items;
  final PublicProfile profile;
  final bool showCta;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          emptyLabel,
          style: theme.typography.body.sm.copyWith(
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
            showCta: showCta,
          ),
      ],
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: FCircularProgress()),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FAlert(variant: FAlertVariant.destructive, title: Text(message)),
        const Gap(8),
        FButton(
          variant: FButtonVariant.outline,
          onPress: onRetry,
          child: const Text('Coba lagi'),
        ),
      ],
    );
  }
}
