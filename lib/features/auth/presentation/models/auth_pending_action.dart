/// Aksi auth yang sedang diproses.
///
/// Spinner / label "Memproses..." hanya di tombol target;
/// aksi lain disabled tanpa loading (pola BusyAwareIcon).
enum AuthPendingAction { email, google, facebook, github }
