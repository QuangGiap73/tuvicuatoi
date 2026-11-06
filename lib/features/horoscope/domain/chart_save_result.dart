class ChartSaveResult {
  const ChartSaveResult({
    required this.chartId,
    this.coinBalance,
    this.coinsSpent,
    this.savedChartsCount,
    this.maxSavedCharts,
    this.message,
  });

  final String chartId;
  final int? coinBalance;
  final int? coinsSpent;
  final int? savedChartsCount;
  final int? maxSavedCharts;
  final String? message;

  bool get usedCoins => (coinsSpent ?? 0) > 0;

  factory ChartSaveResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : const <String, dynamic>{};
    int? integer(List<String> keys) {
      for (final key in keys) {
        final value = json[key] ?? data[key];
        if (value is num) return value.toInt();
        final parsed = int.tryParse(value?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return null;
    }

    return ChartSaveResult(
      chartId:
          (json['chartId'] ?? json['id'] ?? data['chartId'] ?? data['id'] ?? '')
              .toString(),
      coinBalance: integer(const ['coinBalance', 'coin_balance', 'balance']),
      coinsSpent: integer(const [
        'coinsSpent',
        'coins_spent',
        'coinsDeducted',
        'coinCost',
      ]),
      savedChartsCount: integer(const [
        'savedChartsCount',
        'saved_charts_count',
      ]),
      maxSavedCharts: integer(const ['maxSavedCharts', 'max_saved_charts']),
      message: (json['message'] ?? data['message'])?.toString(),
    );
  }
}
