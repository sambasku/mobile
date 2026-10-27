class LinkedAccountsState {
  const LinkedAccountsState({
    this.isLoading = true,
    this.isBusy = false,
    this.googleLinked = false,
    this.githubLinked = false,
    this.googleLinkedAt,
    this.githubLinkedAt,
    this.hasPassword = true,
    this.errorCode,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isBusy;
  final bool googleLinked;
  final bool githubLinked;

  /// ISO timestamp saat provider ditautkan (dari GET /auth/providers).
  final String? googleLinkedAt;
  final String? githubLinkedAt;

  /// Default true supaya tile profil tidak melompat ke "Buat Password"
  /// sebelum GET /auth/providers selesai.
  final bool hasPassword;

  /// Kode error API (mis. RATE_LIMITED, LAST_AUTH_METHOD).
  final String? errorCode;
  final String? errorMessage;
  final String? infoMessage;

  LinkedAccountsState copyWith({
    bool? isLoading,
    bool? isBusy,
    bool? googleLinked,
    bool? githubLinked,
    String? googleLinkedAt,
    String? githubLinkedAt,
    bool? hasPassword,
    String? errorCode,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
    bool clearGoogleLinkedAt = false,
    bool clearGithubLinkedAt = false,
  }) {
    return LinkedAccountsState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      googleLinked: googleLinked ?? this.googleLinked,
      githubLinked: githubLinked ?? this.githubLinked,
      googleLinkedAt: clearGoogleLinkedAt
          ? null
          : (googleLinkedAt ?? this.googleLinkedAt),
      githubLinkedAt: clearGithubLinkedAt
          ? null
          : (githubLinkedAt ?? this.githubLinkedAt),
      hasPassword: hasPassword ?? this.hasPassword,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}

/// "12 Sep 2026" untuk "Terhubung sejak {tanggal}". Kosong bila tanggal rusak
/// (pemanggil yang memilih teks cadangan).
String formatLinkedDate(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return '';
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${date.day} ${bulan[date.month - 1]} ${date.year}';
}
