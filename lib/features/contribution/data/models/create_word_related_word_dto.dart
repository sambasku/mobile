/// Item `related_words[]` Form B (inline)- Form B
///
/// Mobile hanya mengirim lemma baru yang ikut makna induk
/// (`inherit_meanings: true`). Form A (link `word_id`) menyusul bila
/// ada UI pencarian kata.
class CreateWordRelatedWordDto {
  const CreateWordRelatedWordDto({
    required this.relationType,
    required this.lemma,
  });

  /// `synonym` | `antonym` (API relationTypeSchema).
  final String relationType;
  final String lemma;

  factory CreateWordRelatedWordDto.fromJson(Map<String, dynamic> json) {
    final word = json['word'];
    final lemma = word is Map<String, dynamic>
        ? (word['lemma'] as String? ?? '')
        : '';
    return CreateWordRelatedWordDto(
      relationType: json['relation_type'] as String? ?? 'synonym',
      lemma: lemma,
    );
  }

  Map<String, dynamic> toJson() => {
        'relation_type': relationType,
        'word': {
          'lemma': lemma,
          'inherit_meanings': true,
        },
      };
}
