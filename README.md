<p align="center">
  <img src="logo.png" alt="SambasKu" width="320" />
</p>

# SambasKu Mobile

Aplikasi **Flutter** Kamus Digital Sambas-Indonesia. Target utama produk:
cari kata, dengar pelafalan, lihat gambar, bookmark, komentar/vote, dan
kirim kontribusi dari ponsel.

## Stack

| Layer | Pilihan |
| --- | --- |
| Framework | Flutter (SDK ^3.10) |
| State | Riverpod + hooks_riverpod |
| Navigasi | go_router |
| HTTP | Dio + Retrofit |
| UI | Forui, skeletonizer |
| Auth sensitif | flutter_secure_storage |
| Push | Firebase Messaging |
| Env compile-time | envied (baca `.env`) |

Acuan tetap: `docs/mobile/mobile-base-stack.md` di repo
[sambasku-docs](https://github.com/iamutaki/sambasku-docs).
Kontrak API mengikuti `docs/api/*`.

## Flavor

| Flavor | Logo aset | Host API |
| --- | --- | --- |
| `staging` | `assets/icons/logo.staging.png` | `SAMBASKU_API_HOST_STAGING` → `https://sambasku-staging.iamutaki.com` |
| `production` | `assets/icons/logo.png` | `SAMBASKU_API_HOST_PRODUCTION` → `https://api.sambasku.com` |

Host dipilih di `lib/core/constants/env.dart` lewat `F.appFlavor`.
**Jangan** hardcode host di datasource.

## Setup

```bash
cp .env.example .env
# isi host + GOOGLE_WEB_CLIENT_ID_* / FACEBOOK_APP_ID_* bila OAuth dipakai
# lalu: dart run build_runner build

flutter pub get
flutter run --flavor staging
# atau
flutter run --flavor production
```

`.env` di-gitignore. envied membacanya saat compile; `env.g.dart` yang
ter-commit dipakai CI.

## Fitur (modul `lib/features/`)

| Modul | Peran |
| --- | --- |
| `dictionary` | Cari / detail kata, WOTD |
| `auth` | Login, OTP email, Google, Facebook, lupa password |
| `contribution` / `suggest_edit` | Kirim kata / usulan edit |
| `bookmark` / `vote` / `comment` | Interaksi pengguna login |
| `profile` / `user_profile` | Profil saya + profil publik |
| `notification` | Inbox push + in-app |
| `share` | Share card |
| `report_bug` / `word_report` | Laporan |
| `verifier_application` | Pengajuan jadi verifikator |
| `onboarding` | Layar pertama kali |

## Aset media

| Jenis | Alur |
| --- | --- |
| Gambar kata | `POST /api/v1/images?purpose=word` → [sambasku/images](https://github.com/sambasku/images) |
| Avatar | `POST /api/v1/users/me/avatar` → repo yang sama |
| Audio pelafalan | Multipart ke API → [sambasku/audios](https://github.com/sambasku/audios) |
| Bukti / lampiran bug | ImageKit (privat) lewat upload-token |

URL kanonik gambar = jsDelivr. Tampilan di-resize lewat wsrv
(`displayImageUrl`). Lampiran UI wajib lewat
`AttachmentImagesField` / `showImageSheetDrawer` (lihat base stack).

## Struktur singkat

```text
lib/
├── core/                # env, utils, widgets, network
├── features/<fitur>/    # data → domain → presentation (clean)
├── shared/              # widget lintas fitur
└── flavors.dart         # Flavor.staging | production
```

## Deploy

CI staging: `.github/workflows/deploy-staging.yml` (push branch
`staging`) menjalankan analyze dan test. Tidak membangun APK dan tidak
mengunggah ke Play.

CI production: `.github/workflows/deploy-production.yml` (push tag
`v1.1.1`, pola `vMAJOR.MINOR.PATCH`) → **AAB** flavor production
(API `https://api.sambasku.com`) + **draft upload** ke Play Console
track `production` (package `com.iamutaki.sambasku`). GitHub Release pada
tag itu melampirkan **APK split per ABI** (bukan AAB). `versionName` dari
tag, `versionCode` dari Play (max + 1).
Tidak auto-publish.

Setup Play API: `docs/env/google_play_console/credential.md`.
Secret GitHub: `PLAY_STORE_SERVICE_ACCOUNT_JSON` (+ `KEYSTORE_*`).

Detail flavor Android/iOS dan launcher icons ada di
`docs/mobile/mobile-base-stack.md` Section 8.
