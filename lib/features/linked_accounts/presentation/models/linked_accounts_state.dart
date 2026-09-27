class LinkedAccountsState {
  const LinkedAccountsState({
    this.isLoading = true,
    this.isBusy = false,
    this.googleLinked = false,
    this.githubLinked = false,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isBusy;
  final bool googleLinked;
  final bool githubLinked;
  final String? errorMessage;
  final String? infoMessage;

  LinkedAccountsState copyWith({
    bool? isLoading,
    bool? isBusy,
    bool? googleLinked,
    bool? githubLinked,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return LinkedAccountsState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      googleLinked: googleLinked ?? this.googleLinked,
      githubLinked: githubLinked ?? this.githubLinked,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
