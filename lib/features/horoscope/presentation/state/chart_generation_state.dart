import '../../domain/chart_request.dart';
import '../../domain/chart_result.dart';

enum ChartGenerationStatus { idle, generating, ready, saving, saved, error }

class ChartGenerationState {
  const ChartGenerationState({
    this.status = ChartGenerationStatus.idle,
    this.request,
    this.result,
    this.savedChartId,
    this.errorMessage,
  });

  final ChartGenerationStatus status;
  final ChartRequest? request;
  final ChartResult? result;
  final String? savedChartId;
  final String? errorMessage;

  bool get isGenerating => status == ChartGenerationStatus.generating;
  bool get isSaving => status == ChartGenerationStatus.saving;
  bool get isSaved => status == ChartGenerationStatus.saved;
}
