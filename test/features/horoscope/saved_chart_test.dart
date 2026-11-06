import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/horoscope/domain/saved_chart.dart';

void main() {
  test('summary parsing can discard the heavy chart payload', () {
    final chart = SavedChart.fromJson({
      'id': 12,
      'name': 'Lá Số Giáp',
      'chart_data': {
        'solarDate': '15/08/1995',
        'gender': 'Nam',
        'menh': 'Kiếm Phong Kim',
        'palaces': List.generate(12, (index) => {'index': index}),
      },
    }, retainChartData: false);

    expect(chart.id, '12');
    expect(chart.solarDate, '15/08/1995');
    expect(chart.gender, 'Nam');
    expect(chart.menh, 'Kiếm Phong Kim');
    expect(chart.chartData, isEmpty);
  });

  test('detail parsing retains chart payload by default', () {
    final chart = SavedChart.fromJson({
      'id': '12',
      'chart_data': {
        'solarDate': '15/08/1995',
        'palaces': List.generate(12, (index) => {'index': index}),
      },
    });

    expect(chart.chartData['palaces'], isA<List<dynamic>>());
    expect((chart.chartData['palaces'] as List<dynamic>), hasLength(12));
  });
}
