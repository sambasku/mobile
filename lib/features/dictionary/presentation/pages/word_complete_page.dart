import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/word_summary.dart';
import '../providers/word_complete_providers.dart';

/// Pemilih kata untuk entri "Lengkapi kata" di Area Verifikator.
///
/// Halaman ini tidak menambah data apa pun - dia hanya pintasan ke detail
/// kata, tempat semua kemampuan itu sudah ada (makna, relasi, variasi
/// penulisan, contoh kalimat, rekam pelafalan). Sengaja tidak menduplikasi
/// form-nya: satu pintu yang menjelaskan semua kapabilitas, dan form yang
/// sudah terbukti dipakai tetap jadi satu sumber kebenaran.
class WordCompletePage extends ConsumerStatefulWidget {
  const WordCompletePage({super.key});

  @override
  ConsumerState<WordCompletePage> createState() => _WordCompletePageState();
}

class _WordCompletePageState extends ConsumerState<WordCompletePage> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pakai listener (bukan onChange callback) supaya provider
    // auto-dispose ikut ter-reset saat halaman ditutup.
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref
        .read(wordCompleteProvider.notifier)
        .onQueryChanged(_searchCtrl.text);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = ref.watch(wordCompleteProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Lengkapi kata'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pilih kata untuk ditambah maknanya, sinonim atau antonimnya, '
            'variasi penulisannya, contoh kalimatnya, atau rekam pelafasannya.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _searchCtrl),
            focusNode: _searchFocus,
            hint: 'Cari kata Sambas...',
            textInputAction: TextInputAction.search,
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const Icon(FLucideIcons.search),
                ),
          ),
          const Gap(12),
          Expanded(child: _Results(state: state)),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.state});

  final WordCompleteState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage!,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => ref
                  .read(wordCompleteProvider.notifier)
                  .onQueryChanged(state.q),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: FCircularProgress());
    }

    if (!state.isSearching) {
      return _Hint(
        message: 'Ketik minimal 2 huruf untuk mencari kata.',
        icon: FLucideIcons.search,
      );
    }

    if (state.items.isEmpty) {
      return _Hint(
        message: 'Tidak ada kata yang cocok dengan "${state.q.trim()}".',
        icon: FLucideIcons.searchX,
      );
    }

    return FTileGroup.builder(
      count: state.items.length,
      tileBuilder: (context, index) => _WordTile(item: state.items[index]),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: theme.colors.mutedForeground),
          const Gap(8),
          Text(
            message,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget with FTileMixin {
  const _WordTile({required this.item});

  final WordSummary item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final gloss = item.sense?.trim();

    return FTile(
      title: Text(item.lemma),
      subtitle: Text(
        (gloss == null || gloss.isEmpty)
            ? item.wordTypeLabel
            : '$gloss - ${item.wordTypeLabel}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
      ),
      suffix: Icon(
        FLucideIcons.chevronRight,
        size: 16,
        color: theme.colors.mutedForeground,
      ),
      onPress: () => context.push('/words/${item.id}'),
    );
  }
}
