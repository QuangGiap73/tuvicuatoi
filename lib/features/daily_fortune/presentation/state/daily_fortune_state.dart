import '../../domain/daily_fortune.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../../horoscope/domain/saved_chart_detail.dart';

enum DailyFortunePhase { idle, loading, ready, empty, failure }

class DailyFortuneState {
  const DailyFortuneState({
    required this.selectedDate,
    this.phase = DailyFortunePhase.idle,
    this.fortune,
    this.errorMessage,
    this.charts = const [],
    this.selectedChart,
    this.selectedChartDetail,
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
  final SavedChartDetail? selectedChartDetail;
  final bool isChartsLoading;
  final bool isReadingLoading;
  final String? readingErrorMessage;

  bool get isLoading => phase == DailyFortunePhase.loading;

  DailyFortuneState copyWith({
    DateTime? selectedDate,
    DailyFortunePhase? phase,
    DailyFortune? fortune,
    String? errorMessage,
    bool clearFortune = false,
    bool clearError = false,
    List<SavedChart>? charts,
    SavedChart? selectedChart,
    SavedChartDetail? selectedChartDetail,
    bool clearSelectedChart = false,
    bool clearSelectedDetail = false,
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
    selectedChart: clearSelectedChart
        ? null
        : selectedChart ?? this.selectedChart,
    selectedChartDetail: clearSelectedChart || clearSelectedDetail
        ? null
        : selectedChartDetail ?? this.selectedChartDetail,
    isChartsLoading: isChartsLoading ?? this.isChartsLoading,
    isReadingLoading: isReadingLoading ?? this.isReadingLoading,
    readingErrorMessage: clearReadingError
        ? null
        : readingErrorMessage ?? this.readingErrorMessage,
  );
}
