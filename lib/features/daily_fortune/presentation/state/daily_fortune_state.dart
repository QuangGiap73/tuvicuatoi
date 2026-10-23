import '../../domain/daily_fortune.dart';

enum DailyFortunePhase { idle, loading, ready, empty, failure }

class DailyFortuneState {
  const DailyFortuneState({
    required this.selectedDate,
    this.phase = DailyFortunePhase.idle,
    this.fortune,
    this.errorMessage,
  });

  final DateTime selectedDate;
  final DailyFortunePhase phase;
  final DailyFortune? fortune;
  final String? errorMessage;

  bool get isLoading => phase == DailyFortunePhase.loading;

  DailyFortuneState copyWith({
    DateTime? selectedDate,
    DailyFortunePhase? phase,
    DailyFortune? fortune,
    String? errorMessage,
    bool clearFortune = false,
    bool clearError = false,
  }) => DailyFortuneState(
    selectedDate: selectedDate ?? this.selectedDate,
    phase: phase ?? this.phase,
    fortune: clearFortune ? null : fortune ?? this.fortune,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
