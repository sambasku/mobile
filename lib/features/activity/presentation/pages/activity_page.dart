import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/header_action_icon.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../../core/utils/tabfreeze_log.dart';
import '../../../search_miss/search_miss_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../vote/presentation/providers/vote_deck_providers.dart';
import '../../../vote/presentation/widgets/vote_deck_section.dart';
import '../providers/contribution_guide_providers.dart';
import '../widgets/contribution_guide_sheet.dart';

/// Tab KONTRIBUSI: menu usul + deck nilai kata.
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

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(voteDeckControllerProvider.notifier).refresh(),
      ref.refresh(voteDeckGuestSamplesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Guide sekali di kunjungan pertama: cek unread pasca frame pertama.
    if (!_guideChecked) {
      _guideChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowGuide());
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(8),
              const Expanded(child: _VoteDeckHost()),
              // Di bawah action bar deck: dekat jempol.
              const Gap(8),
              _ContributeMenu(theme: theme),
              const Gap(8),
            ],
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

/// Saat overlay root (search-miss / ruang diskusi / …) menutupi shell,
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
        return const RepaintBoundary(
          child: VoteDeckSection(),
        );
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
          'Bantu nilai agar arti kata lebih akurat',
          style: theme.typography.sm.copyWith(
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

/// Satu tombol setinggi pill; isi menu (label lengkap) ada di bottom sheet
/// supaya tinggi deck tidak berkurang.
class _ContributeMenu extends StatelessWidget {
  const _ContributeMenu({required this.theme});

  final FThemeData theme;

  Future<void> _open(BuildContext context) {
    tfLog('sheet open');
    // Single-flight: tile masih bisa di-tap saat animasi pop (~250ms);
    // tanpa ini tap kedua mempop route yang baru saja di-push.
    var handled = false;
    return showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      // Navigator tab ada di dalam padding shell (childPad): tanpa root,
      // barrier + sheet terpotong dan sisi kiri/kanan tidak tertutup.
      useRootNavigator: true,
      backgroundColor: theme.colors.background,
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        // Jangan push dari dalam sheet: pop + push di navigator root yang
        // sama saling balapan (route baru bisa terpop / barrier desync =
        // semua tap tertelan). Path jadi pop result; push jalan setelah
        // sheet benar-benar tertutup.
        void go(String path) {
          if (handled) return;
          handled = true;
          tfLog('sheet pick $path');
          Navigator.of(sheetContext).pop(path);
        }

        FTile tile(IconData icon, String title, String subtitle, VoidCallback onPress) => FTile(
              prefix: Icon(icon, color: theme.colors.primary),
              title: Text(title),
              subtitle: Text(subtitle),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: onPress,
            );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: FTileGroup(
              label: const Text('Menu kontribusi'),
              children: [
                tile(FLucideIcons.plusCircle, 'Usul kata baru', 'Tambah kata yang belum ada', () {
                  AnalyticsService.instance.log(
                    AnalyticsEvents.contributeStart,
                    params: {'from': 'blank'},
                  );
                  go('/contribute');
                }),
                tile(
                  FLucideIcons.search,
                  'Dicari warga',
                  'Dicari, tapi belum ada di kamus',
                  () => go(SearchMissRouter.list.path),
                ),
                tile(
                  FLucideIcons.languages,
                  'Ruang diskusi',
                  'Ngobrol bareng warga di Ruang Diskusi',
                  () => go(DiscussionRouter.feed.path),
                ),
              ],
            ),
          ),
        );
      },
    ).then((path) {
      tfLog('sheet dismissed path=$path');
      if (path case final p?) {
        if (context.mounted) context.push(p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: FButtonVariant.outline,
      size: FButtonSizeVariant.sm,
      onPress: () => _open(context),
      prefix: Icon(FLucideIcons.layoutGrid, color: theme.colors.primary),
      suffix: const Icon(FLucideIcons.chevronUp),
      child: const Text('Menu kontribusi'),
    );
  }
}
