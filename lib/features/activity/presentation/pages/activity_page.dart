import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/header_action_icon.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/presentation/utils/open_verifier_contribute.dart';
import '../../../search_miss/search_miss_router.dart';
import '../../../vote/periksa_kata_router.dart';
import '../../../vote/presentation/providers/vote_deck_providers.dart';
import '../../../vote/presentation/widgets/vote_deck_section.dart';
import '../providers/contribution_guide_providers.dart';
import '../widgets/contribution_guide_sheet.dart';
import '../../../../l10n/app_localizations.dart';

/// Tab KONTRIBUSI: baris aksi pola Home (`_HomeActionChips`) + deck nilai kata.
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

  /// Sama Home: kotak 48 1:1 + gap 6 + slot label 28.
  static const _hubBlock = 8 + _ContributeHubChips.height + 8;

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(voteDeckControllerProvider.notifier).refresh(),
      ref.refresh(voteDeckGuestSamplesProvider.future),
    ]);
  }

  void _openSuggestWordFromDeck() {
    pushVerifierContribute(
      context,
      analyticsFrom: 'kontribusi_vote_deck',
      contributeFrom: 'kontribusi',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guide sekali di kunjungan pertama: cek unread pasca frame pertama.
    if (!_guideChecked) {
      _guideChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowGuide());
    }

    final l10n = AppLocalizations.of(context);
    final role = ref.watch(authStatusProvider).value?.role;
    final isVerifier =
        role == 'admin' || role == 'root' || role == 'reviewer';

    return Column(
      children: [
        FHeader(
          title: const BrandWordmark(),
          suffixes: [
            if (isVerifier)
              FHeaderAction(
                icon: const Icon(
                  FLucideIcons.bookPlus,
                  size: kHeaderActionIconSize,
                ),
                semanticsLabel: l10n.activityVoteDeckSuggestWord,
                onPress: _openSuggestWordFromDeck,
              ),
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
                      const _ContributeHubChips(),
                      const Gap(8),
                      // Deck mengisi sisa viewport minus baris aksi hub.
                      SizedBox(
                        height: (constraints.maxHeight - _hubBlock).clamp(
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

/// Satu baris tile aksi Kontribusi - styling identik Home (`_HomeActionChips`):
/// kotak 1:1 48px, border, ikon 18, label 10px, scroll horizontal Gap(8).
/// Tambah item di list di bawah; baris otomatis scroll bila menu banyak.
class _ContributeHubChips extends StatelessWidget {
  const _ContributeHubChips();

  static const double _tileSize = 48;
  static const double _labelSlot = 28;
  static const double height = _tileSize + 6 + _labelSlot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_ContributeHubChip>[
      _ContributeHubChip(
        icon: FLucideIcons.searchX,
        label: l10n.feedContributeSearchMiss,
        onPress: () => context.push(SearchMissRouter.list.path),
      ),
      _ContributeHubChip(
        icon: FLucideIcons.clipboardCheck,
        label: l10n.feedContributePeriksaKata,
        onPress: () => context.push(PeriksaKataRouter.check.path),
      ),
    ];

    // Shell tab sudah Padding horizontal 12 - jangan dobel (Home pad di dalam
    // ListView karena carousel full-bleed).
    return SizedBox(
      height: height,
      child: ListView.separated(
        key: const ValueKey('contribute_hub_chips'),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) => _ContributeHubTile(item: items[i]),
      ),
    );
  }
}

class _ContributeHubChip {
  const _ContributeHubChip({
    required this.icon,
    required this.label,
    required this.onPress,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPress;
}

class _ContributeHubTile extends StatelessWidget {
  const _ContributeHubTile({required this.item});

  final _ContributeHubChip item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    const size = _ContributeHubChips._tileSize;
    return Semantics(
      button: true,
      label: item.label,
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
