/// Batas kompresi foto sebelum upload (mobile-base-stack §9.2).
///
/// Tidak ada sisi melebihi 1200; aspect ratio tetap. Output **WebP** quality 85
/// lewat [compressImageForUpload] (fallback JPEG bila WebP tidak didukung).
const double kPhotoPickMaxWidth = 1200;
const double kPhotoPickMaxHeight = 1200;
const int kPhotoPickQuality = 85;

/// Batas pick sumber untuk avatar (sebelum crop). Lebih longgar supaya
/// crop 1:1 tetap tajam; export akhir [kAvatarExportSize] WebP.
const double kAvatarPickMaxWidth = 1600;
const double kAvatarPickMaxHeight = 1600;

/// Sisi avatar persegi hasil crop yang diunggah.
const double kAvatarExportSize = 720;
