class ChartSessionService {
  const ChartSessionService();

  Map<String, dynamic> mergeChartData(
    Map<String, dynamic> cached,
    Map<String, dynamic> refreshed,
  ) {
    if (cached.isEmpty) return refreshed;
    if (refreshed.isEmpty) return cached;
    final result = <String, dynamic>{...cached, ...refreshed};
    for (final key in const ['palaces', 'generalReading', 'general_reading']) {
      final cachedValue = cached[key];
      final refreshedValue = refreshed[key];
      if (cachedValue is Map && refreshedValue is Map) {
        result[key] = <String, dynamic>{
          ...Map<String, dynamic>.from(cachedValue),
          ...Map<String, dynamic>.from(refreshedValue),
        };
      } else if (_isEmptyCollection(refreshedValue) && cachedValue != null) {
        result[key] = cachedValue;
      }
    }
    return Map.unmodifiable(result);
  }

  static bool _isEmptyCollection(Object? value) =>
      value == null ||
      (value is Map && value.isEmpty) ||
      (value is List && value.isEmpty);
}
