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
    this.communityStatus,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  final String id;
  final String targetType;
  final String targetId;
  final int value;
  final String votedAt;
  final MyVoteWord? word;

  /// pending | verified | rejected - hanya target meaning (Periksa Kata).
  final String? communityStatus;

  /// Total upvote/downvote komunitas untuk target ini.
  final int upvotes;
  final int downvotes;

  bool get canOpen => word != null;

  /// Boleh revisi vote selama makna belum selesai (bukan verified/rejected).
  bool get canReviseVote =>
      communityStatus == null || communityStatus == 'pending';

  MyVoteItem copyWith({
    String? id,
    String? targetType,
    String? targetId,
    int? value,
    String? votedAt,
    MyVoteWord? word,
    String? communityStatus,
    int? upvotes,
    int? downvotes,
    bool clearWord = false,
    bool clearCommunityStatus = false,
  }) {
    return MyVoteItem(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      value: value ?? this.value,
      votedAt: votedAt ?? this.votedAt,
      word: clearWord ? null : (word ?? this.word),
      communityStatus: clearCommunityStatus
          ? null
          : (communityStatus ?? this.communityStatus),
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }
}
