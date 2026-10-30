import 'package:dio/dio.dart';

import '../data/interpretation_repository.dart';
import '../domain/interpretation_models.dart';

class InterpretationContentService {
  const InterpretationContentService(this._repository);

  final InterpretationRepository _repository;

  Future<InterpretationData> generateIfPossible({
    required InterpretationChartContext context,
    required InterpretationMode mode,
    required CancelToken cancelToken,
  }) {
    if (context.chartData.isEmpty) {
      return Future.value(const InterpretationData());
    }
    return _repository.generate(
      chartData: context.chartData,
      mode: mode,
      cancelToken: cancelToken,
    );
  }

  Future<InterpretationData> loadSavedOrEmpty({
    required InterpretationChartContext context,
    required CancelToken cancelToken,
  }) async {
    if (!context.isSaved) return const InterpretationData();
    try {
      return await _repository.getSavedInterpretation(
        chartId: context.chartId!,
        cancelToken: cancelToken,
      );
    } catch (_) {
      return const InterpretationData();
    }
  }
}
