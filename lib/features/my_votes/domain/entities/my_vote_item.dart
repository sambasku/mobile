class MyVoteWord {
  const MyVoteWord({
    required this.id,
    required this.lemma,
    required this.wordType,
    required this.isVerified,
  });

  final String id;
  final String lemma;
  final String wordType;
  final bool isVerified;
}

class MyVoteItem {
  const MyVoteItem({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.value,
    required this.votedAt,
    required this.word,
  });

  final String id;
  final String targetType;
  final String targetId;
  final int value;
  final String votedAt;
  final MyVoteWord? word;

  bool get canOpen => word != null;

  String get title => word?.lemma ?? 'Kata sudah dihapus';

  String subtitle(String date) {
    final direction = value == 1 ? 'Upvote' : 'Downvote';
    return '$direction · ${voteTargetLabel(targetType)} · $date';
  }
}

String voteTargetLabel(String targetType) {
  return switch (targetType) {
    'word' => 'Kata',
    'meaning' => 'Arti',
    'example' => 'Contoh',
    'pronunciation' => 'Pelafalan',
    'word_image' => 'Gambar',
    'comment' => 'Komentar',
    'discussion_reply' => 'Balasan diskusi',
    'discussion' => 'Pertanyaan diskusi',
    _ => targetType,
  };
}
