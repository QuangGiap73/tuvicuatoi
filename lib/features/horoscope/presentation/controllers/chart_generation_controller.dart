import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chart_repository.dart';
import '../../domain/chart_request.dart';
import '../state/chart_generation_state.dart';

class ChartGenerationController extends Notifier<ChartGenerationState> {
  @override
  ChartGenerationState build() => const ChartGenerationState();

  Future<bool> generate(ChartRequest request) async {
    if (state.isGenerating) return false;
    state = ChartGenerationState(
      status: ChartGenerationStatus.generating,
      request: request,
    );
    try {
      final result = await ref.read(chartRepositoryProvider).generate(request);
      state = ChartGenerationState(
        status: ChartGenerationStatus.ready,
        request: request,
        result: result,
      );
      return true;
    } on ChartException catch (error) {
      state = ChartGenerationState(
        status: ChartGenerationStatus.error,
        request: request,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = ChartGenerationState(
        status: ChartGenerationStatus.error,
        request: request,
        errorMessage: 'Không thể lập lá số. Vui lòng thử lại.',
      );
      return false;
    }
  }

  Future<bool> save() async {
    final request = state.request;
    final result = state.result;
    if (request == null || result == null || state.isSaving || state.isSaved) {
      return false;
    }
    state = ChartGenerationState(
      status: ChartGenerationStatus.saving,
      request: request,
      result: result,
    );
    try {
      final id = await ref.read(chartRepositoryProvider).save(request, result);
      state = ChartGenerationState(
        status: ChartGenerationStatus.saved,
        request: request,
        result: result,
        savedChartId: id,
      );
      return true;
    } on ChartException catch (error) {
      state = ChartGenerationState(
        status: ChartGenerationStatus.ready,
        request: request,
        result: result,
        errorMessage: error.message,
      );
      return false;
    }
  }

  void clear() => state = const ChartGenerationState();
}
