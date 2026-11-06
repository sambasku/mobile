/// Makna kartu voting deck (#232) di depan daftar edit.
///
/// [preferredId] kosong atau tidak ada di [meanings]: urutan asli
/// (makna utama tetap di atas).
List<T> meaningsPreferredFirst<T>(
  List<T> meanings,
  String? preferredId, {
  required String Function(T meaning) idOf,
}) {
  final id = preferredId?.trim();
  if (id == null || id.isEmpty) return meanings;
  final index = meanings.indexWhere((m) => idOf(m) == id);
  if (index <= 0) return meanings;
  return [
    meanings[index],
    for (var i = 0; i < meanings.length; i++)
      if (i != index) meanings[i],
  ];
}
