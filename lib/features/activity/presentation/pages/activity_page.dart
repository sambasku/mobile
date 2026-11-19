import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/header_action_icon.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../search_miss/search_miss_router.dart';
import '../../../vote/periksa_kata_router.dart';
import '../../../vote/presentation/providers/vote_deck_providers.dart';
import '../../../vote/presentation/widgets/vote_deck_section.dart';
import '../providers/contribution_guide_providers.dart';
import '../widgets/contribution_guide_sheet.dart';
import '../../../../l10n/app_localizations.dart';

/// Tab KONTRIBUSI: grid hub (Dicari / Periksa) + deck nilai kata.
///
/// Deck sengaja **di luar** scroll view supaya swipe-atas (lewati) tidak
/// bentrok dengan `CustomScrollView` / pull-to-refresh.
class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  bool _guideChecked = false;

  /// Sama Explore: ikon 48 + gap 6 + 2 baris label (~28).
  static const _menuIconSize = 48.0;
  static const _menuSpacing = 8.0;
  static const _menuColumns = 2;
  static const _cellHeight = _menuIconSize + 6 + 28;

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(voteDeckControllerProvider.notifier).refresh(),
      ref.refresh(voteDeckGuestSamplesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Guide sekali di kunjungan pertama: cek unread pasca frame pertama.
    if (!_guideChecked) {
      _guideChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowGuide());
    }

    // Grid: top Gap 8 + satu baris tile + Gap 8 di bawah.
    const gridBlock = 8 + _cellHeight + 8;

    return Column(
      children: [
        FHeader(
          title: const BrandWordmark(),
          suffixes: [
            FHeaderAction(
              icon: const Icon(
                FLucideIcons.refreshCw,
                size: kHeaderActionIconSize,
              ),
              onPress: _refresh,
            ),
            const ThemeToggleHeaderAction(),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  // Minimal setinggi viewport agar pull-to-refresh tetap
                  // jalan meski konten tidak meluap.
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap(8),
                      _ContributeHubGrid(
                        iconSize: _menuIconSize,
                        spacing: _menuSpacing,
                        columns: _menuColumns,
                        cellHeight: _cellHeight,
                      ),
                      const Gap(8),
                      // Deck mengisi sisa viewport minus grid hub.
                      SizedBox(
                        height: (constraints.maxHeight - gridBlock).clamp(
                          200.0,
                          double.infinity,
                        ),
                        child: _VoteDeckHost(),
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tampilkan guide hanya jika unread. Guard sesi app: maks sekali per
  /// sesi meski user bolak-balik tab. Persist hanya lewat tap "Mengerti".
  Future<void> _maybeShowGuide() async {
    final unread = await ref.read(contributionGuideUnreadProvider.future);
    if (!mounted || !unread) return;
    await showContributionGuideSheet(context);
    if (!mounted) return;
    // Pop dialog TIDAK men-notify routerDelegate. Kalau selama guide
    // terbuka ada notifikasi router nyasar (deep link, goBranch),
    // _VoteDeckHost + _DeferredShellTicker tercatat canPop=true: deck
    // tertukar stub + ticker pause = konten tab tidak terload selamanya.
    // router.refresh() tidak cukup: setNewRoutePath early-return karena
    // konfigurasi identik, widget const di-skip; notify delegate langsung
    // satu-satunya cara membangunkan ListenableBuilder.
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    AppRouter.router.routerDelegate.notifyListeners();
    ref.invalidate(contributionGuideUnreadProvider);
  }
}

/// Grid 2 tile visual-identik Explore (`_ExploreMenuTile`: 48px, label bawah).
class _ContributeHubGrid extends StatelessWidget {
  const _ContributeHubGrid({
    required this.iconSize,
    required this.spacing,
    required this.columns,
    required this.cellHeight,
  });

  final double iconSize;
  final double spacing;
  final int columns;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <({IconData icon, String label, String path})>[
      (
        icon: FLucideIcons.searchX,
        label: l10n.feedContributeSearchMiss,
        path: SearchMissRouter.list.path,
      ),
      (
        icon: FLucideIcons.clipboardCheck,
        label: l10n.feedContributePeriksaKata,
        path: PeriksaKataRouter.check.path,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final childAspectRatio = cellW / cellHeight;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _ContributeHubTile(
              icon: item.icon,
              label: item.label,
              iconSize: iconSize,
              onTap: () => context.push(item.path),
            );
          },
        );
      },
    );
  }
}

class _ContributeHubTile extends StatelessWidget {
  const _ContributeHubTile({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FTappable(
      onPress: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: theme.colors.secondary,
                child: Center(
                  child: Icon(
                    icon,
                    size: iconSize * 0.42,
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          const Gap(6),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Saat overlay root (search-miss / periksa-kata / …) menutupi shell,
/// jangan paint `VoteDeckSection` (swipe + gesture). Stub murah dipakai
/// selama transisi pop; state deck tetap di `voteDeckControllerProvider`
/// (keepAlive).
class _VoteDeckHost extends StatelessWidget {
  const _VoteDeckHost();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRouter.router.routerDelegate,
      builder: (context, _) {
        final obscured =
            AppRouter.rootNavigatorKey.currentState?.canPop() ?? false;
        if (obscured) {
          return const _VoteDeckStub();
        }
        return const RepaintBoundary(child: VoteDeckSection());
      },
    );
  }
}

class _VoteDeckStub extends StatelessWidget {
  const _VoteDeckStub();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).feedVoteDeckHint,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colors.border),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
