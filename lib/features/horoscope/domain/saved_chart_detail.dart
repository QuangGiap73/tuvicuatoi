import 'saved_chart.dart';

class SavedChartDetail {
  const SavedChartDetail({required this.summary, required this.chartData});

  final SavedChart summary;
  final Map<String, dynamic> chartData;

  factory SavedChartDetail.fromResponse(
    SavedChart fallback,
    Map<String, dynamic> response,
  ) {
    final data = _map(response['data']);
    final root =
        _map(response['chart']) ?? _map(data?['chart']) ?? data ?? response;
    final raw =
        _map(root['chartData']) ??
        _map(root['chart_data']) ??
        _map(data?['chartData']) ??
        _map(data?['chart_data']) ??
        _map(response['chartData']) ??
        _map(response['chart_data']) ??
        root;
    final parsed = SavedChart.fromJson({
      ...raw,
      ...root,
      'id': root['id'] ?? fallback.id,
    });
    return SavedChartDetail(
      // Endpoint chi tiết có thể không lặp lại các trường tóm tắt. Luôn giữ
      // dữ liệu hợp lệ từ danh sách thay vì để giá trị rỗng ghi đè lên card.
      summary: SavedChart(
        id: _required(parsed.id, fallback.id),
        name: parsed.name == 'Lá số Tử Vi'
            ? fallback.name
            : _required(parsed.name, fallback.name),
        gender: _required(parsed.gender, fallback.gender),
        solarDate: _required(parsed.solarDate, fallback.solarDate),
        lunarDate: _required(parsed.lunarDate, fallback.lunarDate),
        createdAt: _required(parsed.createdAt, fallback.createdAt),
        hourBranch: _optional(parsed.hourBranch, fallback.hourBranch),
        menh: _optional(parsed.menh, fallback.menh),
        cuc: _optional(parsed.cuc, fallback.cuc),
      ),
      chartData: Map.unmodifiable(raw),
    );
  }

  static String _required(String value, String fallback) =>
      value.trim().isEmpty ? fallback : value;

  static String? _optional(String? value, String? fallback) =>
      value == null || value.trim().isEmpty ? fallback : value;

  static Map<String, dynamic>? _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
}
