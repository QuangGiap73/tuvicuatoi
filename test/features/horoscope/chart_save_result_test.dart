import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/horoscope/domain/chart_save_result.dart';

void main() {
  test('maps paid chart save receipt from top-level response', () {
    final result = ChartSaveResult.fromJson({
      'success': true,
      'chartId': 'chart-3',
      'coinsSpent': 100,
      'coinBalance': 900,
      'savedChartsCount': 3,
      'maxSavedCharts': 2,
    });

    expect(result.chartId, 'chart-3');
    expect(result.usedCoins, isTrue);
    expect(result.coinsSpent, 100);
    expect(result.coinBalance, 900);
    expect(result.savedChartsCount, 3);
    expect(result.maxSavedCharts, 2);
  });

  test('maps aliases and nested save metadata defensively', () {
    final result = ChartSaveResult.fromJson({
      'success': true,
      'id': 'chart-1',
      'data': {
        'coin_balance': '1200',
        'coinsDeducted': 0,
        'saved_charts_count': 1,
        'max_saved_charts': 2,
      },
    });

    expect(result.chartId, 'chart-1');
    expect(result.usedCoins, isFalse);
    expect(result.coinBalance, 1200);
    expect(result.savedChartsCount, 1);
    expect(result.maxSavedCharts, 2);
  });
}
