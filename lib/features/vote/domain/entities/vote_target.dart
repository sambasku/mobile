/// Target polymorphic operasi vote (08-api-upvote-downvote.md).
///
/// `type` = salah satu dari word | meaning | example | pronunciation |
/// word_image | comment | discussion_reply | discussion.
/// `id` = ULID 26 karakter milik target.
class VoteTarget {
  const VoteTarget({required this.type, required this.id});

  final String type;
  final String id;

  /// Kunci lookup "type:id" - dipakai sebagai key map counts/my-votes.
  String get key => '$type:$id';

  bool get isComment => type == 'comment';

  @override
  bool operator ==(Object other) =>
      other is VoteTarget && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'VoteTarget($type, $id)';
}
