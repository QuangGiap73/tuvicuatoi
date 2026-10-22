import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chart_repository.dart';
import '../state/my_charts_state.dart';

class MyChartsController extends Notifier<MyChartsState> {
  @override
  MyChartsState build() {
    Future.microtask(load);
    return const MyChartsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final charts = await ref.read(chartRepositoryProvider).getMyCharts();
      state = MyChartsState(charts: charts);
    } on ChartException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<bool> delete(String id) async {
    if (state.deletingId != null) return false;
    state = state.copyWith(deletingId: id, clearError: true);
    try {
      await ref.read(chartRepositoryProvider).deleteChart(id);
      state = state.copyWith(
        charts: state.charts.where((chart) => chart.id != id).toList(),
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
