import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chart_repository.dart';
import '../state/my_charts_state.dart';

class MyChartsController extends Notifier<MyChartsState> {
  CancelToken? _loadCancelToken;

  @override
  MyChartsState build() {
    ref.onDispose(() => _loadCancelToken?.cancel());
    Future.microtask(load);
    return const MyChartsState(isLoading: true);
  }

  Future<void> load() async {
    _loadCancelToken?.cancel('A newer charts request was started.');
    final cancelToken = CancelToken();
    _loadCancelToken = cancelToken;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final charts = await ref
          .read(chartRepositoryProvider)
          .getMyCharts(cancelToken: cancelToken);
      if (cancelToken.isCancelled) return;
      state = MyChartsState(charts: List.unmodifiable(charts));
    } on ChartException catch (error) {
      if (cancelToken.isCancelled) return;
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } finally {
      if (identical(_loadCancelToken, cancelToken)) {
        _loadCancelToken = null;
      }
    }
  }

  Future<bool> delete(String id) async {
    if (state.deletingId != null) return false;
    state = state.copyWith(deletingId: id, clearError: true);
    try {
      await ref.read(chartRepositoryProvider).deleteChart(id);
      state = state.copyWith(
        charts: List.unmodifiable(
          state.charts.where((chart) => chart.id != id),
        ),
        clearDeletingId: true,
      );
      return true;
    } on ChartException catch (error) {
      state = state.copyWith(
        clearDeletingId: true,
        errorMessage: error.message,
      );
      return false;
    }
  }
}
