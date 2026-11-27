import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/entertainment/domain/pantun_models.dart';

// #367: un-vote harus menghapus myVote (bukan mempertahankan nilai lama).
Pantun _pantun({int? myVote}) => Pantun(
  id: 'p1',
  userId: 'u1',
  username: null,
  displayName: null,
  avatarUrl: null,
  parentId: null,
  language: 'id',
  themeId: null,
  rhymeScheme: 'ABAB',
  lines: const ['a', 'b', 'c', 'd'],
  status: 'published',
  createdAt: DateTime(2026, 11, 1),
  updatedAt: null,
  myVote: myVote,
);

void main() {
  test('copyWith clearMyVote menghapus myVote menjadi null', () {
    final voted = _pantun(myVote: 1);
    final unvoted = voted.copyWith(myVote: null, clearMyVote: true);
    expect(unvoted.myVote, isNull);
  });

  test('copyWith tanpa clearMyVote tetap mempertahankan myVote lama', () {
    final voted = _pantun(myVote: -1);
    expect(voted.copyWith(upvotes: 5).myVote, -1);
  });

  test('copyWith myVote baru tanpa clear mengganti nilai', () {
    expect(_pantun(myVote: -1).copyWith(myVote: 1).myVote, 1);
  });
}
