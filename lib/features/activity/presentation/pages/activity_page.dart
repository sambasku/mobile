import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/header_action_icon.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/presentation/utils/open_verifier_contribute.dart';
import '../../../dictionary/presentation/widgets/action_chips_row.dart';
import '../../../vote/presentation/providers/vote_deck_providers.dart';
import '../../../vote/presentation/widgets/vote_deck_section.dart';
import '../providers/contribution_guide_providers.dart';
import '../widgets/contribution_guide_sheet.dart';
import '../../../../l10n/app_localizations.dart';

/// Tab KONTRIBUSI: baris aksi yang sama dengan Home (`ActionChipsRow`) + deck nilai kata.
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

  static const _hPad = EdgeInsets.symmetric(horizontal: 12);

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
    final isVerifier = role == 'admin' || role == 'root' || role == 'reviewer';

    return Column(
      children: [
        Padding(
          padding: _hPad,
          child: FHeader(
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
        ),
        const ActionChipsRow(from: 'kontribusi'),
        const Gap(8),
        Expanded(
          child: Padding(
            padding: _hPad,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    // Minimal setinggi viewport agar pull-to-refresh tetap
                    // jalan meski konten tidak meluap.
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Deck mengisi sisa viewport di bawah baris aksi hub.
                        SizedBox(
                          height: (constraints.maxHeight - 8).clamp(
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
