/// Riwayat sunting komentar (GET /api/v1/comments/:id/edit-history).
class CommentEditHistory {
  const CommentEditHistory({
    required this.revisions,
    this.currentBody,
    this.currentUpdatedAt,
    this.isEdited = false,
  });

  final String? currentBody;
  final String? currentUpdatedAt;
  final bool isEdited;
  final List<CommentEditRevision> revisions;
}

class CommentEditRevision {
  const CommentEditRevision({
    required this.body,
    required this.editorId,
    required this.createdAt,
  });

  final String body;
  final String editorId;
  final String createdAt;
}
