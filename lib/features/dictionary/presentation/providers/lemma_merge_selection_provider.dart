import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/word_summary.dart';

const lemmaMergeMaxSelection = 8;

class LemmaMergeSelectionState {
  const LemmaMergeSelectionState({
    this.active = false,
    this.selected = const {},
  });

  final bool active;
  final Map<String, WordSummary> selected;

  LemmaMergeSelectionState copyWith({
    bool? active,
    Map<String, WordSummary>? selected,
  }) {
    return LemmaMergeSelectionState(
      active: active ?? this.active,
      selected: selected ?? this.selected,
    );
  }
}

final lemmaMergeSelectionProvider =
    NotifierProvider<LemmaMergeSelectionNotifier, LemmaMergeSelectionState>(
  LemmaMergeSelectionNotifier.new,
);

class LemmaMergeSelectionNotifier extends Notifier<LemmaMergeSelectionState> {
  @override
  LemmaMergeSelectionState build() => const LemmaMergeSelectionState();

  void cancel() {
    state = const LemmaMergeSelectionState();
  }

  void startWith(WordSummary item) {
    state = LemmaMergeSelectionState(active: true, selected: {item.id: item});
  }

  void toggle(WordSummary item) {
    if (!state.active) return;
    final next = Map<String, WordSummary>.from(state.selected);
    if (next.containsKey(item.id)) {
      next.remove(item.id);
      if (next.isEmpty) {
        state = const LemmaMergeSelectionState();
        return;
      }
      state = state.copyWith(selected: next);
      return;
    }
    if (next.length >= lemmaMergeMaxSelection) return;
    next[item.id] = item;
    state = state.copyWith(selected: next);
  }
}