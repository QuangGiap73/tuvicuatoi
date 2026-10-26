import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../horoscope/data/chart_repository.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../data/daily_fortune_repository.dart';
import '../../domain/daily_fortune.dart';
import '../../domain/daily_fortune_reading.dart';
import '../state/daily_fortune_state.dart';

class DailyFortuneController extends Notifier<DailyFortuneState> {
  CancelToken? _calendarToken, _chartToken, _readingToken;
  int _requestId = 0;
  final _calendarCache = <String, DailyFortune>{};
  final _personalCache = <String, DailyFortune>{};

  @override
  DailyFortuneState build() {
    ref.onDispose(() {
      _calendarToken?.cancel();
      _chartToken?.cancel();
      _readingToken?.cancel();
    });
    final now = DateTime.now();
    final initial = DailyFortuneState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
    Future.microtask(() {
      load();
      loadCharts();
    });
    return initial;
  }

  void selectDate(DateTime date) {
    final value = DateTime(date.year, date.month, date.day);
    if (value == state.selectedDate) return;
    _readingToken?.cancel('Ngày xem đã thay đổi');
    state = state.copyWith(
      selectedDate: value,
      phase: DailyFortunePhase.idle,
      clearFortune: true,
      clearError: true,
      isReadingLoading: false,
      clearReadingError: true,
    );
    load();
  }

  void previousDay() =>
      selectDate(state.selectedDate.subtract(const Duration(days: 1)));
  void nextDay() => selectDate(state.selectedDate.add(const Duration(days: 1)));
  void today() {
    final now = DateTime.now();
    selectDate(DateTime(now.year, now.month, now.day));
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    final date = state.selectedDate;
    final key = _dateKey(date);
    final cached = _calendarCache[key];
    if (cached != null) {
      state = state.copyWith(
        phase: DailyFortunePhase.ready,
        fortune: cached,
        clearError: true,
      );
      await _loadReading(requestId, cached);
      return;
    }
    _calendarToken?.cancel('Ngày xem đã thay đổi');
    final token = CancelToken();
    _calendarToken = token;
    state = state.copyWith(phase: DailyFortunePhase.loading, clearError: true);
    try {
      final result = await ref
          .read(dailyFortuneRepositoryProvider)
          .getForDate(date: date, cancelToken: token);
      if (token.isCancelled || requestId != _requestId) return;
      _putCache(_calendarCache, key, result);
      state = state.copyWith(
        phase: DailyFortunePhase.ready,
        fortune: result,
        clearError: true,
      );
      await _loadReading(requestId, result);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || requestId != _requestId) return;
      _setError('Không thể tải lịch Can Chi. Chạm để thử lại.');
    } on DailyFortuneException catch (error) {
      if (requestId != _requestId) return;
      _setError(error.message);
    } finally {
      if (identical(_calendarToken, token)) _calendarToken = null;
    }
  }

  Future<void> loadCharts() async {
    if (ref.read(authControllerProvider).asData?.value?.user == null) return;
    _chartToken?.cancel('Đang tải danh sách mới');
    final token = CancelToken();
    _chartToken = token;
    state = state.copyWith(isChartsLoading: true);
    try {
      final charts = await ref
          .read(chartRepositoryProvider)
          .getMyCharts(cancelToken: token);
      if (token.isCancelled) return;
      state = state.copyWith(
        charts: List.unmodifiable(charts),
        isChartsLoading: false,
      );
      if (charts.isNotEmpty) await selectChart(charts.first);
    } on ChartException catch (error) {
      if (token.isCancelled) return;
      state = state.copyWith(
        isChartsLoading: false,
        errorMessage: error.message,
      );
    }
  }

  Future<void> selectChart(SavedChart chart) async {
    if (state.selectedChart?.id == chart.id &&
        state.selectedChartDetail != null) {
      return;
    }
    _chartToken?.cancel('Đổi lá số');
    _readingToken?.cancel('Đổi lá số');
    final token = CancelToken();
    _chartToken = token;
    state = state.copyWith(
      selectedChart: chart,
      clearSelectedDetail: true,
      fortune: _calendarCache[_dateKey(state.selectedDate)] ?? state.fortune,
      isChartsLoading: true,
    );
    try {
      final detail = await ref
          .read(chartRepositoryProvider)
          .getChartDetail(chart, cancelToken: token);
      if (token.isCancelled || state.selectedChart?.id != chart.id) return;
      state = state.copyWith(
        selectedChart: detail.summary,
        selectedChartDetail: detail,
        isChartsLoading: false,
        clearError: true,
      );
      final fortune = state.fortune;
      if (fortune != null) await _loadReading(_requestId, fortune);
    } on ChartException catch (error) {
      if (token.isCancelled) return;
      state = state.copyWith(
        isChartsLoading: false,
        errorMessage: error.message,
      );
    }
  }

  Future<void> _loadReading(int requestId, DailyFortune base) async {
    final detail = state.selectedChartDetail;
    final chart = state.selectedChart;
    if (detail == null || chart == null) return;
    final key = '${chart.id}:${_dateKey(base.date)}';
    final cached = _personalCache[key];
    if (cached != null) {
      if (requestId == _requestId) {
        state = state.copyWith(fortune: cached, isReadingLoading: false);
      }
      return;
    }
    _readingToken?.cancel('Đang tải Nhật vận mới');
    final token = CancelToken();
    _readingToken = token;
    state = state.copyWith(isReadingLoading: true);
    try {
      final reading = await ref
          .read(dailyFortuneRepositoryProvider)
          .getReading(
            date: base.date,
            chartData: detail.chartData,
            cancelToken: token,
          );
      if (token.isCancelled || requestId != _requestId) return;
      final result = base.applyReading(reading);
      _putCache(_personalCache, key, result);
      state = state.copyWith(
        fortune: result,
        isReadingLoading: false,
        clearError: true,
        clearReadingError: true,
      );
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error)) {
        _useFallbackReading(base, error.response?.data?.toString());
      }
    } on DailyFortuneException catch (error) {
      _useFallbackReading(base, error.message);
    }
  }

  void _useFallbackReading(DailyFortune base, String? message) {
    final raw = state.selectedChartDetail?.chartData;
    final general = raw?['generalReading'];
    final map = general is Map
        ? Map<String, dynamic>.from(general)
        : const <String, dynamic>{};
    String? text(Object? value) {
      final result = value?.toString().trim();
      return result == null || result.isEmpty ? null : result;
    }

    final fallback = DailyFortuneReading(
      summary: text(map['currentYearFortune'] ?? raw?['aiSummary']),
      career: text(map['careerReading']),
      wealth: text(map['wealthReading']),
      love: text(map['loveReading']),
      health: text(map['healthReading']),
    );
    state = state.copyWith(
      fortune: base.applyReading(fallback),
      isReadingLoading: false,
      readingErrorMessage:
          message ?? 'Dịch vụ Nhật vận chưa trả về dữ liệu hợp lệ.',
    );
  }

  void _setError(String message) {
    state = state.copyWith(
      phase: DailyFortunePhase.failure,
      errorMessage: message,
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
  static void _putCache(
    Map<String, DailyFortune> cache,
    String key,
    DailyFortune value,
  ) {
    cache[key] = value;
    if (cache.length > 16) cache.remove(cache.keys.first);
  }
}

final dailyFortuneControllerProvider =
    NotifierProvider.autoDispose<DailyFortuneController, DailyFortuneState>(
      DailyFortuneController.new,
    );
