import '../../../horoscope/domain/saved_chart.dart';
import '../../domain/daily_fortune.dart';

enum DailyFortunePhase { idle, loading, ready, failure }

class DailyFortuneState {
  const DailyFortuneState({
    required this.selectedDate,
    this.phase = DailyFortunePhase.idle,
    this.fortune,
    this.errorMessage,
    this.charts = const [],
    this.selectedChart,
    this.selectedChartData = const {},
    this.isChartsLoading = false,
    this.isReadingLoading = false,
    this.readingErrorMessage,
  });
  final DateTime selectedDate;
  final DailyFortunePhase phase;
  final DailyFortune? fortune;
  final String? errorMessage;
  final List<SavedChart> charts;
  final SavedChart? selectedChart;
  final Map<String, dynamic> selectedChartData;
  final bool isChartsLoading;
  final bool isReadingLoading;
  final String? readingErrorMessage;
  bool get isLoading => phase == DailyFortunePhase.loading;

  DailyFortuneState copyWith({
    DateTime? selectedDate,
    DailyFortunePhase? phase,
    DailyFortune? fortune,
    bool clearFortune = false,
    String? errorMessage,
    bool clearError = false,
    List<SavedChart>? charts,
    SavedChart? selectedChart,
    Map<String, dynamic>? selectedChartData,
    bool? isChartsLoading,
    bool? isReadingLoading,
    String? readingErrorMessage,
    bool clearReadingError = false,
  }) => DailyFortuneState(
    selectedDate: selectedDate ?? this.selectedDate,
    phase: phase ?? this.phase,
    fortune: clearFortune ? null : fortune ?? this.fortune,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    charts: charts ?? this.charts,
    selectedChart: selectedChart ?? this.selectedChart,
    selectedChartData: selectedChartData ?? this.selectedChartData,
    isChartsLoading: isChartsLoading ?? this.isChartsLoading,
    isReadingLoading: isReadingLoading ?? this.isReadingLoading,
    readingErrorMessage: clearReadingError
        ? null
        : readingErrorMessage ?? this.readingErrorMessage,
  );
}
