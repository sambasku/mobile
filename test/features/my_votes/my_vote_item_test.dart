import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/my_votes/domain/entities/my_vote_item.dart';
import 'package:sambasku_mobile/features/my_votes/presentation/my_vote_labels.dart';
import 'package:sambasku_mobile/l10n/app_localizations_id.dart';

MyVoteItem _item(String targetType, {MyVoteWord? word}) => MyVoteItem(
  id: 'v1',
  targetType: targetType,
  targetId: 't1',
  value: 1,
  votedAt: '2026-09-21T10:00:00.000Z',
  word: word,
);

void main() {
  final l10n = AppLocalizationsId();

  test('kata terhapus hanya untuk target word', () {
    expect(myVoteTitle(l10n, 'word', null), 'Kata sudah dihapus');
    expect(myVoteTitle(l10n, 'meaning', null), 'Arti');
    expect(myVoteTitle(l10n, 'pantun', null), 'Pantun');
  });

  test('lemma menang atas label jenis target', () {
    const word = MyVoteWord(
      id: 'w1',
      lemma: 'makan',
      wordType: 'lemma',
      isVerified: true,
    );
    final item = _item('meaning', word: word);
    expect(myVoteTitle(l10n, 'meaning', word.lemma), 'makan');
    expect(item.canOpen, isTrue);
  });

  test('label jenis target lengkap termasuk pantun', () {
    expect(voteTargetLabel(l10n, 'pantun'), 'Pantun');
    expect(voteTargetLabel(l10n, 'pantun_reply'), 'Balasan pantun');
    expect(voteTargetLabel(l10n, 'discussion'), 'Pertanyaan diskusi');
    expect(voteTargetLabel(l10n, 'discussion_reply'), 'Balasan diskusi');
    expect(voteTargetLabel(l10n, 'word'), 'Kata');
  });

  test('subtitle pakai label jenis target', () {
    expect(
      myVoteSubtitle(l10n, _item('pantun'), '21 Sep 2026 10:00'),
      'Upvote · Pantun · 21 Sep 2026 10:00',
    );
  });
}
