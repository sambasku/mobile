import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/my_votes/domain/entities/my_vote_item.dart';

MyVoteItem _item(String targetType, {MyVoteWord? word}) => MyVoteItem(
  id: 'v1',
  targetType: targetType,
  targetId: 't1',
  value: 1,
  votedAt: '2026-09-21T10:00:00.000Z',
  word: word,
);

void main() {
  test('kata terhapus hanya untuk target word', () {
    expect(_item('word').title, 'Kata sudah dihapus');
    expect(_item('meaning').title, 'Arti');
    expect(_item('pantun').title, 'Pantun');
  });

  test('lemma menang atas label jenis target', () {
    const word = MyVoteWord(
      id: 'w1',
      lemma: 'makan',
      wordType: 'lemma',
      isVerified: true,
    );
    final item = _item('meaning', word: word);
    expect(item.title, 'makan');
    expect(item.canOpen, isTrue);
  });

  test('label jenis target lengkap termasuk pantun', () {
    expect(voteTargetLabel('pantun'), 'Pantun');
    expect(voteTargetLabel('pantun_reply'), 'Balasan pantun');
    expect(voteTargetLabel('discussion'), 'Pertanyaan diskusi');
    expect(voteTargetLabel('discussion_reply'), 'Balasan diskusi');
    expect(voteTargetLabel('word'), 'Kata');
  });

  test('subtitle pakai label jenis target', () {
    expect(
      _item('pantun').subtitle('21 Sep 2026 10:00'),
      'Upvote · Pantun · 21 Sep 2026 10:00',
    );
  });
}
