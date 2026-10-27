import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('id', 'SBS'),
  ];

  /// Judul slide 0 onboarding: pilih bahasa antarmuka
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa'**
  String get onboardingLanguageTitle;

  /// Penjelasan slide 0 onboarding
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa antarmuka aplikasi. Kamu bisa mengubahnya kapan saja di Pengaturan.'**
  String get onboardingLanguageBody;

  /// Tombol lanjut antar slide onboarding
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingContinue;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di SambasKu'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Kamus digital Sambas-Indonesia. Temukan arti kata, kenali cara bicara warga Sambas, dan ikut menjaga warisan kata.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingFeatureTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari, usulkan, simpan'**
  String get onboardingFeatureTitle;

  /// No description provided for @onboardingFeatureBody.
  ///
  /// In id, this message translates to:
  /// **'Cari kata dengan cepat, usulkan kata baru atau perbaikan, dan simpan kata favorit biar gampang dibaca ulang.'**
  String get onboardingFeatureBody;

  /// No description provided for @onboardingNotifTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi'**
  String get onboardingNotifTitle;

  /// No description provided for @onboardingNotifBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu dapat kabar saat usulanmu disetujui. Izinkan notifikasi biar tidak ketinggalan.'**
  String get onboardingNotifBody;

  /// No description provided for @onboardingAllowNotif.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi'**
  String get onboardingAllowNotif;

  /// No description provided for @onboardingLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get onboardingLater;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsGroupLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsGroupLanguage;

  /// No description provided for @settingsLanguageTile.
  ///
  /// In id, this message translates to:
  /// **'Bahasa aplikasi'**
  String get settingsLanguageTile;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa antarmuka aplikasi'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsGroupAppearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get settingsGroupAppearance;

  /// No description provided for @settingsGroupSupport.
  ///
  /// In id, this message translates to:
  /// **'Dukungan'**
  String get settingsGroupSupport;

  /// No description provided for @settingsReportBug.
  ///
  /// In id, this message translates to:
  /// **'Laporkan Masalah'**
  String get settingsReportBug;

  /// No description provided for @settingsGroupAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get settingsGroupAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang SambasKu'**
  String get settingsAboutApp;

  /// Judul halaman pilih bahasa di Pengaturan
  ///
  /// In id, this message translates to:
  /// **'Bahasa aplikasi'**
  String get languagePickerTitle;

  /// Catatan di picker bahasa: locale UI beda dari arah pencarian kamus
  ///
  /// In id, this message translates to:
  /// **'Mengubah bahasa antarmuka. Arah pencarian kamus tidak ikut berubah.'**
  String get languagePickerNote;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In id, this message translates to:
  /// **'Eksplorasi'**
  String get navExplore;

  /// No description provided for @navContribute.
  ///
  /// In id, this message translates to:
  /// **'Kontribusi'**
  String get navContribute;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @profileSettingsTile.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get profileSettingsTile;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa, tampilan, tentang'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileGroupActivity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas saya'**
  String get profileGroupActivity;

  /// No description provided for @profileMyContributions.
  ///
  /// In id, this message translates to:
  /// **'Kontribusi Saya'**
  String get profileMyContributions;

  /// No description provided for @profileBookmarks.
  ///
  /// In id, this message translates to:
  /// **'Bookmark'**
  String get profileBookmarks;

  /// No description provided for @profileVotes.
  ///
  /// In id, this message translates to:
  /// **'Vote'**
  String get profileVotes;

  /// No description provided for @profileComments.
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get profileComments;

  /// No description provided for @profileGroupRole.
  ///
  /// In id, this message translates to:
  /// **'Peran'**
  String get profileGroupRole;

  /// No description provided for @profileBecomeVerifier.
  ///
  /// In id, this message translates to:
  /// **'Jadi verifikator'**
  String get profileBecomeVerifier;

  /// No description provided for @profileAnalytics.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get profileAnalytics;

  /// No description provided for @profileGroupAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get profileGroupAccount;

  /// No description provided for @profileLinkedAccounts.
  ///
  /// In id, this message translates to:
  /// **'Akun Terhubung'**
  String get profileLinkedAccounts;

  /// No description provided for @profileChangePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get profileChangePassword;

  /// No description provided for @profileCreatePassword.
  ///
  /// In id, this message translates to:
  /// **'Buat Password'**
  String get profileCreatePassword;

  /// No description provided for @profileLogin.
  ///
  /// In id, this message translates to:
  /// **'Masuk / Login'**
  String get profileLogin;

  /// No description provided for @profileRegister.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get profileRegister;

  /// No description provided for @profileGroupHelp.
  ///
  /// In id, this message translates to:
  /// **'Bantuan'**
  String get profileGroupHelp;

  /// No description provided for @profileAllowNotif.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi'**
  String get profileAllowNotif;

  /// No description provided for @profileAllowNotifSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kabar saat usulanmu disetujui'**
  String get profileAllowNotifSubtitle;

  /// No description provided for @profileGroupLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar & hapus akun'**
  String get profileGroupLogout;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun'**
  String get profileDeleteAccount;

  /// No description provided for @profileLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get profileLogout;

  /// No description provided for @profileLoggingOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar...'**
  String get profileLoggingOut;

  /// No description provided for @profileEditSemantics.
  ///
  /// In id, this message translates to:
  /// **'Edit profil'**
  String get profileEditSemantics;

  /// No description provided for @profileGuestName.
  ///
  /// In id, this message translates to:
  /// **'Belum masuk'**
  String get profileGuestName;

  /// No description provided for @profileDefaultName.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get profileDefaultName;

  /// No description provided for @profileNotReadyToast.
  ///
  /// In id, this message translates to:
  /// **'Profil belum siap, coba lagi'**
  String get profileNotReadyToast;

  /// No description provided for @profileViewPublic.
  ///
  /// In id, this message translates to:
  /// **'Lihat profil publik'**
  String get profileViewPublic;

  /// No description provided for @profileNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get profileNotifications;

  /// Dipakai sebagai subtitle: "{count} belum dibaca" (count di luar key ini)
  ///
  /// In id, this message translates to:
  /// **'belum dibaca'**
  String get profileUnreadSuffix;

  /// No description provided for @profileReviewArea.
  ///
  /// In id, this message translates to:
  /// **'Area Verifikator'**
  String get profileReviewArea;

  /// No description provided for @profileReviewPending.
  ///
  /// In id, this message translates to:
  /// **'Ada usulan yang menunggu'**
  String get profileReviewPending;

  /// No description provided for @appearanceThemeMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Tema'**
  String get appearanceThemeMode;

  /// No description provided for @appearanceThemeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get appearanceThemeSystem;

  /// No description provided for @appearanceThemeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get appearanceThemeLight;

  /// No description provided for @appearanceThemeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get appearanceThemeDark;

  /// No description provided for @appearancePalette.
  ///
  /// In id, this message translates to:
  /// **'Warna Tema'**
  String get appearancePalette;

  /// No description provided for @appearanceFontScale.
  ///
  /// In id, this message translates to:
  /// **'Ukuran Teks'**
  String get appearanceFontScale;

  /// No description provided for @appearanceScaleSmall.
  ///
  /// In id, this message translates to:
  /// **'Kecil'**
  String get appearanceScaleSmall;

  /// No description provided for @appearanceScaleNormal.
  ///
  /// In id, this message translates to:
  /// **'Normal'**
  String get appearanceScaleNormal;

  /// No description provided for @appearanceScaleLarge.
  ///
  /// In id, this message translates to:
  /// **'Besar'**
  String get appearanceScaleLarge;

  /// No description provided for @appearanceScaleHuge.
  ///
  /// In id, this message translates to:
  /// **'Sangat Besar'**
  String get appearanceScaleHuge;

  /// No description provided for @serverTileTitle.
  ///
  /// In id, this message translates to:
  /// **'Server'**
  String get serverTileTitle;

  /// No description provided for @serverAuto.
  ///
  /// In id, this message translates to:
  /// **'Otomatis'**
  String get serverAuto;

  /// No description provided for @serverPickTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Server'**
  String get serverPickTitle;

  /// No description provided for @serverPing.
  ///
  /// In id, this message translates to:
  /// **'Ping'**
  String get serverPing;

  /// No description provided for @serverPinging.
  ///
  /// In id, this message translates to:
  /// **'Ping...'**
  String get serverPinging;

  /// No description provided for @serverPickHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih server yang paling cepat. Hasil uji hanya menunjukkan kondisi saat ini - Render tidur setelah ~15 menit menganggur dan bisa butuh sampai 60 detik untuk bangun.'**
  String get serverPickHint;

  /// No description provided for @serverAutoSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pakai Cloudflare, pindah sendiri kalau gagal (disarankan)'**
  String get serverAutoSubtitle;

  /// No description provided for @serverLockedHint.
  ///
  /// In id, this message translates to:
  /// **'Server terkunci: pindah otomatis ke server lain dimatikan sampai kamu pilih \"Otomatis\" lagi.'**
  String get serverLockedHint;

  /// No description provided for @errorSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get errorSheetTitle;

  /// No description provided for @errorSheetOk.
  ///
  /// In id, this message translates to:
  /// **'Mengerti'**
  String get errorSheetOk;

  /// No description provided for @errorSheetClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get errorSheetClose;

  /// No description provided for @errorSheetRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get errorSheetRetry;

  /// No description provided for @offlineBanner.
  ///
  /// In id, this message translates to:
  /// **'Kamu lagi offline. Nampilin data tersimpan.'**
  String get offlineBanner;

  /// Halaman error router; {error} = path/uri yang gagal
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak ditemukan: {error}'**
  String routerNotFound(String error);

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In id, this message translates to:
  /// **'Kamus Digital Sambas-Indonesia'**
  String get aboutTagline;

  /// Baris versi app
  ///
  /// In id, this message translates to:
  /// **'Versi {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutWhatTitle.
  ///
  /// In id, this message translates to:
  /// **'Apa itu SambasKu?'**
  String get aboutWhatTitle;

  /// No description provided for @aboutWhatBody.
  ///
  /// In id, this message translates to:
  /// **'Kamus digital Melayu Sambas-Indonesia yang dirawat bersama warga. Kamu bisa mencari arti kata, membaca contoh kalimat, menyimpan kata, mengusulkan kata baru, dan membagikan kartu kata. Usulan dari akun yang sudah masuk langsung tayang dengan label Menunggu pengecekan, lalu diperiksa verifikator.'**
  String get aboutWhatBody;

  /// No description provided for @aboutSponsorTitle.
  ///
  /// In id, this message translates to:
  /// **'Sponsor & Tim Kami'**
  String get aboutSponsorTitle;

  /// No description provided for @aboutSponsorBody.
  ///
  /// In id, this message translates to:
  /// **'Para pendukung operasional dan orang-orang yang merawat kamus ini.'**
  String get aboutSponsorBody;

  /// No description provided for @aboutSponsorAction.
  ///
  /// In id, this message translates to:
  /// **'Lihat Sponsor & Tim Kami'**
  String get aboutSponsorAction;

  /// No description provided for @aboutSourceTitle.
  ///
  /// In id, this message translates to:
  /// **'Kode Sumber & Organisasi'**
  String get aboutSourceTitle;

  /// No description provided for @aboutSourceBody.
  ///
  /// In id, this message translates to:
  /// **'SambasKu adalah proyek open source. Kode sumbernya dirilis dengan lisensi GPLv3, jadi kamu bebas mempelajari, mengubah, dan membagikannya sesuai ketentuan lisensi. Konten kamus dan datanya dirilis dengan lisensi CC BY-SA 4.0, jadi wajib mencantumkan sumber dan membagikan hasilnya dengan lisensi yang sama. Di GitHub juga ada profil organisasi, cara ikut serta, info sponsor, dan saluran komunitas.'**
  String get aboutSourceBody;

  /// No description provided for @aboutSourceAction.
  ///
  /// In id, this message translates to:
  /// **'Buka di GitHub'**
  String get aboutSourceAction;

  /// No description provided for @aboutSponsorshipTitle.
  ///
  /// In id, this message translates to:
  /// **'Sponsor & Tim Kami'**
  String get aboutSponsorshipTitle;

  /// No description provided for @aboutTabSponsors.
  ///
  /// In id, this message translates to:
  /// **'Sponsor & Mitra'**
  String get aboutTabSponsors;

  /// No description provided for @aboutTabTeam.
  ///
  /// In id, this message translates to:
  /// **'Tim Kami'**
  String get aboutTabTeam;

  /// No description provided for @aboutSupportTitle.
  ///
  /// In id, this message translates to:
  /// **'Ingin ikut mendukung?'**
  String get aboutSupportTitle;

  /// No description provided for @aboutSupportBody.
  ///
  /// In id, this message translates to:
  /// **'Dukungan bisa lewat GitHub Sponsors atau Saweria. Detail kerja sama ada di profil organisasi kami di GitHub.'**
  String get aboutSupportBody;

  /// No description provided for @aboutTogetherTitle.
  ///
  /// In id, this message translates to:
  /// **'Bersama warga Sambas'**
  String get aboutTogetherTitle;

  /// No description provided for @aboutTogetherBody.
  ///
  /// In id, this message translates to:
  /// **'Kamus ini dirawat orang-orang yang mengusulkan kata, memeriksa entri, dan merekam pelafalan.'**
  String get aboutTogetherBody;

  /// No description provided for @aboutContributorsTitle.
  ///
  /// In id, this message translates to:
  /// **'Kontributor'**
  String get aboutContributorsTitle;

  /// No description provided for @aboutContributorsBody.
  ///
  /// In id, this message translates to:
  /// **'Mengirim kata baru atau perbaikan, dan merekam cara mengucapkan kata agar bisa didengar. Entri tayang setelah verifikasi.'**
  String get aboutContributorsBody;

  /// No description provided for @aboutVerifiersTitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikator'**
  String get aboutVerifiersTitle;

  /// No description provided for @aboutVerifiersBody.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa usulan sebelum masuk kamus.'**
  String get aboutVerifiersBody;

  /// No description provided for @aboutSponsorsSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Sponsor & Mitra'**
  String get aboutSponsorsSectionTitle;

  /// No description provided for @aboutSponsorsTooltip.
  ///
  /// In id, this message translates to:
  /// **'Sponsor: pemberi dana atau barang untuk biaya operasional (domain, server, honorarium). Mitra: rekan kerja sama yang berkontribusi dana, tenaga, materi, atau data. Nama semua pendukung kami cantumkan sebagai apresiasi atas dukungannya.'**
  String get aboutSponsorsTooltip;

  /// No description provided for @aboutOpenWebsiteFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa membuka website'**
  String get aboutOpenWebsiteFailed;

  /// No description provided for @aboutOpenWebsiteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Buka website'**
  String get aboutOpenWebsiteTooltip;

  /// Banner update
  ///
  /// In id, this message translates to:
  /// **'Versi {version} sudah tersedia'**
  String updateAvailableTitle(String version);

  /// No description provided for @updateAvailableBody.
  ///
  /// In id, this message translates to:
  /// **'Update biar dapat fitur terbaru dan perbaikan bug ya.'**
  String get updateAvailableBody;

  /// No description provided for @updateNow.
  ///
  /// In id, this message translates to:
  /// **'Update sekarang'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get updateLater;

  /// No description provided for @reportBugTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporkan Masalah'**
  String get reportBugTitle;

  /// No description provided for @reportBugGuestAnonymous.
  ///
  /// In id, this message translates to:
  /// **'Laporan kamu dikirim sebagai Anonim'**
  String get reportBugGuestAnonymous;

  /// No description provided for @reportBugGuestLoginHint.
  ///
  /// In id, this message translates to:
  /// **'Login untuk bisa melampirkan screenshot'**
  String get reportBugGuestLoginHint;

  /// No description provided for @reportBugDescriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get reportBugDescriptionLabel;

  /// No description provided for @reportBugDescriptionHint.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan apa yang terjadi, langkah reproduksi, dan yang kamu harapkan'**
  String get reportBugDescriptionHint;

  /// No description provided for @reportBugAttachmentsLabel.
  ///
  /// In id, this message translates to:
  /// **'Lampiran (opsional, maks 4)'**
  String get reportBugAttachmentsLabel;

  /// No description provided for @reportBugSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get reportBugSubmit;

  /// No description provided for @reportBugSubmitting.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get reportBugSubmitting;

  /// No description provided for @reportBugThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih, laporan kamu sudah kami terima'**
  String get reportBugThanks;

  /// No description provided for @reportBugWaitUpload.
  ///
  /// In id, this message translates to:
  /// **'Tunggu upload gambar selesai'**
  String get reportBugWaitUpload;

  /// No description provided for @reportBugAllImagesFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Semua gambar gagal'**
  String get reportBugAllImagesFailedTitle;

  /// No description provided for @reportBugAllImagesFailedBody.
  ///
  /// In id, this message translates to:
  /// **'Keterangan tetap bisa dikirim tanpa lampiran. Lanjutkan?'**
  String get reportBugAllImagesFailedBody;

  /// No description provided for @reportBugImagesUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Gambar tidak bisa diunggah'**
  String get reportBugImagesUnavailableTitle;

  /// No description provided for @reportBugImagesUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Penyimpanan gambar sedang tidak tersedia. Kirim laporan tanpa lampiran?'**
  String get reportBugImagesUnavailableBody;

  /// No description provided for @reportBugSendWithoutImages.
  ///
  /// In id, this message translates to:
  /// **'Kirim tanpa gambar'**
  String get reportBugSendWithoutImages;

  /// No description provided for @reportBugCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get reportBugCancel;

  /// No description provided for @reportBugGenericError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan, coba lagi'**
  String get reportBugGenericError;

  /// No description provided for @reportBugTimeout.
  ///
  /// In id, this message translates to:
  /// **'Server lama merespons. Coba lagi dalam beberapa saat.'**
  String get reportBugTimeout;

  /// No description provided for @reportBugConnectionError.
  ///
  /// In id, this message translates to:
  /// **'Gagal terhubung ke server. Coba lagi dalam beberapa saat.'**
  String get reportBugConnectionError;

  /// Pesan server + sisa detik
  ///
  /// In id, this message translates to:
  /// **'{message} Coba lagi dalam {seconds} detik.'**
  String reportBugRateLimited(String message, String seconds);

  /// No description provided for @reportEntryTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporkan entri'**
  String get reportEntryTitle;

  /// No description provided for @reportPhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporkan foto'**
  String get reportPhotoTitle;

  /// No description provided for @reportEntryBody.
  ///
  /// In id, this message translates to:
  /// **'Untuk entri yang tidak layak tayang. Perbaikan isi tetap lewat Usulkan perubahan.'**
  String get reportEntryBody;

  /// No description provided for @reportPhotoBody.
  ///
  /// In id, this message translates to:
  /// **'Laporkan foto ini ke tim Sambasku untuk ditinjau.'**
  String get reportPhotoBody;

  /// No description provided for @reportReasonNotSambas.
  ///
  /// In id, this message translates to:
  /// **'Bukan kosakata Sambas'**
  String get reportReasonNotSambas;

  /// No description provided for @reportReasonInaccurate.
  ///
  /// In id, this message translates to:
  /// **'Arti atau ejaan salah'**
  String get reportReasonInaccurate;

  /// No description provided for @reportReasonDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Duplikat entri lain'**
  String get reportReasonDuplicate;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In id, this message translates to:
  /// **'Tidak pantas'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonVulgar.
  ///
  /// In id, this message translates to:
  /// **'Kata kasar/vulgar'**
  String get reportReasonVulgar;

  /// No description provided for @reportReasonSpam.
  ///
  /// In id, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get reportReasonOther;

  /// No description provided for @reportImageViolence.
  ///
  /// In id, this message translates to:
  /// **'Foto berisi kekerasan'**
  String get reportImageViolence;

  /// No description provided for @reportImageSexual.
  ///
  /// In id, this message translates to:
  /// **'Foto berisi konten seksual'**
  String get reportImageSexual;

  /// No description provided for @reportImageInappropriate.
  ///
  /// In id, this message translates to:
  /// **'Foto tidak pantas'**
  String get reportImageInappropriate;

  /// No description provided for @reportNoteRequiredToast.
  ///
  /// In id, this message translates to:
  /// **'Catatan wajib diisi untuk alasan ini'**
  String get reportNoteRequiredToast;

  /// No description provided for @reportNoteWithChip.
  ///
  /// In id, this message translates to:
  /// **'{chip}. Catatan: {note}'**
  String reportNoteWithChip(String chip, String note);

  /// No description provided for @reportNoteLabelRequired.
  ///
  /// In id, this message translates to:
  /// **'Catatan wajib'**
  String get reportNoteLabelRequired;

  /// No description provided for @reportNoteLabelOptional.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get reportNoteLabelOptional;

  /// No description provided for @reportSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim laporan'**
  String get reportSubmit;

  /// No description provided for @reportSubmitting.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get reportSubmitting;

  /// No description provided for @reportPantunAction.
  ///
  /// In id, this message translates to:
  /// **'Laporkan'**
  String get reportPantunAction;

  /// No description provided for @reportPantunTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporkan pantun'**
  String get reportPantunTitle;

  /// No description provided for @reportPantunSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Laporanmu ditinjau tim Sambasku. Pantun tetap tayang sampai diputuskan.'**
  String get reportPantunSubtitle;

  /// No description provided for @reportPantunInappropriate.
  ///
  /// In id, this message translates to:
  /// **'Tidak pantas'**
  String get reportPantunInappropriate;

  /// No description provided for @reportPantunSexual.
  ///
  /// In id, this message translates to:
  /// **'Konten seksual'**
  String get reportPantunSexual;

  /// No description provided for @reportPantunHarassment.
  ///
  /// In id, this message translates to:
  /// **'Pelecehan atau perundungan'**
  String get reportPantunHarassment;

  /// No description provided for @reportPantunHateSpeech.
  ///
  /// In id, this message translates to:
  /// **'Ujaran kebencian'**
  String get reportPantunHateSpeech;

  /// No description provided for @reportPantunSpam.
  ///
  /// In id, this message translates to:
  /// **'Spam'**
  String get reportPantunSpam;

  /// No description provided for @reportPantunOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get reportPantunOther;

  /// No description provided for @reportPantunSent.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih, laporanmu sudah kami terima'**
  String get reportPantunSent;

  /// No description provided for @reportPantunLoginFirst.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu ya untuk melaporkan pantun'**
  String get reportPantunLoginFirst;

  /// No description provided for @searchMissTitle.
  ///
  /// In id, this message translates to:
  /// **'Dicari warga'**
  String get searchMissTitle;

  /// No description provided for @searchMissHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih kata yang warga cari tapi belum ada, nanti form usulannya terbuka.'**
  String get searchMissHint;

  /// No description provided for @searchMissLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar pencarian'**
  String get searchMissLoadFailed;

  /// No description provided for @searchMissEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kata yang dicari warga. Coba lagi dalam beberapa saat, atau usulkan kata baru dari menu di atas.'**
  String get searchMissEmpty;

  /// No description provided for @searchMissDirectionIdToSbs.
  ///
  /// In id, this message translates to:
  /// **'Indonesia → Sambas'**
  String get searchMissDirectionIdToSbs;

  /// No description provided for @searchMissDirectionSbsToId.
  ///
  /// In id, this message translates to:
  /// **'Sambas → Indonesia'**
  String get searchMissDirectionSbsToId;

  /// No description provided for @searchMissHitCount.
  ///
  /// In id, this message translates to:
  /// **'{count}× dicari'**
  String searchMissHitCount(String count);

  /// No description provided for @voteLoginPrompt.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk memberi vote'**
  String get voteLoginPrompt;

  /// No description provided for @voteDeckLoginPrompt.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk menilai kata'**
  String get voteDeckLoginPrompt;

  /// No description provided for @voteDeckLoginCta.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get voteDeckLoginCta;

  /// No description provided for @voteDeckHelper.
  ///
  /// In id, this message translates to:
  /// **'Bantu nilai agar arti kata lebih akurat'**
  String get voteDeckHelper;

  /// {more} = "+" bila masih ada kartu berikutnya
  ///
  /// In id, this message translates to:
  /// **'sisa {count}{more}'**
  String voteDeckRemaining(String count, String more);

  /// No description provided for @voteDeckSubmitFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan penilaian'**
  String get voteDeckSubmitFailed;

  /// No description provided for @voteDeckSessionEnded.
  ///
  /// In id, this message translates to:
  /// **'Sesi berakhir. Silakan masuk kembali.'**
  String get voteDeckSessionEnded;

  /// No description provided for @voteDeckLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat antrean penilaian. Ketuk refresh di atas untuk coba lagi.'**
  String get voteDeckLoadFailed;

  /// No description provided for @voteDeckEmpty.
  ///
  /// In id, this message translates to:
  /// **'Antrean kosakata voting saat ini sedang kosong. Terima kasih sudah membantu meningkatkan kualitas lemma di SambasKu.'**
  String get voteDeckEmpty;

  /// No description provided for @voteDeckSavedFromDetail.
  ///
  /// In id, this message translates to:
  /// **'Penilaian dari detail tersimpan'**
  String get voteDeckSavedFromDetail;

  /// No description provided for @voteDeckRewound.
  ///
  /// In id, this message translates to:
  /// **'Kartu sebelumnya dikembalikan.'**
  String get voteDeckRewound;

  /// No description provided for @voteDeckFix.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki'**
  String get voteDeckFix;

  /// No description provided for @voteDeckFixSemantics.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki kata ini'**
  String get voteDeckFixSemantics;

  /// No description provided for @voteDeckProcessing.
  ///
  /// In id, this message translates to:
  /// **'Memproses…'**
  String get voteDeckProcessing;

  /// No description provided for @voteDeckRewindSemantics.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke kartu sebelumnya'**
  String get voteDeckRewindSemantics;

  /// No description provided for @voteDeckSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get voteDeckSkip;

  /// No description provided for @voteDeckDisagree.
  ///
  /// In id, this message translates to:
  /// **'Perlu dicek ulang'**
  String get voteDeckDisagree;

  /// No description provided for @voteDeckAgree.
  ///
  /// In id, this message translates to:
  /// **'Sudah pas'**
  String get voteDeckAgree;

  /// No description provided for @voteSemanticsUpvote.
  ///
  /// In id, this message translates to:
  /// **'Upvote'**
  String get voteSemanticsUpvote;

  /// No description provided for @voteSemanticsDownvote.
  ///
  /// In id, this message translates to:
  /// **'Downvote'**
  String get voteSemanticsDownvote;

  /// No description provided for @voteMeaningOrder.
  ///
  /// In id, this message translates to:
  /// **'Makna ke-{order} dari {count}'**
  String voteMeaningOrder(int order, int count);

  /// No description provided for @voteEntryType.
  ///
  /// In id, this message translates to:
  /// **'Jenis entri'**
  String get voteEntryType;

  /// No description provided for @commentLoginPrompt.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk berkomentar'**
  String get commentLoginPrompt;

  /// No description provided for @commentLoginComposerPrompt.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk menulis komentar'**
  String get commentLoginComposerPrompt;

  /// No description provided for @commentSent.
  ///
  /// In id, this message translates to:
  /// **'Komentar terkirim'**
  String get commentSent;

  /// No description provided for @commentRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekam komentar suara'**
  String get commentRecordTitle;

  /// No description provided for @commentRecordBody.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 60 detik. Caption teks bisa ditambahkan di kolom sebelum merekam.'**
  String get commentRecordBody;

  /// No description provided for @commentRecordSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim rekaman'**
  String get commentRecordSubmit;

  /// No description provided for @commentDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus komentar?'**
  String get commentDeleteTitle;

  /// No description provided for @commentDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Komentar akan ditandai sebagai dihapus oleh penulis.'**
  String get commentDeleteBody;

  /// No description provided for @commentDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get commentDeleteConfirm;

  /// No description provided for @commentDeleteCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commentDeleteCancel;

  /// No description provided for @commentDeleted.
  ///
  /// In id, this message translates to:
  /// **'Komentar dihapus'**
  String get commentDeleted;

  /// No description provided for @commentSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Komentar ({count})'**
  String commentSectionTitle(int count);

  /// No description provided for @commentLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat komentar'**
  String get commentLoadFailed;

  /// No description provided for @commentLoadRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi untuk memuat komentar.'**
  String get commentLoadRetry;

  /// No description provided for @commentEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada komentar.'**
  String get commentEmpty;

  /// No description provided for @commentTakenDownModerator.
  ///
  /// In id, this message translates to:
  /// **'dihapus moderator'**
  String get commentTakenDownModerator;

  /// No description provided for @commentDeletedByAuthor.
  ///
  /// In id, this message translates to:
  /// **'dihapus penulis'**
  String get commentDeletedByAuthor;

  /// No description provided for @commentLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get commentLoading;

  /// No description provided for @commentLoadMore.
  ///
  /// In id, this message translates to:
  /// **'Muat lainnya'**
  String get commentLoadMore;

  /// No description provided for @commentMentionSearching.
  ///
  /// In id, this message translates to:
  /// **'Mencari pengguna...'**
  String get commentMentionSearching;

  /// No description provided for @commentSkeletonUsername.
  ///
  /// In id, this message translates to:
  /// **'username'**
  String get commentSkeletonUsername;

  /// No description provided for @commentSkeletonName.
  ///
  /// In id, this message translates to:
  /// **'Nama Pengguna'**
  String get commentSkeletonName;

  /// No description provided for @commentSkeletonBody.
  ///
  /// In id, this message translates to:
  /// **'Cuplikan komentar contoh untuk skeleton.'**
  String get commentSkeletonBody;

  /// No description provided for @commentSkeletonDate.
  ///
  /// In id, this message translates to:
  /// **'baru saja'**
  String get commentSkeletonDate;

  /// No description provided for @shareStockUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Latar stok tidak tersedia. Pakai tanpa latar, galeri, kamera, atau gambar kata.'**
  String get shareStockUnavailable;

  /// No description provided for @sharePhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get sharePhoto;

  /// No description provided for @shareVideo.
  ///
  /// In id, this message translates to:
  /// **'Video'**
  String get shareVideo;

  /// No description provided for @shareCameraFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka kamera'**
  String get shareCameraFailed;

  /// No description provided for @shareGalleryPickFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memilih dari galeri'**
  String get shareGalleryPickFailed;

  /// No description provided for @shareVideoFallbackShared.
  ///
  /// In id, this message translates to:
  /// **'Video tidak bisa diekspor. Dibagikan sebagai foto.'**
  String get shareVideoFallbackShared;

  /// No description provided for @shareVideoFallbackSaved.
  ///
  /// In id, this message translates to:
  /// **'Video tidak bisa diekspor. Disimpan sebagai foto.'**
  String get shareVideoFallbackSaved;

  /// No description provided for @shareFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membagikan: {error}'**
  String shareFailed(String error);

  /// No description provided for @shareSavedToGallery.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan di galeri'**
  String get shareSavedToGallery;

  /// No description provided for @shareSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String shareSaveFailed(String error);

  /// No description provided for @shareSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan kartu'**
  String get shareSheetTitle;

  /// No description provided for @shareAdjustPosition.
  ///
  /// In id, this message translates to:
  /// **'Atur posisi'**
  String get shareAdjustPosition;

  /// No description provided for @shareAdjustHintPannable.
  ///
  /// In id, this message translates to:
  /// **'Geser teks atau crop gambar / video'**
  String get shareAdjustHintPannable;

  /// No description provided for @shareAdjustHintFixed.
  ///
  /// In id, this message translates to:
  /// **'Buka fullscreen untuk geser / putar teks'**
  String get shareAdjustHintFixed;

  /// No description provided for @shareSectionBackdrop.
  ///
  /// In id, this message translates to:
  /// **'Latar'**
  String get shareSectionBackdrop;

  /// No description provided for @shareChipNoBackdrop.
  ///
  /// In id, this message translates to:
  /// **'Tanpa\nlatar'**
  String get shareChipNoBackdrop;

  /// No description provided for @shareChipExplorer.
  ///
  /// In id, this message translates to:
  /// **'Explorer'**
  String get shareChipExplorer;

  /// No description provided for @shareChipGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get shareChipGallery;

  /// No description provided for @shareChipCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get shareChipCamera;

  /// No description provided for @shareChipWord.
  ///
  /// In id, this message translates to:
  /// **'Kata'**
  String get shareChipWord;

  /// No description provided for @shareThumbHint.
  ///
  /// In id, this message translates to:
  /// **'Tahan thumb untuk preview fullscreen · Explorer untuk cari gambar atau video'**
  String get shareThumbHint;

  /// No description provided for @shareSectionStyle.
  ///
  /// In id, this message translates to:
  /// **'Gaya'**
  String get shareSectionStyle;

  /// No description provided for @shareSectionRatio.
  ///
  /// In id, this message translates to:
  /// **'Rasio'**
  String get shareSectionRatio;

  /// No description provided for @shareSectionMeaning.
  ///
  /// In id, this message translates to:
  /// **'Makna'**
  String get shareSectionMeaning;

  /// No description provided for @shareMeaningAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get shareMeaningAll;

  /// No description provided for @shareMeaningNth.
  ///
  /// In id, this message translates to:
  /// **'Makna {n}'**
  String shareMeaningNth(int n);

  /// No description provided for @shareSectionEditor.
  ///
  /// In id, this message translates to:
  /// **'Editor'**
  String get shareSectionEditor;

  /// No description provided for @shareSectionFont.
  ///
  /// In id, this message translates to:
  /// **'Font'**
  String get shareSectionFont;

  /// No description provided for @shareLabelColor.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get shareLabelColor;

  /// No description provided for @shareLabelGradient.
  ///
  /// In id, this message translates to:
  /// **'Gradasi'**
  String get shareLabelGradient;

  /// No description provided for @shareLemmaSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran lemma'**
  String get shareLemmaSize;

  /// No description provided for @shareBodySize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran teks deskripsi'**
  String get shareBodySize;

  /// No description provided for @shareOverlayThickness.
  ///
  /// In id, this message translates to:
  /// **'Ketebalan overlay'**
  String get shareOverlayThickness;

  /// No description provided for @shareShowWordClass.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kelas kata'**
  String get shareShowWordClass;

  /// No description provided for @shareShowTranslation.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan terjemahan'**
  String get shareShowTranslation;

  /// No description provided for @shareShowDefinition.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan definisi'**
  String get shareShowDefinition;

  /// No description provided for @shareShowExample.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan contoh kalimat'**
  String get shareShowExample;

  /// No description provided for @shareWatermarkRequired.
  ///
  /// In id, this message translates to:
  /// **'Watermark SambasKu (wajib untuk foto Creative Commons)'**
  String get shareWatermarkRequired;

  /// No description provided for @shareWatermarkToggle.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan watermark SambasKu'**
  String get shareWatermarkToggle;

  /// No description provided for @shareSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get shareSave;

  /// No description provided for @shareShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get shareShare;

  /// No description provided for @sharePreviewCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Preview kartu'**
  String get sharePreviewCardTitle;

  /// No description provided for @shareLayoutEditorTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur posisi'**
  String get shareLayoutEditorTitle;

  /// No description provided for @shareCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get shareCancel;

  /// No description provided for @shareDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get shareDone;

  /// No description provided for @shareLayoutHintPannable.
  ///
  /// In id, this message translates to:
  /// **'Ketuk teks untuk menggesernya. Area kosong menggeser gambar. Garis putus-putus = tengah.'**
  String get shareLayoutHintPannable;

  /// No description provided for @shareLayoutHintFixed.
  ///
  /// In id, this message translates to:
  /// **'Ketuk teks berborder untuk menggeser. Garis putus-putus = tengah.'**
  String get shareLayoutHintFixed;

  /// No description provided for @shareRotateLabel.
  ///
  /// In id, this message translates to:
  /// **'Rotasi {label}'**
  String shareRotateLabel(String label);

  /// No description provided for @shareDragToCrop.
  ///
  /// In id, this message translates to:
  /// **'Geser di kartu untuk mengatur crop gambar atau video'**
  String get shareDragToCrop;

  /// No description provided for @sharePickBackdropOrText.
  ///
  /// In id, this message translates to:
  /// **'Pilih Latar untuk geser gambar, atau ketuk teks untuk rotasi'**
  String get sharePickBackdropOrText;

  /// No description provided for @sharePickTextElement.
  ///
  /// In id, this message translates to:
  /// **'Pilih elemen teks di kartu untuk mengatur rotasi'**
  String get sharePickTextElement;

  /// No description provided for @shareResetPosition.
  ///
  /// In id, this message translates to:
  /// **'Reset posisi'**
  String get shareResetPosition;

  /// No description provided for @shareExplorerTitle.
  ///
  /// In id, this message translates to:
  /// **'Media Explorer'**
  String get shareExplorerTitle;

  /// No description provided for @shareTabImages.
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get shareTabImages;

  /// No description provided for @shareTabVideos.
  ///
  /// In id, this message translates to:
  /// **'Video'**
  String get shareTabVideos;

  /// No description provided for @shareSearchVideosHint.
  ///
  /// In id, this message translates to:
  /// **'Cari video…'**
  String get shareSearchVideosHint;

  /// No description provided for @shareSearchImagesHint.
  ///
  /// In id, this message translates to:
  /// **'Cari gambar…'**
  String get shareSearchImagesHint;

  /// No description provided for @shareSearchCta.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get shareSearchCta;

  /// No description provided for @sharePopular.
  ///
  /// In id, this message translates to:
  /// **'Populer'**
  String get sharePopular;

  /// No description provided for @shareSearchResult.
  ///
  /// In id, this message translates to:
  /// **'Hasil: {query}'**
  String shareSearchResult(String query);

  /// No description provided for @shareBackdropUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Latar tidak tersedia. Coba lagi dalam beberapa saat.'**
  String get shareBackdropUnavailable;

  /// No description provided for @shareNoResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil.'**
  String get shareNoResults;

  /// No description provided for @shareVideoBadge.
  ///
  /// In id, this message translates to:
  /// **'{provider} video'**
  String shareVideoBadge(String provider);

  /// No description provided for @shareSolidColorTitle.
  ///
  /// In id, this message translates to:
  /// **'Warna polos'**
  String get shareSolidColorTitle;

  /// No description provided for @shareHexLabel.
  ///
  /// In id, this message translates to:
  /// **'Hex'**
  String get shareHexLabel;

  /// No description provided for @shareApply.
  ///
  /// In id, this message translates to:
  /// **'Pakai'**
  String get shareApply;

  /// No description provided for @shareTemplateFull.
  ///
  /// In id, this message translates to:
  /// **'Penuh'**
  String get shareTemplateFull;

  /// No description provided for @shareTemplateEditorial.
  ///
  /// In id, this message translates to:
  /// **'Editorial'**
  String get shareTemplateEditorial;

  /// No description provided for @shareTemplatePoster.
  ///
  /// In id, this message translates to:
  /// **'Poster'**
  String get shareTemplatePoster;

  /// No description provided for @shareTemplateFrame.
  ///
  /// In id, this message translates to:
  /// **'Bingkai'**
  String get shareTemplateFrame;

  /// No description provided for @shareTemplateSide.
  ///
  /// In id, this message translates to:
  /// **'Sisi'**
  String get shareTemplateSide;

  /// No description provided for @shareTemplateGlass.
  ///
  /// In id, this message translates to:
  /// **'Kaca'**
  String get shareTemplateGlass;

  /// No description provided for @shareTemplateQuote.
  ///
  /// In id, this message translates to:
  /// **'Kutipan'**
  String get shareTemplateQuote;

  /// No description provided for @shareTemplateCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu'**
  String get shareTemplateCard;

  /// No description provided for @shareFontClassic.
  ///
  /// In id, this message translates to:
  /// **'Klasik'**
  String get shareFontClassic;

  /// No description provided for @shareFontEditorial.
  ///
  /// In id, this message translates to:
  /// **'Editorial'**
  String get shareFontEditorial;

  /// No description provided for @shareFontModern.
  ///
  /// In id, this message translates to:
  /// **'Modern'**
  String get shareFontModern;

  /// No description provided for @shareElementLemma.
  ///
  /// In id, this message translates to:
  /// **'Lemma'**
  String get shareElementLemma;

  /// No description provided for @shareElementTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get shareElementTranslation;

  /// No description provided for @shareElementDefinition.
  ///
  /// In id, this message translates to:
  /// **'Definisi'**
  String get shareElementDefinition;

  /// No description provided for @shareElementExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get shareElementExample;

  /// No description provided for @shareElementWordClass.
  ///
  /// In id, this message translates to:
  /// **'Kelas kata'**
  String get shareElementWordClass;

  /// No description provided for @suggestCategoryChangeMeaning.
  ///
  /// In id, this message translates to:
  /// **'Ubah makna'**
  String get suggestCategoryChangeMeaning;

  /// No description provided for @suggestCategoryChangeMeaningDesc.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki definisi atau terjemahan'**
  String get suggestCategoryChangeMeaningDesc;

  /// No description provided for @suggestCategoryChangeWordClass.
  ///
  /// In id, this message translates to:
  /// **'Ubah kelas kata'**
  String get suggestCategoryChangeWordClass;

  /// No description provided for @suggestCategoryChangeWordClassDesc.
  ///
  /// In id, this message translates to:
  /// **'Nomina, verba, adjektiva, dsb.'**
  String get suggestCategoryChangeWordClassDesc;

  /// No description provided for @suggestCategoryAddMeaning.
  ///
  /// In id, this message translates to:
  /// **'Tambah makna'**
  String get suggestCategoryAddMeaning;

  /// No description provided for @suggestCategoryAddMeaningDesc.
  ///
  /// In id, this message translates to:
  /// **'Arti lain dari kata ini'**
  String get suggestCategoryAddMeaningDesc;

  /// No description provided for @suggestCategoryAddExample.
  ///
  /// In id, this message translates to:
  /// **'Tambah contoh'**
  String get suggestCategoryAddExample;

  /// No description provided for @suggestCategoryAddExampleDesc.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat untuk satu makna'**
  String get suggestCategoryAddExampleDesc;

  /// No description provided for @suggestCategoryAddPhoto.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get suggestCategoryAddPhoto;

  /// No description provided for @suggestCategoryAddPhotoDesc.
  ///
  /// In id, this message translates to:
  /// **'Foto yang menggambarkan kata ini'**
  String get suggestCategoryAddPhotoDesc;

  /// No description provided for @suggestCategoryChangePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ubah foto'**
  String get suggestCategoryChangePhoto;

  /// No description provided for @suggestCategoryChangePhotoDesc.
  ///
  /// In id, this message translates to:
  /// **'Hapus, ganti, atau pilih foto utama'**
  String get suggestCategoryChangePhotoDesc;

  /// No description provided for @suggestCategorySynonym.
  ///
  /// In id, this message translates to:
  /// **'Sinonim'**
  String get suggestCategorySynonym;

  /// No description provided for @suggestCategorySynonymDesc.
  ///
  /// In id, this message translates to:
  /// **'Kata lain yang artinya sama'**
  String get suggestCategorySynonymDesc;

  /// No description provided for @suggestCategoryAntonym.
  ///
  /// In id, this message translates to:
  /// **'Antonim'**
  String get suggestCategoryAntonym;

  /// No description provided for @suggestCategoryAntonymDesc.
  ///
  /// In id, this message translates to:
  /// **'Kata yang artinya berlawanan'**
  String get suggestCategoryAntonymDesc;

  /// No description provided for @suggestCategoryVariantOf.
  ///
  /// In id, this message translates to:
  /// **'Variasi bentuk'**
  String get suggestCategoryVariantOf;

  /// No description provided for @suggestCategoryVariantOfDesc.
  ///
  /// In id, this message translates to:
  /// **'Kata ini variasi dari kata lain'**
  String get suggestCategoryVariantOfDesc;

  /// No description provided for @suggestCategoryNonstandardOf.
  ///
  /// In id, this message translates to:
  /// **'Bentuk tidak baku'**
  String get suggestCategoryNonstandardOf;

  /// No description provided for @suggestCategoryNonstandardOfDesc.
  ///
  /// In id, this message translates to:
  /// **'Kata ini bentuk tidak baku dari kata baku'**
  String get suggestCategoryNonstandardOfDesc;

  /// No description provided for @suggestCategoryDerivedFrom.
  ///
  /// In id, this message translates to:
  /// **'Kata turunan'**
  String get suggestCategoryDerivedFrom;

  /// No description provided for @suggestCategoryDerivedFromDesc.
  ///
  /// In id, this message translates to:
  /// **'Kata ini diturunkan dari akar kata'**
  String get suggestCategoryDerivedFromDesc;

  /// No description provided for @suggestCategoryMeaningGroup.
  ///
  /// In id, this message translates to:
  /// **'Kelompok makna'**
  String get suggestCategoryMeaningGroup;

  /// No description provided for @suggestCategoryMeaningGroupDesc.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan kata bermakna sama dalam satu kelompok'**
  String get suggestCategoryMeaningGroupDesc;

  /// No description provided for @suggestCategorySpellingVariant.
  ///
  /// In id, this message translates to:
  /// **'Variasi penulisan'**
  String get suggestCategorySpellingVariant;

  /// No description provided for @suggestCategorySpellingVariantDesc.
  ///
  /// In id, this message translates to:
  /// **'Ejaan lain untuk kata yang sama'**
  String get suggestCategorySpellingVariantDesc;

  /// No description provided for @suggestCategoryLemmaNotes.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get suggestCategoryLemmaNotes;

  /// No description provided for @suggestCategoryLemmaNotesDesc.
  ///
  /// In id, this message translates to:
  /// **'Ejaan lemma atau catatan'**
  String get suggestCategoryLemmaNotesDesc;

  /// No description provided for @suggestEntryTileVerifierTitle.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki/lengkapi kata'**
  String get suggestEntryTileVerifierTitle;

  /// No description provided for @suggestEntryTileVerifierSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah makna, relasi, contoh, pelafalan - langsung terbit'**
  String get suggestEntryTileVerifierSubtitle;

  /// No description provided for @suggestEntryTileContributorTitle.
  ///
  /// In id, this message translates to:
  /// **'Usulkan perubahan'**
  String get suggestEntryTileContributorTitle;

  /// No description provided for @suggestEntryTileContributorSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Perbaikan kata yang sudah tayang menunggu persetujuan admin'**
  String get suggestEntryTileContributorSubtitle;

  /// No description provided for @suggestPreSubmitVerifierBanner.
  ///
  /// In id, this message translates to:
  /// **'Ubah yang perlu saja. Perubahan langsung diterapkan, tanpa antrean.'**
  String get suggestPreSubmitVerifierBanner;

  /// No description provided for @suggestPreSubmitVerifierCta.
  ///
  /// In id, this message translates to:
  /// **'Simpan perubahan'**
  String get suggestPreSubmitVerifierCta;

  /// No description provided for @suggestPreSubmitVerifierCtaBusy.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan...'**
  String get suggestPreSubmitVerifierCtaBusy;

  /// No description provided for @suggestPreSubmitContributorBanner.
  ///
  /// In id, this message translates to:
  /// **'Ubah yang perlu saja. Admin mereview sebelum tayang.'**
  String get suggestPreSubmitContributorBanner;

  /// No description provided for @suggestPreSubmitContributorCta.
  ///
  /// In id, this message translates to:
  /// **'Kirim Usulan'**
  String get suggestPreSubmitContributorCta;

  /// No description provided for @suggestPreSubmitContributorCtaBusy.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get suggestPreSubmitContributorCtaBusy;

  /// No description provided for @suggestSuccessThisWord.
  ///
  /// In id, this message translates to:
  /// **'kata ini'**
  String get suggestSuccessThisWord;

  /// No description provided for @suggestSuccessApplied.
  ///
  /// In id, this message translates to:
  /// **'Perubahan langsung diterapkan pada \"{label}\".'**
  String suggestSuccessApplied(String label);

  /// No description provided for @suggestSuccessQueued.
  ///
  /// In id, this message translates to:
  /// **'Usulan untuk \"{label}\" masuk antrean. Isi yang sedang tayang belum berubah.'**
  String suggestSuccessQueued(String label);

  /// No description provided for @suggestSuccessPublishedPending.
  ///
  /// In id, this message translates to:
  /// **'Perubahan sudah tayang di \"{label}\". Statusnya tetap menunggu pengecekan.'**
  String suggestSuccessPublishedPending(String label);

  /// No description provided for @suggestPickMeaning.
  ///
  /// In id, this message translates to:
  /// **'Pilih makna'**
  String get suggestPickMeaning;

  /// No description provided for @suggestUnexpectedError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get suggestUnexpectedError;

  /// No description provided for @suggestNothingChangedFor.
  ///
  /// In id, this message translates to:
  /// **'Belum ada yang diubah untuk {category}.'**
  String suggestNothingChangedFor(String category);

  /// No description provided for @suggestNothingChanged.
  ///
  /// In id, this message translates to:
  /// **'Belum ada perubahan'**
  String get suggestNothingChanged;

  /// No description provided for @suggestExampleFirst.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimatnya diisi dulu ya'**
  String get suggestExampleFirst;

  /// No description provided for @suggestExamplePublishedToast.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat sudah tayang.'**
  String get suggestExamplePublishedToast;

  /// No description provided for @suggestExampleQueuedToast.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat masuk antrean pengecekan.'**
  String get suggestExampleQueuedToast;

  /// No description provided for @suggestSubmitFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim usulan. Coba lagi dalam beberapa saat.'**
  String get suggestSubmitFailed;

  /// No description provided for @suggestReviewForm.
  ///
  /// In id, this message translates to:
  /// **'Periksa lagi isian'**
  String get suggestReviewForm;

  /// No description provided for @suggestStillPendingTitle.
  ///
  /// In id, this message translates to:
  /// **'Usulan masih menunggu'**
  String get suggestStillPendingTitle;

  /// No description provided for @suggestSuggestChangeCta.
  ///
  /// In id, this message translates to:
  /// **'Usulkan Perubahan'**
  String get suggestSuggestChangeCta;

  /// No description provided for @suggestLoginPrompt.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk mengusulkan'**
  String get suggestLoginPrompt;

  /// No description provided for @suggestSendExample.
  ///
  /// In id, this message translates to:
  /// **'Kirim contoh'**
  String get suggestSendExample;

  /// No description provided for @suggestWhatToChange.
  ///
  /// In id, this message translates to:
  /// **'Apa yang ingin diubah?'**
  String get suggestWhatToChange;

  /// No description provided for @suggestChangeTypeSemantics.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk ganti jenis usulan'**
  String get suggestChangeTypeSemantics;

  /// No description provided for @suggestMeaningSection.
  ///
  /// In id, this message translates to:
  /// **'Makna'**
  String get suggestMeaningSection;

  /// No description provided for @suggestReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan (opsional)'**
  String get suggestReasonLabel;

  /// No description provided for @suggestReasonHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: sumber, penutur asli, atau KBBI'**
  String get suggestReasonHint;

  /// No description provided for @suggestExampleSection.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat ({lemma})'**
  String suggestExampleSection(String lemma);

  /// No description provided for @suggestExampleLangHint.
  ///
  /// In id, this message translates to:
  /// **'Kalimat dalam bahasa Sambas'**
  String get suggestExampleLangHint;

  /// No description provided for @suggestExampleTranslationLabel.
  ///
  /// In id, this message translates to:
  /// **'Artinya (opsional)'**
  String get suggestExampleTranslationLabel;

  /// No description provided for @suggestExampleTranslationHint.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan bahasa Indonesia'**
  String get suggestExampleTranslationHint;

  /// No description provided for @suggestExistingPhotos.
  ///
  /// In id, this message translates to:
  /// **'Foto yang ada'**
  String get suggestExistingPhotos;

  /// No description provided for @suggestReplacementPhotos.
  ///
  /// In id, this message translates to:
  /// **'Foto pengganti (opsional)'**
  String get suggestReplacementPhotos;

  /// No description provided for @suggestReplacementPhotosHint.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan bila foto yang dihapus perlu diganti.'**
  String get suggestReplacementPhotosHint;

  /// No description provided for @suggestDerivedFromLabel.
  ///
  /// In id, this message translates to:
  /// **'akar kata'**
  String get suggestDerivedFromLabel;

  /// No description provided for @suggestReferenceLabel.
  ///
  /// In id, this message translates to:
  /// **'kata rujukan'**
  String get suggestReferenceLabel;

  /// No description provided for @suggestAddRelation.
  ///
  /// In id, this message translates to:
  /// **'Tambah {category}'**
  String suggestAddRelation(String category);

  /// No description provided for @suggestRelationPickHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih saran ketik, atau tulis lemma baru sendiri'**
  String get suggestRelationPickHint;

  /// No description provided for @suggestDerivedHint.
  ///
  /// In id, this message translates to:
  /// **'Kata ini diturunkan dari {target} di atas'**
  String suggestDerivedHint(String target);

  /// No description provided for @suggestVariantOfHint.
  ///
  /// In id, this message translates to:
  /// **'Kata ini variasi/bentuk lain dari kata di atas'**
  String get suggestVariantOfHint;

  /// No description provided for @suggestDerivedExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: \"ngansoh\" diturunkan dari \"ansoh\".'**
  String get suggestDerivedExample;

  /// No description provided for @suggestVariantExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: \"tekpalat\" variasi dari \"taek palat\".'**
  String get suggestVariantExample;

  /// No description provided for @suggestRemoveRelation.
  ///
  /// In id, this message translates to:
  /// **'Hapus {category} yang ada'**
  String suggestRemoveRelation(String category);

  /// No description provided for @suggestNewGroupName.
  ///
  /// In id, this message translates to:
  /// **'Nama kelompok baru'**
  String get suggestNewGroupName;

  /// No description provided for @suggestNewGroupNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: kenapa'**
  String get suggestNewGroupNameHint;

  /// No description provided for @suggestOtherMembers.
  ///
  /// In id, this message translates to:
  /// **'Anggota lain'**
  String get suggestOtherMembers;

  /// No description provided for @suggestGroupExplainer.
  ///
  /// In id, this message translates to:
  /// **'Kelompok menghimpun kata bermakna sama. Kata ini otomatis jadi anggota.'**
  String get suggestGroupExplainer;

  /// No description provided for @suggestGroupExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: \"ngape\", \"jape\", \"jope\" = kelompok \"kenapa\".'**
  String get suggestGroupExample;

  /// No description provided for @suggestGroupSeparateNote.
  ///
  /// In id, this message translates to:
  /// **'Kata tetap jadi entri terpisah - kelompok hanya mengelompokkan.'**
  String get suggestGroupSeparateNote;

  /// No description provided for @suggestLeaveGroup.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari kelompok'**
  String get suggestLeaveGroup;

  /// No description provided for @suggestAddVariant.
  ///
  /// In id, this message translates to:
  /// **'Tambah variasi'**
  String get suggestAddVariant;

  /// No description provided for @suggestAddVariantHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: kate, katee (pisahkan dengan koma)'**
  String get suggestAddVariantHint;

  /// No description provided for @suggestRemoveVariant.
  ///
  /// In id, this message translates to:
  /// **'Hapus variasi yang ada'**
  String get suggestRemoveVariant;

  /// No description provided for @suggestLemmaLabel.
  ///
  /// In id, this message translates to:
  /// **'Lemma'**
  String get suggestLemmaLabel;

  /// No description provided for @suggestNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get suggestNotesLabel;

  /// No description provided for @suggestNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Asal kata, pemakaian, atau keterangan lain'**
  String get suggestNotesHint;

  /// No description provided for @suggestTranslationField.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan Indonesia'**
  String get suggestTranslationField;

  /// No description provided for @suggestTranslationHint.
  ///
  /// In id, this message translates to:
  /// **'Satu kata/frasa setara dengan lemma. Contoh: \"makan\". Beda dari definisi.'**
  String get suggestTranslationHint;

  /// No description provided for @suggestTranslationSemanticsHint.
  ///
  /// In id, this message translates to:
  /// **'Satu kata/frasa setara di Indonesia'**
  String get suggestTranslationSemanticsHint;

  /// No description provided for @suggestKbbiSemantics.
  ///
  /// In id, this message translates to:
  /// **'Tekan ikon buku untuk mencari definisi di KBBI'**
  String get suggestKbbiSemantics;

  /// Info di bawah field terjemahan: sumber definisi KBBI pihak ketiga dan efek pilihan ke kolom definisi + terjemahan
  ///
  /// In id, this message translates to:
  /// **'Definisi diambil dari KBBI pihak ketiga. Yang kamu pilih mengisi kolom definisi dan terjemahan - periksa sebelum kirim.'**
  String get kbbiSourceNotice;

  /// No description provided for @suggestDefinitionLabel.
  ///
  /// In id, this message translates to:
  /// **'Definisi'**
  String get suggestDefinitionLabel;

  /// No description provided for @suggestDefinitionHint.
  ///
  /// In id, this message translates to:
  /// **'Uraian makna berbahasa Indonesia - bukan terjemahan satu kata.'**
  String get suggestDefinitionHint;

  /// No description provided for @suggestDefinitionPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan makna kata ini'**
  String get suggestDefinitionPlaceholder;

  /// No description provided for @suggestWordClassLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal muat kelas kata - coba lagi'**
  String get suggestWordClassLoadFailed;

  /// No description provided for @suggestWordClassLabel.
  ///
  /// In id, this message translates to:
  /// **'Kelas kata (opsional)'**
  String get suggestWordClassLabel;

  /// No description provided for @suggestWordClassLabelShort.
  ///
  /// In id, this message translates to:
  /// **'Kelas kata'**
  String get suggestWordClassLabelShort;

  /// No description provided for @suggestWordClassHint.
  ///
  /// In id, this message translates to:
  /// **'Nomina, verba, adjektiva, dsb.'**
  String get suggestWordClassHint;

  /// No description provided for @suggestWordClassPicker.
  ///
  /// In id, this message translates to:
  /// **'Pilih kelas kata'**
  String get suggestWordClassPicker;

  /// No description provided for @suggestRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get suggestRemove;

  /// No description provided for @suggestRemovePrimary.
  ///
  /// In id, this message translates to:
  /// **'Hapus (utama)'**
  String get suggestRemovePrimary;

  /// No description provided for @suggestPrimaryMark.
  ///
  /// In id, this message translates to:
  /// **'Utama ✓'**
  String get suggestPrimaryMark;

  /// No description provided for @suggestSetPrimary.
  ///
  /// In id, this message translates to:
  /// **'Jadikan utama'**
  String get suggestSetPrimary;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat perubahan'**
  String get historyTitle;

  /// No description provided for @historyAdded.
  ///
  /// In id, this message translates to:
  /// **'Ditambah {items}'**
  String historyAdded(String items);

  /// No description provided for @historyRemoved.
  ///
  /// In id, this message translates to:
  /// **'Dihapus {items}'**
  String historyRemoved(String items);

  /// No description provided for @historySetPrimary.
  ///
  /// In id, this message translates to:
  /// **'Dijadikan utama {items}'**
  String historySetPrimary(String items);

  /// No description provided for @historyDuplicateConfirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi duplikat'**
  String get historyDuplicateConfirm;

  /// No description provided for @historyFromSuggestion.
  ///
  /// In id, this message translates to:
  /// **'Dari usulan'**
  String get historyFromSuggestion;

  /// No description provided for @historyDirectEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit langsung'**
  String get historyDirectEdit;

  /// No description provided for @historySystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get historySystem;

  /// No description provided for @historyWordNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kata tidak ditemukan'**
  String get historyWordNotFound;

  /// No description provided for @historyUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Riwayat tidak tersedia untuk entri ini.'**
  String get historyUnavailable;

  /// No description provided for @historyLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat riwayat'**
  String get historyLoadFailed;

  /// No description provided for @historyRetryHint.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi sebentar.'**
  String get historyRetryHint;

  /// No description provided for @historyRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get historyRetry;

  /// No description provided for @historyEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get historyEmpty;

  /// No description provided for @historyEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Perubahan yang diterapkan ke kata ini akan muncul di sini.'**
  String get historyEmptyHint;

  /// No description provided for @historyByActor.
  ///
  /// In id, this message translates to:
  /// **'Oleh {actor}'**
  String historyByActor(String actor);

  /// No description provided for @historyReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get historyReason;

  /// No description provided for @historyReviewerNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan reviewer'**
  String get historyReviewerNote;

  /// No description provided for @historyChanges.
  ///
  /// In id, this message translates to:
  /// **'Perubahan'**
  String get historyChanges;

  /// No description provided for @historyNoDetail.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada detail perubahan.'**
  String get historyNoDetail;

  /// No description provided for @historyBefore.
  ///
  /// In id, this message translates to:
  /// **'Sebelum: {value}'**
  String historyBefore(String value);

  /// No description provided for @historyAfter.
  ///
  /// In id, this message translates to:
  /// **'Sesudah: {value}'**
  String historyAfter(String value);

  /// No description provided for @historyClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get historyClose;

  /// No description provided for @historyFieldLemma.
  ///
  /// In id, this message translates to:
  /// **'Lemma'**
  String get historyFieldLemma;

  /// No description provided for @historyFieldNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get historyFieldNotes;

  /// No description provided for @historyFieldDefinition.
  ///
  /// In id, this message translates to:
  /// **'Definisi'**
  String get historyFieldDefinition;

  /// No description provided for @historyFieldTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get historyFieldTranslation;

  /// No description provided for @historyFieldMeaning.
  ///
  /// In id, this message translates to:
  /// **'Makna'**
  String get historyFieldMeaning;

  /// No description provided for @historyFieldExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get historyFieldExample;

  /// No description provided for @historyFieldVariant.
  ///
  /// In id, this message translates to:
  /// **'Variasi'**
  String get historyFieldVariant;

  /// No description provided for @historyFieldCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get historyFieldCategory;

  /// No description provided for @historyFieldRelation.
  ///
  /// In id, this message translates to:
  /// **'Relasi'**
  String get historyFieldRelation;

  /// No description provided for @historyFieldImage.
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get historyFieldImage;

  /// No description provided for @historyFieldPronunciation.
  ///
  /// In id, this message translates to:
  /// **'Pengucapan'**
  String get historyFieldPronunciation;

  /// No description provided for @historyFieldWordType.
  ///
  /// In id, this message translates to:
  /// **'Jenis kata'**
  String get historyFieldWordType;

  /// No description provided for @historyFieldLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get historyFieldLanguage;

  /// No description provided for @historyFieldVerificationStatus.
  ///
  /// In id, this message translates to:
  /// **'Status verifikasi'**
  String get historyFieldVerificationStatus;

  /// No description provided for @historyFieldStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get historyFieldStatus;

  /// No description provided for @historyFieldSupport.
  ///
  /// In id, this message translates to:
  /// **'Dukungan'**
  String get historyFieldSupport;

  /// No description provided for @historyFieldReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get historyFieldReason;

  /// No description provided for @historyFieldCorrected.
  ///
  /// In id, this message translates to:
  /// **'Dikoreksi'**
  String get historyFieldCorrected;

  /// No description provided for @historyFieldCommaSeparated.
  ///
  /// In id, this message translates to:
  /// **'Pisah koma'**
  String get historyFieldCommaSeparated;

  /// No description provided for @historyFieldCreated.
  ///
  /// In id, this message translates to:
  /// **'Dibuat'**
  String get historyFieldCreated;

  /// No description provided for @historyFieldMergedOnCreate.
  ///
  /// In id, this message translates to:
  /// **'Digabung saat buat'**
  String get historyFieldMergedOnCreate;

  /// No description provided for @historyFieldMergedOnEdit.
  ///
  /// In id, this message translates to:
  /// **'Digabung saat edit'**
  String get historyFieldMergedOnEdit;

  /// No description provided for @historyFieldSelfApplied.
  ///
  /// In id, this message translates to:
  /// **'Terapkan sendiri'**
  String get historyFieldSelfApplied;

  /// No description provided for @historyFieldSourceId.
  ///
  /// In id, this message translates to:
  /// **'ID sumber'**
  String get historyFieldSourceId;

  /// No description provided for @historyFieldSplitOriginId.
  ///
  /// In id, this message translates to:
  /// **'ID asal pisah'**
  String get historyFieldSplitOriginId;

  /// No description provided for @historyFieldMeaningId.
  ///
  /// In id, this message translates to:
  /// **'ID makna'**
  String get historyFieldMeaningId;

  /// No description provided for @historyFieldMergedWordId.
  ///
  /// In id, this message translates to:
  /// **'ID kata digabung'**
  String get historyFieldMergedWordId;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// Semantics tombol kembali di bar melayang halaman ber-cover
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get commonSave;

  /// No description provided for @commonReject.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get commonReject;

  /// No description provided for @commonApprove.
  ///
  /// In id, this message translates to:
  /// **'Setujui'**
  String get commonApprove;

  /// No description provided for @commonSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get commonSkip;

  /// No description provided for @commonDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get commonDelete;

  /// No description provided for @commonYes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get commonNo;

  /// No description provided for @commonPrimary.
  ///
  /// In id, this message translates to:
  /// **'Utama'**
  String get commonPrimary;

  /// No description provided for @commonEmptyField.
  ///
  /// In id, this message translates to:
  /// **'Belum diisi'**
  String get commonEmptyField;

  /// No description provided for @commonNoDetail.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada detail.'**
  String get commonNoDetail;

  /// No description provided for @commonLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat detail'**
  String get commonLoadFailed;

  /// No description provided for @commonForbiddenBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu tidak berwenang meninjau usulan.'**
  String get commonForbiddenBody;

  /// No description provided for @commonForbiddenRole.
  ///
  /// In id, this message translates to:
  /// **'Role tidak diizinkan mengakses endpoint ini'**
  String get commonForbiddenRole;

  /// No description provided for @commonVerifierArea.
  ///
  /// In id, this message translates to:
  /// **'Area Verifikator'**
  String get commonVerifierArea;

  /// No description provided for @commonReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get commonReason;

  /// No description provided for @reviewEntityWord.
  ///
  /// In id, this message translates to:
  /// **'Kata'**
  String get reviewEntityWord;

  /// No description provided for @reviewEntityPronunciation.
  ///
  /// In id, this message translates to:
  /// **'Pelafalan'**
  String get reviewEntityPronunciation;

  /// No description provided for @reviewEntityWordImage.
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get reviewEntityWordImage;

  /// No description provided for @reviewEntityWordAudio.
  ///
  /// In id, this message translates to:
  /// **'Audio'**
  String get reviewEntityWordAudio;

  /// No description provided for @reviewEntityExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat'**
  String get reviewEntityExample;

  /// No description provided for @reviewEntityMeaning.
  ///
  /// In id, this message translates to:
  /// **'Makna'**
  String get reviewEntityMeaning;

  /// No description provided for @reviewEntityOther.
  ///
  /// In id, this message translates to:
  /// **'Usulan'**
  String get reviewEntityOther;

  /// No description provided for @reviewStatusPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get reviewStatusPending;

  /// No description provided for @reviewStatusApproved.
  ///
  /// In id, this message translates to:
  /// **'Disetujui'**
  String get reviewStatusApproved;

  /// No description provided for @reviewStatusRejected.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get reviewStatusRejected;

  /// No description provided for @reviewStatusCorrected.
  ///
  /// In id, this message translates to:
  /// **'Dikoreksi'**
  String get reviewStatusCorrected;

  /// No description provided for @reviewStatusReopened.
  ///
  /// In id, this message translates to:
  /// **'Dibuka ulang'**
  String get reviewStatusReopened;

  /// No description provided for @reviewStatusAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get reviewStatusAll;

  /// No description provided for @reviewContributorFallback.
  ///
  /// In id, this message translates to:
  /// **'Kontributor'**
  String get reviewContributorFallback;

  /// No description provided for @reviewHomeStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai tinjau'**
  String get reviewHomeStart;

  /// No description provided for @reviewHomeContributionTitle.
  ///
  /// In id, this message translates to:
  /// **'Ada usulan yang menunggu'**
  String get reviewHomeContributionTitle;

  /// No description provided for @reviewHomeContributionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Antrean kontribusi untuk ditinjau'**
  String get reviewHomeContributionSubtitle;

  /// No description provided for @reviewHomeCompleteWordTitle.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki/lengkapi kata'**
  String get reviewHomeCompleteWordTitle;

  /// No description provided for @reviewHomeCompleteWordSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah makna, relasi, variasi penulisan, contoh, dan rekam pelafalan'**
  String get reviewHomeCompleteWordSubtitle;

  /// No description provided for @reviewHomeSuggestionTitle.
  ///
  /// In id, this message translates to:
  /// **'Usulan edit'**
  String get reviewHomeSuggestionTitle;

  /// No description provided for @reviewHomeSuggestionWaiting.
  ///
  /// In id, this message translates to:
  /// **'Ada usulan edit yang menunggu'**
  String get reviewHomeSuggestionWaiting;

  /// No description provided for @reviewHomeSuggestionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Antrean usulan perubahan kata'**
  String get reviewHomeSuggestionSubtitle;

  /// No description provided for @reviewHomeDiscussionTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjauan Diskusi'**
  String get reviewHomeDiscussionTitle;

  /// No description provided for @reviewHomeDiscussionWaiting.
  ///
  /// In id, this message translates to:
  /// **'Ada diskusi yang menunggu'**
  String get reviewHomeDiscussionWaiting;

  /// No description provided for @reviewHomeDiscussionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Antrean Ruang Diskusi untuk ditinjau'**
  String get reviewHomeDiscussionSubtitle;

  /// No description provided for @reviewHomeSearchMissTitle.
  ///
  /// In id, this message translates to:
  /// **'Pencarian kosong'**
  String get reviewHomeSearchMissTitle;

  /// No description provided for @reviewHomeSearchMissSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tayangkan ke publik atau usulkan sendiri'**
  String get reviewHomeSearchMissSubtitle;

  /// No description provided for @reviewHomeHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat tinjauan'**
  String get reviewHomeHistoryTitle;

  /// No description provided for @reviewHomeHistorySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Keputusan yang sudah kamu berikan'**
  String get reviewHomeHistorySubtitle;

  /// No description provided for @reviewQueueLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat antrean'**
  String get reviewQueueLoadFailed;

  /// No description provided for @reviewQueueEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada usulan yang menunggu'**
  String get reviewQueueEmpty;

  /// No description provided for @reviewQueueEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Usulan baru dari kontributor akan muncul di sini.'**
  String get reviewQueueEmptyHint;

  /// No description provided for @reviewQueueStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai tinjau'**
  String get reviewQueueStart;

  /// No description provided for @reviewQueueStartCount.
  ///
  /// In id, this message translates to:
  /// **'Mulai tinjau ({count})'**
  String reviewQueueStartCount(String count);

  /// No description provided for @reviewQueueStartMore.
  ///
  /// In id, this message translates to:
  /// **'Mulai tinjau ({count}+)'**
  String reviewQueueStartMore(String count);

  /// No description provided for @reviewSkeletonProposalTitle.
  ///
  /// In id, this message translates to:
  /// **'Usulan kata contoh'**
  String get reviewSkeletonProposalTitle;

  /// No description provided for @reviewSkeletonProposalMeta.
  ///
  /// In id, this message translates to:
  /// **'Kata · kontributor · 21 Sep 2026 00:00'**
  String get reviewSkeletonProposalMeta;

  /// No description provided for @reviewSkeletonLemma.
  ///
  /// In id, this message translates to:
  /// **'Lemma contoh'**
  String get reviewSkeletonLemma;

  /// No description provided for @reviewSuggestionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Usulan edit'**
  String get reviewSuggestionsTitle;

  /// No description provided for @reviewSuggestionsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat usulan edit'**
  String get reviewSuggestionsLoadFailed;

  /// No description provided for @reviewSuggestionsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada usulan edit menunggu'**
  String get reviewSuggestionsEmpty;

  /// No description provided for @reviewSuggestionDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail usulan edit'**
  String get reviewSuggestionDetailTitle;

  /// No description provided for @reviewSuggestionRejectTitle.
  ///
  /// In id, this message translates to:
  /// **'Tolak usulan'**
  String get reviewSuggestionRejectTitle;

  /// No description provided for @reviewSuggestionRejectBody.
  ///
  /// In id, this message translates to:
  /// **'Berikan alasan penolakan untuk kontributor.'**
  String get reviewSuggestionRejectBody;

  /// No description provided for @reviewSuggestionRejectedToast.
  ///
  /// In id, this message translates to:
  /// **'Usulan ditolak'**
  String get reviewSuggestionRejectedToast;

  /// No description provided for @reviewSuggestionApprovedToast.
  ///
  /// In id, this message translates to:
  /// **'Usulan disetujui'**
  String get reviewSuggestionApprovedToast;

  /// No description provided for @reviewSuggestionFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari {contributor} · {date}'**
  String reviewSuggestionFrom(String contributor, String date);

  /// No description provided for @reviewSuggestionReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan: {reason}'**
  String reviewSuggestionReason(String reason);

  /// No description provided for @reviewSuggestionComparison.
  ///
  /// In id, this message translates to:
  /// **'Perbandingan'**
  String get reviewSuggestionComparison;

  /// No description provided for @reviewSuggestionNoDiff.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada diff ringkas'**
  String get reviewSuggestionNoDiff;

  /// No description provided for @reviewSuggestionApproveNote.
  ///
  /// In id, this message translates to:
  /// **'Setujui akan mempromosikan semua gambar staging (ImageKit) ke GitHub. Sensor/tolak per gambar bila perlu.'**
  String get reviewSuggestionApproveNote;

  /// No description provided for @reviewSuggestionStatus.
  ///
  /// In id, this message translates to:
  /// **'Status: {status}'**
  String reviewSuggestionStatus(String status);

  /// No description provided for @reviewSuggestionCurrentEmpty.
  ///
  /// In id, this message translates to:
  /// **'Sekarang: (kosong)'**
  String get reviewSuggestionCurrentEmpty;

  /// No description provided for @reviewSuggestionProposedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Usulan: (kosong)'**
  String get reviewSuggestionProposedEmpty;

  /// No description provided for @reviewSuggestionCurrent.
  ///
  /// In id, this message translates to:
  /// **'Sekarang: {value}'**
  String reviewSuggestionCurrent(String value);

  /// No description provided for @reviewSuggestionProposed.
  ///
  /// In id, this message translates to:
  /// **'Usulan: {value}'**
  String reviewSuggestionProposed(String value);

  /// No description provided for @reviewSuggestionEntryType.
  ///
  /// In id, this message translates to:
  /// **'Jenis entri'**
  String get reviewSuggestionEntryType;

  /// No description provided for @reviewSuggestionDiffCount.
  ///
  /// In id, this message translates to:
  /// **'{label}: {count} perubahan'**
  String reviewSuggestionDiffCount(String label, String count);

  /// No description provided for @reviewSuggestionDiffValue.
  ///
  /// In id, this message translates to:
  /// **'{label}: {value}'**
  String reviewSuggestionDiffValue(String label, String value);

  /// No description provided for @reviewChangeHintLemma.
  ///
  /// In id, this message translates to:
  /// **'lemma'**
  String get reviewChangeHintLemma;

  /// No description provided for @reviewChangeHintNotes.
  ///
  /// In id, this message translates to:
  /// **'catatan'**
  String get reviewChangeHintNotes;

  /// No description provided for @reviewChangeHintMeanings.
  ///
  /// In id, this message translates to:
  /// **'makna ({count})'**
  String reviewChangeHintMeanings(int count);

  /// No description provided for @reviewChangeHintImages.
  ///
  /// In id, this message translates to:
  /// **'gambar ({count})'**
  String reviewChangeHintImages(int count);

  /// No description provided for @reviewChangeHintFallback.
  ///
  /// In id, this message translates to:
  /// **'Perubahan usulan'**
  String get reviewChangeHintFallback;

  /// No description provided for @reviewHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat verifikasi'**
  String get reviewHistoryTitle;

  /// No description provided for @reviewHistoryLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat riwayat'**
  String get reviewHistoryLoadFailed;

  /// No description provided for @reviewHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada keputusan verifikasi'**
  String get reviewHistoryEmpty;

  /// No description provided for @reviewHistoryEmptyFiltered.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada keputusan dengan status ini'**
  String get reviewHistoryEmptyFiltered;

  /// No description provided for @reviewHistoryDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail keputusan'**
  String get reviewHistoryDetailTitle;

  /// No description provided for @reviewHistoryDecisions.
  ///
  /// In id, this message translates to:
  /// **'Riwayat keputusan'**
  String get reviewHistoryDecisions;

  /// No description provided for @reviewHistoryReopenedToast.
  ///
  /// In id, this message translates to:
  /// **'Keputusan dibuka ulang'**
  String get reviewHistoryReopenedToast;

  /// No description provided for @reviewHistoryUnverifiedToast.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi kata dicabut'**
  String get reviewHistoryUnverifiedToast;

  /// No description provided for @reviewHistoryReopenedNote.
  ///
  /// In id, this message translates to:
  /// **'Usulan ini sedang dibuka ulang. Lanjut tinjau untuk memberi keputusan baru.'**
  String get reviewHistoryReopenedNote;

  /// No description provided for @reviewHistoryReopenedHold.
  ///
  /// In id, this message translates to:
  /// **'Buka ulang menahan item dari antrean global sampai ada keputusan baru. Cabut verifikasi membalik status kata.'**
  String get reviewHistoryReopenedHold;

  /// No description provided for @reviewHistoryContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut tinjau'**
  String get reviewHistoryContinue;

  /// No description provided for @reviewHistoryProcessing.
  ///
  /// In id, this message translates to:
  /// **'Memproses...'**
  String get reviewHistoryProcessing;

  /// No description provided for @reviewHistoryReopen.
  ///
  /// In id, this message translates to:
  /// **'Buka ulang'**
  String get reviewHistoryReopen;

  /// No description provided for @reviewHistoryUnverify.
  ///
  /// In id, this message translates to:
  /// **'Cabut verifikasi'**
  String get reviewHistoryUnverify;

  /// No description provided for @reviewHistorySkeletonMeta.
  ///
  /// In id, this message translates to:
  /// **'Disetujui · 21 Sep 2026 00:00'**
  String get reviewHistorySkeletonMeta;

  /// No description provided for @reviewSessionQueueDone.
  ///
  /// In id, this message translates to:
  /// **'Antrean selesai'**
  String get reviewSessionQueueDone;

  /// No description provided for @reviewSessionSkipped.
  ///
  /// In id, this message translates to:
  /// **'Dilewati.'**
  String get reviewSessionSkipped;

  /// No description provided for @reviewSessionApprovedToast.
  ///
  /// In id, this message translates to:
  /// **'Usulan disetujui'**
  String get reviewSessionApprovedToast;

  /// No description provided for @reviewSessionRejectedToast.
  ///
  /// In id, this message translates to:
  /// **'Usulan ditolak'**
  String get reviewSessionRejectedToast;

  /// No description provided for @reviewSessionAlreadyProcessed.
  ///
  /// In id, this message translates to:
  /// **'Usulan ini sudah diproses.'**
  String get reviewSessionAlreadyProcessed;

  /// No description provided for @reviewSessionAccessDenied.
  ///
  /// In id, this message translates to:
  /// **'Akses ditolak'**
  String get reviewSessionAccessDenied;

  /// No description provided for @reviewSessionSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan keputusan'**
  String get reviewSessionSaveFailed;

  /// No description provided for @reviewSessionRestoreFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengembalikan kartu.'**
  String get reviewSessionRestoreFailed;

  /// No description provided for @reviewSessionRestoredToast.
  ///
  /// In id, this message translates to:
  /// **'Kartu sebelumnya dikembalikan'**
  String get reviewSessionRestoredToast;

  /// No description provided for @reviewSessionCorrectionSavedPending.
  ///
  /// In id, this message translates to:
  /// **'Koreksi disimpan. Usulan tetap menunggu.'**
  String get reviewSessionCorrectionSavedPending;

  /// No description provided for @reviewSessionCorrectionSavedClosed.
  ///
  /// In id, this message translates to:
  /// **'Koreksi disimpan dan usulan ditutup.'**
  String get reviewSessionCorrectionSavedClosed;

  /// No description provided for @reviewSessionCounter.
  ///
  /// In id, this message translates to:
  /// **'Tinjau · {position}/{total}'**
  String reviewSessionCounter(int position, int total);

  /// No description provided for @reviewSessionCounterCorrect.
  ///
  /// In id, this message translates to:
  /// **'Koreksi · {position}/{total}'**
  String reviewSessionCounterCorrect(int position, int total);

  /// No description provided for @reviewSessionVerifiedSelf.
  ///
  /// In id, this message translates to:
  /// **'Sudah terverifikasi. Menyetujui hanya menutup antrean.'**
  String get reviewSessionVerifiedSelf;

  /// No description provided for @reviewSessionVerifiedBy.
  ///
  /// In id, this message translates to:
  /// **'Sudah terverifikasi oleh @{verifier}. Menyetujui hanya menutup antrean.'**
  String reviewSessionVerifiedBy(String verifier);

  /// No description provided for @reviewSessionVerifierNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan verifikator'**
  String get reviewSessionVerifierNote;

  /// No description provided for @reviewSessionSwipeHint.
  ///
  /// In id, this message translates to:
  /// **'Kanan setujui · kiri tolak · atas lewati - atau pakai tombol di bawah.'**
  String get reviewSessionSwipeHint;

  /// No description provided for @reviewSessionSkeletonTitle.
  ///
  /// In id, this message translates to:
  /// **'Judul usulan contoh'**
  String get reviewSessionSkeletonTitle;

  /// No description provided for @reviewSessionEntryType.
  ///
  /// In id, this message translates to:
  /// **'Jenis entri'**
  String get reviewSessionEntryType;

  /// No description provided for @reviewSessionSkeletonDate.
  ///
  /// In id, this message translates to:
  /// **'21 Sep 2026 00:00'**
  String get reviewSessionSkeletonDate;

  /// No description provided for @reviewSessionSkeletonSection.
  ///
  /// In id, this message translates to:
  /// **'Judul bagian preview'**
  String get reviewSessionSkeletonSection;

  /// No description provided for @reviewSessionSkeletonBody.
  ///
  /// In id, this message translates to:
  /// **'Isi ringkas usulan agar kerangka kartu mendekati layout asli saat loading.'**
  String get reviewSessionSkeletonBody;

  /// No description provided for @reviewSessionSkeletonMeta.
  ///
  /// In id, this message translates to:
  /// **'Baris meta tambahan untuk shimmer.'**
  String get reviewSessionSkeletonMeta;

  /// No description provided for @reviewSessionCorrect.
  ///
  /// In id, this message translates to:
  /// **'Koreksi'**
  String get reviewSessionCorrect;

  /// No description provided for @reviewSessionBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke kartu sebelumnya'**
  String get reviewSessionBack;

  /// No description provided for @reviewSwipeApprove.
  ///
  /// In id, this message translates to:
  /// **'Setujui'**
  String get reviewSwipeApprove;

  /// No description provided for @reviewSwipeReject.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get reviewSwipeReject;

  /// No description provided for @reviewSwipeSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get reviewSwipeSkip;

  /// No description provided for @reviewRejectReasonInaccurate.
  ///
  /// In id, this message translates to:
  /// **'Kurang akurat'**
  String get reviewRejectReasonInaccurate;

  /// No description provided for @reviewRejectReasonSpelling.
  ///
  /// In id, this message translates to:
  /// **'Ejaan atau penulisan salah'**
  String get reviewRejectReasonSpelling;

  /// No description provided for @reviewRejectReasonDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Duplikat entri yang sudah ada'**
  String get reviewRejectReasonDuplicate;

  /// No description provided for @reviewRejectReasonIrrelevant.
  ///
  /// In id, this message translates to:
  /// **'Tidak relevan'**
  String get reviewRejectReasonIrrelevant;

  /// No description provided for @reviewRejectReasonMedia.
  ///
  /// In id, this message translates to:
  /// **'Media (gambar/audio) tidak sesuai'**
  String get reviewRejectReasonMedia;

  /// No description provided for @reviewRejectReasonInappropriate.
  ///
  /// In id, this message translates to:
  /// **'Konten tidak pantas'**
  String get reviewRejectReasonInappropriate;

  /// No description provided for @reviewRejectReasonIncomplete.
  ///
  /// In id, this message translates to:
  /// **'Informasi kurang lengkap'**
  String get reviewRejectReasonIncomplete;

  /// No description provided for @reviewRejectReasonOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get reviewRejectReasonOther;

  /// No description provided for @reviewRejectSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Tolak usulan'**
  String get reviewRejectSheetTitle;

  /// No description provided for @reviewRejectSheetBody.
  ///
  /// In id, this message translates to:
  /// **'Pilih alasan agar kontributor tahu apa yang perlu diperbaiki.'**
  String get reviewRejectSheetBody;

  /// No description provided for @reviewRejectReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan penolakan'**
  String get reviewRejectReasonLabel;

  /// No description provided for @reviewRejectReasonHint.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan alasan penolakan'**
  String get reviewRejectReasonHint;

  /// No description provided for @reviewDiscussionQueueTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjauan Diskusi'**
  String get reviewDiscussionQueueTitle;

  /// No description provided for @reviewDiscussionQueueLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat antrean diskusi'**
  String get reviewDiscussionQueueLoadFailed;

  /// No description provided for @reviewDiscussionQueueEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada diskusi menunggu tinjauan'**
  String get reviewDiscussionQueueEmpty;

  /// No description provided for @reviewDiscussionDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau diskusi'**
  String get reviewDiscussionDetailTitle;

  /// No description provided for @reviewDiscussionHasLink.
  ///
  /// In id, this message translates to:
  /// **'Ada tautan'**
  String get reviewDiscussionHasLink;

  /// No description provided for @reviewDiscussionNoText.
  ///
  /// In id, this message translates to:
  /// **'(tanpa teks)'**
  String get reviewDiscussionNoText;

  /// No description provided for @reviewDiscussionSkeletonExcerpt.
  ///
  /// In id, this message translates to:
  /// **'Cuplikan diskusi contoh'**
  String get reviewDiscussionSkeletonExcerpt;

  /// No description provided for @reviewDiscussionSkeletonMeta.
  ///
  /// In id, this message translates to:
  /// **'Pengirim · baru saja'**
  String get reviewDiscussionSkeletonMeta;

  /// No description provided for @reviewDiscussionApprovedToast.
  ///
  /// In id, this message translates to:
  /// **'Diskusi disetujui dan tayang'**
  String get reviewDiscussionApprovedToast;

  /// No description provided for @reviewDiscussionRejectedToast.
  ///
  /// In id, this message translates to:
  /// **'Diskusi ditolak'**
  String get reviewDiscussionRejectedToast;

  /// No description provided for @reviewDiscussionPhotosSafe.
  ///
  /// In id, this message translates to:
  /// **'Pastikan semua foto aman'**
  String get reviewDiscussionPhotosSafe;

  /// No description provided for @reviewDiscussionApprovePhotos.
  ///
  /// In id, this message translates to:
  /// **'Kamu menyetujui {approved} foto ({censored} tersensor · {flagged} ber-flag kekerasan).'**
  String reviewDiscussionApprovePhotos(int approved, int censored, int flagged);

  /// No description provided for @reviewDiscussionPhotoChecklist.
  ///
  /// In id, this message translates to:
  /// **'Pastikan foto bukan NSFW, aman ditayangkan publik, data sensitif sudah disensor bila perlu, dan flag kekerasan sudah ditempel bila perlu.'**
  String get reviewDiscussionPhotoChecklist;

  /// No description provided for @reviewDiscussionConfirmCheck.
  ///
  /// In id, this message translates to:
  /// **'Saya sudah memeriksa, setujui'**
  String get reviewDiscussionConfirmCheck;

  /// No description provided for @reviewDiscussionRejectTitle.
  ///
  /// In id, this message translates to:
  /// **'Tolak diskusi'**
  String get reviewDiscussionRejectTitle;

  /// No description provided for @reviewDiscussionRejectReasonRequired.
  ///
  /// In id, this message translates to:
  /// **'Berikan alasan penolakan (wajib).'**
  String get reviewDiscussionRejectReasonRequired;

  /// No description provided for @reviewDiscussionInvalidLink.
  ///
  /// In id, this message translates to:
  /// **'Tautan tidak valid'**
  String get reviewDiscussionInvalidLink;

  /// No description provided for @reviewDiscussionCannotOpenLink.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa membuka tautan'**
  String get reviewDiscussionCannotOpenLink;

  /// No description provided for @reviewDiscussionStagingImageMissing.
  ///
  /// In id, this message translates to:
  /// **'URL gambar staging tidak tersedia'**
  String get reviewDiscussionStagingImageMissing;

  /// No description provided for @reviewDiscussionAttachmentCount.
  ///
  /// In id, this message translates to:
  /// **'Lampiran gambar ({count})'**
  String reviewDiscussionAttachmentCount(int count);

  /// No description provided for @reviewDiscussionTapPhotoFull.
  ///
  /// In id, this message translates to:
  /// **'Ketuk foto untuk melihat ukuran penuh'**
  String get reviewDiscussionTapPhotoFull;

  /// No description provided for @reviewDiscussionEditCensor.
  ///
  /// In id, this message translates to:
  /// **'Edit sensor'**
  String get reviewDiscussionEditCensor;

  /// No description provided for @reviewDiscussionCensor.
  ///
  /// In id, this message translates to:
  /// **'Sensor'**
  String get reviewDiscussionCensor;

  /// No description provided for @reviewDiscussionForceViolence.
  ///
  /// In id, this message translates to:
  /// **'Gambar {index}: berisi kekerasan'**
  String reviewDiscussionForceViolence(int index);

  /// No description provided for @reviewDiscussionForceViolenceHint.
  ///
  /// In id, this message translates to:
  /// **'Centang jika foto menunjukkan kekerasan'**
  String get reviewDiscussionForceViolenceHint;

  /// No description provided for @reviewDiscussionForceViolenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Gambar {index} berisi kekerasan'**
  String reviewDiscussionForceViolenceLabel(int index);

  /// No description provided for @reviewDiscussionApprovePublish.
  ///
  /// In id, this message translates to:
  /// **'Setujui & tayangkan'**
  String get reviewDiscussionApprovePublish;

  /// No description provided for @reviewDiscussionStatus.
  ///
  /// In id, this message translates to:
  /// **'Status: {status}'**
  String reviewDiscussionStatus(String status);

  /// No description provided for @reviewCensorTitle.
  ///
  /// In id, this message translates to:
  /// **'Sensor gambar'**
  String get reviewCensorTitle;

  /// No description provided for @reviewCensorLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat gambar. Coba lagi dalam beberapa saat.'**
  String get reviewCensorLoadFailed;

  /// No description provided for @reviewCensorReadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal baca piksel'**
  String get reviewCensorReadFailed;

  /// No description provided for @reviewCensorEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Body kosong'**
  String get reviewCensorEmptyBody;

  /// No description provided for @reviewCensorExportFailed.
  ///
  /// In id, this message translates to:
  /// **'Export gagal'**
  String get reviewCensorExportFailed;

  /// No description provided for @reviewCensorSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan hasil sensor'**
  String get reviewCensorSaveFailed;

  /// No description provided for @reviewCensorHint.
  ///
  /// In id, this message translates to:
  /// **'Geser jari untuk menyensor. Mode: pixelate, blur, atau blok.'**
  String get reviewCensorHint;

  /// No description provided for @reviewCensorModePixelate.
  ///
  /// In id, this message translates to:
  /// **'Pixelate'**
  String get reviewCensorModePixelate;

  /// No description provided for @reviewCensorModeBlur.
  ///
  /// In id, this message translates to:
  /// **'Blur'**
  String get reviewCensorModeBlur;

  /// No description provided for @reviewCensorModeBlock.
  ///
  /// In id, this message translates to:
  /// **'Blok'**
  String get reviewCensorModeBlock;

  /// No description provided for @reviewCensorBrushSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran kuas'**
  String get reviewCensorBrushSize;

  /// No description provided for @reviewCensorApply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan sensor'**
  String get reviewCensorApply;

  /// No description provided for @reviewSearchMissTitle.
  ///
  /// In id, this message translates to:
  /// **'Pencarian kosong'**
  String get reviewSearchMissTitle;

  /// No description provided for @reviewSearchMissLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat pencarian kosong'**
  String get reviewSearchMissLoadFailed;

  /// No description provided for @reviewSearchMissEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pencarian kosong yang belum terjawab. Warga yang mencari kata belum ada akar yang cocok.'**
  String get reviewSearchMissEmpty;

  /// No description provided for @reviewSearchMissSwipeHint.
  ///
  /// In id, this message translates to:
  /// **'Kanan tayang · kiri singkirkan · atas lewati - atau ketuk kartu untuk mengusulkan.'**
  String get reviewSearchMissSwipeHint;

  /// No description provided for @reviewSearchMissPublish.
  ///
  /// In id, this message translates to:
  /// **'Tayang'**
  String get reviewSearchMissPublish;

  /// No description provided for @reviewSearchMissDismiss.
  ///
  /// In id, this message translates to:
  /// **'Singkirkan'**
  String get reviewSearchMissDismiss;

  /// No description provided for @reviewSearchMissDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai - semua pencarian kosong sudah ditangani.'**
  String get reviewSearchMissDone;

  /// No description provided for @reviewSearchMissReload.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang'**
  String get reviewSearchMissReload;

  /// No description provided for @reviewSearchMissCorrect.
  ///
  /// In id, this message translates to:
  /// **'Koreksi term'**
  String get reviewSearchMissCorrect;

  /// No description provided for @reviewSearchMissCorrectHint.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki salah ketik warga sebelum ditayangkan.'**
  String get reviewSearchMissCorrectHint;

  /// No description provided for @reviewSearchMissTerm.
  ///
  /// In id, this message translates to:
  /// **'Term'**
  String get reviewSearchMissTerm;

  /// No description provided for @reviewSearchMissCorrectedToast.
  ///
  /// In id, this message translates to:
  /// **'\"{term}\" dikoreksi'**
  String reviewSearchMissCorrectedToast(String term);

  /// No description provided for @reviewSearchMissPublishedToast.
  ///
  /// In id, this message translates to:
  /// **'\"{term}\" tayang di beranda publik'**
  String reviewSearchMissPublishedToast(String term);

  /// No description provided for @reviewSearchMissSkippedToast.
  ///
  /// In id, this message translates to:
  /// **'\"{term}\" sudah tayang - dilewati'**
  String reviewSearchMissSkippedToast(String term);

  /// No description provided for @reviewSearchMissDirectionIdSbs.
  ///
  /// In id, this message translates to:
  /// **'Indonesia → Sambas'**
  String get reviewSearchMissDirectionIdSbs;

  /// No description provided for @reviewSearchMissDirectionSbsId.
  ///
  /// In id, this message translates to:
  /// **'Sambas → Indonesia'**
  String get reviewSearchMissDirectionSbsId;

  /// No description provided for @reviewSearchMissDirectionHits.
  ///
  /// In id, this message translates to:
  /// **'{direction} · {count}× dicari'**
  String reviewSearchMissDirectionHits(Object count, Object direction);

  /// No description provided for @reviewSearchMissHits.
  ///
  /// In id, this message translates to:
  /// **'{count} dicari'**
  String reviewSearchMissHits(int count);

  /// No description provided for @reviewSearchMissNotPublished.
  ///
  /// In id, this message translates to:
  /// **'belum tayang'**
  String get reviewSearchMissNotPublished;

  /// No description provided for @reviewSearchMissTapToSuggest.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk mengusulkan kata ini.'**
  String get reviewSearchMissTapToSuggest;

  /// No description provided for @reviewPreviewAudioProposal.
  ///
  /// In id, this message translates to:
  /// **'Audio usulan'**
  String get reviewPreviewAudioProposal;

  /// No description provided for @reviewPreviewTapToRead.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk baca selengkapnya'**
  String get reviewPreviewTapToRead;

  /// No description provided for @reviewPreviewNoMeaning.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada makna.'**
  String get reviewPreviewNoMeaning;

  /// No description provided for @reviewPreviewProposedWord.
  ///
  /// In id, this message translates to:
  /// **'Kata yang diusulkan'**
  String get reviewPreviewProposedWord;

  /// No description provided for @reviewPreviewCompleteness.
  ///
  /// In id, this message translates to:
  /// **'Kelengkapan'**
  String get reviewPreviewCompleteness;

  /// No description provided for @reviewPreviewSynonyms.
  ///
  /// In id, this message translates to:
  /// **'Sinonim'**
  String get reviewPreviewSynonyms;

  /// No description provided for @reviewPreviewAntonyms.
  ///
  /// In id, this message translates to:
  /// **'Antonim'**
  String get reviewPreviewAntonyms;

  /// No description provided for @reviewPreviewVariants.
  ///
  /// In id, this message translates to:
  /// **'Variasi'**
  String get reviewPreviewVariants;

  /// No description provided for @reviewPreviewTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan: {text}'**
  String reviewPreviewTranslation(String text);

  /// No description provided for @reviewPreviewProposedImage.
  ///
  /// In id, this message translates to:
  /// **'Gambar yang diusulkan'**
  String get reviewPreviewProposedImage;

  /// No description provided for @reviewPreviewForWord.
  ///
  /// In id, this message translates to:
  /// **'Untuk kata “{lemma}”'**
  String reviewPreviewForWord(String lemma);

  /// No description provided for @reviewPreviewImageUrlMissing.
  ///
  /// In id, this message translates to:
  /// **'URL gambar tidak tersedia.'**
  String get reviewPreviewImageUrlMissing;

  /// No description provided for @reviewPreviewTapToEnlarge.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk perbesar'**
  String get reviewPreviewTapToEnlarge;

  /// No description provided for @reviewPreviewAltText.
  ///
  /// In id, this message translates to:
  /// **'Alt text'**
  String get reviewPreviewAltText;

  /// No description provided for @reviewPreviewAudioFileMissing.
  ///
  /// In id, this message translates to:
  /// **'File audio tidak tersedia.'**
  String get reviewPreviewAudioFileMissing;

  /// No description provided for @reviewPreviewDurasi.
  ///
  /// In id, this message translates to:
  /// **'Durasi'**
  String get reviewPreviewDurasi;

  /// No description provided for @reviewPreviewUkuran.
  ///
  /// In id, this message translates to:
  /// **'Ukuran'**
  String get reviewPreviewUkuran;

  /// No description provided for @reviewPreviewTipe.
  ///
  /// In id, this message translates to:
  /// **'Tipe'**
  String get reviewPreviewTipe;

  /// No description provided for @reviewPreviewProposedPronunciation.
  ///
  /// In id, this message translates to:
  /// **'Pelafalan yang diusulkan'**
  String get reviewPreviewProposedPronunciation;

  /// No description provided for @reviewPreviewNotation.
  ///
  /// In id, this message translates to:
  /// **'Notasi: {notation}'**
  String reviewPreviewNotation(String notation);

  /// No description provided for @reviewPreviewProposedMeaning.
  ///
  /// In id, this message translates to:
  /// **'Makna yang diusulkan'**
  String get reviewPreviewProposedMeaning;

  /// No description provided for @reviewPreviewSourceOfMeaning.
  ///
  /// In id, this message translates to:
  /// **'Sumber makna'**
  String get reviewPreviewSourceOfMeaning;

  /// No description provided for @reviewPreviewTranslationSection.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan'**
  String get reviewPreviewTranslationSection;

  /// No description provided for @reviewPreviewTranslationEmptyDeliberate.
  ///
  /// In id, this message translates to:
  /// **'Kontributor sengaja tidak mengisi terjemahan.'**
  String get reviewPreviewTranslationEmptyDeliberate;

  /// No description provided for @reviewPreviewTranslationMarkedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Ditandai ada terjemahan, tetapi belum diisi.'**
  String get reviewPreviewTranslationMarkedEmpty;

  /// No description provided for @reviewPreviewTranslationNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada terjemahan.'**
  String get reviewPreviewTranslationNone;

  /// No description provided for @reviewPreviewProposedExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat yang diusulkan'**
  String get reviewPreviewProposedExample;

  /// No description provided for @reviewPreviewSambasSentence.
  ///
  /// In id, this message translates to:
  /// **'Kalimat sambas'**
  String get reviewPreviewSambasSentence;

  /// No description provided for @reviewPreviewTranslationSentence.
  ///
  /// In id, this message translates to:
  /// **'Kalimat terjemahan'**
  String get reviewPreviewTranslationSentence;

  /// No description provided for @reviewPreviewSourceType.
  ///
  /// In id, this message translates to:
  /// **'Jenis sumber'**
  String get reviewPreviewSourceType;

  /// No description provided for @reviewPreviewProposalContent.
  ///
  /// In id, this message translates to:
  /// **'Isi usulan'**
  String get reviewPreviewProposalContent;

  /// No description provided for @reviewPreviewDetailLabel.
  ///
  /// In id, this message translates to:
  /// **'Detail'**
  String get reviewPreviewDetailLabel;

  /// No description provided for @reviewPreviewPlayRecording.
  ///
  /// In id, this message translates to:
  /// **'Putar rekaman'**
  String get reviewPreviewPlayRecording;

  /// No description provided for @reviewPreviewPlayFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memutar - ketuk lagi'**
  String get reviewPreviewPlayFailed;

  /// No description provided for @reviewPreviewPlaying.
  ///
  /// In id, this message translates to:
  /// **'Sedang diputar'**
  String get reviewPreviewPlaying;

  /// No description provided for @reviewPreviewTapToListen.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk mendengar'**
  String get reviewPreviewTapToListen;

  /// No description provided for @reviewPreviewFieldValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai'**
  String get reviewPreviewFieldValue;

  /// No description provided for @reviewPreviewFieldUrlAudio.
  ///
  /// In id, this message translates to:
  /// **'URL audio'**
  String get reviewPreviewFieldUrlAudio;

  /// No description provided for @reviewPreviewFieldUrl.
  ///
  /// In id, this message translates to:
  /// **'URL'**
  String get reviewPreviewFieldUrl;

  /// No description provided for @reviewPreviewFieldSpeech.
  ///
  /// In id, this message translates to:
  /// **'Penutur'**
  String get reviewPreviewFieldSpeech;

  /// No description provided for @reviewPreviewFieldAlt.
  ///
  /// In id, this message translates to:
  /// **'Teks alternatif'**
  String get reviewPreviewFieldAlt;

  /// No description provided for @reviewPreviewDurationSec.
  ///
  /// In id, this message translates to:
  /// **'{sec} dtk'**
  String reviewPreviewDurationSec(int sec);

  /// No description provided for @reviewPreviewDurationMin.
  ///
  /// In id, this message translates to:
  /// **'{min} m'**
  String reviewPreviewDurationMin(int min);

  /// No description provided for @reviewPreviewDurationMinSec.
  ///
  /// In id, this message translates to:
  /// **'{min} m {rem} dtk'**
  String reviewPreviewDurationMinSec(int min, int rem);

  /// No description provided for @reviewPreviewBytesB.
  ///
  /// In id, this message translates to:
  /// **'{bytes} B'**
  String reviewPreviewBytesB(int bytes);

  /// No description provided for @reviewPreviewBytesKb.
  ///
  /// In id, this message translates to:
  /// **'{value} KB'**
  String reviewPreviewBytesKb(String value);

  /// No description provided for @reviewPreviewBytesMb.
  ///
  /// In id, this message translates to:
  /// **'{value} MB'**
  String reviewPreviewBytesMb(String value);

  /// No description provided for @reviewMeaningNumber.
  ///
  /// In id, this message translates to:
  /// **'Makna {index}'**
  String reviewMeaningNumber(int index);

  /// No description provided for @reviewMeaningSwapDefinition.
  ///
  /// In id, this message translates to:
  /// **'Tukar definisi dan terjemahan'**
  String get reviewMeaningSwapDefinition;

  /// No description provided for @reviewMeaningDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus makna {index}'**
  String reviewMeaningDelete(int index);

  /// No description provided for @reviewMeaningWordClassRequired.
  ///
  /// In id, this message translates to:
  /// **'Kelas kata wajib dipilih'**
  String get reviewMeaningWordClassRequired;

  /// No description provided for @reviewMeaningExampleSection.
  ///
  /// In id, this message translates to:
  /// **'Contoh kalimat'**
  String get reviewMeaningExampleSection;

  /// No description provided for @reviewMeaningAddExample.
  ///
  /// In id, this message translates to:
  /// **'Tambah contoh'**
  String get reviewMeaningAddExample;

  /// No description provided for @reviewMeaningExampleSambas.
  ///
  /// In id, this message translates to:
  /// **'Kalimat Sambas'**
  String get reviewMeaningExampleSambas;

  /// No description provided for @reviewMeaningExampleTranslation.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan (opsional)'**
  String get reviewMeaningExampleTranslation;

  /// No description provided for @reviewMeaningDeleteExample.
  ///
  /// In id, this message translates to:
  /// **'Hapus contoh'**
  String get reviewMeaningDeleteExample;

  /// No description provided for @reviewMeaningPickWordClass.
  ///
  /// In id, this message translates to:
  /// **'Pilih kelas kata'**
  String get reviewMeaningPickWordClass;

  /// No description provided for @reviewExtrasSynonymsAntonyms.
  ///
  /// In id, this message translates to:
  /// **'Sinonim & antonim'**
  String get reviewExtrasSynonymsAntonyms;

  /// No description provided for @reviewExtrasSynonyms.
  ///
  /// In id, this message translates to:
  /// **'Sinonim'**
  String get reviewExtrasSynonyms;

  /// No description provided for @reviewExtrasAntonyms.
  ///
  /// In id, this message translates to:
  /// **'Antonim'**
  String get reviewExtrasAntonyms;

  /// No description provided for @reviewExtrasTypeCount.
  ///
  /// In id, this message translates to:
  /// **'{label} ({count})'**
  String reviewExtrasTypeCount(String label, int count);

  /// No description provided for @reviewExtrasNoSynonym.
  ///
  /// In id, this message translates to:
  /// **'Belum ada sinonim. Cari kata di bawah untuk menambah.'**
  String get reviewExtrasNoSynonym;

  /// No description provided for @reviewExtrasNoAntonym.
  ///
  /// In id, this message translates to:
  /// **'Belum ada antonim. Cari kata di bawah untuk menambah.'**
  String get reviewExtrasNoAntonym;

  /// No description provided for @reviewExtrasRemoveRelation.
  ///
  /// In id, this message translates to:
  /// **'Hapus {lemma}'**
  String reviewExtrasRemoveRelation(String lemma);

  /// No description provided for @reviewExtrasSearchWord.
  ///
  /// In id, this message translates to:
  /// **'Cari kata yang sudah ada...'**
  String get reviewExtrasSearchWord;

  /// No description provided for @reviewExtrasMinChars.
  ///
  /// In id, this message translates to:
  /// **'Ketik minimal 2 huruf.'**
  String get reviewExtrasMinChars;

  /// No description provided for @reviewExtrasWordNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kata tidak ditemukan. Hanya kata yang sudah ada di kamus yang bisa dipilih.'**
  String get reviewExtrasWordNotFound;

  /// No description provided for @reviewVariantTitle.
  ///
  /// In id, this message translates to:
  /// **'Variasi penulisan'**
  String get reviewVariantTitle;

  /// No description provided for @reviewVariantHint.
  ///
  /// In id, this message translates to:
  /// **'Ejaan lain untuk \"{lemma}\".'**
  String reviewVariantHint(String lemma);

  /// No description provided for @reviewVariantRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus {form}'**
  String reviewVariantRemove(String form);

  /// No description provided for @reviewVariantAddHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis variasi, mis. klintiak'**
  String get reviewVariantAddHint;

  /// No description provided for @reviewVariantAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get reviewVariantAdd;

  /// No description provided for @reviewVariantSameAsLemma.
  ///
  /// In id, this message translates to:
  /// **'Variasi tidak boleh sama dengan lemma'**
  String get reviewVariantSameAsLemma;

  /// No description provided for @reviewVariantDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Variasi ini sudah ada'**
  String get reviewVariantDuplicate;

  /// No description provided for @reviewVariantMax.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} variasi'**
  String reviewVariantMax(int max);

  /// No description provided for @reviewExtrasNoItems.
  ///
  /// In id, this message translates to:
  /// **'Belum ada'**
  String get reviewExtrasNoItems;

  /// No description provided for @reviewCorrectNotation.
  ///
  /// In id, this message translates to:
  /// **'Notasi'**
  String get reviewCorrectNotation;

  /// No description provided for @reviewCorrectPronunciation.
  ///
  /// In id, this message translates to:
  /// **'Pelafalan'**
  String get reviewCorrectPronunciation;

  /// No description provided for @reviewCorrectAudioUrl.
  ///
  /// In id, this message translates to:
  /// **'URL audio'**
  String get reviewCorrectAudioUrl;

  /// No description provided for @reviewCorrectSpeaker.
  ///
  /// In id, this message translates to:
  /// **'Penutur'**
  String get reviewCorrectSpeaker;

  /// No description provided for @reviewCorrectImageUrl.
  ///
  /// In id, this message translates to:
  /// **'URL gambar'**
  String get reviewCorrectImageUrl;

  /// No description provided for @reviewCorrectAltText.
  ///
  /// In id, this message translates to:
  /// **'Teks alternatif'**
  String get reviewCorrectAltText;

  /// No description provided for @reviewCorrectSambasSentence.
  ///
  /// In id, this message translates to:
  /// **'Kalimat sambas'**
  String get reviewCorrectSambasSentence;

  /// No description provided for @reviewCorrectTranslationSentence.
  ///
  /// In id, this message translates to:
  /// **'Kalimat terjemahan'**
  String get reviewCorrectTranslationSentence;

  /// No description provided for @reviewCorrectSourceType.
  ///
  /// In id, this message translates to:
  /// **'Jenis sumber'**
  String get reviewCorrectSourceType;

  /// No description provided for @reviewCorrectNotesOptional.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get reviewCorrectNotesOptional;

  /// No description provided for @reviewCorrectPublishVerify.
  ///
  /// In id, this message translates to:
  /// **'Langsung terbitkan dan verifikasi'**
  String get reviewCorrectPublishVerify;

  /// No description provided for @reviewCorrectProcessing.
  ///
  /// In id, this message translates to:
  /// **'Memproses...'**
  String get reviewCorrectProcessing;

  /// No description provided for @reviewCorrectSavePublish.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan terbitkan'**
  String get reviewCorrectSavePublish;

  /// No description provided for @reviewCorrectSavePending.
  ///
  /// In id, this message translates to:
  /// **'Simpan, tetap menunggu'**
  String get reviewCorrectSavePending;

  /// No description provided for @reviewCorrectCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal koreksi'**
  String get reviewCorrectCancel;

  /// No description provided for @reviewCorrectPolitenessConflict.
  ///
  /// In id, this message translates to:
  /// **'Halus dan Kasar tidak bisa dipilih bersamaan'**
  String get reviewCorrectPolitenessConflict;

  /// No description provided for @reviewCorrectWordNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan kata'**
  String get reviewCorrectWordNotes;

  /// No description provided for @reviewCorrectRegister.
  ///
  /// In id, this message translates to:
  /// **'Register'**
  String get reviewCorrectRegister;

  /// No description provided for @reviewCorrectRegisterHint.
  ///
  /// In id, this message translates to:
  /// **'Gaya atau pantangan berbahasa. Halus dan Kasar tidak bisa bersamaan.'**
  String get reviewCorrectRegisterHint;

  /// No description provided for @reviewCorrectWarning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get reviewCorrectWarning;

  /// No description provided for @reviewCorrectWarningHint.
  ///
  /// In id, this message translates to:
  /// **'Sensitivitas isi makna.'**
  String get reviewCorrectWarningHint;

  /// No description provided for @reviewCorrectAddMeaning.
  ///
  /// In id, this message translates to:
  /// **'Tambah makna'**
  String get reviewCorrectAddMeaning;

  /// No description provided for @reviewCorrectAddPronunciation.
  ///
  /// In id, this message translates to:
  /// **'Rekam pelafalan'**
  String get reviewCorrectAddPronunciation;

  /// No description provided for @reviewCorrectPronunciationAutoSave.
  ///
  /// In id, this message translates to:
  /// **'Langsung tersimpan, tidak menunggu tombol Simpan'**
  String get reviewCorrectPronunciationAutoSave;

  /// No description provided for @reviewCorrectPronunciationRecorded.
  ///
  /// In id, this message translates to:
  /// **'{count} rekaman baru terkirim'**
  String reviewCorrectPronunciationRecorded(int count);

  /// No description provided for @reviewCorrectSynonymCount.
  ///
  /// In id, this message translates to:
  /// **'{count} sinonim'**
  String reviewCorrectSynonymCount(int count);

  /// No description provided for @reviewCorrectAntonymCount.
  ///
  /// In id, this message translates to:
  /// **'{count} antonim'**
  String reviewCorrectAntonymCount(int count);

  /// No description provided for @reviewCorrectLanguageUnknown.
  ///
  /// In id, this message translates to:
  /// **'Bahasa kata tidak diketahui'**
  String get reviewCorrectLanguageUnknown;

  /// No description provided for @reviewCorrectWordClassLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kelas kata'**
  String get reviewCorrectWordClassLoadFailed;

  /// No description provided for @reviewCorrectMeaningPayloadMissing.
  ///
  /// In id, this message translates to:
  /// **'Payload makna tidak memuat definisi atau terjemahan.'**
  String get reviewCorrectMeaningPayloadMissing;

  /// No description provided for @reviewCorrectKbbiHint.
  ///
  /// In id, this message translates to:
  /// **'Tekan icon buku untuk mencari definisi di KBBI'**
  String get reviewCorrectKbbiHint;

  /// No description provided for @reviewCorrectCarriedTranslations.
  ///
  /// In id, this message translates to:
  /// **'Terjemahan lain milik makna ini ({count}) ikut tersimpan tanpa diubah.'**
  String reviewCorrectCarriedTranslations(int count);

  /// No description provided for @reviewCorrectDefinitionFromKbbi.
  ///
  /// In id, this message translates to:
  /// **'Definisi diisi dari KBBI'**
  String get reviewCorrectDefinitionFromKbbi;

  /// No description provided for @reviewCorrectWordType.
  ///
  /// In id, this message translates to:
  /// **'Jenis entri'**
  String get reviewCorrectWordType;

  /// No description provided for @reviewWordTypeGeneral.
  ///
  /// In id, this message translates to:
  /// **'Umum'**
  String get reviewWordTypeGeneral;

  /// No description provided for @reviewWordTypeWord.
  ///
  /// In id, this message translates to:
  /// **'Kata'**
  String get reviewWordTypeWord;

  /// No description provided for @reviewWordTypeIdiom.
  ///
  /// In id, this message translates to:
  /// **'Idiom'**
  String get reviewWordTypeIdiom;

  /// No description provided for @reviewWordTypeProverb.
  ///
  /// In id, this message translates to:
  /// **'Peribahasa'**
  String get reviewWordTypeProverb;

  /// No description provided for @reviewWordTypeExpression.
  ///
  /// In id, this message translates to:
  /// **'Ungkapan'**
  String get reviewWordTypeExpression;

  /// No description provided for @reviewInlineTypeLocked.
  ///
  /// In id, this message translates to:
  /// **'Jenis tidak bisa diubah'**
  String get reviewInlineTypeLocked;

  /// No description provided for @reviewInlineTypeLockedHint.
  ///
  /// In id, this message translates to:
  /// **'has_component hanya untuk entri idiom/peribahasa/ungkapan'**
  String get reviewInlineTypeLockedHint;

  /// No description provided for @reviewPendingNotFound.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada usulan yang menunggu untuk kata ini.'**
  String get reviewPendingNotFound;

  /// No description provided for @reviewRepoQueueLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat antrean review'**
  String get reviewRepoQueueLoadFailed;

  /// No description provided for @reviewRepoSuggestionDetailLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat detail usulan'**
  String get reviewRepoSuggestionDetailLoadFailed;

  /// No description provided for @reviewRepoReopenFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka ulang keputusan'**
  String get reviewRepoReopenFailed;

  /// No description provided for @reviewRepoSkipFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal melewati usulan'**
  String get reviewRepoSkipFailed;

  /// No description provided for @reviewRepoRestoreFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengembalikan usulan'**
  String get reviewRepoRestoreFailed;

  /// No description provided for @reviewRepoUnverifyFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mencabut verifikasi kata'**
  String get reviewRepoUnverifyFailed;

  /// No description provided for @reviewRepoDecisionSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan keputusan'**
  String get reviewRepoDecisionSaveFailed;

  /// No description provided for @reviewRepoSearchMissLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat pencarian kosong'**
  String get reviewRepoSearchMissLoadFailed;

  /// No description provided for @reviewRepoSearchMissPublishFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah tayang'**
  String get reviewRepoSearchMissPublishFailed;

  /// No description provided for @reviewRepoSearchMissCorrectFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengoreksi term'**
  String get reviewRepoSearchMissCorrectFailed;

  /// No description provided for @reviewRepoSearchMissDismissFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyingkirkan'**
  String get reviewRepoSearchMissDismissFailed;

  /// No description provided for @reviewRepoSearchMissSkipFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal melewati'**
  String get reviewRepoSearchMissSkipFailed;

  /// No description provided for @reviewRepoSuggestionsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat antrean usulan edit'**
  String get reviewRepoSuggestionsLoadFailed;

  /// No description provided for @reviewRepoSuggestionLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat detail usulan edit'**
  String get reviewRepoSuggestionLoadFailed;

  /// No description provided for @reviewRepoSuggestionApproveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyetujui usulan'**
  String get reviewRepoSuggestionApproveFailed;

  /// No description provided for @reviewRepoSuggestionRejectFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menolak usulan'**
  String get reviewRepoSuggestionRejectFailed;

  /// No description provided for @reviewCorrectKindLabel.
  ///
  /// In id, this message translates to:
  /// **'Ubah jenis atau kelas kata'**
  String get reviewCorrectKindLabel;

  /// No description provided for @reviewSearchMissHitsText.
  ///
  /// In id, this message translates to:
  /// **'{value} dicari'**
  String reviewSearchMissHitsText(String value);

  /// No description provided for @reviewSearchMissVisibleSuffix.
  ///
  /// In id, this message translates to:
  /// **'tayang'**
  String get reviewSearchMissVisibleSuffix;

  /// No description provided for @reviewSearchMissDirectionHitsFull.
  ///
  /// In id, this message translates to:
  /// **'{direction} · {count}× dicari · {status}'**
  String reviewSearchMissDirectionHitsFull(
    String direction,
    int count,
    String status,
  );

  /// No description provided for @dictUsageKasar.
  ///
  /// In id, this message translates to:
  /// **'Kasar'**
  String get dictUsageKasar;

  /// No description provided for @dictUsageTabu.
  ///
  /// In id, this message translates to:
  /// **'Tabu'**
  String get dictUsageTabu;

  /// No description provided for @dictUsageInformal.
  ///
  /// In id, this message translates to:
  /// **'Informal'**
  String get dictUsageInformal;

  /// No description provided for @dictUsageHalus.
  ///
  /// In id, this message translates to:
  /// **'Halus'**
  String get dictUsageHalus;

  /// No description provided for @dictUsageSeksual.
  ///
  /// In id, this message translates to:
  /// **'Seksual'**
  String get dictUsageSeksual;

  /// No description provided for @dictUsageDiskriminatif.
  ///
  /// In id, this message translates to:
  /// **'Diskriminatif'**
  String get dictUsageDiskriminatif;

  /// No description provided for @dictWordTypeWord.
  ///
  /// In id, this message translates to:
  /// **'Kata'**
  String get dictWordTypeWord;

  /// No description provided for @dictWordTypeIdiom.
  ///
  /// In id, this message translates to:
  /// **'Idiom'**
  String get dictWordTypeIdiom;

  /// No description provided for @dictWordTypeProverb.
  ///
  /// In id, this message translates to:
  /// **'Peribahasa'**
  String get dictWordTypeProverb;

  /// No description provided for @dictWordTypeExpression.
  ///
  /// In id, this message translates to:
  /// **'Ungkapan'**
  String get dictWordTypeExpression;

  /// No description provided for @dictRelationSynonym.
  ///
  /// In id, this message translates to:
  /// **'Sinonim'**
  String get dictRelationSynonym;

  /// No description provided for @dictRelationAntonym.
  ///
  /// In id, this message translates to:
  /// **'Antonim'**
  String get dictRelationAntonym;

  /// No description provided for @dictRelationComponent.
  ///
  /// In id, this message translates to:
  /// **'Komponen'**
  String get dictRelationComponent;

  /// No description provided for @dictRelationSeeAlso.
  ///
  /// In id, this message translates to:
  /// **'Lihat juga'**
  String get dictRelationSeeAlso;

  /// No description provided for @dictRelationDerivedFrom.
  ///
  /// In id, this message translates to:
  /// **'Diturunkan dari'**
  String get dictRelationDerivedFrom;

  /// No description provided for @dictRelationVariantOf.
  ///
  /// In id, this message translates to:
  /// **'Variasi dari'**
  String get dictRelationVariantOf;

  /// No description provided for @dictRelationNonstandardOf.
  ///
  /// In id, this message translates to:
  /// **'Bentuk tidak baku dari'**
  String get dictRelationNonstandardOf;

  /// No description provided for @dictVariantAlternative.
  ///
  /// In id, this message translates to:
  /// **'Variasi penulisan'**
  String get dictVariantAlternative;

  /// No description provided for @dictVariantInflection.
  ///
  /// In id, this message translates to:
  /// **'Fleksi'**
  String get dictVariantInflection;

  /// No description provided for @dictVariantDerivation.
  ///
  /// In id, this message translates to:
  /// **'Derivasi'**
  String get dictVariantDerivation;

  /// No description provided for @dictVariantReduplication.
  ///
  /// In id, this message translates to:
  /// **'Reduplikasi'**
  String get dictVariantReduplication;

  /// No description provided for @dictAttributionCreatedBy.
  ///
  /// In id, this message translates to:
  /// **'Dibuat oleh {name}'**
  String dictAttributionCreatedBy(String name);

  /// No description provided for @dictAttributionVerifiedBy.
  ///
  /// In id, this message translates to:
  /// **'Diverifikasi oleh {name}'**
  String dictAttributionVerifiedBy(String name);

  /// No description provided for @dictAttributionCreatedAndVerifiedBy.
  ///
  /// In id, this message translates to:
  /// **'Dibuat dan diverifikasi oleh {name}'**
  String dictAttributionCreatedAndVerifiedBy(String name);

  /// No description provided for @dictSpeakerAnonymous.
  ///
  /// In id, this message translates to:
  /// **'Anonim'**
  String get dictSpeakerAnonymous;

  /// No description provided for @dictCopiedWord.
  ///
  /// In id, this message translates to:
  /// **'Teks kata disalin'**
  String get dictCopiedWord;

  /// No description provided for @dictCopiedMeaning.
  ///
  /// In id, this message translates to:
  /// **'Makna disalin'**
  String get dictCopiedMeaning;

  /// No description provided for @dictSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari kata Sambas...'**
  String get dictSearchHint;

  /// No description provided for @dictAZ.
  ///
  /// In id, this message translates to:
  /// **'A-Z'**
  String get dictAZ;

  /// No description provided for @dictProposeWord.
  ///
  /// In id, this message translates to:
  /// **'Usul kata baru'**
  String get dictProposeWord;

  /// No description provided for @dictDiscussion.
  ///
  /// In id, this message translates to:
  /// **'Ruang Diskusi'**
  String get dictDiscussion;

  /// No description provided for @dictDiscussionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tanya arti atau bahas kata Sambas bareng warga'**
  String get dictDiscussionSubtitle;

  /// No description provided for @dictRecentActivity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas terbaru'**
  String get dictRecentActivity;

  /// No description provided for @dictNoActivity.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas.'**
  String get dictNoActivity;

  /// No description provided for @dictActivitySkeletonLine.
  ///
  /// In id, this message translates to:
  /// **'aktivitas singkat satu baris'**
  String get dictActivitySkeletonLine;

  /// No description provided for @dictCitizenFallback.
  ///
  /// In id, this message translates to:
  /// **'Warga Sambas'**
  String get dictCitizenFallback;

  /// No description provided for @dictLetterTitle.
  ///
  /// In id, this message translates to:
  /// **'Huruf {letter}'**
  String dictLetterTitle(String letter);

  /// No description provided for @dictLetterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kata yang dimulai dengan huruf {letter}.'**
  String dictLetterSubtitle(String letter);

  /// No description provided for @dictLetterEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kata untuk huruf {letter}.'**
  String dictLetterEmpty(String letter);

  /// No description provided for @dictSeeAllWords.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua kata'**
  String get dictSeeAllWords;

  /// No description provided for @dictSkeletonWord.
  ///
  /// In id, this message translates to:
  /// **'kata Sambas contoh'**
  String get dictSkeletonWord;

  /// No description provided for @dictLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get dictLoading;

  /// No description provided for @dictMicPermissionTooltip.
  ///
  /// In id, this message translates to:
  /// **'Izin mikrofon diperlukan untuk merekam pelafalan'**
  String get dictMicPermissionTooltip;

  /// No description provided for @dictMicPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin mikrofon'**
  String get dictMicPermissionTitle;

  /// No description provided for @dictMicHeroTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekam pelafalan butuh akses mikrofon'**
  String get dictMicHeroTitle;

  /// No description provided for @dictMicHeroBody.
  ///
  /// In id, this message translates to:
  /// **'Sebelum merekam, SambasKu meminta izin mikrofon. Ini hanya dipakai untuk fitur pelafalan - bukan untuk menyadap atau merekam di latar belakang.'**
  String get dictMicHeroBody;

  /// No description provided for @dictMicFactsTitle.
  ///
  /// In id, this message translates to:
  /// **'Yang perlu kamu tahu'**
  String get dictMicFactsTitle;

  /// No description provided for @dictMicFactRequiredTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin mikrofon wajib'**
  String get dictMicFactRequiredTitle;

  /// No description provided for @dictMicFactRequiredBody.
  ///
  /// In id, this message translates to:
  /// **'Tanpa izin, tombol rekam tidak bisa mulai. Kamu bisa mencabut izin kapan saja di Pengaturan perangkat.'**
  String get dictMicFactRequiredBody;

  /// No description provided for @dictMicFactDurationTitle.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 60 detik'**
  String get dictMicFactDurationTitle;

  /// No description provided for @dictMicFactDurationBody.
  ///
  /// In id, this message translates to:
  /// **'Cukup untuk lemma atau contoh kalimat. Format suara AAC/m4a - tanpa video.'**
  String get dictMicFactDurationBody;

  /// No description provided for @dictMicFactReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Ditinjau sebelum tayang'**
  String get dictMicFactReviewTitle;

  /// No description provided for @dictMicFactReviewBody.
  ///
  /// In id, this message translates to:
  /// **'Rekaman dikirim ke server SambasKu dan masuk antrean review. Nama penutur opsional - boleh kirim tanpa nama.'**
  String get dictMicFactReviewBody;

  /// No description provided for @dictMicFactOnlyRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Hanya saat kamu merekam'**
  String get dictMicFactOnlyRecordTitle;

  /// No description provided for @dictMicFactOnlyRecordBody.
  ///
  /// In id, this message translates to:
  /// **'Mikrofon aktif hanya selama sesi rekam di layar ini. Tidak merekam diam-diam.'**
  String get dictMicFactOnlyRecordBody;

  /// No description provided for @dictMicRequesting.
  ///
  /// In id, this message translates to:
  /// **'Meminta izin...'**
  String get dictMicRequesting;

  /// No description provided for @dictMicGrant.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan & izinkan mikrofon'**
  String get dictMicGrant;

  /// No description provided for @dictMicLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get dictMicLater;

  /// No description provided for @dictCompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi kata'**
  String get dictCompleteTitle;

  /// No description provided for @dictCompleteSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kata untuk ditambah maknanya, sinonim atau antonimnya, variasi penulisannya, contoh kalimatnya, atau rekam pelafasannya.'**
  String get dictCompleteSubtitle;

  /// No description provided for @dictCompleteHint.
  ///
  /// In id, this message translates to:
  /// **'Cari kata Sambas...'**
  String get dictCompleteHint;

  /// No description provided for @dictCompleteMinChars.
  ///
  /// In id, this message translates to:
  /// **'Ketik minimal 2 huruf untuk mencari kata.'**
  String get dictCompleteMinChars;

  /// No description provided for @dictCompleteNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kata yang cocok dengan \"{query}\".'**
  String dictCompleteNoMatch(String query);

  /// No description provided for @dictDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail kata'**
  String get dictDetailTitle;

  /// No description provided for @dictChangeHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat perubahan'**
  String get dictChangeHistory;

  /// No description provided for @dictWordNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kata tidak ditemukan'**
  String get dictWordNotFound;

  /// No description provided for @dictPendingCheck.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pengecekan'**
  String get dictPendingCheck;

  /// No description provided for @dictUnverifiedWarning.
  ///
  /// In id, this message translates to:
  /// **'Kata ini belum dicek tim SambasKu, jadi makna atau terjemahannya bisa saja kurang pas'**
  String get dictUnverifiedWarning;

  /// No description provided for @dictReview.
  ///
  /// In id, this message translates to:
  /// **'Tinjau'**
  String get dictReview;

  /// No description provided for @dictImageUnderReview.
  ///
  /// In id, this message translates to:
  /// **'Gambar sedang dalam peninjauan.'**
  String get dictImageUnderReview;

  /// No description provided for @dictLoginToReportPhoto.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melaporkan foto'**
  String get dictLoginToReportPhoto;

  /// No description provided for @dictPhotoReportSent.
  ///
  /// In id, this message translates to:
  /// **'Laporan terkirim. Foto tetap tayang sampai ditinjau.'**
  String get dictPhotoReportSent;

  /// No description provided for @dictSeeVerifiers.
  ///
  /// In id, this message translates to:
  /// **'Lihat verifikator'**
  String get dictSeeVerifiers;

  /// No description provided for @dictPronunciationLine.
  ///
  /// In id, this message translates to:
  /// **'{notation} {value}'**
  String dictPronunciationLine(String notation, String value);

  /// No description provided for @dictVariantsTitle.
  ///
  /// In id, this message translates to:
  /// **'Variasi penulisan'**
  String get dictVariantsTitle;

  /// No description provided for @dictVariantsAndDerived.
  ///
  /// In id, this message translates to:
  /// **'Variasi & bentuk turunan'**
  String get dictVariantsAndDerived;

  /// No description provided for @dictAppearsIn.
  ///
  /// In id, this message translates to:
  /// **'Muncul dalam'**
  String get dictAppearsIn;

  /// No description provided for @dictRelatedMeanings.
  ///
  /// In id, this message translates to:
  /// **'Makna terkait'**
  String get dictRelatedMeanings;

  /// No description provided for @dictImagePendingReview.
  ///
  /// In id, this message translates to:
  /// **'Gambar menunggu tinjauan'**
  String get dictImagePendingReview;

  /// No description provided for @dictViolenceImage.
  ///
  /// In id, this message translates to:
  /// **'Foto berisi kekerasan, ketuk untuk menampilkan'**
  String get dictViolenceImage;

  /// No description provided for @dictImagePreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau gambar'**
  String get dictImagePreview;

  /// No description provided for @dictImageCounter.
  ///
  /// In id, this message translates to:
  /// **'{index}/{total}'**
  String dictImageCounter(int index, int total);

  /// No description provided for @dictLoginToSave.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk menyimpan kata'**
  String get dictLoginToSave;

  /// No description provided for @dictShareLink.
  ///
  /// In id, this message translates to:
  /// **'Bagikan tautan'**
  String get dictShareLink;

  /// No description provided for @dictShareLinkSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kirim link detail kata ke WhatsApp, grup, dan aplikasi lain'**
  String get dictShareLinkSubtitle;

  /// No description provided for @dictShareCard.
  ///
  /// In id, this message translates to:
  /// **'Bagikan kartu'**
  String get dictShareCard;

  /// No description provided for @dictShareCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buat kartu untuk cerita IG, WhatsApp, dan lainnya'**
  String get dictShareCardSubtitle;

  /// No description provided for @dictLoginToSuggest.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk mengusulkan perubahan'**
  String get dictLoginToSuggest;

  /// No description provided for @dictReportEntry.
  ///
  /// In id, this message translates to:
  /// **'Laporkan entri'**
  String get dictReportEntry;

  /// No description provided for @dictReportEntrySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Untuk entri yang tidak layak tayang, bukan perbaikan isi'**
  String get dictReportEntrySubtitle;

  /// No description provided for @dictLoginToReportEntry.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melaporkan entri'**
  String get dictLoginToReportEntry;

  /// No description provided for @dictEntryReportSent.
  ///
  /// In id, this message translates to:
  /// **'Laporan terkirim. Entri tetap tayang sampai ditinjau.'**
  String get dictEntryReportSent;

  /// No description provided for @dictReportPhoto.
  ///
  /// In id, this message translates to:
  /// **'Laporkan foto'**
  String get dictReportPhoto;

  /// No description provided for @dictReportPhotoSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Foto bermasalah ditandai agar orang lain harus ketuk dulu sebelum melihat'**
  String get dictReportPhotoSubtitle;

  /// No description provided for @dictPhotoReportThanks.
  ///
  /// In id, this message translates to:
  /// **'Laporan foto terkirim. Terima kasih.'**
  String get dictPhotoReportThanks;

  /// No description provided for @dictMostSupported.
  ///
  /// In id, this message translates to:
  /// **'Paling didukung'**
  String get dictMostSupported;

  /// No description provided for @dictContributionBy.
  ///
  /// In id, this message translates to:
  /// **'oleh {name}'**
  String dictContributionBy(String name);

  /// No description provided for @dictNoTranslation.
  ///
  /// In id, this message translates to:
  /// **'Belum ada terjemahan'**
  String get dictNoTranslation;

  /// No description provided for @dictExampleAudio.
  ///
  /// In id, this message translates to:
  /// **'Audio contoh'**
  String get dictExampleAudio;

  /// No description provided for @dictCopyMeaning.
  ///
  /// In id, this message translates to:
  /// **'Salin makna'**
  String get dictCopyMeaning;

  /// No description provided for @dictSkeletonLemma.
  ///
  /// In id, this message translates to:
  /// **'lemma contoh kata'**
  String get dictSkeletonLemma;

  /// No description provided for @dictSkeletonWordClass.
  ///
  /// In id, this message translates to:
  /// **'Nomina'**
  String get dictSkeletonWordClass;

  /// No description provided for @dictSkeletonComment.
  ///
  /// In id, this message translates to:
  /// **'isi komentar skeleton beberapa kata di sini'**
  String get dictSkeletonComment;

  /// No description provided for @dictSkeletonDefinition.
  ///
  /// In id, this message translates to:
  /// **'Definisi makna singkat untuk skeleton layout'**
  String get dictSkeletonDefinition;

  /// No description provided for @dictSkeletonExampleTranslation.
  ///
  /// In id, this message translates to:
  /// **'terjemahan contoh'**
  String get dictSkeletonExampleTranslation;

  /// No description provided for @dictSkeletonUsername.
  ///
  /// In id, this message translates to:
  /// **'nama pengguna'**
  String get dictSkeletonUsername;

  /// No description provided for @dictRoleVerifier.
  ///
  /// In id, this message translates to:
  /// **'{label}, Verifikator'**
  String dictRoleVerifier(String label);

  /// No description provided for @dictAttribution.
  ///
  /// In id, this message translates to:
  /// **'Atribusi'**
  String get dictAttribution;

  /// No description provided for @dictSeeProfile.
  ///
  /// In id, this message translates to:
  /// **'Lihat profil'**
  String get dictSeeProfile;

  /// No description provided for @dictProfileOf.
  ///
  /// In id, this message translates to:
  /// **'Profil {username}'**
  String dictProfileOf(String username);

  /// No description provided for @dictListTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Kata A-Z'**
  String get dictListTitle;

  /// No description provided for @dictLangSambas.
  ///
  /// In id, this message translates to:
  /// **'Sambas'**
  String get dictLangSambas;

  /// No description provided for @dictLangIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get dictLangIndonesia;

  /// No description provided for @dictSearchIndonesianHint.
  ///
  /// In id, this message translates to:
  /// **'Cari kata Indonesia...'**
  String get dictSearchIndonesianHint;

  /// No description provided for @dictSearchSambasHint.
  ///
  /// In id, this message translates to:
  /// **'Cari atau saring kata Sambas...'**
  String get dictSearchSambasHint;

  /// No description provided for @dictCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get dictCategory;

  /// No description provided for @dictSearchIndonesianEmpty.
  ///
  /// In id, this message translates to:
  /// **'Ketik kata Indonesia untuk mencari terjemahannya di Sambas.'**
  String get dictSearchIndonesianEmpty;

  /// No description provided for @dictNoPublishedWord.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kata terbit.'**
  String get dictNoPublishedWord;

  /// No description provided for @dictNoMatchFor.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kata untuk \"{query}\"'**
  String dictNoMatchFor(String query);

  /// No description provided for @dictNotInDictionary.
  ///
  /// In id, this message translates to:
  /// **'Belum ada di kamus. Usulkan supaya bisa dicari orang lain.'**
  String get dictNotInDictionary;

  /// No description provided for @dictProposeThisWord.
  ///
  /// In id, this message translates to:
  /// **'Usul kata ini'**
  String get dictProposeThisWord;

  /// No description provided for @dictRelatedMeaningSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Makna terkait · {subtitle}'**
  String dictRelatedMeaningSubtitle(String subtitle);

  /// No description provided for @dictSearchHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat pencarian'**
  String get dictSearchHistory;

  /// No description provided for @dictRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get dictRemove;

  /// No description provided for @dictAudioPlay.
  ///
  /// In id, this message translates to:
  /// **'Putar audio {meta}'**
  String dictAudioPlay(String meta);

  /// No description provided for @dictAudioPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda audio {meta}'**
  String dictAudioPause(String meta);

  /// No description provided for @dictAudioResume.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan audio {meta}'**
  String dictAudioResume(String meta);

  /// No description provided for @dictAudioLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat audio {meta}'**
  String dictAudioLoading(String meta);

  /// No description provided for @dictAudioError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memutar {meta}, ketuk untuk coba lagi'**
  String dictAudioError(String meta);

  /// No description provided for @dictAudioErrorRetry.
  ///
  /// In id, this message translates to:
  /// **'Gagal memutar audio. Coba lagi dalam beberapa saat.'**
  String get dictAudioErrorRetry;

  /// No description provided for @dictAudioProgress.
  ///
  /// In id, this message translates to:
  /// **'Progres pemutaran'**
  String get dictAudioProgress;

  /// No description provided for @dictAudioProgressPercent.
  ///
  /// In id, this message translates to:
  /// **'{percent} persen'**
  String dictAudioProgressPercent(int percent);

  /// No description provided for @dictPronunciationSection.
  ///
  /// In id, this message translates to:
  /// **'Pelafalan'**
  String get dictPronunciationSection;

  /// No description provided for @dictNoPronunciationAudio.
  ///
  /// In id, this message translates to:
  /// **'Belum ada audio pelafalan kata'**
  String get dictNoPronunciationAudio;

  /// No description provided for @dictRecordExampleAudio.
  ///
  /// In id, this message translates to:
  /// **'Rekam audio contoh'**
  String get dictRecordExampleAudio;

  /// No description provided for @dictRecordPronunciation.
  ///
  /// In id, this message translates to:
  /// **'Rekam pelafalan'**
  String get dictRecordPronunciation;

  /// No description provided for @dictLoginToRecord.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk rekam pelafalan'**
  String get dictLoginToRecord;

  /// No description provided for @dictRecMicPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin mikrofon diperlukan untuk rekam pelafalan'**
  String get dictRecMicPermissionTitle;

  /// No description provided for @dictRecMicUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Mikrofon tidak tersedia'**
  String get dictRecMicUnavailable;

  /// No description provided for @dictRecSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Rekaman gagal disimpan'**
  String get dictRecSaveFailed;

  /// No description provided for @dictRecStoppedInactive.
  ///
  /// In id, this message translates to:
  /// **'Rekaman dihentikan karena aplikasi tidak aktif'**
  String get dictRecStoppedInactive;

  /// No description provided for @dictRecTooShort.
  ///
  /// In id, this message translates to:
  /// **'Rekaman terlalu singkat - coba ucapkan sekali lagi dengan jelas'**
  String get dictRecTooShort;

  /// No description provided for @dictRecTooQuiet.
  ///
  /// In id, this message translates to:
  /// **'Suara terdengar pelan - dekatkan mikrofon lalu rekam ulang'**
  String get dictRecTooQuiet;

  /// No description provided for @dictRecClipTooShort.
  ///
  /// In id, this message translates to:
  /// **'Potongan terlalu pendek (min {min} dtk)'**
  String dictRecClipTooShort(String min);

  /// No description provided for @dictRecPreviewFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memutar pratinjau. Coba rekam ulang atau potong ulang.'**
  String get dictRecPreviewFailed;

  /// No description provided for @dictRecLicenseTitle.
  ///
  /// In id, this message translates to:
  /// **'Publikasi & Lisensi Rekaman'**
  String get dictRecLicenseTitle;

  /// No description provided for @dictRecLicenseBody.
  ///
  /// In id, this message translates to:
  /// **'Suara penutur akan dipublikasikan di SambasKu (situs dan aplikasi) di bawah lisensi CC BY-SA 4.0, dan bisa didengar siapa saja.\n\nPastikan penutur yang bersuara tahu dan setuju rekamannya dipakai. Penutur tidak harus punya aplikasi, cukup setuju saat kamu merekam. Rekaman bisa diminta dihapus kapan saja lewat mail@sambasku.com.'**
  String get dictRecLicenseBody;

  /// No description provided for @dictRecAgree.
  ///
  /// In id, this message translates to:
  /// **'Saya setuju'**
  String get dictRecAgree;

  /// No description provided for @dictRecNoRecording.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rekaman. Rekam dulu sebelum mengirim.'**
  String get dictRecNoRecording;

  /// No description provided for @dictRecNoDisplayName.
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan tidak tersedia. Matikan opsi nama, atau perbarui profil dulu.'**
  String get dictRecNoDisplayName;

  /// No description provided for @dictRecTrimFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memotong audio. Sesuaikan rentang lalu coba kirim lagi.'**
  String get dictRecTrimFailed;

  /// No description provided for @dictRecTooMany.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak, coba lagi nanti'**
  String get dictRecTooMany;

  /// No description provided for @dictRecThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih, rekaman menunggu pengecekan'**
  String get dictRecThanks;

  /// No description provided for @dictRecDialectOptional.
  ///
  /// In id, this message translates to:
  /// **'Dialek (opsional)'**
  String get dictRecDialectOptional;

  /// No description provided for @dictRecMaxSecondsHint.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} detik · cukup 1-2 kali baca kalimat'**
  String dictRecMaxSecondsHint(int max);

  /// No description provided for @dictRecMaxSecondsHintSpeak.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} detik · cukup 1-2 kali ucapan'**
  String dictRecMaxSecondsHintSpeak(int max);

  /// No description provided for @dictRecWaitUpload.
  ///
  /// In id, this message translates to:
  /// **'Tunggu hingga pengiriman selesai'**
  String get dictRecWaitUpload;

  /// No description provided for @dictRecFinishOrCancel.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan atau batalkan rekaman dulu'**
  String get dictRecFinishOrCancel;

  /// No description provided for @dictRecSay.
  ///
  /// In id, this message translates to:
  /// **'Ucapkan'**
  String get dictRecSay;

  /// No description provided for @dictRecIncludeName.
  ///
  /// In id, this message translates to:
  /// **'Cantumkan nama saya sebagai penutur'**
  String get dictRecIncludeName;

  /// No description provided for @dictRecNoDisplayNameShort.
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan belum ada di profil'**
  String get dictRecNoDisplayNameShort;

  /// No description provided for @dictRecAnonymous.
  ///
  /// In id, this message translates to:
  /// **'Tanpa nama (Anonim)'**
  String get dictRecAnonymous;

  /// No description provided for @dictRecFollowProfileName.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti nama tampilan di profilmu'**
  String get dictRecFollowProfileName;

  /// No description provided for @dictRecHoldHint.
  ///
  /// In id, this message translates to:
  /// **'Tahan untuk rekam, lepas untuk stop · ketuk singkat untuk kunci'**
  String get dictRecHoldHint;

  /// No description provided for @dictRecRecording.
  ///
  /// In id, this message translates to:
  /// **'Merekam... {elapsed}s / {max}s'**
  String dictRecRecording(int elapsed, int max);

  /// No description provided for @dictRecReleaseToStop.
  ///
  /// In id, this message translates to:
  /// **'Lepas untuk stop'**
  String get dictRecReleaseToStop;

  /// No description provided for @dictRecStop.
  ///
  /// In id, this message translates to:
  /// **'Stop'**
  String get dictRecStop;

  /// No description provided for @dictRecStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai rekam'**
  String get dictRecStart;

  /// No description provided for @dictRecMicLevel.
  ///
  /// In id, this message translates to:
  /// **'Level mikrofon · ketuk tombol untuk stop'**
  String get dictRecMicLevel;

  /// No description provided for @dictRecTrim.
  ///
  /// In id, this message translates to:
  /// **'Potong rekaman'**
  String get dictRecTrim;

  /// No description provided for @dictRecPreparingEditor.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan editor...'**
  String get dictRecPreparingEditor;

  /// No description provided for @dictRecTrimRange.
  ///
  /// In id, this message translates to:
  /// **'Geser rentang ({selection} dari {total}).'**
  String dictRecTrimRange(String selection, String total);

  /// No description provided for @dictRecTrimSelectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Bagian terpilih yang akan dikirim.'**
  String get dictRecTrimSelectionLabel;

  /// No description provided for @dictRecWaveformUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Waveform tidak tersedia - geser slider untuk memotong'**
  String get dictRecWaveformUnavailable;

  /// No description provided for @dictRecPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get dictRecPause;

  /// No description provided for @dictRecPreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau'**
  String get dictRecPreview;

  /// No description provided for @dictRecAgreeBeforeSend.
  ///
  /// In id, this message translates to:
  /// **'Tekan Kirim untuk setuju soal publikasi & lisensi rekaman'**
  String get dictRecAgreeBeforeSend;

  /// No description provided for @dictRecRerecord.
  ///
  /// In id, this message translates to:
  /// **'Rekam ulang'**
  String get dictRecRerecord;

  /// No description provided for @dictRecSending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get dictRecSending;

  /// No description provided for @dictRecSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get dictRecSend;

  /// No description provided for @dictRecLevelSemantic.
  ///
  /// In id, this message translates to:
  /// **'Level mikrofon'**
  String get dictRecLevelSemantic;

  /// No description provided for @dictWordOfDay.
  ///
  /// In id, this message translates to:
  /// **'Kata hari ini'**
  String get dictWordOfDay;

  /// No description provided for @dictWordOfDayShownToday.
  ///
  /// In id, this message translates to:
  /// **'Ditampilkan hari ini · baru minggu ini'**
  String get dictWordOfDayShownToday;

  /// No description provided for @dictWordOfDayRotates.
  ///
  /// In id, this message translates to:
  /// **'Ditampilkan hari ini, berganti setiap hari'**
  String get dictWordOfDayRotates;

  /// No description provided for @dictSkeletonLemmaShort.
  ///
  /// In id, this message translates to:
  /// **'lemma contoh'**
  String get dictSkeletonLemmaShort;

  /// No description provided for @dictSkeletonGloss.
  ///
  /// In id, this message translates to:
  /// **'arti pertama satu baris'**
  String get dictSkeletonGloss;

  /// Toast saat user menutup sheet Google/Facebook/GitHub
  ///
  /// In id, this message translates to:
  /// **'Masuk dibatalkan'**
  String get authSignInCanceled;

  /// Akun baru dari halaman masuk wajib lewat persetujuan legal di halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Daftar dulu ya supaya bisa setujui ketentuan'**
  String get authRegisterFirst;

  /// Judul peringatan saat verifikator perlu login ulang
  ///
  /// In id, this message translates to:
  /// **'Masuk kembali'**
  String get authReloginTitle;

  /// Penjelasan peringatan login ulang verifikator
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan akunmu agar peran Verifikator aktif.'**
  String get authReloginBody;

  /// Label kolom identitas pada halaman masuk
  ///
  /// In id, this message translates to:
  /// **'Email atau Username'**
  String get authIdentifierLabel;

  /// Contoh isian kolom identitas
  ///
  /// In id, this message translates to:
  /// **'email@contoh.com / username'**
  String get authIdentifierHint;

  /// Label kolom password
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Tautan ke halaman lupa password
  ///
  /// In id, this message translates to:
  /// **'Lupa password?'**
  String get authForgotPasswordQuestion;

  /// Label tombol saat permintaan sedang berjalan
  ///
  /// In id, this message translates to:
  /// **'Memproses...'**
  String get authSubmitting;

  /// Tombol kirim form masuk
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginAction;

  /// Label tombol masuk lewat Facebook
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Facebook'**
  String get authFacebookLogin;

  /// Awalan kalimat menuju halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? '**
  String get authNoAccountPrefix;

  /// Tombol menuju halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authRegisterAction;

  /// Tombol lewati masuk
  ///
  /// In id, this message translates to:
  /// **'Lanjut tanpa akun (Anonim)'**
  String get authContinueAnonymous;

  /// Tautan ke halaman laporan bug
  ///
  /// In id, this message translates to:
  /// **'Laporkan masalah'**
  String get authReportIssue;

  /// Judul sheet email belum diverifikasi
  ///
  /// In id, this message translates to:
  /// **'Email belum diverifikasi'**
  String get authEmailUnverifiedTitle;

  /// Isi sheet email belum diverifikasi
  ///
  /// In id, this message translates to:
  /// **'Cek email kamu untuk kode OTP 6 karakter 0-9A-Z, verifikasi dulu sebelum masuk.'**
  String get authEmailUnverifiedBody;

  /// Tombol menuju halaman verifikasi email
  ///
  /// In id, this message translates to:
  /// **'Verifikasi sekarang'**
  String get authVerifyNow;

  /// Tombol menunda verifikasi email
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get authLater;

  /// Pesan cadangan saat kena batas permintaan
  ///
  /// In id, this message translates to:
  /// **'Coba lagi dalam beberapa saat'**
  String get authRateLimitedFallback;

  /// Judul halaman lupa password
  ///
  /// In id, this message translates to:
  /// **'Lupa password'**
  String get authForgotTitle;

  /// Judul besar halaman lupa password
  ///
  /// In id, this message translates to:
  /// **'Atur ulang password'**
  String get authResetTitle;

  /// Penjelasan halaman lupa password
  ///
  /// In id, this message translates to:
  /// **'Tulis email akunmu. Kalau terdaftar, kami kirim kode 6 karakter 0-9A-Z ke email.'**
  String get authForgotBody;

  /// Label kolom email
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Tombol kirim kode reset password
  ///
  /// In id, this message translates to:
  /// **'Kirim kode reset'**
  String get authSendCode;

  /// Label tombol saat kode sedang dikirim
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get authSending;

  /// Judul info bahwa akun masuk lewat provider OAuth
  ///
  /// In id, this message translates to:
  /// **'Akun OAuth'**
  String get authOauthAccountTitle;

  /// Judul halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authRegisterTitle;

  /// Judul besar halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Buat akun Kontributor'**
  String get authRegisterHeadline;

  /// Penjelasan halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Kami kirim kode 6 karakter 0-9A-Z ke emailmu. Verifikasi dulu sebelum masuk ya.'**
  String get authRegisterBody;

  /// Label kolom nama
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get authNameLabel;

  /// Label kolom nomor HP
  ///
  /// In id, this message translates to:
  /// **'No. HP (opsional)'**
  String get authPhoneOptionalLabel;

  /// Petunjuk aturan password
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter, huruf + angka'**
  String get authPasswordHint;

  /// Label kolom konfirmasi password
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password'**
  String get authConfirmPasswordLabel;

  /// Label checkbox persetujuan dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Saya setuju Syarat dan Ketentuan'**
  String get authAgreeTerms;

  /// Tautan ke dokumen legal lengkap
  ///
  /// In id, this message translates to:
  /// **'Baca dokumen lengkap di SambasKu'**
  String get authReadFullDoc;

  /// Label aksesibilitas tombol daftar lewat Google
  ///
  /// In id, this message translates to:
  /// **'Daftar dengan Google'**
  String get authRegisterWithGoogle;

  /// Label tombol daftar lewat Facebook
  ///
  /// In id, this message translates to:
  /// **'Daftar dengan Facebook'**
  String get authRegisterWithFacebook;

  /// Tombol menuju halaman masuk
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? Masuk'**
  String get authHaveAccount;

  /// Toast saat user menutup sheet provider sosial di halaman daftar
  ///
  /// In id, this message translates to:
  /// **'Daftar dibatalkan'**
  String get authRegisterCanceled;

  /// Pesan gagal memuat versi dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat dokumen legal'**
  String get authLegalLoadFailed;

  /// Toast setelah kode reset dikirim
  ///
  /// In id, this message translates to:
  /// **'Kode baru dikirim ke email'**
  String get authResetCodeSent;

  /// Judul sheet setelah password berhasil direset
  ///
  /// In id, this message translates to:
  /// **'Password berhasil direset'**
  String get authResetSuccess;

  /// Judul halaman atur password baru
  ///
  /// In id, this message translates to:
  /// **'Password baru'**
  String get authNewPasswordTitle;

  /// Penjelasan saat datang lewat tautan reset
  ///
  /// In id, this message translates to:
  /// **'Tautan diterima. Buat password baru (minimal 8 karakter, huruf + angka).'**
  String get authResetLinkBody;

  /// Penjelasan saat memakai kode email
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode 6 karakter 0-9A-Z yang dikirim ke {email} (berlaku 10 menit), lalu password baru.'**
  String authResetCodeBody(String email);

  /// Penjelasan saat email reset tidak diketahui
  ///
  /// In id, this message translates to:
  /// **'Minta kodenya dulu di halaman lupa password ya.'**
  String get authResetAskCode;

  /// Label kolom kode reset password
  ///
  /// In id, this message translates to:
  /// **'Kode Reset Password'**
  String get authResetCodeLabel;

  /// Label kolom konfirmasi password baru
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password baru'**
  String get authConfirmNewPassword;

  /// Tombol simpan password baru
  ///
  /// In id, this message translates to:
  /// **'Simpan password'**
  String get authSavePassword;

  /// Tombol kirim ulang kode verifikasi
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang kode'**
  String get authResendCode;

  /// Tombol kirim ulang saat hitung mundur berjalan
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang kode ({time})'**
  String authResendCodeCountdown(String time);

  /// Pesan validasi konfirmasi password
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password tidak sama'**
  String get authPasswordMismatch;

  /// Judul halaman verifikasi email
  ///
  /// In id, this message translates to:
  /// **'Verifikasi email'**
  String get authVerifyTitle;

  /// Judul besar halaman verifikasi email
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode 6 karakter'**
  String get authEnterCode;

  /// Penjelasan saat email tujuan tidak diketahui
  ///
  /// In id, this message translates to:
  /// **'Emailnya tidak ada. Balik ke daftar atau masuk lagi ya.'**
  String get authEmailMissing;

  /// Penjelasan kode verifikasi dikirim
  ///
  /// In id, this message translates to:
  /// **'Kode dikirim ke {email} (berlaku 10 menit).'**
  String authCodeSentTo(String email);

  /// Label kolom kode OTP
  ///
  /// In id, this message translates to:
  /// **'Kode OTP'**
  String get authOtpLabel;

  /// Tombol verifikasi email
  ///
  /// In id, this message translates to:
  /// **'Verifikasi'**
  String get authVerifyAction;

  /// Pesan setelah minta kode baru
  ///
  /// In id, this message translates to:
  /// **'Kalau email terdaftar, kode baru sudah dikirim.'**
  String get authResendOk;

  /// Judul sheet persetujuan dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Sebelum lanjut, ada dua dokumen'**
  String get authLegalSheetTitle;

  /// Penjelasan sheet persetujuan dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Kamu masuk lewat Google, GitHub, atau Facebook, jadi kami belum punya catatan persetujuanmu. Dua dokumen di bawah ini singkat kok - kami pakai datamu cuma untuk menjalankan kamus ini.'**
  String get authLegalSheetBody;

  /// Keterangan dokumen syarat dan ketentuan
  ///
  /// In id, this message translates to:
  /// **'Aturan main pakai SambasKu. Versi {version}.'**
  String authTermsTileSubtitle(String version);

  /// Keterangan dokumen kebijakan privasi
  ///
  /// In id, this message translates to:
  /// **'Data apa yang kami simpan dan bagaimana kami menjaganya. Versi {version}.'**
  String authPrivacyTileSubtitle(String version);

  /// Hyperlink membuka dokumen syarat dan ketentuan
  ///
  /// In id, this message translates to:
  /// **'Baca Syarat dan Ketentuan'**
  String get authReadTerms;

  /// Hyperlink membuka dokumen kebijakan privasi
  ///
  /// In id, this message translates to:
  /// **'Baca Kebijakan Privasi'**
  String get authReadPrivacy;

  /// Judul kegagalan memuat dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Dokumennya belum ke-load'**
  String get authDocsUnavailableTitle;

  /// Isi kegagalan memuat dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Koneksinya mungkin sedang kurang bagus. Coba muat lagi ya.'**
  String get authDocsUnavailableBody;

  /// Versi dokumen legal belum tersedia di server
  ///
  /// In id, this message translates to:
  /// **'Dokumennya belum siap di server. Coba sebentar lagi ya.'**
  String get authLegalNotReady;

  /// Tombol muat ulang dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Coba muat lagi'**
  String get authReload;

  /// Catatan bahwa persetujuan bisa dihentikan dengan keluar
  ///
  /// In id, this message translates to:
  /// **'Belum siap setuju? Kamu bisa keluar dulu, kapan saja.'**
  String get authStopAnytime;

  /// Tombol menyetujui dokumen legal
  ///
  /// In id, this message translates to:
  /// **'Setuju, lanjut'**
  String get authAcceptAndContinue;

  /// Label tombol saat persetujuan disimpan
  ///
  /// In id, this message translates to:
  /// **'Menyimpan...'**
  String get authSaving;

  /// Tombol keluar dari akun pada sheet persetujuan
  ///
  /// In id, this message translates to:
  /// **'Keluar dulu'**
  String get authExit;

  /// Pesan gagal menyimpan persetujuan legal
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan persetujuan. Coba lagi ya.'**
  String get authConsentSaveFailed;

  /// Label aksesibilitas tombol Google
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get authSignInWithGoogle;

  /// Label aksesibilitas tombol GitHub
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan GitHub'**
  String get authSignInWithGithub;

  /// Konfigurasi Google Sign-In di perangkat belum lengkap
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google belum siap di perangkat ini. Coba lagi dalam beberapa saat.'**
  String get authGoogleUnavailable;

  /// Kegagalan umum Google Sign-In
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa masuk dengan Google. Coba lagi.'**
  String get authGoogleFailed;

  /// Kegagalan umum Facebook Sign-In
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa masuk dengan Facebook. Coba lagi.'**
  String get authFacebookFailed;

  /// Konfigurasi GitHub OAuth belum lengkap
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan GitHub belum siap di perangkat ini. Coba lagi dalam beberapa saat.'**
  String get authGithubUnavailable;

  /// Kegagalan umum GitHub Sign-In
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa masuk dengan GitHub. Coba lagi.'**
  String get authGithubFailed;

  /// Judul dokumen syarat dan ketentuan
  ///
  /// In id, this message translates to:
  /// **'Syarat dan Ketentuan'**
  String get authTermsTitle;

  /// Judul dokumen kebijakan privasi
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get authPrivacyTitle;

  /// Pesan cadangan saat pendaftaran gagal tanpa pesan server
  ///
  /// In id, this message translates to:
  /// **'Registrasi gagal'**
  String get authRegisterFailed;

  /// Pesan cadangan saat masuk gagal tanpa pesan server
  ///
  /// In id, this message translates to:
  /// **'Login gagal'**
  String get authLoginFailed;

  /// Pesan cadangan saat verifikasi email gagal tanpa pesan server
  ///
  /// In id, this message translates to:
  /// **'Verifikasi gagal'**
  String get authVerifyFailed;

  /// Pesan cadangan setelah reset password tanpa pesan server
  ///
  /// In id, this message translates to:
  /// **'Password berhasil direset'**
  String get authResetDone;

  /// Pesan saat tidak ada koneksi ke API
  ///
  /// In id, this message translates to:
  /// **'Gagal terhubung ke server. Coba lagi dalam beberapa saat.'**
  String get authServerUnreachable;

  /// Konfigurasi Facebook Sign-In belum lengkap
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Facebook belum siap di perangkat ini.'**
  String get authFacebookUnavailable;

  /// Chip kategori feed: semua aktivitas
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get feedCategoryAll;

  /// Chip kategori feed: pencarian tanpa hasil
  ///
  /// In id, this message translates to:
  /// **'Pencarian warga'**
  String get feedCategorySearchMiss;

  /// Chip kategori feed: perbaikan kata
  ///
  /// In id, this message translates to:
  /// **'Perbaikan'**
  String get feedCategoryCorrection;

  /// Chip kategori feed: tempat dan kuliner
  ///
  /// In id, this message translates to:
  /// **'Eksplorasi'**
  String get feedCategoryExplore;

  /// Chip kategori feed: pengumuman admin
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get feedCategoryAnnouncement;

  /// Chip kategori feed: warga baru bergabung
  ///
  /// In id, this message translates to:
  /// **'Warga'**
  String get feedCategoryJoined;

  /// Label jenis aktivitas: kata
  ///
  /// In id, this message translates to:
  /// **'Kata'**
  String get feedKindWord;

  /// Label jenis aktivitas: komentar
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get feedKindComment;

  /// Label jenis aktivitas: vote
  ///
  /// In id, this message translates to:
  /// **'Penilaian'**
  String get feedKindVote;

  /// Label jenis aktivitas: diskusi
  ///
  /// In id, this message translates to:
  /// **'Diskusi'**
  String get feedKindDiscussion;

  /// Label jenis aktivitas: foto kata
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get feedKindImage;

  /// Label jenis aktivitas: rekaman suara
  ///
  /// In id, this message translates to:
  /// **'Suara'**
  String get feedKindAudio;

  /// Label jenis aktivitas: cara baca
  ///
  /// In id, this message translates to:
  /// **'Cara baca'**
  String get feedKindPronunciation;

  /// Label jenis aktivitas: contoh kalimat
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get feedKindExample;

  /// Label jenis aktivitas: pencarian tanpa hasil
  ///
  /// In id, this message translates to:
  /// **'Kata tidak ditemukan'**
  String get feedKindSearchMiss;

  /// Label jenis aktivitas: warga bergabung
  ///
  /// In id, this message translates to:
  /// **'Bergabung'**
  String get feedKindWelcome;

  /// Label jenis aktivitas: bagikan kartu kata
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get feedKindShare;

  /// Label jenis aktivitas: usulan edit
  ///
  /// In id, this message translates to:
  /// **'Usulan'**
  String get feedKindSuggestion;

  /// Label jenis aktivitas: usulan kata baru
  ///
  /// In id, this message translates to:
  /// **'Usulan kata baru'**
  String get feedKindContribution;

  /// Label jenis aktivitas: verifikasi kata
  ///
  /// In id, this message translates to:
  /// **'Verifikasi'**
  String get feedKindVerification;

  /// Label jenis aktivitas: pengumuman
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get feedKindAnnouncement;

  /// Label jenis aktivitas: foto tempat wisata
  ///
  /// In id, this message translates to:
  /// **'Foto wisata'**
  String get feedKindPlacePhoto;

  /// Label jenis aktivitas: tempat wisata terbit
  ///
  /// In id, this message translates to:
  /// **'Wisata'**
  String get feedKindPlace;

  /// Label jenis aktivitas: acara terbit
  ///
  /// In id, this message translates to:
  /// **'Acara'**
  String get feedKindEvent;

  /// Label jenis aktivitas: usaha terbit
  ///
  /// In id, this message translates to:
  /// **'Usaha'**
  String get feedKindUsaha;

  /// Label jenis aktivitas: kuliner terbit
  ///
  /// In id, this message translates to:
  /// **'Kuliner'**
  String get feedKindCulinary;

  /// Ajakan membuka sesi tinjau usulan
  ///
  /// In id, this message translates to:
  /// **'Tinjau usulan'**
  String get feedCtaReview;

  /// Ajakan ikut vote
  ///
  /// In id, this message translates to:
  /// **'Ikut menilai'**
  String get feedCtaVote;

  /// Ajakan membuka detail kata
  ///
  /// In id, this message translates to:
  /// **'Lihat arti'**
  String get feedCtaSeeMeaning;

  /// Ajakan membalas komentar
  ///
  /// In id, this message translates to:
  /// **'Balas'**
  String get feedCtaReply;

  /// Ajakan membuka diskusi
  ///
  /// In id, this message translates to:
  /// **'Ikut diskusi'**
  String get feedCtaDiscuss;

  /// Ajakan membuka foto
  ///
  /// In id, this message translates to:
  /// **'Lihat foto'**
  String get feedCtaSeePhoto;

  /// Ajakan memutar audio
  ///
  /// In id, this message translates to:
  /// **'Dengarkan'**
  String get feedCtaListen;

  /// Ajakan membuka cara baca
  ///
  /// In id, this message translates to:
  /// **'Lihat cara baca'**
  String get feedCtaSeePronunciation;

  /// Ajakan membuka contoh kalimat
  ///
  /// In id, this message translates to:
  /// **'Lihat contoh'**
  String get feedCtaSeeExample;

  /// Ajakan mengisi kata yang belum ada
  ///
  /// In id, this message translates to:
  /// **'Bantu isi'**
  String get feedCtaHelpFill;

  /// Ajakan membuka profil
  ///
  /// In id, this message translates to:
  /// **'Lihat profil'**
  String get feedCtaSeeProfile;

  /// Ajakan membuka kartu kata
  ///
  /// In id, this message translates to:
  /// **'Lihat kartu'**
  String get feedCtaSeeCard;

  /// Ajakan membuka usulan
  ///
  /// In id, this message translates to:
  /// **'Lihat usulan'**
  String get feedCtaSeeSuggestion;

  /// Ajakan membuka kata
  ///
  /// In id, this message translates to:
  /// **'Lihat kata'**
  String get feedCtaSeeWord;

  /// Ajakan membuka pengumuman
  ///
  /// In id, this message translates to:
  /// **'Baca pengumuman'**
  String get feedCtaReadAnnouncement;

  /// Ajakan membuka tempat
  ///
  /// In id, this message translates to:
  /// **'Lihat tempat'**
  String get feedCtaSeePlace;

  /// Ajakan membuka acara
  ///
  /// In id, this message translates to:
  /// **'Lihat acara'**
  String get feedCtaSeeEvent;

  /// Ajakan membuka usaha
  ///
  /// In id, this message translates to:
  /// **'Lihat usaha'**
  String get feedCtaSeeUsaha;

  /// Ajakan membuka kuliner
  ///
  /// In id, this message translates to:
  /// **'Lihat kuliner'**
  String get feedCtaSeeCulinary;

  /// Sebutan aktor saat data aktor tidak ada
  ///
  /// In id, this message translates to:
  /// **'Warga'**
  String get feedActorFallback;

  /// Toast saat kata usulan belum ditinjau
  ///
  /// In id, this message translates to:
  /// **'Kata ini masih menunggu tinjauan verifikator'**
  String get feedPendingToast;

  /// Pesan gagal memuat feed
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat aktivitas.'**
  String get feedLoadFailed;

  /// Judul halaman pengumuman
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get announcementTitle;

  /// Pesan pengumuman sudah dihapus
  ///
  /// In id, this message translates to:
  /// **'Pengumuman tidak lagi tersedia.'**
  String get announcementGone;

  /// Judul halaman pengumuman yang dipin
  ///
  /// In id, this message translates to:
  /// **'Pengumuman Prioritas'**
  String get announcementPinnedTitle;

  /// Kondisi kosong halaman pengumuman prioritas
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengumuman yang dipin'**
  String get announcementPinnedEmpty;

  /// Pesan gagal memuat pengumuman prioritas
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat pengumuman'**
  String get announcementPinnedLoadFailed;

  /// Badge pengumuman yang dipin
  ///
  /// In id, this message translates to:
  /// **'Dipin'**
  String get announcementPinnedBadge;

  /// Badge pengumuman kedaluwarsa
  ///
  /// In id, this message translates to:
  /// **'Berakhir'**
  String get announcementExpiredBadge;

  /// Catatan pengumuman kedaluwarsa
  ///
  /// In id, this message translates to:
  /// **'Pengumuman ini sudah berakhir, tapi tetap bisa dibaca.'**
  String get announcementExpiredNote;

  /// Tombol membuka tautan pengumuman
  ///
  /// In id, this message translates to:
  /// **'Buka tautan'**
  String get announcementOpenLink;

  /// Label aksesibilitas kartu pengumuman
  ///
  /// In id, this message translates to:
  /// **'Pengumuman: {title}'**
  String announcementSemantics(String title);

  /// Label aksesibilitas kartu pengumuman kedaluwarsa
  ///
  /// In id, this message translates to:
  /// **'Pengumuman: {title}, sudah berakhir'**
  String announcementSemanticsExpired(String title);

  /// Keterangan tautan pengumuman yang dibuka di dalam aplikasi
  ///
  /// In id, this message translates to:
  /// **'{host} · buka di aplikasi'**
  String announcementInAppHost(String host);

  /// Teks skeleton judul pengumuman
  ///
  /// In id, this message translates to:
  /// **'Judul Pengumuman'**
  String get announcementSkeletonTitle;

  /// Teks skeleton isi pengumuman
  ///
  /// In id, this message translates to:
  /// **'Isi pengumuman singkat untuk skeleton'**
  String get announcementSkeletonBody;

  /// Label aksesibilitas banner pengumuman
  ///
  /// In id, this message translates to:
  /// **'Judul pengumuman prioritas'**
  String get announcementBannerSemantics;

  /// Teks skeleton cuplikan pengumuman
  ///
  /// In id, this message translates to:
  /// **'cuplikan isi pengumuman'**
  String get announcementBannerPreview;

  /// Judul menu kontribusi di tab aktivitas
  ///
  /// In id, this message translates to:
  /// **'Menu kontribusi'**
  String get feedContributeMenu;

  /// Item menu usul kata baru
  ///
  /// In id, this message translates to:
  /// **'Usul kata baru'**
  String get feedContributeNewWord;

  /// Keterangan item usul kata baru
  ///
  /// In id, this message translates to:
  /// **'Kata Sambas belum ada di kamus? Tambahkan sendiri'**
  String get feedContributeNewWordSubtitle;

  /// Item menu daftar pencarian tanpa hasil
  ///
  /// In id, this message translates to:
  /// **'Dicari warga'**
  String get feedContributeSearchMiss;

  /// Keterangan item daftar pencarian tanpa hasil
  ///
  /// In id, this message translates to:
  /// **'Kata yang dicari warga tapi belum ketemu. Bantu isi artinya'**
  String get feedContributeSearchMissSubtitle;

  /// Item menu diskusi
  ///
  /// In id, this message translates to:
  /// **'Ruang diskusi'**
  String get feedContributeDiscussion;

  /// Keterangan item menu diskusi
  ///
  /// In id, this message translates to:
  /// **'Tanya arti atau bahas kata Sambas bareng warga'**
  String get feedContributeDiscussionSubtitle;

  /// Ajakan pada kartu vote
  ///
  /// In id, this message translates to:
  /// **'Bantu nilai agar arti kata lebih akurat'**
  String get feedVoteDeckHint;

  /// Judul panduan gestur kartu vote
  ///
  /// In id, this message translates to:
  /// **'Kartu bisa digeser untuk menilai'**
  String get feedGuideTitle;

  /// Isi panduan gestur kartu vote
  ///
  /// In id, this message translates to:
  /// **'Gunakan jari untuk menggeser kartu kata:\n• Geser kanan → \"Sudah pas\" (arti sudah benar)\n• Geser kiri → \"Perlu dicek ulang\" (arti kurang tepat)\n• Geser ke atas → \"Lewati\" (ragu / belum yakin)'**
  String get feedGuideBody;

  /// Label aksesibilitas latar panduan kontribusi
  ///
  /// In id, this message translates to:
  /// **'Panduan kontribusi'**
  String get feedGuideBarrier;

  /// Chip filter aktivitas profil publik: semua
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get profileActivityFilterAll;

  /// Chip filter aktivitas profil publik: perbaikan
  ///
  /// In id, this message translates to:
  /// **'Perbaikan'**
  String get profileActivityFilterCorrection;

  /// Chip filter aktivitas profil publik: komentar
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get profileActivityFilterComment;

  /// Kondisi kosong aktivitas profil publik
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas publik.'**
  String get profileActivityEmpty;

  /// Kondisi kosong aktivitas profil publik per filter
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas {filter}.'**
  String profileActivityEmptyFiltered(String filter);

  /// Pesan gagal memuat aktivitas profil publik
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat aktivitas'**
  String get profileActivityLoadFailed;

  /// Judul bagian aktivitas terbaru
  ///
  /// In id, this message translates to:
  /// **'Aktivitas terbaru'**
  String get profileActivityRecent;

  /// Judul halaman potong foto profil
  ///
  /// In id, this message translates to:
  /// **'Atur foto profil'**
  String get profileCropTitle;

  /// Tombol memakai hasil potong foto
  ///
  /// In id, this message translates to:
  /// **'Pakai'**
  String get profileCropUse;

  /// Pesan gagal unggah foto profil
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunggah foto profil'**
  String get profilePhotoUploadFailed;

  /// Pesan gagal hapus foto profil
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus foto profil'**
  String get profilePhotoDeleteFailed;

  /// Pesan gagal membuka pemotong foto
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka pemotong foto'**
  String get profilePhotoPickerFailed;

  /// Toast setelah foto profil berhasil diganti
  ///
  /// In id, this message translates to:
  /// **'Foto profil diperbarui'**
  String get profilePhotoUpdated;

  /// Aksi mengganti foto profil
  ///
  /// In id, this message translates to:
  /// **'Ganti foto profil'**
  String get profileChangePhoto;

  /// Aksi mengubah bingkai foto profil
  ///
  /// In id, this message translates to:
  /// **'Ubah bingkai profil'**
  String get profileChangeFrame;

  /// Toast saat izin notifikasi diberikan
  ///
  /// In id, this message translates to:
  /// **'Notifikasi diizinkan'**
  String get profileAllowNotifGranted;

  /// Toast saat izin notifikasi ditolak
  ///
  /// In id, this message translates to:
  /// **'Notifikasi belum diizinkan'**
  String get profileAllowNotifPending;

  /// Judul sheet izin notifikasi dimatikan
  ///
  /// In id, this message translates to:
  /// **'Notifikasi dimatikan'**
  String get profileAllowNotifOffTitle;

  /// Penjelasan cara mengaktifkan notifikasi dari pengaturan perangkat
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi SambasKu di Pengaturan perangkat agar kabar usulan tetap sampai.'**
  String get profileAllowNotifOffBody;

  /// Tombol membuka pengaturan perangkat
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get profileOpenSettings;

  /// Judul halaman edit profil
  ///
  /// In id, this message translates to:
  /// **'Edit profil'**
  String get profileEditTitle;

  /// Label kolom username
  ///
  /// In id, this message translates to:
  /// **'Username'**
  String get profileUsernameLabel;

  /// Aturan penulisan username
  ///
  /// In id, this message translates to:
  /// **'a-z, 0-9, titik, underscore (3-30 karakter)'**
  String get profileUsernameHint;

  /// Label kolom nama tampilan
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan'**
  String get profileDisplayNameLabel;

  /// Penjelasan kolom nama tampilan
  ///
  /// In id, this message translates to:
  /// **'Nama yang tampil di profil publik'**
  String get profileDisplayNameHint;

  /// Label kolom bio
  ///
  /// In id, this message translates to:
  /// **'Bio'**
  String get profileBioLabel;

  /// Penjelasan kolom bio
  ///
  /// In id, this message translates to:
  /// **'Ceritakan singkat tentangmu (opsional)'**
  String get profileBioHint;

  /// Label pilihan kecamatan
  ///
  /// In id, this message translates to:
  /// **'Kecamatan'**
  String get profileDistrictLabel;

  /// Label pilihan desa
  ///
  /// In id, this message translates to:
  /// **'Desa'**
  String get profileVillageLabel;

  /// Status saat wilayah sedang dimuat
  ///
  /// In id, this message translates to:
  /// **'Memuat wilayah...'**
  String get profileRegionLoading;

  /// Status saat wilayah gagal dimuat
  ///
  /// In id, this message translates to:
  /// **'Wilayah belum termuat'**
  String get profileRegionNotLoaded;

  /// Placeholder saat data profil kosong
  ///
  /// In id, this message translates to:
  /// **'Tidak diisi'**
  String get profileNotFilled;

  /// Pesan sukses menyimpan profil
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil disimpan.'**
  String get profileSaveSuccess;

  /// Judul halaman profil publik
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileViewTitle;

  /// Tombol menuju edit profil
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get profileEditAction;

  /// Pesan profil pengguna tidak ada
  ///
  /// In id, this message translates to:
  /// **'Pengguna tidak ditemukan'**
  String get profileUserNotFound;

  /// Pesan gagal memuat profil publik
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat profil'**
  String get profileLoadFailed;

  /// Judul halaman ubah password
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get passwordChangeTitle;

  /// Toast setelah password diubah
  ///
  /// In id, this message translates to:
  /// **'Password berhasil diubah'**
  String get passwordChangeSuccess;

  /// Tombol menuju halaman masuk setelah sesi berakhir
  ///
  /// In id, this message translates to:
  /// **'Login ulang'**
  String get passwordRelogin;

  /// Label kolom password lama
  ///
  /// In id, this message translates to:
  /// **'Password Lama'**
  String get passwordOldLabel;

  /// Label kolom password baru
  ///
  /// In id, this message translates to:
  /// **'Password Baru'**
  String get passwordNewLabel;

  /// Label kolom konfirmasi password baru
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password Baru'**
  String get passwordConfirmNewLabel;

  /// Tombol menyimpan password
  ///
  /// In id, this message translates to:
  /// **'Simpan Password'**
  String get passwordSave;

  /// Catatan konsekuensi mengganti password
  ///
  /// In id, this message translates to:
  /// **'Setelah password diganti, semua sesi (termasuk yang ini) diakhiri dan kamu diminta login ulang dengan password baru.'**
  String get passwordChangeNote;

  /// Judul halaman buat password
  ///
  /// In id, this message translates to:
  /// **'Buat Password'**
  String get passwordCreateTitle;

  /// Judul sheet setelah password dibuat
  ///
  /// In id, this message translates to:
  /// **'Password dibuat'**
  String get passwordCreated;

  /// Penjelasan cara masuk setelah password dibuat
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan {provider} dan password baru.'**
  String passwordCreatedBody(String provider);

  /// Penjelasan sebelum membuat password
  ///
  /// In id, this message translates to:
  /// **'Username kamu: {username}. Setelah password tersimpan, masuk manual menggunakan username atau email yang ditampilkan.'**
  String passwordCreateHint(String username);

  /// Judul bagian verifikasi akun
  ///
  /// In id, this message translates to:
  /// **'Buktikan akun'**
  String get passwordVerifyAccount;

  /// Pesan provider masuk tidak dikenal
  ///
  /// In id, this message translates to:
  /// **'Provider tidak dikenal.'**
  String get passwordProviderUnknown;

  /// Pesan provider masuk belum dikonfigurasi
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan {provider} belum siap di perangkat ini.'**
  String passwordProviderNotReady(String provider);

  /// Kata yang harus diketik untuk konfirmasi hapus akun
  ///
  /// In id, this message translates to:
  /// **'HAPUS'**
  String get deleteAccountConfirmWord;

  /// Judul halaman hapus akun
  ///
  /// In id, this message translates to:
  /// **'Hapus akun'**
  String get deleteAccountTitle;

  /// Penjelasan data yang dihapus saat hapus akun
  ///
  /// In id, this message translates to:
  /// **'Nama, email, nomor HP, kata sandi, foto profil, sesi, dan token notifikasi akan kami hapus. Kata yang sudah tayang tetap ada, tapi tanpa namamu.'**
  String get deleteAccountBody;

  /// Label kolom kata sandi pada hapus akun
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get deleteAccountPasswordLabel;

  /// Petunjuk kolom kata sandi hapus akun
  ///
  /// In id, this message translates to:
  /// **'Kosongkan jika akun masuk lewat Google'**
  String get deleteAccountPasswordHint;

  /// Label kolom konfirmasi hapus akun
  ///
  /// In id, this message translates to:
  /// **'Ketik HAPUS'**
  String get deleteAccountTypeToConfirm;

  /// Label tombol saat akun sedang dihapus
  ///
  /// In id, this message translates to:
  /// **'Menghapus...'**
  String get deleteAccountDeleting;

  /// Judul sheet setelah akun dihapus
  ///
  /// In id, this message translates to:
  /// **'Akun dihapus'**
  String get deleteAccountDone;

  /// Judul halaman akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Akun Terhubung'**
  String get linkedAccountsTitle;

  /// Judul bagian akun masuk
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan'**
  String get linkedAccountsSignInWith;

  /// Judul konfirmasi melepas akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Lepas {provider}?'**
  String linkedAccountsUnlinkTitle(String provider);

  /// Penjelasan setelah melepas akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Kamu tetap bisa masuk dengan email dan password atau provider lain.'**
  String get linkedAccountsUnlinkBody;

  /// Tombol melepas akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Lepas'**
  String get linkedAccountsUnlink;

  /// Keterangan tanggal akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Terhubung sejak {date}'**
  String linkedAccountsLinkedSince(String date);

  /// Keterangan akun terhubung siap dipakai
  ///
  /// In id, this message translates to:
  /// **'Terhubung - bisa dipakai untuk masuk'**
  String get linkedAccountsLinkedHint;

  /// Keterangan akun belum terhubung
  ///
  /// In id, this message translates to:
  /// **'Belum terhubung'**
  String get linkedAccountsNotLinked;

  /// Keterangan status akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Terhubung'**
  String get linkedAccountsLinked;

  /// Pesan sukses menambah akun terhubung
  ///
  /// In id, this message translates to:
  /// **'Berhasil ditambahkan ke akun terhubung.'**
  String get linkedAccountsAdded;

  /// Judul halaman notifikasi
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notificationTitle;

  /// Ajakan masuk untuk melihat notifikasi
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melihat notifikasi'**
  String get notificationLoginRequired;

  /// Pesan gagal memuat notifikasi
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat notifikasi'**
  String get notificationLoadFailed;

  /// Kondisi kosong daftar notifikasi
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi'**
  String get notificationEmpty;

  /// Penjelasan kondisi kosong notifikasi
  ///
  /// In id, this message translates to:
  /// **'Status usulan yang sudah direview akan muncul di sini.'**
  String get notificationEmptyBody;

  /// Label tombol saat menandai notifikasi
  ///
  /// In id, this message translates to:
  /// **'Menandai...'**
  String get notificationMarking;

  /// Tombol menandai semua notifikasi dibaca
  ///
  /// In id, this message translates to:
  /// **'Tandai semua telah dibaca'**
  String get notificationMarkAllRead;

  /// Aksi membuka gambar notifikasi
  ///
  /// In id, this message translates to:
  /// **'Lihat gambar'**
  String get notificationViewImage;

  /// Petunjuk gambar bisa diketuk
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk melihat gambar'**
  String get notificationTapImage;

  /// Tombol membuka tautan notifikasi
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get notificationOpen;

  /// Aksi menyalin tautan notifikasi
  ///
  /// In id, this message translates to:
  /// **'Salin tautan'**
  String get notificationCopyLink;

  /// Toast setelah tautan disalin
  ///
  /// In id, this message translates to:
  /// **'Tautan disalin'**
  String get notificationLinkCopied;

  /// Pesan pengumuman pada notifikasi tidak ada
  ///
  /// In id, this message translates to:
  /// **'Pengumuman tidak ditemukan'**
  String get notificationAnnouncementMissing;

  /// Judul halaman komentar saya
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get myCommentsTitle;

  /// Ajakan masuk untuk melihat komentar
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melihat komentar kamu'**
  String get myCommentsLoginRequired;

  /// Pesan gagal memuat komentar
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat komentar'**
  String get myCommentsLoadFailed;

  /// Kondisi kosong komentar
  ///
  /// In id, this message translates to:
  /// **'Belum ada komentar'**
  String get myCommentsEmpty;

  /// Kondisi kosong komentar per filter
  ///
  /// In id, this message translates to:
  /// **'Tidak ada komentar dengan status ini'**
  String get myCommentsEmptyFiltered;

  /// Judul halaman kontribusi saya
  ///
  /// In id, this message translates to:
  /// **'Kontribusi Saya'**
  String get myContributionsTitle;

  /// Ajakan masuk untuk melihat usulan
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melihat usulanmu'**
  String get myContributionsLoginRequired;

  /// Pesan gagal memuat kontribusi
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kontribusi'**
  String get myContributionsLoadFailed;

  /// Kondisi kosong daftar usulan
  ///
  /// In id, this message translates to:
  /// **'Belum ada usulan'**
  String get myContributionsEmpty;

  /// Penjelasan kondisi kosong usulan
  ///
  /// In id, this message translates to:
  /// **'Usul kata baru atau perubahan akan muncul di sini.'**
  String get myContributionsEmptyBody;

  /// Status usulan menunggu pengecekan
  ///
  /// In id, this message translates to:
  /// **'Menunggu pengecekan'**
  String get myContributionPending;

  /// Pesan usulan tidak ditemukan
  ///
  /// In id, this message translates to:
  /// **'Usulan tidak ditemukan'**
  String get myContributionNotFound;

  /// Tombol membuka kata dari usulan
  ///
  /// In id, this message translates to:
  /// **'Buka kata'**
  String get myContributionOpenWord;

  /// Label baris status usulan
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get myContributionStatus;

  /// Label baris jenis usulan
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get myContributionKind;

  /// Label waktu usulan dikirim
  ///
  /// In id, this message translates to:
  /// **'Dikirim'**
  String get myContributionSubmitted;

  /// Label waktu usulan ditinjau
  ///
  /// In id, this message translates to:
  /// **'Ditinjau'**
  String get myContributionReviewed;

  /// Label baris aksi usulan
  ///
  /// In id, this message translates to:
  /// **'Aksi'**
  String get myContributionAction;

  /// Label baris kode alasan
  ///
  /// In id, this message translates to:
  /// **'Kode alasan'**
  String get myContributionReasonCode;

  /// Label baris alasan perubahan
  ///
  /// In id, this message translates to:
  /// **'Alasan perubahan'**
  String get myContributionChangeReason;

  /// Label baris catatan peninjau
  ///
  /// In id, this message translates to:
  /// **'Catatan reviewer'**
  String get myContributionReviewerNote;

  /// Teks skeleton lemma usulan
  ///
  /// In id, this message translates to:
  /// **'lemma contoh usulan'**
  String get myContributionsSkeletonLemma;

  /// Teks skeleton meta usulan
  ///
  /// In id, this message translates to:
  /// **'Usul kata baru · Menunggu pengecekan · 21 Sep 2026 00:00'**
  String get myContributionsSkeletonMeta;

  /// Judul halaman vote saya
  ///
  /// In id, this message translates to:
  /// **'Vote'**
  String get myVotesTitle;

  /// Ajakan masuk untuk melihat vote
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melihat vote kamu'**
  String get myVotesLoginRequired;

  /// Pesan gagal memuat vote
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat vote'**
  String get myVotesLoadFailed;

  /// Kondisi kosong daftar vote
  ///
  /// In id, this message translates to:
  /// **'Belum ada vote'**
  String get myVotesEmpty;

  /// Teks skeleton meta vote
  ///
  /// In id, this message translates to:
  /// **'Upvote · Kata · 21 Sep 2026 10:00'**
  String get myVotesSkeletonMeta;

  /// Judul halaman kata tersimpan
  ///
  /// In id, this message translates to:
  /// **'Bookmark'**
  String get bookmarkTitle;

  /// Ajakan masuk untuk melihat kata tersimpan
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk melihat kata tersimpan'**
  String get bookmarkLoginRequired;

  /// Pesan gagal memuat bookmark
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat bookmark'**
  String get bookmarkLoadFailed;

  /// Kondisi kosong kata tersimpan
  ///
  /// In id, this message translates to:
  /// **'Belum ada kata tersimpan.'**
  String get bookmarkEmpty;

  /// Petunjuk cara menyimpan kata
  ///
  /// In id, this message translates to:
  /// **'Tekan ikon bookmark di halaman detail kata.'**
  String get bookmarkEmptyHint;

  /// Keterangan entri kata sudah tidak ada
  ///
  /// In id, this message translates to:
  /// **'Entri tidak lagi tersedia'**
  String get bookmarkEntryGone;

  /// Aksi melepas kata dari bookmark
  ///
  /// In id, this message translates to:
  /// **'Lepas kata dari bookmark'**
  String get bookmarkRemove;

  /// Aksi menyimpan kata ke bookmark
  ///
  /// In id, this message translates to:
  /// **'Simpan kata ke bookmark'**
  String get bookmarkAdd;

  /// Tombol masuk singkat di layar yang butuh akun
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get commonLoginRequiredShort;

  /// Teks skeleton lemma
  ///
  /// In id, this message translates to:
  /// **'lemma contoh'**
  String get commonSkeletonLemma;

  /// Nama provider masuk Google
  ///
  /// In id, this message translates to:
  /// **'Google'**
  String get providerGoogle;

  /// Nama provider masuk Facebook
  ///
  /// In id, this message translates to:
  /// **'Facebook'**
  String get providerFacebook;

  /// Nama provider masuk GitHub
  ///
  /// In id, this message translates to:
  /// **'GitHub'**
  String get providerGithub;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Disetujui'**
  String get notificationTypeApproved;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get notificationTypeRejected;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Dikoreksi'**
  String get notificationTypeCorrected;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Ditarik'**
  String get notificationTypeTakenDown;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Diskusi menunggu'**
  String get notificationTypeDiscussionPending;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Diskusi disetujui'**
  String get notificationTypeDiscussionApproved;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Diskusi ditolak'**
  String get notificationTypeDiscussionRejected;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Diskusi diturunkan'**
  String get notificationTypeDiscussionTakenDown;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Balasan diskusi'**
  String get notificationTypeDiscussionReply;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Sebutan diskusi'**
  String get notificationTypeDiscussionMention;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Balasan pantun'**
  String get notificationTypePantunReply;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Sebutan pantun'**
  String get notificationTypePantunMention;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get notificationTypeCampaign;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get notificationTypeComment;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Vote'**
  String get notificationTypeVote;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get notificationTypeExample;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Pelafalan'**
  String get notificationTypeAudio;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Wisata disetujui'**
  String get notificationTypePlaceApproved;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Wisata ditolak'**
  String get notificationTypePlaceRejected;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Acara disetujui'**
  String get notificationTypeEventApproved;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Acara ditolak'**
  String get notificationTypeEventRejected;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Acara perlu revisi'**
  String get notificationTypeEventNeedsRevision;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Pembaruan'**
  String get notificationTypeUpdate;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usulan disetujui contoh'**
  String get notificationSkeletonTitle;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Disetujui · 21 Sep 2026 00:00 · Usulan kata Anda'**
  String get notificationSkeletonMeta;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Tayang · cuplikan · 21 Sep 2026'**
  String get myCommentsSkeletonMeta;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Kata tidak tersedia'**
  String get myCommentsWordGone;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get myCommentsFilterAll;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Tayang'**
  String get myCommentsFilterPublished;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Diturunkan'**
  String get myCommentsFilterTakenDown;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Dihapus'**
  String get myCommentsFilterDeleted;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul makna'**
  String get mySubmissionKindMeaning;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul pengucapan'**
  String get mySubmissionKindPronunciation;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul gambar'**
  String get mySubmissionKindImage;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul audio'**
  String get mySubmissionKindAudio;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul contoh'**
  String get mySubmissionKindExample;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul perubahan'**
  String get mySubmissionKindChange;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Usul kata baru'**
  String get mySubmissionKindNewWord;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Kata'**
  String get myVoteTargetWord;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Arti'**
  String get myVoteTargetMeaning;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get myVoteTargetExample;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Pelafalan'**
  String get myVoteTargetPronunciation;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get myVoteTargetImage;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get myVoteTargetComment;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Balasan diskusi'**
  String get myVoteTargetDiscussionReply;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan diskusi'**
  String get myVoteTargetDiscussion;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Pantun'**
  String get myVoteTargetPantun;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Balasan pantun'**
  String get myVoteTargetPantunReply;

  /// Label UI M3 (notification/komentar/usulan/vote)
  ///
  /// In id, this message translates to:
  /// **'Kata sudah dihapus'**
  String get myVoteWordGone;

  /// Pesan error data layer M3
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat jumlah notifikasi'**
  String get notificationUnreadCountFailed;

  /// Pesan error data layer M3
  ///
  /// In id, this message translates to:
  /// **'Gagal menandai notifikasi'**
  String get notificationMarkReadFailed;

  /// Pesan error data layer M3
  ///
  /// In id, this message translates to:
  /// **'Gagal menandai semua notifikasi'**
  String get notificationMarkAllReadFailed;

  /// Pesan error data layer M3
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat detail usulan'**
  String get myContributionDetailLoadFailed;

  /// Pesan error generik M3
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah bookmark'**
  String get bookmarkToggleFailed;

  /// Pesan error generik M3
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat status bookmark'**
  String get bookmarkStatusLoadFailed;

  /// Pesan error generik M3
  ///
  /// In id, this message translates to:
  /// **'Kata tidak ditemukan atau sudah dihapus'**
  String get bookmarkWordGone;

  /// Pesan error generik M3
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak permintaan. Coba lagi dalam beberapa saat.'**
  String get commonRateLimited;

  /// Pesan error generik M3
  ///
  /// In id, this message translates to:
  /// **'Sesi berakhir, silakan masuk kembali'**
  String get commonSessionExpired;

  /// Pesan error generik M3
  ///
  /// In id, this message translates to:
  /// **'Server sedang gangguan. Coba lagi dalam beberapa saat.'**
  String get commonServerError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'id':
      {
        switch (locale.countryCode) {
          case 'SBS':
            return AppLocalizationsIdSbs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
