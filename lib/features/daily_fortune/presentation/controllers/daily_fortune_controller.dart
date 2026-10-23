import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_fortune_repository.dart';
import '../../domain/daily_fortune.dart';
import '../state/daily_fortune_state.dart';

class DailyFortuneController extends Notifier<DailyFortuneState> {
  CancelToken? _cancelToken;
  int _requestId = 0;

  @override
  DailyFortuneState build() {
    ref.onDispose(() => _cancelToken?.cancel());
    final now = DateTime.now();
    final initial = DailyFortuneState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
    Future.microtask(load);
    return initial;
  }

  void selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized == state.selectedDate) return;
    state = state.copyWith(
      selectedDate: normalized,
      phase: DailyFortunePhase.idle,
      clearFortune: true,
      clearError: true,
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
    _cancelToken?.cancel('Ngày xem đã thay đổi');
    final token = CancelToken();
    _cancelToken = token;
    setLoading();
    try {
      final result = await ref
          .read(dailyFortuneRepositoryProvider)
          .getForDate(date: state.selectedDate, cancelToken: token);
      if (token.isCancelled || requestId != _requestId) return;
      setFortune(result);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      if (requestId != _requestId) return;
      setError('Không thể tải lịch Can Chi. Chạm để thử lại.');
    } on DailyFortuneException catch (error) {
      if (requestId != _requestId) return;
      setError(error.message);
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
    }
  }

  void setLoading() {
    state = state.copyWith(phase: DailyFortunePhase.loading, clearError: true);
  }

  void setFortune(DailyFortune fortune) {
    state = state.copyWith(
      phase: DailyFortunePhase.ready,
      fortune: fortune,
      clearError: true,
    );
  }

  void setEmpty() {
    state = state.copyWith(
      phase: DailyFortunePhase.empty,
      clearFortune: true,
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      phase: DailyFortunePhase.failure,
      errorMessage: message,
    );
  }
}

final dailyFortuneControllerProvider =
    NotifierProvider.autoDispose<DailyFortuneController, DailyFortuneState>(
      DailyFortuneController.new,
    );
