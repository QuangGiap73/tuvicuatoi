import '../../domain/saved_chart.dart';

class MyChartsState {
  const MyChartsState({
    this.isLoading = false,
    this.deletingId,
    this.charts = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final String? deletingId;
  final List<SavedChart> charts;
  final String? errorMessage;

  MyChartsState copyWith({
    bool? isLoading,
    String? deletingId,
    bool clearDeletingId = false,
    List<SavedChart>? charts,
    String? errorMessage,
    bool clearError = false,
  }) => MyChartsState(
    isLoading: isLoading ?? this.isLoading,
    deletingId: clearDeletingId ? null : deletingId ?? this.deletingId,
    charts: charts ?? this.charts,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
