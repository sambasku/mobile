/// Ukuran ikon aksi di [FHeader] root.
///
/// Forui `.touch` memakai `typography.xl2` (30) untuk `actionStyle` - terlalu
/// besar di samping judul. Material AppBar biasanya ~24; kita pakai 20 agar
/// lebih ringan tanpa mengecilkan tap target (padding Forui tetap).
const double kHeaderActionIconSize = 20;
