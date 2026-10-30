import 'package:flutter/foundation.dart';

import '../../domain/interpretation_models.dart';

@immutable
class InterpretationContentState {
  const InterpretationContentState({
    this.context,
    this.mode = InterpretationMode.deep,
    this.interpretation,
    this.contentRevision = 0,
    this.isLoadingChart = false,
    this.isLoadingContent = false,
    this.isSavingChart = false,
    this.chartError,
    this.contentError,
  });

  final InterpretationChartContext? context;
  final InterpretationMode mode;
  final InterpretationData? interpretation;
  final int contentRevision;
  final bool isLoadingChart;
  final bool isLoadingContent;
  final bool isSavingChart;
  final String? chartError;
  final String? contentError;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterpretationContentState &&
          identical(context, other.context) &&
          mode == other.mode &&
          identical(interpretation, other.interpretation) &&
          contentRevision == other.contentRevision &&
          isLoadingChart == other.isLoadingChart &&
          isLoadingContent == other.isLoadingContent &&
          isSavingChart == other.isSavingChart &&
          chartError == other.chartError &&
          contentError == other.contentError;

  @override
  int get hashCode => Object.hash(
    identityHashCode(context),
    mode,
    identityHashCode(interpretation),
    contentRevision,
    isLoadingChart,
    isLoadingContent,
    isSavingChart,
    chartError,
    contentError,
  );
}
