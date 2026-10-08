import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/parse_mentions.dart';
import '../providers/mention_suggest_providers.dart';

/// Overlay saran @username di atas composer komentar/balasan.
///
/// Dipasang di [ThreadComposer] via [ThreadComposer.suggestBuilder];
/// listener `controller` dipasang pemilik composer (page) agar
/// `onTextChanged` terpanggil. Insert = ganti token aktif via
/// [insertMention], lalu [MentionSuggestController.dismiss].
///
/// ponytail: overlay Column sederhana di atas field (bukan OverlayPortal
/// mengikuti kursor) - cukup untuk 1-2 baris suggestion; naikkan ke
/// OverlayPortal jika butuh posisi mengikuti caret.
class MentionSuggestOverlay extends ConsumerWidget {
  const MentionSuggestOverlay({
    super.key,
    required this.onSelect,
  });

  /// Dipanggil dengan username terpilih; wajib menyisipkan ke composer.
  final void Function(String username) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mentionSuggestControllerProvider);
    if (!state.isVisible) return const SizedBox.shrink();

    final theme = context.theme;
    return _MentionSuggestOverlayContent(
      state: state,
      onSelect: onSelect,
      theme: theme,
      ref: ref,
    );
  }
}

class _MentionSuggestOverlayContent extends ConsumerStatefulWidget {
  const _MentionSuggestOverlayContent({
    required this.state,
    required this.onSelect,
    required this.theme,
    required this.ref,
  });

  final MentionSuggestState state;
  final void Function(String username) onSelect;
  final FThemeData theme;
  final WidgetRef ref;

  @override
  ConsumerState<_MentionSuggestOverlayContent> createState() =>
      _MentionSuggestOverlayContentState();
}

class _MentionSuggestOverlayContentState
    extends ConsumerState<_MentionSuggestOverlayContent> {
  int _highlightedIndex = 0;

  @override
  void didUpdateWidget(covariant _MentionSuggestOverlayContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isVisible && _highlightedIndex >= widget.state.items.length) {
      _highlightedIndex = widget.state.items.length - 1;
    }
    if (!widget.state.isVisible) {
      _highlightedIndex = 0;
    }
  }

  void _handleKey(KeyEvent event) {
    final state = widget.state;
    if (!state.isVisible) return;

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          setState(() {
            _highlightedIndex =
                (_highlightedIndex + 1) % state.items.length;
          });
          break;
        case LogicalKeyboardKey.arrowUp:
          setState(() {
            _highlightedIndex =
                (_highlightedIndex - 1 + state.items.length) % state.items.length;
          });
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.numpadEnter:
          if (state.items.isNotEmpty) {
            final selected = state.items[_highlightedIndex];
            widget.onSelect(selected.username);
            ref.read(mentionSuggestControllerProvider.notifier).dismiss();
          }
          break;
        case LogicalKeyboardKey.escape:
          ref.read(mentionSuggestControllerProvider.notifier).dismiss();
          break;
        default:
          return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = widget.theme;

    return Focus(
      // #129: autofocus=false - overlay tidak boleh mencuri fokus dari
      // TextField composer. Navigasi arrow/enter/escape masih jalan lewat
      // onKeyEvent tanpa autofocus.
      onKeyEvent: (node, event) {
        _handleKey(event);
        return KeyEventResult.handled;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          // Panel melayang: pakai warna card tema (bukan hardcoded).
          color: theme.colors.card,
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(maxHeight: 180),
        child: state.isLoading && state.items.isEmpty
            // Indikator pencarian user: panel sama, isi spinner + teks tipis.
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      // Warna spinner default tema sudah selaras; ukuran kecil.
                      child: const FCircularProgress(),
                    ),
                    const Gap(8),
                    Text(
                      'Mencari pengguna...',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            final isHighlighted = index == _highlightedIndex;
            // GestureDetector, bukan InkWell: overlay ada di dalam FScaffold
            // Forui yang tidak menyediakan ancestor Material.
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.onSelect(item.username);
                ref.read(mentionSuggestControllerProvider.notifier).dismiss();
              },
              child: Container(
                // Highlight abu tipis dari token muted tema.
                color: isHighlighted ? theme.colors.muted : Colors.transparent,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundImage: item.avatarUrl != null
                            ? NetworkImage(item.avatarUrl!)
                            : null,
                        child: item.avatarUrl == null
                            ? Text(
                                item.username.isNotEmpty
                                    ? item.username[0].toUpperCase()
                                    : '?',
                                style: theme.typography.xs,
                              )
                            : null,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          '@${item.username}',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.displayName != null &&
                          item.displayName!.trim().isNotEmpty)
                        Flexible(
                          child: Text(
                            item.displayName!,
                            style: theme.typography.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Sisip username terpilih ke [controller] pada token aktif.
void insertIntoComposer(
  TextEditingController controller,
  String username,
) {
  final selection = controller.selection;
  final cursor =
      selection.isValid && selection.baseOffset >= 0
          ? selection.baseOffset
          : controller.text.length;
  final result = insertMention(controller.text, cursor, username);
  controller
    ..text = result.text
    ..selection = TextSelection.collapsed(offset: result.cursor);
}
