import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../horoscope/data/chart_repository.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../data/daily_fortune_repository.dart';
import '../../domain/daily_fortune.dart';
import '../state/daily_fortune_state.dart';

class DailyFortuneController extends Notifier<DailyFortuneState> {
  CancelToken? _fortuneToken;
  CancelToken? _chartToken;
  int _session = 0;
  final _calendarCache = <String, DailyFortune>{};
  final _personalCache = <String, DailyFortune>{};

  @override
  DailyFortuneState build() {
    ref.onDispose(() {
      _fortuneToken?.cancel();
      _chartToken?.cancel();
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
    _fortuneToken?.cancel('Ngày xem đã thay đổi');
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

  Future<void> load({bool force = false}) async {
    final session = ++_session;
    final date = state.selectedDate;
    final chart = state.selectedChart;
    final chartData = state.selectedChartData;
    final personalized = chart != null && chartData.isNotEmpty;
    final key = personalized ? '${chart.id}:${_dateKey(date)}' : _dateKey(date);
    final cache = personalized ? _personalCache : _calendarCache;
    final cached = cache[key];
    if (!force && cached != null) {
      state = state.copyWith(
        phase: DailyFortunePhase.ready,
        fortune: cached,
        isReadingLoading: false,
        clearError: true,
        clearReadingError: true,
      );
      return;
    }
    _fortuneToken?.cancel('Tải dữ liệu vận hạn mới');
    final token = CancelToken();
    _fortuneToken = token;
    final hasData = state.fortune != null;
    state = state.copyWith(
      phase: hasData ? DailyFortunePhase.ready : DailyFortunePhase.loading,
      isReadingLoading: personalized,
      clearError: true,
      clearReadingError: true,
    );
    try {
      final repository = ref.read(dailyFortuneRepositoryProvider);
      final result = personalized
          ? await repository.getPersonalized(
              date: date,
              chartData: chartData,
              cancelToken: token,
            )
          : await repository.getCalendar(date: date, cancelToken: token);
      if (token.isCancelled || session != _session) return;
      _putCache(cache, key, result);
      if (personalized) {
        _putCache(_calendarCache, _dateKey(date), result.calendarOnly);
      }
      state = state.copyWith(
        phase: DailyFortunePhase.ready,
        fortune: result,
        isReadingLoading: false,
        clearError: true,
        clearReadingError: true,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || session != _session) return;
      await _handleFailure(
        session,
        date,
        personalized,
        error.message ?? 'Không thể tải dữ liệu vận hạn.',
        token,
      );
    } on DailyFortuneException catch (error) {
      if (session != _session) return;
      await _handleFailure(session, date, personalized, error.message, token);
    } finally {
      if (identical(_fortuneToken, token)) _fortuneToken = null;
    }
  }

  Future<void> loadCharts() async {
    if (ref.read(authControllerProvider).asData?.value?.user == null) return;
    _chartToken?.cancel('Tải danh sách lá số mới');
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
      if (charts.isNotEmpty && state.selectedChart == null) {
        await selectChart(charts.first);
      }
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
        _hasUsableChartData(state.selectedChartData)) {
      return;
    }
    final initialData = _chartPayload(chart, chart.chartData);
    // Dữ liệu từ API danh sách thường chỉ là bản tóm tắt. Chỉ dùng ngay khi
    // object đã có 12 cung; nếu không, tải endpoint chi tiết trước khi xem hạn.
    final hasInitialData = _hasPalaceData(initialData);
    _fortuneToken?.cancel('Đổi lá số');
    state = state.copyWith(
      selectedChart: chart,
      selectedChartData: initialData,
      isChartsLoading: !hasInitialData,
      fortune: _calendarCache[_dateKey(state.selectedDate)],
      clearReadingError: true,
    );
    if (hasInitialData) {
      await load();
      return;
    }
    _chartToken?.cancel('Tải chi tiết lá số');
    final token = CancelToken();
    _chartToken = token;
    try {
      final detail = await ref
          .read(chartRepositoryProvider)
          .getChartDetail(chart, cancelToken: token);
      if (token.isCancelled || state.selectedChart?.id != chart.id) return;
      final detailData = _chartPayload(detail.summary, detail.chartData);
      if (!_hasUsableChartData(detailData)) {
        state = state.copyWith(
          isChartsLoading: false,
          readingErrorMessage:
              'Lá số chưa có đủ ngày, giờ sinh, giới tính hoặc dữ liệu 12 cung.',
        );
        return;
      }
      state = state.copyWith(
        selectedChart: detail.summary,
        selectedChartData: detailData,
        isChartsLoading: false,
      );
      await load();
    } on ChartException catch (error) {
      if (token.isCancelled) return;
      state = state.copyWith(
        isChartsLoading: false,
        readingErrorMessage: error.message,
      );
    }
  }

  Future<void> _handleFailure(
    int session,
    DateTime date,
    bool personalized,
    String message,
    CancelToken cancelToken,
  ) async {
    if (personalized) {
      try {
        final fallback =
            _calendarCache[_dateKey(date)] ??
            await ref
                .read(dailyFortuneRepositoryProvider)
                .getCalendar(date: date, cancelToken: cancelToken);
        if (cancelToken.isCancelled || session != _session) return;
        _putCache(_calendarCache, _dateKey(date), fallback);
        state = state.copyWith(
          phase: DailyFortunePhase.ready,
          fortune: fallback,
          isReadingLoading: false,
          readingErrorMessage: message,
        );
        return;
      } catch (_) {}
    }
    state = state.copyWith(
      phase: DailyFortunePhase.failure,
      isReadingLoading: false,
      errorMessage: message,
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  static Map<String, dynamic> _chartPayload(
    SavedChart chart,
    Map<String, dynamic> raw,
  ) {
    final result = <String, dynamic>{...raw};
    void put(String key, Object? value) {
      if (result[key] != null && result[key].toString().trim().isNotEmpty) {
        return;
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        result[key] = value;
      }
    }

    put('fullName', chart.displayName);
    put('gender', chart.gender);
    put('gioiTinh', chart.gender);
    put('gio', chart.hourBranch?.replaceFirst(RegExp(r'^Giờ\s+'), ''));
    put('menh', chart.menh);

    final dateParts = RegExp(
      r'\d+',
    ).allMatches(chart.solarDate).map((match) => match.group(0)!).toList();
    if (dateParts.length >= 3) {
      final first = int.tryParse(dateParts[0]);
      final second = int.tryParse(dateParts[1]);
      final third = int.tryParse(dateParts[2]);
      if (first != null && second != null && third != null) {
        if (dateParts[0].length == 4) {
          result['solarDate'] =
              '${first.toString().padLeft(4, '0')}-${second.toString().padLeft(2, '0')}-${third.toString().padLeft(2, '0')}';
          put('nam', first);
          put('thang', second);
          put('ngay', third);
        } else {
          result['solarDate'] =
              '${third.toString().padLeft(4, '0')}-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}';
          put('ngay', first);
          put('thang', second);
          put('nam', third);
        }
      }
    }
    return Map.unmodifiable(result);
  }

  static bool _hasUsableChartData(Map<String, dynamic> data) {
    if (_hasPalaceData(data)) return true;
    bool has(String key) =>
        data[key] != null && data[key].toString().trim().isNotEmpty;
    final vietnameseBirth =
        has('ngay') &&
        has('thang') &&
        has('nam') &&
        has('gio') &&
        has('gioiTinh');
    final solarBirth =
        has('solarDate') &&
        (has('solarTime') || has('gio')) &&
        (has('gender') || has('gioiTinh'));
    return vietnameseBirth || solarBirth;
  }

  static bool _hasPalaceData(Map<String, dynamic> data) {
    final palaces = data['palaces'] ?? data['cung'] ?? data['twelvePalaces'];
    return palaces is Map && palaces.isNotEmpty;
  }

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
