import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/analytics_service.dart';
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
          title: const Text('Kontribusi'),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: _ContributeMenus(theme: theme),
              ),
              const Gap(16),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
                  child: _VoteDeckHost(),
                ),
              ),
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
        const Gap(12),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colors.border),
              ),
              child: const SizedBox(height: 240, width: double.infinity),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContributeMenus extends StatelessWidget {
  const _ContributeMenus({required this.theme});

  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      children: [
        FTile(
          prefix: Icon(FLucideIcons.plusCircle, color: theme.colors.primary),
          title: const Text('Usul kata baru'),
          subtitle: const Text('Isi form kosong dari awal'),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () {
            AnalyticsService.instance.log(
              AnalyticsEvents.contributeStart,
              params: {'from': 'blank'},
            );
            context.push('/contribute');
          },
        ),
        FTile(
          prefix: Icon(FLucideIcons.search, color: theme.colors.primary),
          title: const Text('Kata yang sering dicari'),
          subtitle: const Text('Pilih kata yang warga cari tapi belum ada'),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push(SearchMissRouter.list.path),
        ),
        FTile(
          prefix: Icon(FLucideIcons.languages, color: theme.colors.primary),
          title: const Text('Ruang Diskusi'),
          subtitle: const Text('Tanya bahasa, warga bantu jawab'),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => context.push(DiscussionRouter.feed.path),
        ),
      ],
    );
  }
}
