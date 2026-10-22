class SavedChart {
  const SavedChart({
    required this.id,
    required this.name,
    required this.gender,
    required this.solarDate,
    required this.lunarDate,
    required this.createdAt,
    this.hourBranch,
    this.menh,
  });

  final String id;
  final String name;
  final String gender;
  final String solarDate;
  final String lunarDate;
  final String createdAt;
  final String? hourBranch;
  final String? menh;

  String get displayName {
    final value = name
        .replaceFirst(RegExp(r'^Lá\s*Số\s*', caseSensitive: false), '')
        .trim();
    return value.isEmpty ? 'Lá số Tử Vi' : value;
  }

  String get element {
    final value = menh?.toLowerCase() ?? '';
    if (value.contains('kim')) return 'KIM';
    if (value.contains('mộc')) return 'MỘC';
    if (value.contains('thủy')) return 'THỦY';
    if (value.contains('hỏa')) return 'HỎA';
    if (value.contains('thổ')) return 'THỔ';
    return '';
  }

  factory SavedChart.fromJson(Map<String, dynamic> json) {
    final nested = _nestedData(json);
    String? optional(Object? value) {
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    }

    return SavedChart(
      id: (json['id'] ?? json['chartId'] ?? '').toString(),
      name: (json['name'] ?? nested['fullName'] ?? 'Lá số Tử Vi').toString(),
      gender: (json['gender'] ?? nested['gender'] ?? '').toString(),
      solarDate: (json['solarDate'] ?? nested['solarDate'] ?? '').toString(),
      lunarDate: (json['lunarDate'] ?? nested['lunarDate'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      hourBranch: optional(json['hourBranch'] ?? nested['hourBranch']),
      menh: optional(json['menh'] ?? nested['menh']),
    );
  }

  static Map<String, dynamic> _nestedData(Map<String, dynamic> json) {
    final value = json['chartData'] ?? json['chart_data'] ?? json['data'];
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }
}
