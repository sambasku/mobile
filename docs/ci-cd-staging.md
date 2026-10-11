# CI/CD Staging (Android)

Push branch `staging` menjalankan `.github/workflows/deploy-staging.yml`:
`flutter analyze` dan `flutter test`. Workflow ini tidak membangun APK
dan tidak mengunggah ke Play.

Rilis production: tag `v1.1.1` (pola `vMAJOR.MINOR.PATCH`) memicu
`.github/workflows/deploy-production.yml`. `versionName` diambil dari tag.
`versionCode` = 1 + angka tertinggi yang sudah ada di Play (semua track,
termasuk draft). Hasilnya AAB flavor production, draft di track
`production`, plus GitHub Release pada tag yang sama.

Rilis Huawei AppGallery lewat workflow terpisah `.github/workflows/deploy-huawei.yml`,
trigger manual (Actions → Deploy (Huawei AppGallery) → Run workflow). Input
tag kosong = tag terbaru; isi `v1.2.3` untuk deploy versi lama. `versionCode`
= `MAJOR*10000+MINOR*100+PATCH` (deterministik dari tag, tidak pakai resolver
Play). Hasil: draft AAB di AppGallery Connect, submit review manual di AGC.
Alasan terpisah: review Huawei lebih lama dari Play, versi kerap desinkron.

## Prerequisites

1. **Repo GitHub** untuk mobile (submodule seperti `sambasku-api`), dengan
   workflow di `.github/workflows/deploy-staging.yml` (sudah ada di folder
   `mobile/` ini).
2. **Flavor Android** sudah aktif (`android/app/flavorizr.gradle.kts`).
3. **Keystore** release (satu untuk staging & production):

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
base64 -i upload-keystore.jks | pbcopy   # macOS
```

4. **GitHub Secrets** (Settings → Secrets → Actions). Dipakai workflow
   production, bukan test staging:

| Secret | Isi |
| --- | --- |
| `KEYSTORE_BASE64` | output base64 keystore |
| `KEYSTORE_PASSWORD` | store password |
| `KEY_ALIAS` | `upload` (atau alias yang kamu buat) |
| `KEY_PASSWORD` | key password |

## Local release build (opsional)

```bash
cp android/key.properties.example android/key.properties
# edit password + letakkan upload-keystore.jks di android/app/
flutter build apk --release --flavor staging -t lib/main.dart
```

Tanpa `key.properties`, release otomatis pakai debug signing.

## Versioning

- Staging CI tidak mengubah versi.
- Production: `versionName` = tag tanpa `v` (`v1.1.1` → `1.1.1`).
  `versionCode` diisi CI dari Play, bukan dari `pubspec.yaml`.
