enum HomeStatus { ready, refreshing, failure }

class HomeState {
  const HomeState({
    required this.status,
    required this.dailyMessage,
    required this.auspiciousYear,
    this.errorMessage,
  });

  final HomeStatus status;
  final String dailyMessage;
  final int auspiciousYear;
  final String? errorMessage;

  bool get isRefreshing => status == HomeStatus.refreshing;

  HomeState copyWith({
    HomeStatus? status,
    String? dailyMessage,
    int? auspiciousYear,
    String? errorMessage,
    bool clearError = false,
  }) => HomeState(
    status: status ?? this.status,
    dailyMessage: dailyMessage ?? this.dailyMessage,
    auspiciousYear: auspiciousYear ?? this.auspiciousYear,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  factory HomeState.initial({
    required String dailyMessage,
    required int auspiciousYear,
  }) => HomeState(
    status: HomeStatus.ready,
    dailyMessage: dailyMessage,
    auspiciousYear: auspiciousYear,
  );
}
