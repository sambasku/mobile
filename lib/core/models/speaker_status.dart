/// Self-declare status bahasa Sambas (mobile#258).
///
/// Wire API: `native` | `learner` | null.
enum SpeakerStatus {
  native,
  learner;

  String get wire => switch (this) {
    SpeakerStatus.native => 'native',
    SpeakerStatus.learner => 'learner',
  };

  static SpeakerStatus? tryParse(String? raw) => switch (raw) {
    'native' => SpeakerStatus.native,
    'learner' => SpeakerStatus.learner,
    _ => null,
  };
}
