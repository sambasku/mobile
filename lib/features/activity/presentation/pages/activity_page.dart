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
import '../../../search_miss/search_miss_router.dart';
import '../../../discussion/discussion_router.dart';
import '../../../vote/presentation/providers/vote_deck_providers.dart';
import '../../../vote/presentation/widgets/vote_deck_section.dart';

/// Tab KONTRIBUSI: menu usul + deck nilai kata.
///
/// Deck sengaja **di luar** scroll view supaya swipe-atas (lewati) tidak
/// bentrok dengan `CustomScrollView` / pull-to-refresh.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(voteDeckControllerProvider.notifier).refresh(),
      ref.refresh(voteDeckGuestSamplesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

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
              onPress: () => _refresh(ref),
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

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      // Navigator tab ada di dalam padding shell (childPad): tanpa root,
      // barrier + sheet terpotong dan sisi kiri/kanan tidak tertutup.
      useRootNavigator: true,
      backgroundColor: theme.colors.background,
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        void go(String path) {
          Navigator.of(sheetContext).pop();
          context.push(path);
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
                  'Bahas kata bersama warga',
                  () => go(DiscussionRouter.feed.path),
                ),
              ],
            ),
          ),
        );
      },
    );
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
