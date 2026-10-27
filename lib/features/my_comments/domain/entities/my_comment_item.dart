class MyCommentItem {
  const MyCommentItem({
    required this.id,
    required this.wordId,
    required this.wordLemma,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.reviewedAt,
  });

  final String id;
  final String wordId;
  final String? wordLemma;
  final String body;
  final String status;
  final String createdAt;
  final String? reviewedAt;

  bool get canOpen => wordLemma != null && wordLemma!.isNotEmpty;
}
