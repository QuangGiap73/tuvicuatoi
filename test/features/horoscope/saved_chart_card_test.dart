import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/horoscope/domain/saved_chart.dart';
import 'package:tuvicuatoi/features/horoscope/presentation/widgets/saved_chart_card.dart';

void main() {
  const chart = SavedChart(
    id: 'chart-id',
    name: 'Lá Số Nguyễn Văn Giáp 1995',
    gender: 'Nam',
    solarDate: '15/08/1995',
    lunarDate: '20/07/1995 (Ất Hợi)',
    createdAt: '21/10/2026 14:54',
    hourBranch: 'Giờ Thìn',
    menh: 'Sơn Đầu Hỏa',
  );

  for (final width in [288.0, 320.0, 398.0]) {
    testWidgets('saved chart card fits ${width.toInt()}dp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: SavedChartCard(
                  chart: chart,
                  isDeleting: false,
                  onInterpret: () {},
                  onAskAi: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
