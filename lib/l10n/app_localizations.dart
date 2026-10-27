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
