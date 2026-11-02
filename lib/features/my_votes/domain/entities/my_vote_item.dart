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
}
